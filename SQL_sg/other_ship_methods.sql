--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2022-07-29 16:50:16
--********************************************************************--
SELECT distinct
rr.create_seller_time
, rr.seller_admin_id
, rr.seller_admin_seq
, rr.legal_company_type
, rr.legal_tin
, rr.legal_ogrn_ogrnip
, rr.store_link
, seller_stats.funnel_status
, seller_stats.gmv_last_30d
, seller_stats.pord_last_30d
, lg.seller_log_type
, case when LTP_tag.seller_id is not null then "ltp" else "global" end ltp_tag
, case when req_cnt > 0 then 'Y' else 'N' end API
FROM aer_bi_sg.adm_local_sellers_registration rr

-- LTP TAG
LEFT JOIN (
select * from aer_ods_sg.s_l2l_sellers_with_tags
) LTP_tag on LTP_tag.seller_id = rr.seller_admin_seq

--LOGISTIS
LEFT JOIN (
select *,
case when AER_log > 0 and CAINIAO_log=0 and OTHER_log = 0 then "AER"
when AER_log = 0 and CAINIAO_log>0 and OTHER_log = 0 then "CAINIAO"
else "MIX/OTHER" end seller_log_type
from
(
select seller_admin_seq, seller_admin_id,
sum(case when log_type = "Cainiao" then 1 else 0 end) CAINIAO_log,
sum(case when log_type = "AER" then 1 else 0 end) AER_log,
sum(case when log_type = "OTHER" then 1 else 0 end) OTHER_log

from

(select item_id, seller_admin_id, seller_admin_seq,
case when freight_template_type = "NEW" AND provider_name = "Cainiao" THEN
"Cainiao"
when freight_template_type = "NEW" AND provider_name IN ("Почта России", "AliExpress Russia") THEN
"AER"
else "OTHER" end log_type
from aer_pa_sg.adm_sx_itm_slr_freight_tmplt_df) item_log
group by seller_admin_seq, seller_admin_id
)
) Lg ON rr.seller_admin_id = lg.seller_admin_id

--SELLER STATS
LEFT JOIN (
select seller_admin_seq, api_days_30d, gmv_last_30d, funnel_status, pord_last_30d
from aer_bi_sg.mv_seller_classification
where ds = MAX_PT('aer_bi_sg.mv_seller_classification')
) seller_stats on seller_stats.seller_admin_seq = rr.seller_admin_seq

--API
LEFT JOIN (
select seller_admin_seq, sum(req_cnt) req_cnt
from aer_bi_sg.mv_local_sellers_api
where ds > TO_CHAR(dateadd(getdate(),-32,'dd'),'yyyymmdd')
group by seller_admin_seq
) api on api.seller_admin_seq = rr.seller_admin_seq

WHERE rr.ds = max_pt('aer_bi_sg.adm_local_sellers_registration')
and seller_status_local='APPROVED'
;