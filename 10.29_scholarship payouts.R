library(dplyr)

payouts <- Clean.MasterScholarship %>%
  mutate(
    Amount.Awarded = as.numeric(gsub("[$,[:space:]]", "", Amount.Awarded)),
    Process.Name = trimws(sub("\\s*\\d{4}$", "", Process.Name))
  ) %>%
  group_by(Process.Name) %>%
  summarise(
    Total_Awarded  = sum(Amount.Awarded, na.rm = TRUE),
    Avg_Award      = mean(Amount.Awarded, na.rm = TRUE),
    Number_Awarded = sum(!is.na(Amount.Awarded)),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Awarded))

View(payouts)      
 

write.csv(payouts,"ScholarshipPayouts",row.names = FALSE)

sum(as.numeric(gsub("[$,[:space:]]", "", OneRow.Scholarship$Amount.Awarded)), na.rm = TRUE)

sum(as.numeric(gsub("[$,[:space:]]", "", winners$Amount.Awarded)), na.rm = TRUE)
