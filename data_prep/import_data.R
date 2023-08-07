
library( tabulizer )

file_folder <- "data_prep" 
file_name   <- list.files( file_folder, pattern = ".pdf" )
file_path   <- file.path( file_folder, file_name ) 

# Select areas to extract
tables <- extract_areas( file_path )

title <- tables[[1]][3,]
notes <- tables[[3]]

data <- tables[4:14]

test <- lapply( seq_along(data), function(d){
  tmp <- data.frame( data[[d]] ) 
  col_names_raw <- tmp[1:3,]
  col_names <- paste( col_names_raw[1,], col_names_raw[2,], col_names_raw[3,] )
  })



tmp <- data.frame( data[[1]] ) 
col_names_raw <- tmp[1:3,]
col_names <- trimws( paste( col_names_raw[1,], col_names_raw[2,], col_names_raw[3,] ))


do.call( rbind, tables[4:14]

data.frame( tables[[5]] )
