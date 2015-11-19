select pb_date as 'bmqDate',cast(hpi_index as DECIMAL(10,2)) as 'hpi', cast(hpa_yoy as DECIMAL(10,5)) as 'hpa_y'
from hpi_ofheo_hist
where
region_type= 'CN' and
region_code='USA' and
pb_date>19800101 and
pb_date<20130601 
order by pb_date
GO
