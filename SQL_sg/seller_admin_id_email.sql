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
TRUNCATE TABLE temp_slr_email;

INSERT INTO  temp_slr_email

SELECT
  seller_admin_seq,
  seller_admin_id,
  email
 FROM aer_bi_sg.adm_sellers a
 LEFT JOIN aer_dwh_sg.dim_ae_mbr_v b
 on a.seller_admin_id = b.member_id
 AND a.ds = b.ds
 WHERE a.ds = MAX_PT('aer_bi_sg.adm_sellers')
 AND a.register_country_id in ('CN')
 ORDER BY a.trd_pay_pord_30d DESC
 LIMIT 100000