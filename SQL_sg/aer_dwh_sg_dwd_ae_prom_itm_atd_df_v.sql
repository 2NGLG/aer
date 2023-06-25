INSERT INTO temp_prom_itm

SELECT
  ds
  ,prom_id
  ,prom_name
  ,item_id
  ,item_price
  ,seller_admin_seq
  ,seller_admin_id
 FROM aer_dwh_sg.dwd_ae_prom_itm_atd_df_v
 WHERE ds = to_char(DATEADD(getdate(),-2,'dd'),'yyyymmdd')
 AND prom_id in (30000053427, 30000053595, 30000053415, 30000052429)