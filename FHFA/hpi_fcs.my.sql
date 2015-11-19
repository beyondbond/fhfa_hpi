USE HPI;
DELETE FROM hpi_ofheo_hist WHERE region_dsr='FORECAST';
LOAD DATA LOCAL INFILE 'csv/upd_hpi_fcs.tsv' INTO TABLE hpi_ofheo_hist
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 0 LINES;
DELETE FROM hpi_state;
INSERT INTO hpi_state 
(SELECT region_code,pb_date,hpi_index,hpa_yoy,hpa_qoq from hpi_ofheo_hist WHERE region_type='sts')
