SELECT
  seller_admin_id,
  seller_admin_seq,
  store_id,
  store_name,
  company_id,
  merchant_sub_type,
  is_oversea_seller,
  create_seller_time,
  seller_start_time,
  start_store_time,
  seller_status,
  is_admin_seller,
  local_seller_account_unit,
  register_country_id,
  business_segement,
  business_sub_group,
  business_type_lv1,
  business_type_lv2,
  business_type_lv3,
  pcate_leaf_id,
  pcate_lv3_id,
  pcate_lv2_id,
  pcate_lv1_id,
  pcate_leaf_desc_en,
  pcate_lv3_desc_en,
  pcate_lv2_desc_en,
  pcate_lv1_desc_en,
  cate_group_desc_cn,
  parent_cate_desc_cn,
  fst_public_item_time,
  is_have_online_item,
  ds
 FROM aer_bi_sg.dim_jv_slr
 WHERE ds = '20220410'
 limit 100