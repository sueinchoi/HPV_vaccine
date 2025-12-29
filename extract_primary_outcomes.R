# ============================================================================
# HPV 예방접종의 자궁경부 상피내 병변 재발 예방 효과 연구
# Primary Outcomes 추출 코드
# ============================================================================
#
# 주요 결과변수 (Primary Outcomes):
# 1) 병변 재발: 조직검사로 확인된 HSIL/CIN3 이상 병변 재발
# 2) 새로운 고위험 HPV 감염: Index date 이후 HPV 양성 전환
#
# ============================================================================

# 필요한 패키지 로드
library(dplyr)
library(lubridate)
library(readr)
library(stringr)

# ============================================================================
# 1. 데이터 로드
# ============================================================================

# 파일 경로 설정
data_path <- "Data/"

# pathology_sample 데이터 로드
pathology <- read_csv(paste0(data_path, "pathology_sample.csv"))

# 진단검사(Lab) 데이터 로드 (HPV 검사 결과 포함)
lab_data <- read_csv(paste0(data_path, "한국 HPV 코호트 자료를 이용한 자_진단검사(Lab).csv"))

# 코호트 데이터 로드 (환자 기본정보, index date 등)
cohort <- read_csv(paste0(data_path, "한국 HPV 코호트 자료를 이용한 자_코호트.csv"))

# ============================================================================
# 2. 데이터 구조 확인 및 컬럼명 표준화
# ============================================================================

# 데이터 구조 확인
cat("=== Pathology 데이터 구조 ===\n")
glimpse(pathology)
cat("\n=== Lab 데이터 구조 ===\n")
glimpse(lab_data)
cat("\n=== Cohort 데이터 구조 ===\n")
glimpse(cohort)

# ============================================================================
# 3. Primary Outcome 1: 병변 재발 (HSIL/CIN3 이상)
# ============================================================================

#' 병변 재발 정의 함수
#' @description 조직검사 결과에서 HSIL/CIN3 이상 병변을 식별
#' @param diagnosis_text 진단명 또는 진단코드 텍스트
#' @return logical: TRUE if HSIL/CIN3 이상
#'
#' 참고: 실제 데이터의 진단코드/진단명 형식에 따라 수정 필요
identify_hsil_cin3_or_higher <- function(diagnosis_text) {
  if (is.na(diagnosis_text)) return(FALSE)

  diagnosis_upper <- toupper(diagnosis_text)

  # HSIL/CIN3 이상 병변 패턴
  # CIN3, HSIL, CIS (Carcinoma in situ), 자궁경부암
  hsil_patterns <- c(
    "HSIL",           # High-grade Squamous Intraepithelial Lesion
    "CIN3", "CIN 3", "CIN-3",  # Cervical Intraepithelial Neoplasia Grade 3
    "CIN III",
    "CIS",            # Carcinoma in situ
    "CARCINOMA",      # 암종
    "CANCER",
    "N87.2",          # ICD-10: CIN3, 중증 이형성
    "D06",            # ICD-10: 자궁경부 상피내암
    "C53"             # ICD-10: 자궁경부암
  )

  # 패턴 매칭
  any(sapply(hsil_patterns, function(p) grepl(p, diagnosis_upper, fixed = TRUE)))
}

#' 병변 재발 결과변수 생성
#' @param pathology_df pathology 데이터프레임
#' @param cohort_df cohort 데이터프레임 (index_date 포함)
#' @param patient_id_col 환자 ID 컬럼명
#' @param exam_date_col 검사일 컬럼명
#' @param diagnosis_col 진단 컬럼명
#' @param index_date_col index date 컬럼명
#' @return 환자별 병변 재발 정보 데이터프레임
create_recurrence_outcome <- function(pathology_df,
                                       cohort_df,
                                       patient_id_col = "환자ID",
                                       exam_date_col = "검사일자",
                                       diagnosis_col = "진단명",
                                       index_date_col = "index_date") {

  # 컬럼명 심볼로 변환
  patient_id_sym <- sym(patient_id_col)
  exam_date_sym <- sym(exam_date_col)
  diagnosis_sym <- sym(diagnosis_col)
  index_date_sym <- sym(index_date_col)

  # 1. HSIL/CIN3 이상 병변 식별
  pathology_hsil <- pathology_df %>%
    mutate(
      is_hsil_cin3_plus = sapply(!!diagnosis_sym, identify_hsil_cin3_or_higher)
    ) %>%
    filter(is_hsil_cin3_plus == TRUE)

  # 2. cohort와 병합하여 index date 이후 재발 확인
  recurrence <- cohort_df %>%
    select(!!patient_id_sym, !!index_date_sym) %>%
    left_join(pathology_hsil, by = patient_id_col) %>%
    mutate(
      # 날짜 형식 변환 (필요시)
      exam_date = as.Date(!!exam_date_sym),
      index_date = as.Date(!!index_date_sym),
      # Index date 이후 여부
      is_after_index = exam_date > index_date
    ) %>%
    filter(is_after_index == TRUE | is.na(is_after_index))

  # 3. 환자별 첫 재발 정보 추출
  recurrence_summary <- recurrence %>%
    group_by(!!patient_id_sym) %>%
    summarise(
      # 재발 여부
      recurrence_event = any(!is.na(exam_date) & is_after_index, na.rm = TRUE),
      # 첫 재발일 (재발이 있는 경우)
      first_recurrence_date = if(any(!is.na(exam_date) & is_after_index, na.rm = TRUE)) {
        min(exam_date[is_after_index], na.rm = TRUE)
      } else {
        NA_Date_
      },
      # Index date
      index_date = first(index_date),
      .groups = "drop"
    ) %>%
    mutate(
      # 재발까지의 시간 (일 단위)
      time_to_recurrence_days = as.numeric(first_recurrence_date - index_date),
      # 재발까지의 시간 (월 단위)
      time_to_recurrence_months = time_to_recurrence_days / 30.44,
      # 이벤트 지시자 (생존분석용)
      recurrence_event_numeric = as.numeric(recurrence_event)
    )

  return(recurrence_summary)
}

# ============================================================================
# 4. Primary Outcome 2: 새로운 고위험 HPV 감염
# ============================================================================

# 고위험 HPV 유형 정의
HIGH_RISK_HPV_TYPES <- c(16, 18, 31, 33, 45, 52, 58, 35, 39, 51, 56, 59, 66, 68)

#' 고위험 HPV 양성 여부 확인 함수
#' @param hpv_result HPV 검사 결과 (텍스트 또는 숫자)
#' @param hpv_type HPV 유형 (있는 경우)
#' @return logical: TRUE if 고위험 HPV 양성
identify_high_risk_hpv_positive <- function(hpv_result, hpv_type = NA) {
  if (is.na(hpv_result)) return(FALSE)

  result_upper <- toupper(as.character(hpv_result))

  # 양성 패턴
  positive_patterns <- c("POSITIVE", "양성", "POS", "DETECTED", "검출", "+")

  is_positive <- any(sapply(positive_patterns, function(p) grepl(p, result_upper, fixed = TRUE)))

  # HPV 유형이 지정된 경우, 고위험 유형 확인
  if (!is.na(hpv_type)) {
    hpv_type_num <- as.numeric(gsub("[^0-9]", "", as.character(hpv_type)))
    is_high_risk <- hpv_type_num %in% HIGH_RISK_HPV_TYPES
    return(is_positive & is_high_risk)
  }

  # 결과 텍스트에서 고위험 HPV 유형 검색
  for (hr_type in HIGH_RISK_HPV_TYPES) {
    if (grepl(as.character(hr_type), result_upper)) {
      return(is_positive)
    }
  }

  # "High Risk", "HR", "고위험" 등의 패턴 확인
  high_risk_patterns <- c("HIGH RISK", "HR-HPV", "HIGH-RISK", "고위험")
  if (any(sapply(high_risk_patterns, function(p) grepl(p, result_upper, fixed = TRUE)))) {
    return(is_positive)
  }

  return(FALSE)
}

#' 새로운 고위험 HPV 감염 결과변수 생성
#' @param lab_df Lab 데이터프레임
#' @param cohort_df cohort 데이터프레임 (index_date 포함)
#' @param patient_id_col 환자 ID 컬럼명
#' @param exam_date_col 검사일 컬럼명
#' @param test_name_col 검사명 컬럼명
#' @param test_result_col 검사결과 컬럼명
#' @param hpv_type_col HPV 유형 컬럼명 (있는 경우)
#' @param index_date_col index date 컬럼명
#' @return 환자별 HPV 양성 전환 정보 데이터프레임
create_hpv_infection_outcome <- function(lab_df,
                                          cohort_df,
                                          patient_id_col = "환자ID",
                                          exam_date_col = "검사일자",
                                          test_name_col = "검사명",
                                          test_result_col = "검사결과",
                                          hpv_type_col = NULL,
                                          index_date_col = "index_date") {

  # 컬럼명 심볼로 변환
  patient_id_sym <- sym(patient_id_col)
  exam_date_sym <- sym(exam_date_col)
  test_name_sym <- sym(test_name_col)
  test_result_sym <- sym(test_result_col)
  index_date_sym <- sym(index_date_col)

  # 1. HPV 검사 데이터 필터링
  hpv_tests <- lab_df %>%
    filter(grepl("HPV", toupper(!!test_name_sym)) |
           grepl("HUMAN PAPILLOMA", toupper(!!test_name_sym)) |
           grepl("인유두종", !!test_name_sym))

  # 2. 고위험 HPV 양성 여부 판정
  if (!is.null(hpv_type_col) && hpv_type_col %in% names(lab_df)) {
    hpv_type_sym <- sym(hpv_type_col)
    hpv_tests <- hpv_tests %>%
      mutate(
        is_hr_hpv_positive = mapply(
          identify_high_risk_hpv_positive,
          !!test_result_sym,
          !!hpv_type_sym
        )
      )
  } else {
    hpv_tests <- hpv_tests %>%
      mutate(
        is_hr_hpv_positive = sapply(!!test_result_sym, identify_high_risk_hpv_positive)
      )
  }

  # 3. cohort와 병합
  hpv_with_index <- cohort_df %>%
    select(!!patient_id_sym, !!index_date_sym) %>%
    left_join(hpv_tests, by = patient_id_col) %>%
    mutate(
      exam_date = as.Date(!!exam_date_sym),
      index_date = as.Date(!!index_date_sym),
      is_after_index = exam_date > index_date
    )

  # 4. Index date 이전 HPV 상태 확인 (baseline)
  baseline_hpv <- hpv_with_index %>%
    filter(is_after_index == FALSE | is.na(is_after_index)) %>%
    group_by(!!patient_id_sym) %>%
    summarise(
      baseline_hr_hpv_positive = any(is_hr_hpv_positive, na.rm = TRUE),
      .groups = "drop"
    )

  # 5. Index date 이후 HPV 양성 전환 확인
  post_index_hpv <- hpv_with_index %>%
    filter(is_after_index == TRUE) %>%
    filter(is_hr_hpv_positive == TRUE)

  # 6. 환자별 요약
  hpv_outcome <- cohort_df %>%
    select(!!patient_id_sym, !!index_date_sym) %>%
    left_join(baseline_hpv, by = patient_id_col) %>%
    left_join(
      post_index_hpv %>%
        group_by(!!patient_id_sym) %>%
        summarise(
          first_hr_hpv_positive_date = min(exam_date, na.rm = TRUE),
          .groups = "drop"
        ),
      by = patient_id_col
    ) %>%
    mutate(
      index_date = as.Date(!!index_date_sym),
      # Baseline에서 HPV 음성이었다가 양성으로 전환된 경우
      baseline_hr_hpv_positive = ifelse(is.na(baseline_hr_hpv_positive), FALSE, baseline_hr_hpv_positive),
      # 새로운 HPV 감염 이벤트 (baseline 음성 → 양성 전환)
      new_hpv_infection_event = !baseline_hr_hpv_positive & !is.na(first_hr_hpv_positive_date),
      # 감염까지의 시간 (일 단위)
      time_to_hpv_infection_days = as.numeric(first_hr_hpv_positive_date - index_date),
      # 감염까지의 시간 (월 단위)
      time_to_hpv_infection_months = time_to_hpv_infection_days / 30.44,
      # 이벤트 지시자 (생존분석용)
      new_hpv_infection_event_numeric = as.numeric(new_hpv_infection_event)
    )

  return(hpv_outcome)
}

# ============================================================================
# 5. 결과변수 생성 실행
# ============================================================================

# 주의: 아래 컬럼명은 실제 데이터에 맞게 수정 필요
# 예시 실행 코드

# Outcome 1: 병변 재발
# recurrence_outcome <- create_recurrence_outcome(
#   pathology_df = pathology,
#   cohort_df = cohort,
#   patient_id_col = "환자ID",       # 실제 컬럼명으로 수정
#   exam_date_col = "검사일자",       # 실제 컬럼명으로 수정
#   diagnosis_col = "진단명",         # 실제 컬럼명으로 수정
#   index_date_col = "index_date"    # 실제 컬럼명으로 수정
# )

# Outcome 2: 새로운 고위험 HPV 감염
# hpv_outcome <- create_hpv_infection_outcome(
#   lab_df = lab_data,
#   cohort_df = cohort,
#   patient_id_col = "환자ID",       # 실제 컬럼명으로 수정
#   exam_date_col = "검사일자",       # 실제 컬럼명으로 수정
#   test_name_col = "검사명",         # 실제 컬럼명으로 수정
#   test_result_col = "검사결과",     # 실제 컬럼명으로 수정
#   hpv_type_col = NULL,             # HPV 유형 컬럼이 있으면 지정
#   index_date_col = "index_date"    # 실제 컬럼명으로 수정
# )

# ============================================================================
# 6. 최종 결과변수 병합
# ============================================================================

#' 모든 Primary Outcome을 병합하는 함수
#' @param cohort_df 기본 cohort 데이터
#' @param recurrence_outcome 병변 재발 outcome
#' @param hpv_outcome HPV 감염 outcome
#' @param patient_id_col 환자 ID 컬럼명
#' @return 모든 primary outcome이 포함된 데이터프레임
merge_primary_outcomes <- function(cohort_df,
                                    recurrence_outcome,
                                    hpv_outcome,
                                    patient_id_col = "환자ID") {

  patient_id_sym <- sym(patient_id_col)

  # 재발 outcome 컬럼 선택
  recurrence_cols <- recurrence_outcome %>%
    select(
      !!patient_id_sym,
      recurrence_event,
      first_recurrence_date,
      time_to_recurrence_days,
      time_to_recurrence_months,
      recurrence_event_numeric
    )

  # HPV 감염 outcome 컬럼 선택
  hpv_cols <- hpv_outcome %>%
    select(
      !!patient_id_sym,
      baseline_hr_hpv_positive,
      new_hpv_infection_event,
      first_hr_hpv_positive_date,
      time_to_hpv_infection_days,
      time_to_hpv_infection_months,
      new_hpv_infection_event_numeric
    )

  # 병합
  final_outcome <- cohort_df %>%
    left_join(recurrence_cols, by = patient_id_col) %>%
    left_join(hpv_cols, by = patient_id_col)

  return(final_outcome)
}

# ============================================================================
# 7. 결과 저장
# ============================================================================

# 결과 저장 예시
# write_csv(final_outcome, "Data/primary_outcomes.csv")

# ============================================================================
# 8. 데이터 구조 확인 후 실행할 코드 (템플릿)
# ============================================================================

# 아래 코드는 데이터 컬럼명 확인 후 실행
run_outcome_extraction <- function() {

  cat("=== 데이터 로드 중... ===\n")

  # 데이터 로드
  pathology <- read_csv(paste0(data_path, "pathology_sample.csv"))
  lab_data <- read_csv(paste0(data_path, "한국 HPV 코호트 자료를 이용한 자_진단검사(Lab).csv"))
  cohort <- read_csv(paste0(data_path, "한국 HPV 코호트 자료를 이용한 자_코호트.csv"))

  cat("=== 데이터 컬럼 확인 ===\n")
  cat("\nPathology 컬럼:\n")
  print(names(pathology))
  cat("\nLab 컬럼:\n")
  print(names(lab_data))
  cat("\nCohort 컬럼:\n")
  print(names(cohort))

  # 실제 컬럼명 확인 후 아래 코드 수정하여 실행
  # ...

  cat("\n=== 컬럼명을 확인 후 위의 함수들을 실제 컬럼명에 맞게 수정하여 실행하세요 ===\n")
}

# 실행
# run_outcome_extraction()

cat("
============================================================================
코드 사용 안내:
============================================================================

1. 먼저 run_outcome_extraction() 함수를 실행하여 실제 데이터 컬럼명을 확인하세요.

2. 확인된 컬럼명을 기반으로 다음 함수들의 매개변수를 수정하세요:
   - create_recurrence_outcome(): 병변 재발 변수 생성
   - create_hpv_infection_outcome(): 고위험 HPV 감염 변수 생성

3. 결과변수 설명:

   [Outcome 1: 병변 재발]
   - recurrence_event: 재발 여부 (TRUE/FALSE)
   - first_recurrence_date: 첫 재발일
   - time_to_recurrence_days/months: 재발까지의 시간
   - recurrence_event_numeric: 생존분석용 이벤트 지시자 (0/1)

   [Outcome 2: 새로운 고위험 HPV 감염]
   - baseline_hr_hpv_positive: Index date 이전 HPV 양성 여부
   - new_hpv_infection_event: 새로운 HPV 감염 발생 여부
   - first_hr_hpv_positive_date: 첫 HPV 양성 전환일
   - time_to_hpv_infection_days/months: 감염까지의 시간
   - new_hpv_infection_event_numeric: 생존분석용 이벤트 지시자 (0/1)

4. 고위험 HPV 유형: 16, 18, 31, 33, 45, 52, 58, 35, 39, 51, 56, 59, 66, 68

============================================================================
")
