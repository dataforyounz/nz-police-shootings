
library( tabulizer )

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
dfs <- lapply( seq_along(data), 
               function(d){
                  tmp <- data.frame( data[[d]] ) 
                  col_names_raw <- tmp[1:3,]
                  col_names <- trimws( paste( col_names_raw[1,], col_names_raw[2,], col_names_raw[3,] ))
                  colnames( tmp ) <- col_names
                  tmp[-c(1:3),]
                })

# Bind all rows together to craete a final data frame
shooting_df <- do.call( rbind, dfs )

# Save the variables
save( title, notes, shooting_df, file = file.path(file_folder, "shooting_data.Rdata") )
