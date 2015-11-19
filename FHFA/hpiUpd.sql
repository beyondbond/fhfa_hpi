insert into HPI.dbo.hpi_zcta
select distinct Y.zip_code as 'region_code', '20130331' as 'pb_date',0,0,0
from  SPGBulkData.dbo.zip_cbsa Y
GO
insert into HPI.dbo.hpi_county
select distinct Y.fips_county, '20130331' as 'pb_date',0,0,0
from  HPI.dbo.county2cbsa Y
GO
insert into HPI.dbo.hpi_cbsa
select distinct Y.fips_cbsa, '20130331',0,0,0
from  HPI.dbo.county2cbsa Y 
where len(Y.fips_cbsa)>1
GO
insert into HPI.dbo.hpi_state
select distinct Y.fips_state, '20130331' as 'pb_date',0,0,0
from  HPI.dbo.county2cbsa Y
GO
update z
set z.pb_date=x.pb_date,
z.hpi_index=x.hpi_index,
z.hpi_yoy=x.hpa_yoy,
z.hpi_qoq=x.hpa_qoq
from 
sfdb.dbo.hpi_ofheo_hist x,HPI.dbo.fips_state y,HPI.dbo.hpi_state z
where x.region_type='sts'
and x.region_code=y.state_ab
and x.pb_date='20130331'
and y.fips_state=z.region_code
GO
update z
set z.pb_date=x.pb_date,
z.hpi_index=x.hpi_index,
z.hpi_yoy=x.hpa_yoy,
z.hpi_qoq=x.hpa_qoq
from 
sfdb.dbo.hpi_ofheo_hist x,HPI.dbo.hpi_cbsa z
where x.region_type='cbsa'
and x.pb_date='20130331'
and x.region_code=z.region_code
GO

