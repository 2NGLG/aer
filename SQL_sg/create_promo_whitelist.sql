create table temp_promo_whitelist (
 seller_admin_id STRING
,seller_admin_seq STRING
,business_model STRING
,all_finished_pord STRING
,trd_pay_pord_30d STRING
,itm_with_30d_sales STRING
,avg_desc_eval_180d STRING
,avg_service_eval_180d STRING
,avg_shipping_eval_180d STRING
,rating_180d STRING
,cancel_rate STRING
,ns_rate_90d STRING
,in_stock_itm_cnt STRING
,is_local_manually_blocked STRING
)

INSERT INTO temp_promo_whitelist (
 seller_admin_id
,seller_admin_seq
,business_model
,all_finished_pord
,trd_pay_pord_30d
,itm_with_30d_sales
,avg_desc_eval_180d
,avg_service_eval_180d
,avg_shipping_eval_180d
,rating_180d
,cancel_rate
,ns_rate_90d
,in_stock_itm_cnt
,is_local_manually_blocked
)
