############################################################################
################### Descarga de datos climaticos ###########################
############################################################################

###Librerias

install.packages("chirps")
library(readxl)
library(dplyr)
library(terra)


##carga de datos

path_input = "D:/OneDrive - CGIAR/Desktop/Descarga de datos agroclimaticos/coordenadas_csv.csv" #### Ubicaci?n del archivo con las coordenadas

path_output = "D:/OneDrive - CGIAR/Desktop/Descarga de datos agroclimaticos/" ### Ubicaci?n donde se guardar? la informaci?n

input_data = read.csv(path_input, header = TRUE) ### Lectura del archivo de las coordenadas

special_data<-input_data ## asignaci?n del nombre del archivo

file_date<-read_excel("D:/OneDrive - CGIAR/Desktop/Descarga de datos agroclimaticos/dim_tiempo_agg.xlsx_20221128.xlsx",col_names = T, 
                      na="")  




### Declaración de niveles de meses 

special_data$month_planting=tolower(special_data$month_planting) #### se tranforman los nombres de los meses a minusculas
special_data$month_hervest=tolower(special_data$month_hervest)


level_month<-c("enero"=1, "febrero"=2, "marzo"=3, "abril"=4, "mayo"=5 , "junio"=6, "julio"=7, "agosto"=8,  
               "septiembre"=9, "octubre"=10, "noviembre"=11, "diciembre"=12)  


special_data=transform(special_data, 
                       month_planting=factor(dplyr::recode(month_planting,!!!level_month)),
                       month_hervest=factor(dplyr::recode(month_hervest,!!!level_month)))


special_data$month_planting <- special_data$month_planting   %>% as.character() %>% as.numeric()
special_data$month_hervest<-special_data$month_hervest %>% as.character() %>% as.numeric()




#### Agregación de fechas 


special_data$first_date<-as.Date(paste0(special_data$year,'-',special_data$month_planting,'-01'))
names(file_date)[2]<-'month_hervest'
file_date$first_date<-NULL
file_date<-as.data.frame(file_date)
Data_comple<-dplyr::left_join(x=special_data,y=file_date, by=c("year","month_hervest"))


############ función de descarga 


### Pruebas

var1<-"T2M_MAX,"
var2<-"T2M_MIN,"
var3<-"RH2M,"
#var3<-"HR"
#var4<-"PRECTOTCORR,"
var4<-"ALLSKY_SFC_SW_DWN"
temporal<-"daily"
formato<-"CSV"
longitud<-Data_comple$lon
latitud<-Data_comple$lat
ini<-Data_comple$first_date



wcurl<-"https://power.larc.nasa.gov/api/temporal"  #### URL de donde se descargar la informacion 



climate<-function(spacial_date,path, formato,temporal, var1,var2,var3,var4){
  
  tablas <- purrr::map(.x = 1:nrow(Data_comple), .f = function(i){
    
    date_ini =  Data_comple$first_date[i]
    date_end =  Data_comple$last_date[i]
    ini<-format(as.Date(date_ini),"%Y%m%d")
    fin<-format(as.Date(date_end),"%Y%m%d")
    longitud<-Data_comple$lon[i]
    latitud<-Data_comple$lat[i]
    ident_site<-Data_comple$id_site[i]
    
    URL<-paste0(wcurl,"/",temporal,"/point?parameters=",var1,var2,var3,var4,"&community=AG&longitude=",longitud,"&latitude=",latitud,"&start=",ini,"&end=",fin,"&format=",formato)
    #URL1<-(paste0(wcurl,"/",temporal,"/point?parameters=T2M_MIN,T2M_MAX,ALLSKY_SFC_UVB,RH2M,PRECTOTCORR&community=AG&longitude=",longitud,"&latitude=",latitud,"&start=",ini,"&end=",fin,"&format=",formato))
    
    
    range_date<-seq(as.Date(date_ini), as.Date(date_end),"days")
    
    #print(range_date)
    
    tmp<-data.frame()
    
    
    prec_data<-read.csv(file=URL, skip = 12)
    prec_data$ID<-(ID=ident_site)
    prec_data$lon<-(lon = longitud)
    prec_data$lat<-(lat = latitud)
    prec_data$fecha<-range_date
    tmp<-rbind(tmp,prec_data)
    
    return(tmp)
  })
  
  tablas<-dplyr::bind_rows(tablas)
  
  write.csv(tablas, paste(path_output ,"nasapower_data.csv"))}




#### Descarga de datos precipitacion 


# Load data frame with id_site, lat, lon, planting_date, harvest_date
input_data <- Data_comple
dates <-as.character(c(min(input_data$first_date), max(input_data$last_date)))

# Download data from CHIRPS
prec_data <- chirps::get_chirps(input_data[c("lon", "lat")], dates, server = "CHC")

write.csv(prec_data, paste(path_output + "CHIRPS_data.csv")) 

  
  
