연구 계획서 개요

HPV 예방접종의 자궁경부 상피내 병변 재발 예방 효과 연구

1. 연구 목적

자궁경부 상피내 병변(ASCUS/LSIL)으로 진단받고 수술적 치료를 시행한 환자에서, 수술 후 HPV 예방접종 여부가 병변 재발 및 새로운 HPV 감염에 미치는 영향을 평가

2. 연구 설계

Retrospective matched cohort study

3. 연구 대상

3.1 초기 추출 기준

* ASCUS/LSIL 진단 환자

3.2 최종 선정 기준

* ASCUS/LSIL 진단 후 HSIL/CIN3 또는 자궁경부암으로 진행
* 수술적 치료 시행 (원추절제술 또는 자궁절제술 : 현재 추출되어 있는 모든 코드) 
    → 수술 구분 시 dropbox내 구분파일 참조 
* 수술 후 충분한 추적관찰 기간 확보

3.3 제외 기준

* Index date 이전 재발 발생
* Index date 시점 사망 또는 자격 상실
* 2020년 이후 백신 접종 완료 (접종 효과 확인을 위해 5년 추적 필요)


4. 연구군 정의 및 Index Date

4.1 접종군

* 정의: 수술 후 HPV 예방접종 시행
* Index date: 백신 접종일

4.2 비접종군

* 정의: 수술 후 HPV 예방접종 미시행
* Index date: 접종군의 "수술-접종 간격(T)"을 비접종군 수술일에 적용하여 부여


4.3 Index Date 부여 절차

Step 1: 접종군 간격(T) 계산
각 접종군 환자의 "수술일 → 접종일" 간격 산출

접종군 환자
	수술일
	접종일
	간격(T)

A
	2018-01-01
	2018-07-01
	6개월

B
	2017-05-01
	2018-05-01
	12개월

C
	2019-03-01
	2019-06-01
	3개월


Step 2: 비접종군 Pseudo Index Date 부여
비접종군 수술일 + 매칭된 접종군의 간격(T) = Index date

접종군
	간격(T)
	비접종군
	수술일
	Index date (부여)

A
	6개월
	D
	2018-02-01
	2018-08-01

B
	12개월
	E
	2017-06-01
	2018-06-01

C
	3개월
	F
	2019-04-01
	2019-07-01


Step 3: 비접종군 적격성 확인
부여된 index date 시점에서 아래 조건 충족 필요:

* Index date 이전 재발 미발생
* Index date 시점 사망/자격상실 없음
* Index date 이후 추적 가능 상태

→ 조건 미충족 시 해당 매칭 제외

Step 4: 추가 변수로 Fine Matching 진행

5. 매칭 방법

5.1 Index Date 부여 (Section 4.3 참조)

* 접종군의 "수술-접종 간격(T)"을 비접종군에 그대로 적용하여 pseudo index date 부여
* 이는 매칭 변수가 아닌 index date 설정 방법론임

5.2 매칭 변수

변수
	매칭 기준

수술 시점 (calendar year)
	± 1년 이내

연령
	± 5세 이내

수술 방법
	Exact matching (원추절제술/자궁절제술)


5.2 매칭 비율

* 1:1 매칭 (primary)
* Sample size 부족 시 1:4 매칭 고려

5.3 추가 보정 (Propensity Score)

* PSM 또는 IPTW 적용 고려
* PS 산출 변수: 연령, BMI, 수술 방법, 진단 중증도, 수술 연도


6. 추적 관찰

6.1 추적 시작

* Index date

6.2 추적 종료

* Outcome 발생일
* 사망일
* 자격 상실일
* 연구 종료일 (2025-12-31)
* 위 중 가장 빠른 날짜


7. 결과 변수

7.1 주요 결과변수 (Primary Outcomes)

1) 병변 재발

* 정의: 조직검사로 확인된 HSIL/CIN3 이상 병변 재발
* 측정: Index date 이후 첫 재발까지의 시간

2) 새로운 고위험 HPV 감염

* 정의: Index date 이후 HPV 양성 전환
* 고위험 HPV 유형: 16, 18, 31, 33, 45, 52, 58, 35, 39, 51, 56, 59, 66, 68

7.2 이차 결과변수 (Secondary Outcomes)

3) 당뇨 발생

* 정의: HbA1c ≥ 6.5% (1회 이상)
* Index date 이전 당뇨 진단자 제외

4) 고혈압 발생

* 정의: SBP ≥ 140 또는 DBP ≥ 90 (2회 이상)
* Index date 이전 고혈압 진단자 제외


8. 통계 분석

8.1 기술 통계

* 접종군 vs 비접종군 baseline characteristics 비교
* 연속형: t-test 또는 Wilcoxon rank-sum test
* 범주형: Chi-square test 또는 Fisher's exact test
* Standardized mean difference (SMD) 제시

8.2 주요 분석

분석 방법
	적용

Kaplan-Meier curve
	재발까지의 시간 시각화

Log-rank test
	군간 생존 곡선 비교

Cox proportional hazard model
	HR (95% CI) 산출, 보정 분석


8.3 하위군 분석

* 수술 방법별 (원추절제술 vs 자궁절제술)
* 백신 종류별

8.4 민감도 분석

* 추적 기간 제한 (3년, 5년)
* As-treated analysis


10. 연구 일정

단계
	일정

데이터 추출 및 정제
	협의 중

통계 분석
	TBD

초록 작성
	TBD

2026 부인종양학회 포스터 발표
	2026



11. 추가 확인 필요 사항

* [ ] 수술 코드 구분 (원추절제술/자궁절제술) - 코드 확인 후 재전달 예정
* [ ] HPV 지속감염 정의 - 허수영 교수님과 협의 후 확정
* [ ] CAD 관련 진단 추가 (IRB 연장 심의 후)

