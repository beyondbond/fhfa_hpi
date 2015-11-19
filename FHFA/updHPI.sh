#!/bin/sh
#
#- USAGE OF:
#- /apps/fafa/webDir/pubWebData/FHFA/updHPI.sh 
#- Ensure data from 
#-   http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/
#- are available.
#- Last modified
#- Ted, Mon Aug  3 10:23:55 EDT 2015
#-------------------------------------------------------------

prog=`basename ${0}`
binDir=/apps/fafa/webDir/pubWebData/FHFA
curDir=`pwd`

for arg in "$@"
do
        eval "$arg"
done
rtURI="http://www.fhfa.gov/DataTools/Downloads/Documents/HPI"
dbHost=${dbHost:=bbub1}
datDir=${datDir:=csv}
datDir=$binDir/$datDir
runDate=`date +'%Y%m%d'`

# $1,2,3:url,tmp,local files 
checkUpdFlg() {
	echo "wget $1 -O $2 ..." 2>&1
	wget -N $1 
	# wget $1 -O $2 
        if [ -s "$2" ] ; then
		if [ ! -f $3 ]; then
			echo "===> Start HPIs, continue $prog ..." 1>&2
		elif ! cmp $2 $3 >/dev/null 2>&1
		then
			echo "===> Renew HPIs, continue $prog ..." 1>&2
		else
  			echo "===> Error: No new HPIs, abort $prog ..." 1>&2
			# rm -f $2
                	exit 1
                fi
        else
  		echo "===> Error: URL not exists, abort $prog ..." 1>&2
                exit 1
        fi
	# wget $rtURI/HPI_AT_state.csv -O ${datDir}/hpi_sts.csv
	# wget $rtURI/HPI_AT_metro.csv -O ${datDir}/hpi_cbsa.csv
  	cp -p $2 $3
	return 0
}

cd $binDir
echo "===> Current Working Dir: [$binDir]" 1>&2
echo "0. Check if FHFA: ${rtURI} releases new HPIs?" 1>&2
checkUpdFlg $rtURI/HPI_AT_us_and_census.csv HPI_AT_us_and_census.csv ${datDir}/hpi_reg.csv

#- 1. GET HPI from FHFA site
echo "1. GET HPI from FHFA site" 1>&2
echo "   AND" 1>&2

#- 2. LOAD HPIs into database
echo "2. LOAD HPIs into database HPI" 1>&2
/usr/bin/R -f gdpGet.R
/usr/bin/R -f hpiGet.R
/usr/bin/R -f hpiLoad.R

#- 3. REGRESS & FORECAST HPIs  
echo "3. REGRESS & FORECAST HPIs" 1>&2
# RegrR code not finished, using updHpiFcs.egx instead
# /usr/bin/R -f hpiRegr.R
#- update quarterly HPI forecasts: x_hpiStudy.egx,updHpiFcs.egx
echo "3a. Create HPIs files:[upd_hpi_???.txt.csv] for regression use" 1>&2
/usr/bin/R -f hpiCsv.R
echo "3b. Modeling HPIs & create forecasts to file:[upd_hpi_fcs.tsv] " 1>&2
/apps/fafa/bin/zxy updHpiFcs.egx > ${datDir}/upd_hpi_fcs.tsv
echo "3c. Save HPI forecasts into to table:[hpiOfheoHist] " 1>&2
tsql.sh -dsn ${dbHost} < hpi_fcs.my.sql

#- 4. UPDATE Monthly HPIs & FORECASTs
echo "4. UPDATE Monthly HPIs & FORECASTs" 1>&2
echo "4a. Create monthly forecasts to file:[hpi_ofheo_monthly.tsv] " 1>&2
zxy updHpiOfheoMonthly.egx
echo "4b. Save HPI monthly forecasts into to table:[hpiOfheoMonthly] " 1>&2
tsql.sh -dsn ${dbHost} < hpi_ofheo_monthly.my.sql
