LoadGoogleSourced<-function(){ #takes a long time to process.
#@article{Wahltinez2020,
#  author = "O. Wahltinez and others",
#  year = 2020,
#  title = "COVID-19 Open-Data: curating a fine-grained, global-scale data repository for SARS-CoV-2",
#  note = "Work in progress",
#  url = {https://goo.gle/covid-19-open-data},
#}



 #full list
 #LIST =c("Argentina", "South Korea", "Philippines", "Pakistan", "Colombia", "Israel", "Haiti", "Afghanistan" ,"Mozambique", "Sierra Leone", "Democratic Republic of the Congo", "Sudan", "Kenya", "Bangladesh","Libya")
 #list with recent subnational data as of 8th August 2021.
 #don't want to incorp Israel yet. Bangladesh looks like data resource is broken.
 LIST =c("Argentina", "Colombia", "Afghanistan","Mozambique")

#index file
INDEX = vroom("https://storage.googleapis.com/covid19-open-data/v3/index.csv", col_types = cols(aggregation_level = col_double(), .default = col_character()))
KEYS=c()
LOCALES = c()
COUNTRY = c()
for(aa in 1:length(LIST)){
	Inds = which(INDEX$country_name==LIST[aa] & INDEX$aggregation_level==1)
	KEYS = c(KEYS,INDEX$location_key[Inds])
	LOCALES =  c(LOCALES,INDEX$subregion1_name[Inds])
	COUNTRY = c(COUNTRY,rep(LIST[aa],length(Inds)))	
}

DateReport=c()
CaseDiff=c()
Pop=c()
for(bb in 1:length(KEYS)){
  # cat("\n",bb,"\n")
	DAT = vroom(paste0("https://storage.googleapis.com/covid19-open-data/v3/location/",KEYS[bb],".csv"), guess_max = 1000, show_col_types = FALSE)
	problems(DAT)
	naIND = which(is.na(DAT$new_confirmed))
	DateReport[bb] = as.character(max(DAT$date[-naIND]))
	curr = DAT$cumulative_confirmed[which(DAT$date == as.Date(DateReport[bb]))]
	past = DAT$cumulative_confirmed[which(DAT$date == as.Date(DateReport[bb])-14)]
	CaseDiff[bb] = (10/14)*(curr-past)
	if(length(DAT$population[1])==1){
	Pop[bb] = DAT$population[1]
	} else {
	Pop[bb] = NA
	}
}


IndexTable = data.frame(KEYS,LOCALES,Country = COUNTRY,DateReport,CaseDiff,Pop)

#2017 census
IndexTable$Pop[IndexTable$KEYS == "MZ_A"] = 1865976 # Niassa Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_A"] = "Nassa"
IndexTable$Pop[IndexTable$KEYS == "MZ_B"] = 1911237#            Manica Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_B"] = "Manica"
IndexTable$Pop[IndexTable$KEYS == "MZ_G"] = 1446654#             Gaza Province Mozambique
IndexTable$LOCALES[IndexTable$KEYS == "MZ_G"] = "Gaza" 
IndexTable$Pop[IndexTable$KEYS == "MZ_I"] = 1496824#       Inhambane Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_I"] ="Inhambane"
IndexTable$Pop[IndexTable$KEYS == "MZ_L"] = 2507098 #           Maputo Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_L"] = "Maputo"
IndexTable$Pop[IndexTable$KEYS == "MZ_MPM"] = 1101170 #                    Maputo Mozambique
IndexTable$LOCALES[IndexTable$KEYS == "MZ_MPM"] = "Maputo City"   
IndexTable$Pop[IndexTable$KEYS == "MZ_N"] = 6102867#          Nampula Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_N"] = "Nampula"  
IndexTable$Pop[IndexTable$KEYS == "MZ_P"] = 2333278#     Cabo Delgado Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_P"] = "Cabo Delgado"
IndexTable$Pop[IndexTable$KEYS == "MZ_Q"] = 5110787 #         Zambezia Province Mozambique 
IndexTable$LOCALES[IndexTable$KEYS == "MZ_Q"] = "Zambezia" 
IndexTable$Pop[IndexTable$KEYS == "MZ_S"] = 2221803#                    Sofala Mozambique 
IndexTable$Pop[IndexTable$KEYS == "MZ_T"] = 2764169#             Tete Province Mozambique
IndexTable$LOCALES[IndexTable$KEYS == "MZ_T"] ="Tete"

#2015 census
IndexTable$Pop[IndexTable$KEYS == "AF_JOW"] = 540255 #   Jowzjan Afghanistan
IndexTable$LOCALES[IndexTable$KEYS == "AF_JOW"] = "Jawzjan"
IndexTable$Pop[IndexTable$KEYS == "AF_KAN"] = 1226593 #  Kandahar Afghanistan
IndexTable$Pop[IndexTable$KEYS == "AF_KHO"] = 574582 #    Khost Afghanistan 
IndexTable$Pop[IndexTable$KEYS == "AF_LOG"] = 392045 #     Logar Afghanistan  
IndexTable$Pop[IndexTable$KEYS == "AF_NAN"] = 1517388 # Nangarhar Afghanistan 
IndexTable$Pop[IndexTable$KEYS == "AF_PAN"] = 371902 # Panjshir Afghanistan
IndexTable$LOCALES[IndexTable$KEYS == "AF_PAN"] = "Panjsher"
IndexTable$Pop[IndexTable$KEYS == "AF_SAM"] = 387928 #  Samangan Afghanistan 
IndexTable$Pop[IndexTable$KEYS == "AF_TAK"] = 983336 #    Takhar Afghanistan 
IndexTable$Pop[IndexTable$KEYS == "AF_URU"] = 386818 #  Urozgan Afghanistan 
IndexTable$LOCALES[IndexTable$KEYS == "AF_URU"] = "Uruzgan"
IndexTable$Pop[IndexTable$KEYS == "AF_ZAB"] = 304126 #     Zabul Afghanistan


IndexTable$LOCALES[IndexTable$KEYS == "AF_WAR"] = "Maydan Wardak" 
IndexTable$LOCALES[IndexTable$KEYS == "AF_HEL"] = "Hilmand"
IndexTable$LOCALES[IndexTable$KEYS == "AF_HER"] = "Hirat"
IndexTable$LOCALES[IndexTable$KEYS == "AF_NIM"] = "Nimroz"
IndexTable$LOCALES[IndexTable$KEYS == "AF_SAR"] = "Sari Pul"
IndexTable$LOCALES[IndexTable$KEYS == "AF_PIA"] = "Paktya"



IndexTable$pInf = IndexTable$CaseDiff/IndexTable$Pop
IndexTable$MATCH = paste(IndexTable$LOCALES,IndexTable$Country, sep=", ")

# geomArgentina = st_read("https://github.com/deldersveld/topojson/raw/master/countries/argentina/argentina-provinces.json")
 geomArgentina = st_read("countries/data/geom/geomArgentina.geojson")
 geomArgentina$micro_name[which(geomArgentina$micro_name=="Buenos Aires")] = "Buenos Aires Province"
 geomArgentina$micro_name[which(geomArgentina$micro_name=="Ciudad de Buenos Aires")] = "City of Buenos Aires"
 geomArgentina$RegionName = paste(geomArgentina$micro_name,geomArgentina$country_name, sep=", ")

 
# geomColombia = st_read("https://www.acolgen.org.co/wp-content/uploads/geo-json/colombia.geo.json")
 geomColombia = st_read("countries/data/geom/geomColombia.geojson")# %>% select(c(NAME = NOMBRE_DPT,geometry))
 geomColombia$micro_name = str_to_title(geomColombia$micro_name)
 geomColombia$micro_name[2] = LOCALES[26]
 geomColombia$micro_name[3] = LOCALES[27]
 geomColombia$micro_name[4] = LOCALES[28]
 geomColombia$micro_name[5] = LOCALES[29]
 geomColombia$micro_name[7] = LOCALES[31]
 geomColombia$micro_name[10] = LOCALES[34]
 geomColombia$micro_name[12] = LOCALES[36]
 geomColombia$micro_name[18] = LOCALES[42]
 geomColombia$micro_name[19] = LOCALES[43]
 geomColombia$micro_name[29] = LOCALES[54]
 geomColombia$micro_name[31] = LOCALES[56]
 geomColombia$micro_name[33] = LOCALES[52]
 geomColombia$RegionName = paste(geomColombia$micro_name, geomColombia$country_name, sep=", ")
 
  
# geomAfghanistan = st_read("https://gist.github.com/notacouch/246dcbb684571b8dff41fc3ed325972f/raw/5e1f3c66b4213fb0424743cd1eb036e1c8c7fb23/afghanistan_provinces_geometry--cities-demo.json")
 geomAfghanistan = st_read("countries/data/geom/geomAfghanistan.geojson")#%>% select(c(NAME = name,geometry))
 geomAfghanistan$RegionName = paste(geomAfghanistan$micro_name,geomAfghanistan$country_name, sep = ", ")
 
 #geomBangladesh = st_read("https://github.com/mapmeld/mro-map/raw/master/bangladesh-divisions.geojson")
 
# geomMozambique = st_read("https://geonode.ingc.gov.mz/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typename=geonode%3Amoz_adm1&outputFormat=json&srs=EPSG%3A4326&srsName=EPSG%3A4326")
 geomMozambique = st_read("countries/data/geom/geomMozambique.geojson")# %>% select(c(NAME = NAME_1,geometry))
 geomMozambique$RegionName =  paste(geomMozambique$micro_name,geomMozambique$country_name, sep = ", ")
 
geo = bind_rows(geomArgentina,geomColombia,geomAfghanistan,geomMozambique)

GoogleMap = inner_join(geo,IndexTable, by=c("RegionName" = "MATCH"))
# GoogleMap$RegionName = GoogleMap$MATCH

GOOGLE_DATA = subset(GoogleMap,select=c("DateReport","geoid","RegionName","Country","pInf","geometry"))

return(GOOGLE_DATA)
}
