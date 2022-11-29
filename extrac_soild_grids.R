
install.packages('soilDB', dependencies = TRUE)

path_input = ""
path_output = ""
# Data frame with three columns: id_site, lat, lon
# include only sites with complete lat and lon
input_data = read.csv(path_input, header = TRUE)


# This function returns information of soilgrids at different levels for 49 
# different variables

# Download multiple sites
soil_data <- soilDB::fetchSoilGrids(
  x = input_data,
  loc.names = c("id_site", "lat", "lon"),
  verbose = FALSE,
  progress = FALSE
)

# Download only one site
# tst <- soilDB::fetchSoilGrids(x = data.frame(id = '1', lat =-0.829093 , 

save(soil_data,file =paste(path_output+"soil_data.RData"))

# Check the number of rows downloaded
dim(soil_data@horizons)
dim(input_data)

