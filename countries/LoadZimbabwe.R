LoadZimbabwe = function() {
#COVID-19 Data Repository by African Surveyors Connect https://github.com/African-Surveyors-Connect/Zimbabwe-COVID-19-Data/
#Dashboard: https://surveyor-jr.maps.arcgis.com/apps/dashboards/8ef907d2658c44c6a143819aa7979b20

#note could be improved by calling data from ESRI, provincial timeseries feature Id: 20703dd3a24f45f08ea37034285d3492


Data = read.csv("https://raw.githubusercontent.com/African-Surveyors-Connect/Zimbabwe-COVID-19-Data/master/time_series_data/daily_provincial_records.csv")

Dates = as.character(as.Date(Data$reportDate))
DateReport = max(Dates)
DATERANGE = which(as.Date(Dates) > (as.Date(DateReport)-14))

CaseDiff=c()
CaseDiff[1] = (10/14)*sum(Data$case_newHarare[DATERANGE])
CaseDiff[2] = (10/14)*sum(Data$case_newManicaland[DATERANGE])
CaseDiff[3] = (10/14)*sum(Data$case_newMashCentral[DATERANGE])
CaseDiff[4] = (10/14)*sum(Data$case_newMashEast[DATERANGE])
CaseDiff[5] = (10/14)*sum(Data$case_newMashWest[DATERANGE])
CaseDiff[6] = (10/14)*sum(Data$case_newMidlands[DATERANGE])
CaseDiff[7] = (10/14)*sum(Data$case_newMasvingo[DATERANGE])
CaseDiff[8] = (10/14)*sum(Data$case_newMatNorth[DATERANGE])
CaseDiff[9] = (10/14)*sum(Data$case_newMatSouth[DATERANGE])
CaseDiff[10] = (10/14)*sum(Data$case_newBulawayo[DATERANGE])

Province =  c("Harare", "Manicaland", "Mashonaland Central", "Mashonaland East", "Mashonaland West" ,"Midlands", "Masvingo", "Matabeleland North","Matabeleland South","Bulawayo")    

#Pop = read.csv("https://github.com/zimgeospatial/census/raw/master/province_population.csv")
#write.csv(Pop,"countries/data/Zimbabwe_pop.csv",row.names=FALSE)
Pop = read.csv("countries/data/Zimbabwe_pop.csv")


zimbabwedf = data.frame(Province,DateReport,CaseDiff)


#geometry
#geomZimbabwe = st_read("https://github.com/zimgeospatial/admin_boundaries/raw/master/admin_level1_provinces.geojson") %>%
#st_cast("MULTIPOLYGON") #NEED TO CAST TO MULTIPOLYGON
#st_write(geomZimbabwe,"countries/data/geom/geomZimbabwe.geojson")
geomZimbabwe = st_read("countries/data/geom/geomZimbabwe.geojson")

ZimbabweMap <- inner_join(geomZimbabwe,zimbabwedf, by = c('micro_name' = "Province"))
ZimbabweMap$micro_code <- as.numeric(ZimbabweMap$micro_code)
ZimbabweMap <- inner_join(ZimbabweMap,Pop, by = c('micro_code' = "provincepc"))
ZimbabweMap$Country = "Zimbabwe"
ZimbabweMap$RegionName = paste(ZimbabweMap$micro_name,", ",ZimbabweMap$Country)
ZimbabweMap$pInf = ZimbabweMap$CaseDiff/ZimbabweMap$pop_2012
Zimbabwe_DATA = subset(ZimbabweMap,select=c("DateReport","geoid","RegionName","Country","pInf","geometry"))
return(Zimbabwe_DATA)
}
