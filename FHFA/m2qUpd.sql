UPDATE Q
SET Q.hpa_yoy = M.hpa_yoy
FROM hpi_ofheo_hist AS Q
   INNER JOIN hpi_ofheo_monthly AS M
       ON Q.region_code=M.region_code
       AND Q.pb_date=M.pb_date
WHERE  Q.pb_date < 20130701
