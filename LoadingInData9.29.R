library(tidyverse)
#
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

LocationTally <- OneRow.Scholarship |>
  group_by(year, CityTown.of.Residence) |>
  summarise(
    Winners = sum(total_awarded > 0, na.rm = TRUE),
    Nonwinners = sum(total_awarded == 0, na.rm = TRUE),
    Total = n(),
    Dollars_Awarded = sum(total_awarded, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(year, CityTown.of.Residence)

View(LocationTally)

write.csv(LocationTally, "LocationTally.csv", row.names = FALSE)
sort(LocationTally,decreasing=FALSE)

OneRow.Scholarship <- OneRow.Scholarship |>
  mutate(town = tolower(trimws(CityTown.of.Residence)),
         region = case_when(
           town == "worcester" ~ "Worcester",
           town %in% c("west boylston","boylston","shrewsbury","northborough","westborough","southborough","berlin","bolton","clinton","sterling","lancaster","harvard","leominster","fitchburg","lunenburg") ~ "Northeast",
           town %in% c("holden","paxton","princeton","rutland","oakham","barre","hubbardston","westminster","ashburnham","gardner","winchendon","templeton","phillipston","royalston","athol","petersham","hardwick","new braintree","north brookfield") ~ "Northwest",
           town %in% c("millbury","grafton","upton","sutton","northbridge","hopedale","mendon","douglas","uxbridge","millville","blackstone","milford") ~ "Southeast",
           town %in% c("auburn","leicester","spencer","charlton","oxford","sturbridge","southbridge","dudley","webster","brookfield","east brookfield","west brookfield","warren") ~ "Southwest",
           TRUE ~ "Other"))

table(OneRow.Scholarship$region)
table(OneRow.Scholarship$region, ifelse(OneRow.Scholarship$total_awarded > 0, "Winner", "Loser"))

View(
  OneRow.Scholarship |>
    select(
      year,
      fake_first,
      fake_last,
      CityTown.of.Residence,
      Request.Status,
      scholarships,
      n_scholarships,
      total_awarded
    )
)

s <- str_to_lower(OneRow.Scholarship$scholarships)

geo <- case_when(
  str_detect(s, "auburn knights|auburn woman|hedin|bourke") ~ "Auburn",
  str_detect(s, "falby") ~ "Boylston",
  str_detect(s, "charlton parent") ~ "Charlton",
  str_detect(s, "wagner") ~ "Douglas",
  str_detect(s, "east brookfield scholarship") ~ "East Brookfield",
  str_detect(s, "kelly.{0,4}davis|ahlquist") ~ "Grafton",
  str_detect(s, "arsenault|leicester (high|savings|samaritan)|expository") ~ "Leicester",
  str_detect(s, "lunenburg") ~ "Lunenburg",
  str_detect(s, "carolyn.{0,4}cannon") ~ "Millbury",
  str_detect(s, "anne carey|salem educational") ~ "North Brookfield",
  str_detect(s, "keeler|northbridge high") ~ "Northbridge",
  str_detect(s, "olive wood") ~ "Oxford",
  str_detect(s, "simonatis") ~ "Princeton",
  str_detect(s, "wolcott") ~ "Shrewsbury",
  str_detect(s, "eppinger|gaudette") ~ "Spencer",
  str_detect(s, "fedeli") ~ "Sterling",
  str_detect(s, "junnila|simonian|freeland|connolly|henrickson|norlin") ~ "Sutton",
  str_detect(s, "bradford.{0,4}kemp") ~ "Webster",
  str_detect(s, "denfeld|fannie.{0,4}forbes|grynsel") ~ "Westborough",
  str_detect(s, "janet fraser") ~ "Medway",
  str_detect(s, "harold.{0,4}jensen|john buckley|worcester woman|lincoln village|joseph.{0,4}early|feingold|kaufman|belmont street|elm park|lyons|dorothy.{0,4}smith|davidian|webster square|hanson") ~ "Worcester",
  str_detect(s, "tahanto|debbie anne|goulet") ~ "Boylston",
  str_detect(s, "andrew sala") ~ "Upton",
  str_detect(s, "walker family") ~ "Templeton",
  str_detect(s, "proko") ~ "Holden",
  str_detect(s, "greg.{0,2}s grant") ~ "Acton",
  str_detect(s, "kathleen terry") ~ "Sturbridge",
  str_detect(s, "hampel") ~ "Cheshire",
  str_detect(s, "kuhner") ~ "Oakham",
  str_detect(s, "belval") ~ "Northbridge",
  str_detect(s, "burgholzer") ~ "Shrewsbury",
  str_detect(s, "lock memorial") ~ "Spencer"
)

old <- if ("CityTown.of.Residence" %in% names(OneRow.Scholarship)) OneRow.Scholarship$CityTown.of.Residence else OneRow.Scholarship$Town
old <- na_if(trimws(as.character(old)), "  NA")

OneRow.Scholarship$Town <- coalesce(old, geo)
OneRow.Scholarship <- select(OneRow.Scholarship, -any_of(c("CityTown.of.Residence", "geo_town")))
