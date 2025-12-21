from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from airflow.models import Variable
from airflow.exceptions import AirflowSkipException

from datetime import datetime, timedelta
import yfinance as yf
import pandas as pd
from google.cloud import bigquery

import pandas_market_calendars as mcal
import requests
from pendulum import timezone
NY = timezone("America/New_York")

SYMBOL = "AAPL"


def send_slack_alert(message: str):
    url = Variable.get("SLACK_WEBHOOK_URL")
    requests.post(url, json={"text": message}, timeout=10)


def validate_dataframe(df):
    for col in df.columns:
        series = df[col].dropna()
        if series.empty:
            continue
        for v in series.head(10):
            if isinstance(v, (list, dict, tuple)):
                raise ValueError(f"Invalid value in column {col}")


def get_stock_to_staging(**context):
    project_id = Variable.get("BQ_PROJECT")
    dataset_id = Variable.get("BQ_DATASET")

    staging_table = f"{project_id}.{dataset_id}.stock_staging"

    trade_date = (
        context["logical_date"]
        .date()
        )

    start = trade_date.isoformat()
    end = (trade_date + timedelta(days=1)).isoformat()


    df = yf.download(
        SYMBOL,
        start=start,
        end=end,
        auto_adjust=False
    )

    if df.empty:
        nyse = mcal.get_calendar("NYSE")
        is_trading_day = not nyse.valid_days(trade_date, trade_date).empty

        if is_trading_day:
            send_slack_alert(
                f"Stock Pipeline Warning\n"
                f"Symbol: {SYMBOL}\n"
                f"Date: {trade_date}\n"
                f"Reason: No data returned on trading day"
            )
            raise AirflowSkipException(
                f"No data returned on trading day: {trade_date}"
            )
        else:
            raise AirflowSkipException(
                f"Market closed on {trade_date}"
            )


    if isinstance(df.columns, pd.MultiIndex):
        df.columns = df.columns.get_level_values(0)

    df = (
        df.reset_index()
          .rename(columns={
              "Date": "date",
              "Open": "open",
              "High": "high",
              "Low": "low",
              "Close": "close",
              "Volume": "volume",
          })
    )

    df["date"] = pd.to_datetime(df["date"]).dt.date
    df["symbol"] = SYMBOL
    df = df[["symbol", "date", "open", "high", "low", "close", "volume"]]

    validate_dataframe(df)

    hook = BigQueryHook(gcp_conn_id="google_cloud_default")
    client = hook.get_client(project_id=project_id)

    job = client.load_table_from_dataframe(
        df,
        staging_table,
        job_config=bigquery.LoadJobConfig(
            write_disposition="WRITE_TRUNCATE"
        )
    )
    job.result()


MERGE_SQL = """
MERGE `{{ var.value.BQ_PROJECT }}.{{ var.value.BQ_DATASET }}.stock_raw` T
USING `{{ var.value.BQ_PROJECT }}.{{ var.value.BQ_DATASET }}.stock_staging` S
ON T.symbol = S.symbol AND T.date = S.date
WHEN NOT MATCHED THEN
  INSERT (symbol, date, open, high, low, close, volume)
  VALUES (S.symbol, S.date, S.open, S.high, S.low, S.close, S.volume)
"""


default_args = {
    "owner": "jiin",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="api_to_bigquery_stock_pipeline",
    start_date=datetime(2025, 1, 1,tzinfo=NY),
    schedule="0 23 * * *",
    catchup=True,
    max_active_runs=1,
    default_args=default_args,
    tags=["api", "bigquery"],
) as dag:

    get_api = PythonOperator(
        task_id="get_stock_api",
        python_callable=get_stock_to_staging,
    )

    merge_to_raw = BigQueryInsertJobOperator(
        task_id="merge_to_raw",
        configuration={
            "query": {
                "query": MERGE_SQL,
                "useLegacySql": False,
            }
        },
    )

    get_api >> merge_to_raw
