#- INPUT Initialization
#- Get GDP raw data from FHFA website
#- Save GDP raw data to hpi_gdp in HPI
#-------------------------------------
library(curl)
library(RMySQL)

LDF=c("A939RX0Q048SBEA","GDP","USSTHPI")
LDX=c("GDPPC","GDP","HPI")
#LDF=c("A939RX0Q048SBEA","GDP")
#LDX=c("GDPPC","GDP")
for (i in 1:length(LDF)) {
	x=LDF[i]
	y=LDX[i]
	fp=paste("https://research.stlouisfed.org/fred2/series/",x,"/downloaddata/",x,".csv",sep="")
	datax=read.csv(curl(fp),header=T)
	colnames(datax)[2] <- y
	if(i==1) {
		hpiGDP=datax
	} else {
		hpiGDP <- merge(datax,hpiGDP,by="DATE")
	}
}

#- Using Start-of-Quarter as date
# dYmd=gsub("-","",hpiGDP$DATE)

#- Using End-of-Quarter instead of Start-of-Quarter as date
eYmd=seq(as.Date(hpiGDP$DATE[2],"%Y-%m-%d"),length=length(hpiGDP$DATE),by="3 month")-1
dYmd=as.integer(gsub("-","",as.character(eYmd)))

hpiGDP$GDPPC <- as.double(hpiGDP$GDPPC)
hpiGDP$DATE <- dYmd
colnames(hpiGDP)[1] <- "PB_DATE"
mydb = dbConnect(MySQL(), user='sfdbo', password='sfdbo0', host='localhost', dbname="HPI")
dbWriteTable(mydb, "hpi_gdp", hpiGDP, row.names=F, append=F,overwrite=T)

