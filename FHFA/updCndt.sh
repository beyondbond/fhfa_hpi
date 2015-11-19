#!/bin/sh
#
# USAGE OF:
#  updCndt.sh 
#
# need to ensure data is download from www.ofheo.gov site
# Note: for cbsa dataset in ofheo, 
#    download ${qqyy}hpi_cbsa.csv and open EXCEL and then save it as text format into ${qqyy}hpi_cbsa.txt

for arg in "$@"
do
      eval "$arg"
done

. /apps/fafa/cronJob/shell/SYBASE.sh
export LANG="en_US"

#cd /apps/fafa/deals/EcoData/

#- get Congressional District data from US Census of Bureau

urlName=http://www2.census.gov/geo/relfiles
wget $urlName/cd110th/natl_code/cou_cd110_natl.txt
wget $urlName/cd110th/natl_code/land_cd110_natl.txt
wget $urlName/cd110th/natl_code/zcta_cd110_natl.txt
wget $urlName/cd109th/fips_to_state_name.txt
wget $urlName/cd109th/fips_to_cou_name.txt
wget $urlName/cd109th/fips_to_plc_name.txt
wget $urlName/cd109th/sch_dist_code_to_name.txt

#gawk 'NR>2{print $0}' cou_cd110_natl.txt > cou_cndt_natl.bcp
#bcp cou_cndt_natl in /apps/fafa/deals/EcoData/cou_cndt_natl.bcp  -b 1000 -c -t, -Usfdbo -Psfdbo0 -SBBDB1 -e bcp.err

#gawk 'NR>2{print $0}' zcta_cd110_natl.txt > zcta_cndt_natl.bcp
#bcp zcta_cndt_natl in /apps/fafa/deals/EcoData/zcta_cndt_natl.bcp  -b 1000 -c -t, -Usfdbo -Psfdbo0 -SBBDB1 -e bcp.err

#bcp ym_200901 in /apps/fafa/egx/x  -b 1000 -c -t\\t -Usfdbo -Psfdbo0 -SBBDB1 -e bcp.err

