--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2022-11-24 15:26:50
--********************************************************************--
with c_pord as(  -- считаем количество заказов, завершенных из-за отмены покупателями за 30 дн
    select seller_admin_id, count (distinct mord_id) c_pord
    from aer_bi_sg.adm_trade_v
    where ds = to_char(DATEADD(getdate(),-2,'dd'),'yyyymmdd')
    and event_type = 'complete'
    and event_time_msc >= DATEADD(getdate(),-32,'dd')
    and end_reason in ('cancel_order_close_trade')
    group by seller_admin_id
),

paid_pord as( -- считаем общее количество завершенных заказов за 30 дн
    select seller_admin_id
    , count (distinct mord_id) complete_pord
    , round (sum(item_commission_amount_rub)
            + sum(marketing_commission_amount_rub)
            + sum (logistics_commission_amount_rub),2) commission_30d
    , round (avg(gmv_accounting_rub),2) aov_30d
    from aer_bi_sg.adm_trade_v
    where ds = to_char(DATEADD(getdate(),-2,'dd'),'yyyymmdd')
    and event_type = 'complete'
    and event_time_msc >= DATEADD(getdate(),-32,'dd')
    group by seller_admin_id
),

itm_sales as (
    select
        seller_admin_id
        , count (item_id) itm_with_30d_sales
    from (
        select
            seller_admin_id
            , item_id
            , count (distinct mord_id) complete_pord
        from aer_bi_sg.adm_trade_v
        where ds = to_char(DATEADD(getdate(),-2,'dd'),'yyyymmdd')
        and event_type = 'complete'
        and event_time_msc >= DATEADD(getdate(),-32,'dd')
        group by seller_admin_id, item_id
    )
    where complete_pord >= 1
    group by seller_admin_id
)


select
    slr.seller_admin_id
    , slr.seller_admin_seq
    , slr.business_model
    , all_finished_pord
    , slr.trd_pay_pord_30d
    , itm_sales.itm_with_30d_sales
    , round(slr.avg_desc_eval_180d,2) avg_desc_eval_180d
    , round(slr.avg_service_eval_180d,2) avg_service_eval_180d
    , round(slr.avg_shipping_eval_180d,2) avg_shipping_eval_180d
    , round (slr.rating_avg_180d, 2) rating_180d
    , round (c_pord.c_pord / paid_pord.complete_pord, 2) cancel_rate
    , round ((slr.cnt_ord_ns_90d / slr.cnt_ord_s_and_ns_90d),2) ns_rate_90d
    , slr.in_stock_itm_cnt
    , slr.is_local_manually_blocked

FROM aer_bi_sg.adm_sellers slr

left join (
    select seller_admin_id, legal_company_type
    from aer_bi_sg.adm_local_sellers_registration
    where ds = MAX_PT('aer_bi_sg.adm_local_sellers_registration')
) rr on rr.seller_admin_id = slr.seller_admin_id

left join c_pord on c_pord.seller_admin_id = slr.seller_admin_id
left join paid_pord on paid_pord.seller_admin_id = slr.seller_admin_id
left join itm_sales on itm_sales.seller_admin_id = slr.seller_admin_id

where     ( -- отбираем хороших FBS
        slr.ds = MAX_PT('aer_bi_sg.adm_sellers')
        and business_model in ('AE MKTP','TMALL MKTP','TMALL 1P')
        and (round((c_pord.c_pord / paid_pord.complete_pord),2) <= 0.08
            or (c_pord.c_pord / paid_pord.complete_pord) is null) -- cancel rate ≤ 8%
        and slr.avg_desc_eval_180d >= 4.5 -- store avg dsr desc ≥ 4.5
        and slr.avg_service_eval_180d >= 4.5 -- store avg dsr service ≥ 4.5
        and slr.avg_shipping_eval_180d >= 4.5 -- store avg dsr shipping speed ≥ 4.5
        and slr.rating_avg_180d >= 0.92 -- 180d positive reviews ≥ 92%
        and (round((cnt_ord_ns_90d / cnt_ord_s_and_ns_90d),2) <= 0.05
            or cnt_ord_ns_30d is null) -- 30d NS rate ≤ 5% or 0
        and is_local_manually_blocked = 'N' --not blocked locally
        and in_stock_itm_cnt >= 3 -- items with stock ≥ 10
        and slr.online_itm_cnt >= 5 -- online items > 5
            )

    or (slr.seller_admin_id in ('ru2396754831qecae','ru2436425582mriae', 'ru3340142668vyhae','ru3350196499gmgae','ru2976229609crgae') -- Исключения: 1P and TURKISH
    and slr.ds = MAX_PT('aer_bi_sg.adm_sellers'))

order by seller_admin_id asc
;