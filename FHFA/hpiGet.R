#- INPUT Initialization 
#- Get HPI raw data from FHFA website
#- Save HPI raw data to DB
#-------------------------------------
library(RMySQL)
urlPath="http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/"
hpiNames=c("HPI_AT_us_and_census.csv","HPI_AT_state.csv","HPI_AT_metro.csv")
dstTbls=c('hpi_reg_raw', 'hpi_sts_raw', 'hpi_cbsa_raw')
colNames<-list(
	c('name','y4','q1','hpi'),
	c('name','y4','q1','hpi'),
	c('name','code','y4','q1','hpi','hpa')
)

#- To load HPI raw data from FHFA website
load_hpi <- function(fpName,colName) {
	print(fpName)
	print(colName)
	data <- read.csv(fpName,header=F)
	colnames(data) <- colName
	return(data)
}

save_hpi2DB <- function(dbdata,dstTbl,dbConn) {
	query <- paste('DELETE FROM',dstTbl)
	rst <- dbGetQuery(mydb, query)
	if(is.element('code',colnames(dbdata)))
		as.character(dbdata$code)
	dbWriteTable(dbConn, dstTbl, dbdata, row.names=F, append=T,overwrite=F)
}

#----------------------------------
#- Main Program
#----------------------------------

mydb = dbConnect(MySQL(), user='sfdbo', password='sfdbo0', host='localhost', dbname="HPI")


data_hpi={}
for(j in 1:3) {
	fpN=paste(urlPath,hpiNames[j],sep="")
	data_hpi[[j]]=load_hpi(fpN,colNames[[j]])  #- Get web data
	save_hpi2DB(data_hpi[[j]],dstTbls[j],mydb) #- Insert data to DB
}
dbDisconnect(mydb)
