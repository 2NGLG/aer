SELECT
  business_model,
  seller_status,
  MONTH (first_pay_order_time) as first_pay_order_time_month,
  COUNT(DISTINCT seller_admin_id) as slr_qty,
  SUM(all_finished_pord) as fin_pord,
  SUM(all_finished_gmv_rub) as fin_gmv_rub,
  SUM(30d_paid_pord) as 30d_paid_ord,
  SUM(90d_paid_pord) as 90d_paid_ord
 FROM aer_ads_sg.adm_slr_local_base_dataset_df
 where ds = MAX_PT('aer_ads_sg.adm_slr_local_base_dataset_df')
 GROUP BY
  business_model,
  seller_status,
  MONTH (first_pay_order_time) as first_pay_order_time_month
 limit 100