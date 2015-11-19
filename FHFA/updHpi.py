#!/usr/bin/env python
#
#- USAGE OF:


#import pymysql
import numpy
import MySQLdb as pymysql
import subprocess
import os,pwd
import json
import cgi,cgitb
import csv
import StringIO

# INPUT PARAMETERS
urlPath="http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/"
hpiList=[
	("HPI_AT_us_and_census.csv","hpi_reg.csv" ,"hpi_reg_raw"),
	("HPI_AT_state.csv" ,"hpi_sts.csv" ,"hpi_sts_raw"),
	("HPI_AT_metro.csv" ,"hpi_cbsa.csv","hpi_cbsa_raw")]
mydb = pymysql.connect(
	host='localhost', 
	port=3306, 
	user='sfdbo', 
	passwd='sfdbo0', 
	db='HPI')

def _getHPI(fpi,fpo):
	subprocess.call(["wget", fpi,"-O",fpo])

def _cvs2db(fp,tb,sep=','):
	#csv.DictReader(fp, delimiter=sep)    
	csv_data = csv.reader(fp, delimiter=sep)

def _readf(fp,t='r'):
	f = open(fp, t)
	c = f.read()
	return c

# repls=[['hello', 'goodbye'], ['world', 'earth']]
# s='hello, world'
# 'bye, earth'
def _multi_replace(s,repls):
	return reduce(lambda a, kv: a.replace(*kv), repls, s)
	



#- update quarterly HPI data
#- update for ZXY script: x_hpiGrp.egx
#/apps/fafa/bin/zxy x_hpiGrp.egx 'fname="upd_hpi_reg.txt";'
#/apps/fafa/bin/zxy x_hpiGrp.egx 'fname="upd_hpi_sts.txt";'
#/apps/fafa/bin/zxy x_hpiGrp.egx 'fname="upd_hpi_cbsa.txt";'

#- update quarterly HPI forecasts: x_hpiStudy.egx,updHpiFcs.egx
#sed -e "s/_CsvName_/upd_hpi_fcs.bcp/" -e "s/_TableName_/hpi_ofheo_hist/" ${binDir}/bulkMyTmp.sql | tsql.sh -dsn ${dbHost}

#- update monthly HPI data history and forecasts
#zxy updHpiOfheoMonthly.egx
#bcp hpi_ofheo_monthly in hpi_ofheo_monthly.bcp  -b 1000 -c -t, -Usfdbo -Psfdbo0 -SBBDB1 -e bcp.err

#isql.rsh -dsn BBSQL < /apps/fafa/bbdb/hpi_ofheo_monthly.sql
#tsql.sh -dsn bbub1 < hpi_ofheo_monthly.mySql.sql

#- update quarterly HPA history 
#tsql.sh -dsn BBSQL < m2qUpd.sql
#tsql.sh -dsn BBSQL < BmQ.sql >  /apps/fafa/ppyUpd/hpihst/BmQuarterly.ecd
#tsql.sh -dsn BBSQL < BmM.sql >  /apps/fafa/ppyUpd/hpihst/BmMonthly.ecd




#- Load FHFA HPI (quarterly) to update HPI into DB
#sed -e "s/_CsvName_/hpi_cbsa.csv/" -e "s/_TableName_/hpi_ofheo_cbsa/" /apps/fafa/ppyUpd/hpihst/bulkCsv.sql | tsql.sh -dsn BBSQL

#- Load HPI (quarterly) from FHFA and saved in DB
def load_HPI(rtn):
	for (fpi,fpo,tbl) in hpiList:
		_getHPI(urlPath+fpi,fpo)
		s=_readf("bulkMyTmp.sql") #- bulkLoad Template
		repls=[("_CsvName_",fpo),("_TableName_",tbl)]
		qry=_multi_replace(s,repls)
		print qry
		#curr = mydb.cursor()
		#curr.execute(qry)
		#mydb.commit()
		p = subprocess.Popen("tsql.sh", shell=True, bufsize=1024,
	                stdin=subprocess.PIPE, stderr=None)
		p.stdin.write(qry)
		p.stdin.flush()


def _getDBArray(qry,mydb):
	curr = mydb.cursor()
	curr.execute(qry)
	results=curr.fetchall()
	print results
	cols = zip( *results ) # return a list of each column
			      # ( the * unpacks the 1st level of the tuple )
	outlist = []
	for col in cols:
		arr = numpy.asarray( col )
		type = arr.dtype
		if str(type)[0:2] == '|S':
			# it's a string array!
			outlist.append( arr )
		else:
			outlist.append( numpy.asarray(arr, numpy.float32) ) 
	return outlist

#- Calculate HPI & HPA (quarterly YoY & QoQ) and saved in DB
#- using ZXY script: x_hpiGrp.egx
def calc_HPI(rtn):
	return rtn

#- Regress HPI (quarterly) and saved coeficients in DB
#- using  x_hpiStudy.egx,updHpiFcs.egx
def rgrs_HPI(rtn):
	rtn=1
	return rtn

#- Forecast HPI (quarterly) HPI & HPA and saved in DB
#- using  x_hpiStudy.egx,updHpiFcs.egx
def fcst_HPI(rtn):
	return rtn

#- Interpolate HPI from Quarterly to Monthly for history and forecasts
def intp_HPI(rtn):
	return rtn

if __name__ == "__main__":
	load_HPI(1)
#	qry='select * from hpi_sts_raw limit 10'
#	outp=_getDBArray(qry,mydb)
#	print(outp)
	

#curr = mydb.cursor(pymysql.cursors.DictCursor)
#print curr.description
#print json.dumps(cur.fetchall())
quit()
#close the connection to the database.
mydb.close()
