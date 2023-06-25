--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2022-07-29 16:51:20
--********************************************************************--
SELECT
  seller_admin_id,
  seller_admin_seq,
  business_model,
  store_id,
  freight_template_id,
  freight_template_name,
  item_id,
  item_url,
  --local_cate_lv1_id,
  --local_cate_lv1_desc,
  brand_value_id,
  brand_value,
  is_global_block,
  global_block_rule_level1_name,
  global_block_rule_level2_name,
  global_block_rule_level3_name,
   --COUNT(item_id) as item_qty,
  SUM(trd_pay_gmv_usd_7d) as GMV_7d,
  SUM(trd_pay_gmv_usd_30d) as GMV_30d,
  SUM(trd_pay_gmv_rub_365d) as GMV_365d,
  SUM(trd_pay_pord_7d) as pord_7d,
  SUM(trd_pay_pord_30d) as pord_30d,
  SUM(trd_pay_pord_365d) as pord_365d
 FROM aer_bi_sg.adm_items
 WHERE ds = MAX_PT ('aer_bi_sg.adm_items')
 --AND is_online = 'Y'
 AND seller_admin_id in ('ru2396754831qecae')
 GROUP BY
  seller_admin_id
  ,seller_admin_seq
  ,business_model
  ,store_id
  ,freight_template_id
  ,freight_template_name
  ,item_id
  ,item_url
  --,local_cate_lv1_id
  --,local_cate_lv1_desc
  ,brand_value_id
  ,brand_value
  ,is_global_block
  ,global_block_rule_level1_name
  ,global_block_rule_level2_name
  ,global_block_rule_level3_name