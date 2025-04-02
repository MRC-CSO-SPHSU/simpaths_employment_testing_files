#! /usr/bin/Rscript

args <- commandArgs(trailingOnly = TRUE)

library(dplyr)
library(fixest)
library(dtplyr)

run_no <- args[1]

population <- data.table::fread(paste0("outfiles/run_", run_no, ".csv"), select = c("id_Person", "time", "les_c4")) |> 
  panel(~ id_Person + time)

population[,lag_empl := l(les_c4)]

transition_rates <- population |> 
  as_tibble() |>
  mutate(
    NotEmpToEmp = case_when(
      lag_empl == "NotEmployed" & les_c4 == "EmployedOrSelfEmployed" ~ 1L,
      lag_empl == "NotEmployed" ~ 0L
    ),
    EmpToNotEmp = case_when(
      lag_empl == "EmployedOrSelfEmployed" & les_c4 == "NotEmployed" ~ 1L,
      lag_empl == "EmployedOrSelfEmployed" ~ 0L
    )
  ) |>
  summarise(
    NotEmpToEmp = mean(NotEmpToEmp, na.rm = TRUE),
    EmpToNotEmp = mean(EmpToNotEmp, na.rm = TRUE),
    .by = c("time")) |> 
  filter(!is.na(NotEmpToEmp))

transition_rates

employment_rates <- population |> 
  as_tibble() |>
  summarise(
    employment = mean(les_c4 == "EmployedOrSelfEmployed"),
    .by = c("time")
  )

  employment_rates


if (any(transition_rates$EmpToNotEmp > 0.10)) {
  warning("Transition rates out of employment go as high as ", 
          scales::percent_format(.1)(max(transition_rates$EmpToNotEmp)),
          " (expected 3-5%)")
}

if (any(transition_rates$EmpToNotEmp < 0.02)) {
  warning("Transition rates out of employment go as low as ", 
          scales::percent_format(.1)(min(transition_rates$EmpToNotEmp)),
          " (expected 3-5%)")
}

if (any(transition_rates$NotEmpToEmp > 0.35)) {
  warning("Transition rates into employment go as high as ", 
          scales::percent_format(.1)(max(transition_rates$NotEmpToEmp)),
          " (expected 18-22%)")
}

if (any(transition_rates$NotEmpToEmp < 0.10)) {
  warning("Transition rates into employment go as low as ", 
          scales::percent_format(.1)(min(transition_rates$NotEmpToEmp)),
          " (expected 18-22%)")
}

