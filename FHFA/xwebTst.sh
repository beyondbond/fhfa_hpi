#!/bin/sh

checkUpdFlg() {
	if [ -s "$2" ] ; then
		echo $2 is good 
	else
		echo Error 
		return 2
	fi
	echo $@,$#,$1,$2
}

checkUpdFlg http://www.fhfa.gov/DataTools/Downloads/Documents/HPI/HPI_AT_us_and_census hpi_reg.tmp
