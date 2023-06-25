SELECT  ds
        ,prom_id
        ,prom_name
        ,COUNT(DISTINCT item_id) itm_cnt
        ,COUNT(DISTINCT seller_admin_seq) slr_cnt
FROM    aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v promo
WHERE   promo.ds = (
            SELECT  MAX(ds)
            FROM    aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
        )
AND     prom_id IN ('30000046974') -- promotion ids
--AND     status IN ('approved') -- if choose only approved
GROUP BY promo.ds
         ,prom_id
         ,prom_name
;