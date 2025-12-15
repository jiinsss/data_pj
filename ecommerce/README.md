### eCommerce 로그 기반 DW 구축 및 전환·리텐션 분석

데이터 : Kaggle eCommerce 로그(oct,5.67GB)


### 1. 데이터 확인 및 적재

Spark로 원본 CSV의 결측치와 스키마를 확인한 뒤 Parquet로 변환

원본 CSV와 변환된 Parquet 파일을 폴더를 나눠 순서대로 적재

GCS 업로드 → BigQuery 


### 2. DW/DM 설계 (BigQuery)

preprocessing : (no_brand, no_code 등 결측치 처리, kst 변환, day ,dow, isoweek 등 시간처리 ) 

fact: fact (event_date 파티셔닝, category_id, brand 클러스터링 )

dim_category, dim_session .. : dimension (카테고리 분류 및 파생칼럼 생성)

d_funnel: 분석용 테이블


### 3. 분석

퍼널 (세션, view → cart → purchase)

no_code(카테고리 누락)에서 cart 전 이탈률이 높음

0–10초 단기 초기 이탈 집중


코호트

첫 방문일 기준 D1, D7, D30 리텐션 계산

D1 이후 급격한 유지율 하락 확인


-> 데이터 누락(no_code)로 인해 전환 저하 발생, 초기 화면/로딩 단계에서 대량 이탈

퍼널–세그먼트–코호트 모두 초기 사용자 경험이 가장 큰 병목으로 나타남