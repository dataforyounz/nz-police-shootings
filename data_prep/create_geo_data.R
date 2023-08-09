
library( sf )
library( tidyverse )

geo_data_folder <- "data_prep/police-district-boundaries"
geo_data_file   <- "nz-police-district-boundaries.shp"
geo_data_path   <- file.path( geo_data_folder, geo_data_file ) 

boundary_data <- st_read( geo_data_path ) %>% 
                 st_transform('+proj=longlat +datum=WGS84') %>% 
                 arrange( DISTRICT_N ) %>% 
                 mutate( district_id = str_pad(1:12, width = 2, pad = "0") )


data_folder <- "dashboard/dat"
data_file   <- "shooting_data_clean.Rdata" 
data_path   <- file.path( data_folder, data_file )

load( data_path )


district_geo_data <- boundary_data %>% 
                     left_join( shootings_by_district, by = "district_id") %>% 
                     select( district_id, District, Count, total_fatal, 
                             total_non_fatal, total_miss, geometry )


save( district_geo_data,
      file = file.path(data_folder, "geo_data.Rdata") )




