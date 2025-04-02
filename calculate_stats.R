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
