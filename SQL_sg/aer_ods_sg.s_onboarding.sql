SELECT
  id,
  gmt_create,
  gmt_modified,
  seller_id,
  inn,
  store_name,
  phone,
  registration_step,
  kontur_data,
  kontur_status,
  store_info,
  seller_login,
  kpp,
  env,
  company_type,
  ds
 FROM aer_ods_sg.s_onboarding
 WHERE ds = '20220410' 