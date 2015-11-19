USE HPI;
DELETE FROM hpi_ofheo_monthly;
LOAD DATA LOCAL INFILE 'csv/hpi_ofheo_monthly.tsv' INTO TABLE hpi_ofheo_monthly
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 0 LINES;
DELETE FROM hpi_state_monthly;
INSERT INTO hpi_state_monthly 
(SELECT round(pb_date/100,0),region_code,round(hpi_index,2),round(hpa_yoy,2) from hpi_ofheo_monthly WHERE region_type='sts')
