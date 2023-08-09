
library( tidyverse )

# Reads in original data

data_folder <- "dashboard/dat"
data_file   <- "shooting_data.Rdata" 
data_path   <- file.path( data_folder, data_file )

load( data_path )

# 1. Recode Districts so they are all consistent
# 2. Create flag for fatal shootings
# 3. Create flag for non-fatal shootings
# 4. Create flag for misses

shooting_df <- shooting_df %>% 
               mutate( District = recode( 
                                  District,
                                  "Auckland" = "Auckland City",
                                  "Counties Manukau" = "Counties/Manukau"
                       ),
                       fatal_fl = case_when(
                         Outcome.of.Shots.Fired %in% c("Fatal", "Fatal (bystander)", 
                                                       "Fatal-cause unconfirmed") ~ 1,
                         TRUE ~ 0
                       ),
                       non_fatal_fl = case_when(
                         Outcome.of.Shots.Fired %in% c("Non-fatal injury", "Non-fatal injury (offender)", 
                                                       "Non-fatal injury (bystander)") ~ 1,
                         TRUE ~ 0
                       ),
                       outcome_category = case_when(
                         fatal_fl == 1 ~ "Fatal",
                         non_fatal_fl == 1 ~ "Non-Fatal",
                         TRUE ~ "Miss"
                       )
) 

# Measures
total_shootings <- nrow( shooting_df )
total_fatal     <- nrow( shooting_df %>% filter( fatal_fl == 1) )
total_non_fatal <- nrow( shooting_df %>% filter( non_fatal_fl == 1) )
total_miss      <- nrow( shooting_df %>% filter( non_fatal_fl != 1 & fatal_fl != 1) )

# Summary data for shootings per year
shootings_by_year <- tibble( shooting_df ) %>% 
                     mutate( year = year(Incident.Date) ) %>% 
                     summarise( n = n(), .by = c(year, outcome_category)) %>% 
                     rename( Count = n, Year = year, Outcome = outcome_category ) 

# Summary data for shootings by district
shootings_by_district <- tibble( shooting_df ) %>% 
                         summarise( Count = n(), 
                                    total_fatal = sum( fatal_fl ),
                                    total_non_fatal = sum( non_fatal_fl ),
                                    total_miss = sum( !fatal_fl & !non_fatal_fl ),
                                    .by = c(District)) %>% 
                         arrange( District ) %>% 
                         mutate( district_id = str_pad(1:12, width = 2, pad = "0") ) %>% 
                         relocate( district_id, 1 )


save( title, notes, shooting_df, total_shootings, total_fatal, total_non_fatal, 
      total_miss, shootings_by_year, shootings_by_district,
      file = file.path(data_folder, "shooting_data_clean.Rdata") )


