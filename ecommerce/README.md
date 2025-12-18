### eCommerce 로그 데이터 DW 구축

데이터 :eCommerce 로그데이터 (oct,5.67GB,csv)


### 1. 데이터 확인 및 적재

- Spark를 사용해 원본 CSV 데이터의 스키마 및 결측치 확인

- 원본 CSV 데이터를 Parquet 포맷으로 변환

- 원본 CSV와 Parquet 데이터를 폴더 단위로 분리하여 순서대로 적재

- GCS 업로드 후 BigQuery 적재 


### 2. DW/DM 설계 (BigQuery)

- Preprocessing (BigQuery SQL)

no_brand, no_code 등으로 결측치 처리

타임존 KST 변환

day, dow, isoweek 등 시간 파생 컬럼 생성

- Fact 테이블

event_date 기준 Partitioning

category_id, brand 기준 Clustering

- Dimension 테이블

dim_category, dim_session 등

카테고리 분류 및 파생 컬럼 생성


### 3.DW 활용

설계된 DW를 기반으로 퍼널 분석 및 코호트 리텐션 분석 수행