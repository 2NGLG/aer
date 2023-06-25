--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2023-02-17 00:27:28
--********************************************************************--
--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2023-01-13 16:20:34
--********************************************************************--
TRUNCATE TABLE temp_adm_sellers;

INSERT INTO  temp_adm_sellers

SELECT
  seller_admin_seq,
  seller_admin_id,
  business_model,
  register_country_id,
  sub_accounts,
  merchant_type,
  create_seller_time,
  store_id,
  store_name,
  store_link,
  store_type,
  havana_id,
  is_ka_ind,
  first_public_item_time,
  first_pay_order_time,
  funnel_status,
  online_itm_cnt,
  in_stock_itm_cnt,
  offline_itm_cnt,
  all_finished_pord,
  all_finished_gmv_rub,
  all_finished_gmv_usd,
  all_finished_item_commission_rub,
  all_finished_market_commission_rub,
  all_finished_log_commission_rub,
  all_finished_item_commission_usd,
  all_finished_market_commission_usd,
  all_finished_log_commission_usd,
  date_r6,
  date_s0,
  date_s1,
  date_s2,
  date_s3,
  itm_cate_lv1_desc,
  itm_cate_lv1_id,
  gmv_cate_lv1_desc,
  gmv_cate_lv1_id,
  login_days_7d,
  login_days_30d,
  login_days_90d,
  login_days_180d,
  itm_change_days_7d,
  itm_change_days_30d,
  itm_change_days_90d,
  itm_change_days_180d,
  send_days_7d,
  send_days_30d,
  send_days_90d,
  send_days_180d,
  api_days_7d,
  api_days_30d,
  api_days_90d,
  api_days_1800d,
  trd_pay_gmv_rub_7d,
  trd_pay_gmv_rub_30d,
  trd_pay_gmv_rub_90d,
  trd_pay_gmv_rub_180d,
  trd_pay_gmv_rub_365d,
  trd_pay_gmv_rub_ttl,
  trd_pay_gmv_usd_7d,
  trd_pay_gmv_usd_30d,
  trd_pay_gmv_usd_90d,
  trd_pay_gmv_usd_180d,
  trd_pay_gmv_usd_365d,
  trd_pay_gmv_usd_ttl,
  trd_pay_pord_7d,
  trd_pay_pord_30d,
  trd_pay_pord_90d,
  trd_pay_pord_180d,
  trd_pay_pord_365d,
  trd_pay_pord_ttl,
  trd_pay_items_7d,
  trd_pay_items_30d,
  trd_pay_items_90d,
  trd_pay_items_180d,
  trd_pay_items_365d,
  online_items_7d,
  online_items_30d,
  online_items_90d,
  online_items_180d,
  online_items_365d,
  exposure_7d,
  exposure_30d,
  ipv_7d,
  ipv_30d,
  exposure_mbr_uv_7d,
  exposure_mbr_uv_30d,
  ipv_mbr_uv_7d,
  ipv_mbr_uv_30d,
  buynow_7d,
  buynow_30d,
  addwishlist_7d,
  addwishlist_30d,
  addcart_7d,
  addcart_30d,
  date_slr_offline,
  item_qty_before_offline,
  trd_pay_before_offline_gmv_rub_30d,
  trd_pay_before_offline_gmv_usd_30d,
  trd_pay_before_offline_pord_30d,
  is_churn,
  slr_total_price_index,
  itm_match_price_index,
  itm_ozon,
  itm_wb,
  rating_avg_180d,
  avg_desc_eval_180d,
  avg_service_eval_180d,
  avg_shipping_eval_180d,
  is_affiliate,
  is_local_manually_blocked,
  local_block_type,
  local_block_time,
  local_unblock_time,
  cnt_ord_s_and_ns_7d,
  cnt_ord_s_and_ns_30d,
  cnt_ord_s_and_ns_90d,
  cnt_ord_s_and_ns_180d,
  cnt_ord_s_and_ns_365d,
  cnt_ord_s_and_ns_ttl,
  cnt_ord_ns_7d,
  cnt_ord_ns_30d,
  cnt_ord_ns_90d,
  cnt_ord_ns_180d,
  cnt_ord_ns_365d,
  cnt_ord_ns_ttl,
  main_log_model_orders,
  main_provider_orders,
  main_log_model_items,
  main_provider_items,
  ds
 FROM aer_bi_sg.adm_sellers
 WHERE ds = MAX_PT('aer_bi_sg.adm_sellers')
 AND register_country_id in ('CN')
 ORDER BY trd_pay_pord_30d DESC
 LIMIT 100000