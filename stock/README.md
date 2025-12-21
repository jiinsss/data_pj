###  주식 데이터 배치 파이프라인 (Airflow)


- 외부 API(yfinance)에서 일별 주식 데이터를 수집

- Airflow로 배치 스케줄링하여 BigQuery에 증분 적재

- Docker Compose로 Airflow(LocalExecutor + Postgres) 환경 구성


#### 파이프라인

yfinance API

 → Airflow (PythonOperator)

 → BigQuery stock_staging (WRITE_TRUNCATE)

 → BigQuery stock_raw (MERGE)


#### 스케줄링

0 23 * * *

catchup=True

max_active_runs=1



+ logical_date.date() 기준으로 하루 데이터를 수집

+ 거래일인데 데이터가 없으면 DAG를 실패시키고 알림을 보냄, 휴장일은 skip 처리

+ BigQuery 적재 시 문제가 될 수 있는 타입(list, tuple 등)을 사전 검증

+ BigQuery 테이블은 DAG 실행 전에 SQL로 스키마를 선언하고 사전 생성
