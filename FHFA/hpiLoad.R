#---------------------------------------#
#- hpiLoad.R
#- Convert raw HPIs fron *_raw tables to time series data 
#- Save HPIs to hpi_ofheo_hist
#
#-  Note: *_raw refers to hpi_reg_raw,hpi_sts_raw,hpi_cbsa_raw
#---------------------------------------#

#----- DECLARE FUNCTIONS
#- raw2cbsaX(): To convert data from raw HPIs to HPAs with End-of-Quarter yyyymmdd date by REGION/STATE  
raw2stsX <- function(rdata,rtype,dstTbl) {
	dbdata=NULL
	dbdata<-rdata
	y=ts(as.vector(rdata$hpi))
	xlen=length(y)
	xdt=paste(rdata$y4[1],3*rdata$q1[1],1,sep="-")
	xd=seq(as.Date(xdt), length=2, by="month")[2]
	vd=seq(as.Date(xd), length=xlen, by="3 month") -1
	pbDate=as.character(as.Date(vd, "%Y-%m-%d"), "%Y%m%d") 

	dbdata$region_type= rtype
	dbdata$region_code= rdata$name
	dbdata$pb_year= rdata$y4
	dbdata$pb_quar= rdata$q1
	dbdata$pb_date= pbDate
	dbdata$hpi_index= rdata$hpi
	dbdata$hpa_yoy[5:xlen]= round(diff(y,lag=4)/lag(y,-4)*100,digits=4)
	dbdata$hpa_qoq[2:xlen]= round(diff(y,lag=1)/lag(y,-1)*100,digits=4)
	dbdata$hpa_yoy[1:4]= vector('numeric',4)
	dbdata$hpa_qoq[1]= vector('numeric',1)
	dbdata$region_dsr= ''
	dbdata$name = dbdata$hpi = dbdata$y4 =dbdata$q1 = NULL
	dbWriteTable(mydb, dstTbl, dbdata, row.names=F, append=T,overwrite=F)
}

#- raw2cbsaX(): To convert data from raw HPIs to HPAs with End-of-Quarter yyyymmdd date by CBSA  
raw2cbsaX <- function(rdata,rtype,dstTbl) {
	as.character(rdata$code)
	dbdata<-rdata
	y=ts(as.vector(rdata$hpi))
	xlen=length(y)
	xdt=paste(rdata$y4[1],3*rdata$q1[1],1,sep="-")
	xd=seq(as.Date(xdt), length=2, by="month")[2]
	vd=seq(as.Date(xd), length=xlen, by="3 month") -1
	pbDate=as.character(as.Date(vd, "%Y-%m-%d"), "%Y%m%d") 

	dbdata$region_type= rtype
	dbdata$region_code= rdata$code
	dbdata$pb_year= rdata$y4
	dbdata$pb_quar= rdata$q1
	dbdata$pb_date= pbDate
	dbdata$hpi_index= rdata$hpi
	dbdata$hpa_yoy[5:xlen]= round(diff(y,lag=4)/lag(y,-4)*100,digits=4)
	dbdata$hpa_qoq[2:xlen]= round(diff(y,lag=1)/lag(y,-1)*100,digits=4)
	dbdata$hpa_yoy[1:4]= vector('numeric',4)
	dbdata$hpa_qoq[1]= vector('numeric',1)
	dbdata$region_dsr= ''
	dbdata$hpa = dbdata$code = dbdata$name = dbdata$hpi = dbdata$y4 =dbdata$q1 = NULL
	dbWriteTable(mydb, dstTbl, dbdata, row.names=F, append=T,overwrite=F)
}

#- raw2stsBat(): To batch loop the raw2stsX() by STATE/REGION abbrviation
raw2stsBat <- function(srcTbl,rtype,dstTbl) {
	tdata=NULL
	tdata <- dbReadTable(mydb, srcTbl)
	tdata.Levels <- levels(factor(tdata$name))
	for (xt in tdata.Levels) {
		raw2stsX(tdata[which(tdata$name==xt),],rtype,dstTbl)
	}
}

#- raw2cbsaBat(): To batch loop the raw2cbsaX() by CBSA code
raw2cbsaBat <- function(srcTbl,rtype,dstTbl) {
	tdata=NULL
	tdata <- dbReadTable(mydb, srcTbl)
	tdata.Levels <- levels(factor(tdata$code))
	for (xt in tdata.Levels) {
		raw2cbsaX(tdata[which(tdata$code==xt),],rtype,dstTbl)
	}
}

#----- MAIN PROGRAM

library(RMySQL) 

#- Connect DB
mydb = dbConnect(MySQL(), user='sfdbo', password='sfdbo0', host='localhost', dbname="HPI")

#- Delete & renew 'hpi_ofheo_hist' table from *_raw tables
dstTbl='hpi_ofheo_hist'
query <- paste('DELETE FROM',dstTbl)
rst <- dbGetQuery(mydb, query)
raw2stsBat('hpi_reg_raw','CN',dstTbl)
raw2stsBat('hpi_sts_raw','sts',dstTbl)
raw2cbsaBat('hpi_cbsa_raw','cbsa',dstTbl)

#- Disconnect DB
dbDisconnect(mydb)
