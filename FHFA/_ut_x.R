#---------------------------------------#
#- _ut_x.R
#- General Utility Functions
#---------------------------------------#

#----- DECLARE FUNCTIONS
#- installPkg(): To install necessary plugin package
installPkg <- function(toInstall) {
        for (xlib in toInstall) {
                isInLib=xlib %in% rownames(installed.packages())
                if(isInLib==F){
                        install.packages(toInstall, repos="http://cran.rstudio.com/")
                }
        }
        lapply(toInstall, library, character.only=T)
}

#- dbConn(): Connect DB
dbConn <- function(dbname) {
	mydb = dbConnect(MySQL(), user='sfdbo', password='sfdbo0', host='localhost', dbname)
	return(mydb)
}
