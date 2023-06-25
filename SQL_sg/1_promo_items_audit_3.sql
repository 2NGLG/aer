TRUNCATE TABLE temp_item_audit;

with cte_min_price as (
     select item_id, min(web_price_rub_amt) as min_sku_price
     from aer_dwh_sg.dim_aer_itm_sku_ke
     where ds >= '20230304' and ds < '20230604' -- choose period to find minimal price in it
     group by item_id
)

,cte_pay2ascan as (
     select
          trd.item_id
         ,avg(actual_pay_2_ascan_day) avg_pay_2_ascan
         ,count(distinct trade_parent_order_id) ord_cnt
     from (
           select parent_order_id, item_id
           from aer_dwh_sg.dwd_ae_trd_ord_flow_di_l2l_v flow
           join
               (select seller_admin_seq
                from aer_dwh_sg.dim_ae_jv_slr_v
                where 1=1
                      and is_admin_seller = 'Y'
                      and business_type = 'Local'
                      and ds = '${bizdate}') slr
           on slr.seller_admin_seq = flow.seller_admin_seq
           where 1=1
                 and ds >= to_char(dateadd(to_date('${bizdate}','yyyymmdd'),-180,'dd'),'yyyymmd')
                 and end_reason = 'buyer_accept_goods'
                 and to_date(trade_end_time) >= to_date(dateadd(to_date('${bizdate}','yyyymmdd'),-180,'dd')) ) trd
     left join (
           select*
           from aer_pa_sg.adm_lgt_ord_wide_df
           where 1=1
                 and ds = max_pt('aer_pa_sg.adm_lgt_ord_wide_df') ) lgs
     where 1=1
           and cast(trd.parent_order_id as string) = cast(lgs.trade_parent_order_id as string)
     group by trd.item_id )



,cte_promo as (
     select
          row_number() over (partition by ds order by join_time) row_nmb
         ,prom_id
         ,seller_admin_seq
         ,join_time
         ,item_id
         ,item_price / 100 as itm_price
         ,discount / 100 as discount
         ,round ((item_price / 100),2) * (1 - discount/100) as promo_price
     from aer_dwh_sg.dwd_ae_prom_itm_atd_camp_df_v
     where 1=1
           and prom_id in (30000061408) -- сюда подтавляем номера входов
           and ds = '${bizdate}'--max_pt('ae_cdm.dwd_ae_prom_itm_atd_camp_df')
     order by join_time
)

INSERT INTO temp_item_audit
     select
           row_nmb,
           promo.seller_admin_seq,
           promo.prom_id,
           promo.join_time,
           promo.item_id,
           promo.itm_price,
           promo.discount,
           promo.promo_price,
           cte_pay2ascan.avg_pay_2_ascan,
           cte_min_price.min_sku_price,
           count(promo.item_id) over ( partition by prom_id) ttl_items
     from cte_promo promo

     left join cte_min_price
     on promo.item_id = cte_min_price.item_id

     left join cte_pay2ascan
     on promo.item_id = cte_pay2ascan.item_id

     where 1=1
           -- and avg_pay_2_ascan <= 3.5
           -- and promo_price <= min_sku_price
     -- and row_nmb >= 10000
     --order by row_nmb
;