--odps sql
--********************************************************************--
--author:Dzhamban, Tunglg
--create time:2022-12-06 19:05:20
--********************************************************************--
SELECT
  id,
  create,
  modified,
  seller_id,
  question,
  answer
 FROM aer_ads_sg.adm_slr_questionnaire_df
 LIMIT 100