
SELECT  ds
        ,COUNT(DISTINCT seller_admin_seq) unique_slr
        ,COUNT(DISTINCT item_id) unique_items
FROM    aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
WHERE   prom_id IN ('30000044657') -- promotion ids
AND     status IN ('approved')
AND     ds = ( -- latest date
            SELECT  MAX(ds)
            FROM    aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
        )
GROUP BY ds
