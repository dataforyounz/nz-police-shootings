
library( tabulizer )
library( tidyverse )

# Directory variables
file_folder <- "data_prep" 
file_name   <- list.files( file_folder, pattern = ".pdf" )
file_path   <- file.path( file_folder, file_name ) 

# Table extraction or file import
if( !file.exists( file.path(file_folder, "extracted_data.Rdata") ) ) {
 
  # Select areas to extract
  tables <- extract_areas( file_path )
  save( tables, file = file.path(file_folder, "extracted_data.Rdata") )

} else load( file.path(file_folder, "extracted_data.Rdata") )
  
# Assign title, notes, and data to its own variable.
title <- tables[[1]][3,]
notes <- tables[[3]]
data  <- tables[4:14]

# Loop through each list element and tidy up column names
# Columns names are spread over the first three rows
# Export each page to .csv file for some manual processing (seemed easier...)
if( !dir.exists(file.path(file_folder, "tmp")) ){
dfs <- lapply( seq_along(data), 
               function(d){
                  tmp <- data.frame( data[[d]] ) 
                  col_names_raw <- tmp[1:3,]
                  col_names <- trimws( paste( col_names_raw[1,], col_names_raw[2,], col_names_raw[3,] ))
                  colnames( tmp ) <- col_names
                  write.csv(  tmp[-c(1:3),], row.names = F, 
                              file = file.path(file_folder, paste0("tmp/tmp_",d,".csv") ),
                              fileEncoding = "UTF-8"
                              )
                })

}

dfs_in <- lapply( seq_along(data), function(d){
  
  file <- paste0("tmp/tmp_",d,".csv") 
  read.csv( file = file.path(file_folder, file), stringsAsFactors = FALSE )
  
})


# Bind all rows together to create a final data frame
shooting_df <- tibble( do.call( rbind, dfs_in ) ) %>% 
               mutate( Incident.Date = dmy(Incident.Date), 
                       Subject.Weapon = case_when(
                         Subject.Weapon == "" ~ NA_character_,
                         TRUE ~ str_squish(Subject.Weapon)
                       ),
                       Subject.Sex = case_when(
                         Subject.Sex == "" ~ NA_character_,
                         TRUE ~ str_squish(Subject.Sex)
                       ),
                       Link.to.IPCA.Investigation.Public.Report = case_when(
                         Link.to.IPCA.Investigation.Public.Report == "" ~ NA_character_,
                         TRUE ~ Link.to.IPCA.Investigation.Public.Report
                       ))

# Save the variables
save( title, notes, shooting_df, file = file.path(file_folder, "shooting_data.Rdata") )
write.csv( shooting_df, row.names = F, file = file.path(file_folder, "shooting_data.csv") )

