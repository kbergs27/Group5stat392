library(tidyverse)
Scholarship22<- read.csv("deidScholarship22.csv")
Scholarship23<- read.csv("deidScholarship23.csv")
Scholarship24<- read.csv("deidScholarship24.csv")
Scholarship25<- read.csv("deidScholarship25.csv")
Scholarship26<- read.csv("deidScholarship26.csv")
mean(Scholarship25$GPA, na.rm = TRUE)

all_chr <- function(df) mutate(df, across(everything(), as.character))

MasterScholarship <- bind_rows(
  "2022" = all_chr(Scholarship22),
  "2023" = all_chr(Scholarship23),
  "2024" = all_chr(Scholarship24),
  "2025" = all_chr(Scholarship25),
  "2026" = all_chr(Scholarship26),
  .id = "year"
)

MasterScholarship <- type.convert(MasterScholarship, as.is = TRUE)

write.csv(MasterScholarship, "masterScholarship.csv", row.names = FALSE)


sapply(list(Scholarship22, Scholarship23, Scholarship24, Scholarship25, Scholarship26),
       function(d) "Request.Status" %in% names(d))
table(c(Scholarship22$Request.Status, Scholarship23$Request.Status,
        Scholarship24$Request.Status, Scholarship25$Request.Status,
        Scholarship26$Request.Status), useNA = "ifany")
Clean.MasterScholarship <- MasterScholarship |>
  filter(Request.Status %in% c("Application Complete", "Evaluations Assigned",
                               "Evaluations Closed", "Follow Up(s) Assigned",
                               "Denied", "Closed", "Approved", "Approval Draft"))

nrow(Clean.MasterScholarship)
nrow(distinct(Clean.MasterScholarship, year, fake_first, fake_last))
Clean.MasterScholarship |>
  count(year, fake_first, fake_last) |>
  count(n, name = "applicants")

MasterCompleteApps <- Clean.MasterScholarship |>
  mutate(rank = case_when(
    Request.Status == "Approved" ~ 1,
    Request.Status == "Approval Draft" ~ 2,
    Request.Status %in% c("Evaluations Assigned", "Evaluations Closed",
                          "Follow Up(s) Assigned") ~ 3,
    Request.Status == "Denied" ~ 4,
    Request.Status == "Closed" ~ 5,
    Request.Status == "Application Complete" ~ 6))

best_row <- MasterCompleteApps |>
  arrange(year, fake_first, fake_last, rank) |>
  distinct(year, fake_first, fake_last, .keep_all = TRUE)

summary_cols <- MasterCompleteApps |>
  group_by(year, fake_first, fake_last) |>
  summarise(n_scholarships = n_distinct(Process.Name),
            scholarships = paste(sort(unique(Process.Name)), collapse = "; "),
            total_awarded = sum(parse_number(as.character(Amount.Awarded)), na.rm = TRUE),
            .groups = "drop")

OneRow.Scholarship <- best_row |>
  left_join(summary_cols, by = c("year", "fake_first", "fake_last")) |>
  select(-rank)

nrow(OneRow.Scholarship)
rm(master, all_chr, MasterComplete, best_row, summary_cols)

MasterScholarship <- MasterScholarship %>%
  mutate(
    amount_num = suppressWarnings(as.numeric(trimws(as.character(Amount.Awarded)))),
    won_money  = if_else(!is.na(amount_num) & amount_num > 0, "Won money", "Did not win")
  )

winners    <- filter(MasterScholarship, won_money == "Won money")
nonwinners <- filter(MasterScholarship, won_money == "Did not win")

write.csv(MasterScholarship, "$WonMasterScholarship.csv", row.names = FALSE)
table(MasterScholarship$year, MasterScholarship$won_money)
