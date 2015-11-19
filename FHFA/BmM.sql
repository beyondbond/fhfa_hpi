select pb_date as 'vMdate',cast(hpi_index as DECIMAL(10,2)) as 'vMhpi', cast(hpa_yoy as DECIMAL(10,5)) as 'vMhpa'
from hpi_ofheo_monthly
where
region_type= 'CN' and
region_code='USA' and 
pb_date>19800101 and
pb_date<20130601 
order by pb_date
GO
