#---------------------------------------------------#
#- hpiCsv.R
#- REGRESS & FORECAST HPIs
#- Save the parameter sets to hpiParam
#- Save HPI forecasts to hpi_ofheo_hist
#- Last modified: Ted, Fri Jul 31 09:53:11 EDT 2015
#---------------------------------------------------#

#----- DECLARE FUNCTIONS

getHpiRegions <- function(xdb) {
	query <- "SELECT region_type as rtype,region_code as rcode FROM hpi_ofheo_hist 
		GROUP BY region_type,region_code
		ORDER BY region_type,region_code ASC"
	rst <- dbGetQuery(mydb, query)
	return(rst)
}

getHpiByRegion <- function(xdb,rtype,rcode) {
	query <- paste(
		"SELECT pb_date as YYYYMMDD,hpi_index as HPI FROM hpi_ofheo_hist",
		" WHERE region_type='",rtype,"'", 
		" AND region_code='",rcode,"'",
		sep="")
	rst <- dbGetQuery(mydb, query)
	return(rst)
}

#----- MAIN PROGRAM
#--- Load Utility functions, load necessary packages & connect database
if(!exists("installPkg", mode = "function")) source("_ut_x.R")
installPkg(c("RMySQL"))
mydb <- dbConn("HPI")

#--- Run Regression at USA level
# Get data from database table: hpi_gdp
rgnD <- getHpiRegions(mydb)
#for ( j in 1:length(rgnD$rtype) )
for(xtyp in unique(rgnD$rtype) ) {
  hpiM={}
  for(j in which(rgnD$rtype %in% xtyp)) {
	xcod=toString(rgnD$rcode[j])
	hpiD <- getHpiByRegion(mydb,xtyp,xcod)
	if(!length(hpiM)) hpiM$YYYYMMDD=hpiD$YYYYMMDD
	colnames(hpiD)[2]=xcod
	hpiM=cbind(hpiM,hpiD[xcod])
  }
  if(xtyp=="CN") xtyp="reg"
  fp=sprintf("%s_%s.%s","csv/upd_hpi",xtyp,"txt.csv")
  write.csv(hpiM,file=fp,row.names=F)
# write.csv(hpiD,file=fp,row.names=F)
}

#- Disconnect DB
dbDisconnect(mydb)
