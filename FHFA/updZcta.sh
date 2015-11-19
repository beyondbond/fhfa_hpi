#!/bin/sh -x
#
#- USAGE OF:
#- updZcta.sh.sh 
#-
#- need to ensure data is download from www.ofheo.gov site

for arg in "$@"
do
        eval "$arg"
done


dbDir=/apps/fafa/bbdb/
progDir=/apps/fafa/ppyUpd/hpihst/
dataDir=/apps/fafa/deals/EcoData/
cd $dataDir

#- get HPI data from OFHEO site
dbLst="county2cbsa hpi_ofheo_zcta zcta_cbsa_rel_10 zcta_county_rel_10"
dbLst="zcta_cbsa_rel_10 zcta_county_rel_10"

for dbTbl in  $dbLst 
do
	echo $dbTbl
#	tsql.sh -dsn BBSQL < ${dbDir}${dbTbl}.sql
#	unix2dos ${dbTbl}.txt
#	chmod 666 ${dbTbl}.txt
#	sed -e "s/_CsvName_/${dbTbl}.txt/" -e "s/_TableName_/${dbTbl}/" /apps/fafa/ppyUpd/hpihst/bulkCsv2.sql | tsql.sh -dsn BBSQL

done

#tsql.sh -dsn BBSQL < ${dbDir}hpi_state.sql
#tsql.sh -dsn BBSQL < ${dbDir}hpi_cbsa.sql
#tsql.sh -dsn BBSQL < ${dbDir}hpi_county.sql
#tsql.sh -dsn BBSQL < ${dbDir}hpi_zcta.sql
dbTbl=county2cbsa
tsql.sh -dsn BBSQL < ${dbDir}${dbTbl}.sql
sed -e "s/_CsvName_/${dbTbl}.txt/" -e "s/_TableName_/${dbTbl}/" /apps/fafa/ppyUpd/hpihst/bulkTab2.sql | tsql.sh -dsn BBSQL
