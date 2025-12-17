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


project_id = Variable.get("BQ_PROJECT")
dataset_id = Variable.get("BQ_DATASET")

staging_table = f"{project_id}.{dataset_id}.stock_staging"
raw_table = f"{project_id}.{dataset_id}.stock_raw"

symbol = "AAPL"


def validate_dataframe(df):
    for col in df.columns:
        series = df[col].dropna()
        if series.empty:
            continue
        for v in series.head(10):
            if isinstance(v, (list, dict, tuple)):
                raise ValueError(f"Invalid value in column {col}")


def get_stock_to_staging(**context):
    execution_date = context["data_interval_start"].date()

    start = execution_date.isoformat()
    end = (execution_date + timedelta(days=1)).isoformat()

    df = yf.download(
        symbol,
        start=start,
        end=end,
        auto_adjust=False
    )

    if df.empty:
        raise AirflowSkipException(
            f"Market closed on {execution_date}"
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
    df["symbol"] = symbol
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


MERGE_SQL = f"""
MERGE `{raw_table}` T
USING `{staging_table}` S
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
    start_date=datetime(2025, 1, 1),
    schedule_interval="@daily",
    catchup=True,
    max_active_runs=1,
    default_args=default_args,
    tags=["api", "bigquery", "incremental"],
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
