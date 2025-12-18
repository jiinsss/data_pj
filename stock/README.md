###  주식 데이터 배치 파이프라인 (Airflow)


- 외부 API(yfinance)에서 일별 주식 데이터를 수집

- Airflow로 배치 스케줄링하여 BigQuery에 증분 적재


#### 파이프라인

yfinance API

 → Airflow (PythonOperator)

 → BigQuery stock_staging (WRITE_TRUNCATE)

 → BigQuery stock_raw (MERGE)


#### 스케줄링

@daily

catchup=True

max_active_runs=1



+ DAG 실행 날짜(data_interval_start) 기준으로 하루 단위 데이터 수집

+ 비거래일(API 응답 없음)은 skip 처리

+ BigQuery 적재 시 문제가 될 수 있는 타입(list, tuple 등)을 사전 검증

