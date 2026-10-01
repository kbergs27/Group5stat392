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
