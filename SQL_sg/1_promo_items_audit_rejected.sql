TRUNCATE TABLE temp_item_audit;

WITH min_price AS
(
    SELECT  item_id
            ,MIN(web_price_rub_amt) AS min_sku_price
    FROM    aer_dwh_sg.dim_aer_itm_sku_ke
    WHERE   (
                ds >= TO_CHAR(DATEADD(TO_DATE('${bizdate}','yyyymmdd'),-29,'dd'),'yyyymmdd')
    ) -- choose period to find minimal price in it
    GROUP BY item_id
)
,pay2ascan AS
(
    SELECT  trd.item_id
            ,round(AVG(actual_pay_2_ascan_day),1) avg_pay_2_ascan
            ,COUNT(DISTINCT trade_parent_order_id) ord_cnt
    FROM    (
                SELECT  mord_id
                        ,item_id
                FROM    aer_bi_sg.adm_trade_df
                WHERE   event_type = 'complete'
                AND     end_reason = 'buyer_accept_goods'
                AND     business_segment = 'Local'
                AND     ds = MAX_PT('aer_bi_sg.adm_trade_df')
            ) trd
    LEFT JOIN aer_bi_sg.adm_lgt_ord_wide_df lgs
    ON      trd.mord_id = lgs.trade_parent_order_id
    AND     lgs.ds = MAX_PT('aer_pa_sg.adm_lgt_ord_wide_df')
    GROUP BY trd.item_id
)
,promo AS
(
    SELECT  ROW_NUMBER() OVER (PARTITION BY ds ORDER BY join_time ) row_nmb
            ,prom_id
            ,seller_admin_seq
            ,join_time
            ,item_id
            ,item_price / 100 AS itm_price
            ,discount / 100 AS discount
            ,round((item_price / 100),2) * (
                        1 - discount / 100
            ) AS promo_price
    FROM    aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
    WHERE   1 = 1
    AND     prom_id IN (${prom_id}) -- сюда подтавляем номера входов
    AND     ds = MAX_PT('ae_cdm.dwd_ae_prom_itm_atd_camp_df')
    ORDER BY join_time
)

INSERT INTO temp_item_audit
SELECT  row_nmb,
        promo.seller_admin_seq,
        promo.prom_id,
        promo.join_time,
        promo.item_id,
        promo.itm_price,
        promo.discount,
        promo.promo_price,
        pay2ascan.avg_pay_2_ascan,
        min_price.min_sku_price,
        count(promo.item_id) over (PARTITION by prom_id) ttl_items
FROM    promo
LEFT JOIN min_price
ON      promo.item_id = min_price.item_id
LEFT JOIN pay2ascan
ON      promo.item_id = pay2ascan.item_id
WHERE   1 = 1
-- AND seller_admin_seq in (1057634576, 1037590031)
-- AND     (avg_pay_2_ascan <= 3.5 or avg_pay_2_ascan is null)
-- AND     promo_price <= (min_sku_price)*(1-${percent})
-- OR promo.seller_admin_seq in ('4130635272') -- вайтлистим shopotam
-- OR promo.seller_admin_seq in ('848667346') -- вайтлистим 1P
-- and row_nmb >= 10000
ORDER BY row_nmb
;