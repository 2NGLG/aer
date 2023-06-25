SELECT
  id,
  gmt_create,
  gmt_modified,
  seller_id,
  contract_type,
  contract_state,
  guide_state,
  was_changed,
  comment_col,
  welcome_slider,
  welcome_modal,
  congratulations_modal,
  guide_meta,
  seller_status,
  ds
 FROM aer_ods_sg.s_guide
 WHERE ds = '20220407' 
 LIMIT 100