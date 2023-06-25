--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2022-11-24 17:24:47
--********************************************************************--
TRUNCATE TABLE temp_item_audit;

with min_price as(
            SELECT  item_id,
                    min(web_price_rub_amt) AS min_sku_price
            FROM    aer_dwh_sg.dim_aer_itm_sku_ke
            WHERE   (ds >= '20230204' and ds < '20230306') -- choose period to find minimal price in it
            GROUP BY item_id
)

,pay2ascan AS (     SELECT  trd.item_id
        ,AVG(actual_pay_2_ascan_day) avg_pay_2_ascan
        ,COUNT(DISTINCT trade_parent_order_id) ord_cnt
FROM    (
            SELECT  mord_id
                    ,item_id
            FROM    aer_bi_sg.adm_trade_v
            WHERE   event_type = 'complete'
            AND     end_reason = 'buyer_accept_goods'
            AND     business_segment = 'Local'
        ) trd
LEFT JOIN aer_bi_sg.adm_lgt_ord_wide_df lgs
ON      CAST(trd.mord_id AS STRING) = CAST(lgs.trade_parent_order_id AS STRING)
AND     lgs.ds = MAX_PT('aer_pa_sg.adm_lgt_ord_wide_df')
GROUP BY trd.item_id)

,promo as (
    select
        row_number() over (partition by ds order by join_time) row_nmb,
        prom_id,
        seller_admin_seq,
        join_time,
        item_id,
        item_price / 100 as itm_price,
        discount / 100 as discount,
        round ((item_price / 100),2) * (1 - discount/100) as promo_price
    from aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
    where 1=1
    and prom_id in ('30000053427') -- сюда подтавляем номера входов
    and ds = max_pt('ae_cdm.dwd_ae_prom_itm_atd_camp_df')
    -- and seller_admin_seq not in ('950049511')
    order by join_time
)

INSERT INTO temp_item_audit
select  row_nmb,
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
from promo
left join min_price on promo.item_id = min_price.item_id
left join pay2ascan on promo.item_id = pay2ascan.item_id
where 1=1
and avg_pay_2_ascan <= 3.5
AND     promo_price <= (min_sku_price)*(1-0.06)
-- and row_nmb >= 10000
order by row_nmb
;