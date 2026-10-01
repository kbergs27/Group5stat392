library(tidyverse)
Scholarship22<- read.csv("deidScholarship22.csv")
Scholarship23<- read.csv("deidScholarship23.csv")
Scholarship24<- read.csv("deidScholarship24.csv")
Scholarship25<- read.csv("deidScholarship25.csv")
Scholarship26<- read.csv("deidScholarship26.csv")
mean(Scholarship25$GPA, na.rm = TRUE)

all_chr <- function(df) mutate(df, across(everything(), as.character))

master <- bind_rows(
  "2022" = all_chr(Scholarship22),
  "2023" = all_chr(Scholarship23),
  "2024" = all_chr(Scholarship24),
  "2025" = all_chr(Scholarship25),
  "2026" = all_chr(Scholarship26),
  .id = "year"
)

master <- type.convert(master, as.is = TRUE)

write.csv(master, "masterScholarship.csv", row.names = FALSE)
master <- master %>%
  mutate(
    amount_num = suppressWarnings(as.numeric(trimws(as.character(Amount.Awarded)))),
    won_money  = if_else(!is.na(amount_num) & amount_num > 0, "Won money", "Did not win")
  )

winners    <- filter(master, won_money == "Won money")
nonwinners <- filter(master, won_money == "Did not win")

write.csv(master, "masterScholarship.csv", row.names = FALSE)
table(master$year, master$won_money)  