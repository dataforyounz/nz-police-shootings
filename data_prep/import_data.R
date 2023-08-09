
library( tabulizer )
library( tidyverse )

## SETUP ----------------------------------------------------------------------------------------------
#
# Directory variables
file_folder <- "data_prep" 
file_name   <- list.files( file_folder, pattern = ".pdf" )
file_path   <- file.path( file_folder, file_name ) 

# Target folder
output_folder <- "dashboard/dat"

## PDF EXTRACTION / FILE IMPORT ----------------------------------------------------------------------------------
#
# If an extracted data file doesn't exist, run the extract area routine
if( !file.exists( file.path(file_folder, "extracted_data.Rdata") ) ) {
 
  # Select table areas to extract
  tables <- extract_areas( file_path )
  save( tables, file = file.path(file_folder, "extracted_data.Rdata") )

} else load( file.path(file_folder, "extracted_data.Rdata") )
  
# Assign title, notes, and data to its own variable.
title <- tables[[1]][3,]
notes <- tables[[3]]
data  <- tables[4:14]

## FIX COLUMN NAMES ----------------------------------------------------------------------------------
#
# Loop through each list element and tidy up column names
# Columns names are spread over the first three rows
# Then...
# Export each page to temp .csv file for some manual processing (seemed easier...)
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

## =====================================================================================================
# Manual Processing Notes
# 1. Tidied up file encoding errors
# 2. Tidied up dates so 1916 wasn't read in as 2016
# 3. Where multiple weapons were listed, separated with semi-colon
# 4. Links to IPCA reports were sometimes broken across multiple lines, this was fixed
# 5. Outcome of shots fired also spread across multiple lines, this was fixed
#
# All fixes are saved in tmp folder which can then be read in.
# Further fixes can also be applied without affecting the execution of this script
# It will simply read in the files as saved in the tmp folder
## =====================================================================================================

## COMBINE TEMP FILES ----------------------------------------------------------------------------------
#
# Read the tidied temp files back in and assign to list object
dfs_in <- lapply( seq_along(data), function(d){
  
  file <- paste0("tmp/tmp_",d,".csv") 
  read.csv( file = file.path(file_folder, file), stringsAsFactors = FALSE )
  
})

# Bind all rows together to create a final data frame
# Apply some formatting to handle missing values and NAs
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

## EXPORT ----------------------------------------------------------------------------------------------
#
# Save the variables to the target folder
save( title, notes, shooting_df, file = file.path(output_folder, "shooting_data.Rdata") )
write.csv( shooting_df, row.names = F, file = file.path(output_folder, "shooting_data.csv") )

