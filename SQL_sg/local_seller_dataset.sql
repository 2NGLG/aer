--odps sql 

--********************************************************************--

--author:Milovanov, Aleksandr

--create time:2022-02-07 02:34:23

--********************************************************************--

-- SET odps.sql.mapper.split.size=10000;

SET odps.instance.priority=1;

WITH l_reg_slr AS (

    SELECT

    seller_admin_seq,

    seller_admin_id,

    business_model

    FROM aer_ads_sg.adi_ae_jv_local_reg_slr_biz_type_df

    WHERE ds = '${bizdate}'

),

approve_seller_process AS (

    SELECT 

        seller_id,

        process_state,

        gmt_modified,

        gmt_create,

        ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY gmt_modified DESC) AS r_n

    FROM aer_ods_sg.s_sellercenter_approve_seller_process

    WHERE ds = '${bizdate}'

),

online_process AS (

    SELECT

        g.seller_id,

        p.process_state,

        p.gmt_modified,

        p.gmt_create,

        g.contract_type,

        ROW_NUMBER() OVER(PARTITION BY g.seller_id ORDER BY p.gmt_modified DESC) AS r_n

    FROM aer_ods_sg.s_sellercenter_registration_guide g

    LEFT JOIN aer_ods_sg.s_sellercenter_online_process p 

        ON p.guide_id = g.id AND p.ds = g.ds

    WHERE p.ds = '${bizdate}'

),

diadoc_state AS (

    SELECT

        seller_id,

        contract_status,

        gmt_create,

        gmt_modified,

        ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY gmt_modified DESC) AS r_n

    FROM aer_ods_sg.s_sellercenter_diadoc_state

    WHERE ds = '${bizdate}'

),

legal_info AS (

    SELECT

        o.seller_id,

        CASE WHEN o.company_type = 'individual_entrepreneur' 

            THEN COALESCE(CONCAT('ИП ', get_json_object(o.store_info, '$.nameGeneralManager')),

                          CONCAT('ИП ', get_json_object(o.kontur_data, '$.IP.fio')))

            WHEN o.company_type = 'legal_entity'

            THEN COALESCE(REPLACE(REPLACE(get_json_object(o.store_info, '$.fullCompanyName'), '\\', ''), 'Общество с ограниченной ответственностью', 'ООО'),

                          REPLACE(get_json_object(o.kontur_data, '$.UL.legalName.short'), '\\', '')

            )

            WHEN o.company_type = 'self_employed'

            THEN get_json_object(o.store_info, '$.nameGeneralManager')

        END AS legal_entity_name,

        COALESCE(get_json_object(o.store_info, '$.ogrn'),

                 get_json_object(o.kontur_data, '$.ogrn')) AS legal_ogrn_ogrnip,

        get_json_object(o.store_info, '$.kpp') AS legal_kpp, -- kpp only here

        o.phone AS phone_no,

        COALESCE(get_json_object(o.store_info, '$.tin'),

                 get_json_object(o.kontur_data, '$.inn')) AS tin,

        get_json_object(o.store_info, '$.email') AS company_email, -- email only here

        o.company_type AS legal_company_type,

        COALESCE(get_json_object(o.store_info, '$.legalAddress.province'),

                 CONCAT(get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoValue'), ' ', 

                        get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoFullName'))) 

                 AS region_by_tin_ru,

        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(

            COALESCE(get_json_object(o.store_info, '$.legalAddress.province'),

                 CONCAT(get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoValue'), ' ', 

                        get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoFullName'))) ,'ый','y'),'ЫЙ','Y'),'а','a'),'б','b'),'в','v'),'г','g'),'д','d'),'е','e'),'ё','yo'),'ж','zh'),'з','z'),'и','i'),'й','y'),'к','k'),'л','l'),'м','m'),'н','n'),'о','o'),'п','p'),'р','r'),'с','s'),'т','t'),'у','u'),'ф','f'),'х','kh'),'ц','c'),'ч','ch'),'ш','sh'),'щ','shch'),'ъ',''),'ы','y'),'ь',''),'э','e'),'ю','yu'),'я','ya'),'А','A'),'Б','B'),'В','V'),'Г','G'),'Д','D'),'Е','E'),'Ё','Yo'),'Ж','ZH'),'З','Z'),'И','I'),'Й','Y'),'К','K'),'Л','L'),'М','M'),'Н','N'),'О','O'),'П','P'),'Р','R'),'С','S'),'Т','T'),'У','U'),'Ф','F'),'Х','Kh'),'Ц','C'),'Ч','Ch'),'Ш','SH'),'Щ','Shch'),'Ъ',''),'Ы','Y'),'Ь',''),'Э','E'),'Ю','Yu'),'Я','Ya')

            AS region_by_tin_en,

        CONCAT(get_json_object(o.store_info, '$.postalAddress.postcode'),

            ', ',

            get_json_object(o.store_info, '$.postalAddress.country'),

            ', ', 

            get_json_object(o.store_info, '$.postalAddress.province'),

            ', ',

            get_json_object(o.store_info, '$.postalAddress.streetAddress')

        ) AS legal_address_mail,

        COALESCE(

            CONCAT(

                get_json_object(o.store_info, '$.legalAddress.postcode'),

                ', ',

                get_json_object(o.store_info, '$.legalAddress.country'),

                ', ', 

                get_json_object(o.store_info, '$.legalAddress.province'),

                ', ',

                get_json_object(o.store_info, '$.legalAddress.streetAddress')),

            CONCAT(

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.zipCode'),

                ', ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoValue'),

                ' ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.regionName.topoShortName'),

                ', ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.city.topoShortName'),

                ' ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.city.topoValue'),

                ', ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.street.topoShortName'),

                ' ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.street.topoValue'),

                ', ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.house.topoValue'),

                ', ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.flat.topoShortName'),

                ' ',

                get_json_object(o.kontur_data, '$.UL.legalAddress.parsedAddressRF.flat.topoValue')

                )

            ) AS legal_address_reg,

        o.gmt_create,

        o.gmt_modified,

        approve_seller_process.gmt_create AS apply_kyc_time,

        kyc_approval_time.gmt_modified AS kyc_approval_time,

        COALESCE(online_process.gmt_create, diadoc_state.gmt_create) AS apply_contract_time,

        COALESCE(contract_approval_time_online.gmt_modified, contract_approval_time_diadoc.gmt_modified) AS contract_approval_time,

        online_process.contract_type,

        rel.merchant_id,

        ROW_NUMBER() OVER(PARTITION BY o.seller_id ORDER BY o.gmt_modified DESC) AS r_n

    FROM aer_ods_sg.s_sellercenter_registration_onboarding o

    LEFT JOIN approve_seller_process ON approve_seller_process.seller_id = o.seller_id AND r_n = 1

    LEFT JOIN (SELECT seller_id, MAX(CASE WHEN process_state = 'CSTEP_APPROVED' THEN gmt_modified END) gmt_modified

            FROM approve_seller_process

            GROUP BY seller_id) AS kyc_approval_time ON kyc_approval_time.seller_id = o.seller_id

    LEFT JOIN online_process ON online_process.seller_id = o.seller_id AND online_process.r_n = 1

    LEFT JOIN diadoc_state ON diadoc_state.seller_id = o.seller_id AND diadoc_state.r_n = 1

    LEFT JOIN (SELECT seller_id, MAX(CASE WHEN process_state = 'CSTEP_APPROVED' THEN gmt_modified END) AS gmt_modified

            FROM online_process 

            GROUP BY seller_id) AS contract_approval_time_online ON contract_approval_time_online.seller_id = o.seller_id

    LEFT JOIN (SELECT seller_id, MAX(CASE WHEN contract_status = "SENDER_SIGNATURE_CHECKED_AND_VALID" THEN gmt_modified END) AS gmt_modified

            FROM diadoc_state 

            GROUP BY seller_id) AS contract_approval_time_diadoc ON contract_approval_time_diadoc.seller_id = o.seller_id

    LEFT JOIN aer_ods_sg.s_ae_seller_merchant_relation_v rel 

        ON rel.seller_id = o.seller_id AND rel.ds = o.ds

    WHERE o.ds = '${bizdate}'

),

contracts_pop AS (

    SELECT

        g.seller_id,

        g.contract_type,

        g.guide_state,

        CASE WHEN g.contract_type = "offer" THEN g.gmt_modified

             WHEN g.contract_type = "online" THEN legal_info.gmt_modified

             WHEN g.contract_type = "diadoc" THEN s.gmt_modified

        END AS gmt_modified,

        CASE WHEN g.contract_type = "offer" THEN g.contract_state

             WHEN g.contract_type = "online" AND legal_info.seller_id IS NOT NULL THEN 'APPROVED'

             WHEN g.contract_type = "online" AND legal_info.seller_id IS NULL THEN 'FAILED'

             WHEN g.contract_type = "diadoc" THEN s.contract_status

        END AS contract_state

    FROM aer_ods_sg.s_guide g

    LEFT JOIN legal_info ON legal_info.seller_id = g.seller_id

    LEFT JOIN aer_ods_sg.s_diadoc_state s 

        ON s.seller_id = g.seller_id

        AND s.ds = '${bizdate}'

    WHERE TRUE 

    AND g.ds = '${bizdate}'

    AND g.contract_type IN ("offer", "diadoc", "online")

),

contracts AS (

    SELECT seller_id, contract_type, guide_state, gmt_modified, contract_state,

           ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY gmt_modified DESC) AS r_n

    FROM contracts_pop

),

sub_accounts AS (

    SELECT  t1.seller_admin_seq

            ,count(DISTINCT member_seq) sub_accounts

    FROM    aer_bi_sg.aer_local_sellers_mbr_info t1

    LEFT JOIN aer_dwh_sg.dim_ae_mbr_v t2

    ON      t1.seller_admin_seq = t2.member_admin_seq

    AND     t2.ds = '${bizdate}'

    AND     t2.is_seller = 'Y'

    AND     t2.member_status = 'enabled'

    AND     t2.is_admin_member = 'N'

    AND     t2.register_country_id = 'RU'

    WHERE   t1.ds = '${bizdate}'

    GROUP BY t1.seller_admin_seq

),

seller_status AS (

SELECT  member_admin_seq

        ,status AS seller_status

        ,gmt_create AS reg_status_update_time

        ,ROW_NUMBER() OVER(PARTITION BY member_admin_seq ORDER BY gmt_create DESC) AS r_n

FROM    aer_dwh_sg.oversea_seller_onboarding_analysis_data_v

WHERE   ds = '${bizdate}'

),

order_flow AS (

    SELECT  

    seller_admin_id, 

    min(gmt_create_order_time) AS first_pay_order_time,

    COUNT(DISTINCT 

            CASE WHEN CAST(gmt_create_order_time AS DATETIME) >= DATEADD(TO_DATE('${bizdate}', 'YYYYMMDD'),-30,'dd')

            AND CAST(gmt_create_order_time AS DATETIME) <= TO_DATE('${bizdate}', 'YYYYMMDD')

            THEN parent_order_id END) AS 30d_paid_pord,

    COUNT(DISTINCT 

            CASE WHEN CAST(gmt_create_order_time AS DATETIME) >= DATEADD(TO_DATE('${bizdate}', 'YYYYMMDD'),-90,'dd')

            AND CAST(gmt_create_order_time AS DATETIME) <= TO_DATE('${bizdate}', 'YYYYMMDD')

            THEN parent_order_id END) AS 90d_paid_pord,

    SUM(CASE WHEN CAST(gmt_create_order_time AS DATETIME) >= DATEADD(TO_DATE('${bizdate}', 'YYYYMMDD'),-30,'dd')

        AND CAST(gmt_create_order_time AS DATETIME) <= TO_DATE('${bizdate}', 'YYYYMMDD')

        THEN div_payable_amt/100 END) AS 30d_div_payable_amount,

    SUM(

    CASE WHEN is_buyer_accept = 'Y'

    AND is_cancel = 'N' AND is_send_all_goods = 'Y' AND is_trade_end = 'Y'

    AND end_reason = 'buyer_accept_goods' AND parent_logistics_status = 'BUYER_ACCEPT_GOODS'

    AND is_seller_send_goods_timeout = 'N' THEN div_payable_amt/100 END) AS all_finished_gmv_usd,

    SUM(

    CASE WHEN is_buyer_accept = 'Y'

    AND is_cancel = 'N' AND is_send_all_goods = 'Y' AND is_trade_end = 'Y'

    AND end_reason = 'buyer_accept_goods' AND parent_logistics_status = 'BUYER_ACCEPT_GOODS'

    AND is_seller_send_goods_timeout = 'N' THEN div_payable_amt/100*ex_rate.rate END) AS all_finished_gmv_rub,

    COUNT(DISTINCT

            CASE WHEN is_buyer_accept = 'Y' 

            AND is_cancel = 'N' AND is_send_all_goods = 'Y'  AND is_trade_end = 'Y'

            AND end_reason = 'buyer_accept_goods' AND parent_logistics_status = 'BUYER_ACCEPT_GOODS'

            AND is_seller_send_goods_timeout = 'N' THEN parent_order_id END) AS all_finished_pord

    FROM    aer_dwh_sg.dwd_ae_trd_ord_flow_di_v ord

    LEFT OUTER JOIN (

        SELECT --SUBSTR(rate_date ,1,10) AS rate_date

        REPLACE(SUBSTR(rate_date ,1,10),'-','') AS rate_date

        ,rate

        FROM aer_dwh_sg.cnv_tp_exchange_rate_v

        WHERE transaction_cur = 'RUB'

        AND base_cur = 'USD'

        ) ex_rate

        --ON TO_CHAR( TO_DATE(ord.ds,'yyyymmdd'),'yyyy-mm-dd') = ex_rate.rate_date

          ON TO_CHAR( ord.pay_order_time,'yyyymmdd')=TO_CHAR( dateadd(TO_DATE(ex_rate.rate_date,'yyyymmdd'),1,'dd'),'yyyymmdd')

    WHERE TRUE

    AND is_risk = 'N'

    AND is_success_pay = 'Y'

    AND CAST(gmt_create_order_time AS DATETIME) <= TO_DATE('${bizdate}', 'YYYYMMDD')

    GROUP BY seller_admin_id

),

qty AS (

    SELECT  itm.seller_admin_id

            ,COUNT(

                DISTINCT CASE    WHEN is_online = 'N' THEN itm.item_id 

                        END

            ) AS offline_item_qty

            ,COUNT(

                DISTINCT CASE    WHEN is_online = 'Y' THEN itm.item_id 

                        END

            ) AS online_item_qty

            ,COUNT(

                DISTINCT CASE    WHEN is_online = 'Y' AND stock > 0 THEN itm.item_id 

                        END

            ) AS online_item_w_stock_qty

            , MIN (itm.create_item_time) AS first_item_time

    FROM    aer_dwh_sg.dim_ae_itm_v itm

    LEFT OUTER JOIN (

                        SELECT  ds

                                ,item_id

                                ,sum(sku_stock) AS stock

                                ,avg(sku_promoted_price) AS promoted_price_w_o_prec_discount

                        FROM    aer_dwh_sg.dim_ae_itm_sku_v

                        WHERE   ds = '${bizdate}'

                        AND     is_online = 'Y'

                        GROUP BY ds

                                ,item_id

                    ) AS sku

    ON      itm.item_id = sku.item_id

    WHERE   itm.ds = '${bizdate}'

    GROUP BY itm.seller_admin_id

),

evals AS (

SELECT  seller_admin_seq

        ,round(avg(pro_desc_eval_aft_disclaim),1) AS avg_desc_eval

        ,round(avg(seller_service_eval_aft_disclaim),1) AS avg_service_eval

        ,round(avg(shipping_service_eval_aft_disclaim),1) AS avg_shipping_eval

FROM    aer_dwh_sg.dwd_ae_rsk_dsr_df_v

WHERE   gmt_create>=DATEADD(TO_DATE('${bizdate}', 'YYYYMMDD'),-180,'dd')

AND     ds = '${bizdate}'

GROUP BY seller_admin_seq

),

wh AS (

    SELECT  s.seller_id

            ,city_pinyin AS city_by_default_wh

            ,prov_pinyin AS region_by_default_wh

            , ROW_NUMBER() OVER (PARTITION BY a.seller_id ORDER BY a.gmt_create DESC) AS r_n

    FROM    aer_ods_sg.s_seller_warehouse a

    JOIN    aer_ods_sg.s_geo_points b

    ON      a.geo_point_id = b.id

    AND     b.ds = '${bizdate}'

    JOIN    aer_dwh_sg.dim_ae_jv_slr_v s

    ON      a.seller_id = s.seller_seq

    AND     s.ds = '${bizdate}'

    AND     s.is_admin_seller = 'Y'

    AND     s.register_country_id = 'RU'

    join    (

                SELECT  DISTINCT city_code

                        ,prov_name

                        ,case    WHEN prov_pinyin='Москва' AND city_pinyin <> 'Зеленоград' THEN prov_pinyin

                                WHEN prov_pinyin='Москва' AND city_pinyin = 'Зеленоград' THEN city_pinyin

                                WHEN prov_pinyin='Санкт-Петербург' THEN prov_pinyin 

                                ELSE city_pinyin 

                        END AS city_pinyin

                        ,prov_pinyin

                FROM    aer_dwh_sg.dim_csn_area_v

                WHERE   city_code IS NOT NULL

                AND     city_pinyin IS NOT NULL

                AND     country_id = 174

            ) ct

    ON      b.cn_city_id = ct.city_code

    WHERE   a.ds = '${bizdate}'

    AND     a.is_default = 1

),

lock_s AS (

    SELECT

        seller_id, lock_type, locked_at, unlocked_at,

        ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY gmt_modified DESC) AS r_n

    FROM ae_jv_operation_sg.aer_so_seller_lock_sg

    WHERE ds = MAX_PT("ae_jv_operation_sg.aer_so_seller_lock_sg")

),

legal_info_old AS (

    SELECT

    seller_id	

    ,max(legal_entity_name) legal_entity_name

    ,max(legal_ogrn_ogrnip)	legal_ogrn_ogrnip

    ,max(legal_kpp)	legal_kpp

    ,max(phone_no) phone_no	

    ,max(tin) tin	

    ,max(region_by_tin_ru)	region_by_tin_ru

    ,max(region_by_tin_en) region_by_tin_en	

    ,max(company_email)	company_email

    ,max(company_type) legal_company_type	

    ,max(address_mail) legal_address_mail	

    ,max(address_reg) legal_address_reg

    ,max(merchant_id) merchant_id

    ,max(gmt_create) gmt_create

    ,min(gmt_modified) gmt_modified

    FROM 

    (SELECT

        a.merchant_id

        ,b.seller_id

        ,legal_entity_name

        ,a.gmt_create

        ,a.gmt_modified

        ,legal_OGRN_OGRNIP

        ,legal_KPP

        ,phone_no

        ,a.TIN

        ,rt.region_name_ru AS region_by_tin_ru

  		,rt.region_name_en AS region_by_tin_en

        ,company_email

        ,company_type  

       ,COALESCE( CONCAT(a.obl_mail, '-' ,a.city_mail, '-' ,a.address_mail), 

            CONCAT(a.beneficarys_details_postal_address1, '-' ,a.beneficarys_details_postal_address2), 

            CONCAT(a.beneficarys_details_postal_address2, '-' ,a.ru_entLegalNoticeAddressDetail), 

            CONCAT(a.city2_mail, '-' ,a.address_mail),

            a.beneficarys_details_postal_address1,

            CONCAT(a.obl_mail, '-' ,a.city_mail, '-' ,a.ru_entLegalNoticeAddressDetail)) AS address_mail

        ,COALESCE( CONCAT(a.obl_reg, '-' ,a.city_reg,a.address_reg, '-' ,a.ru_entRegAddressDetail), 

            concat(a.beneficarys_details_legal_address1, '-' ,a.beneficarys_details_legal_address2), 

            CONCAT(a.beneficarys_details_legal_address2, '-' ,a.ru_entCorpRegAddressDetail), 

            CONCAT(a.city2_reg, '-' ,a.ru_entCorpRegAddressDetail),

            CONCAT(a.city2_reg, '-' ,a.address_reg, '-' ,a.ru_entRegAddressDetail),

            CONCAT(a.city2_reg, '-' ,a.address_reg),

            a.beneficarys_details_legal_address1,

            CONCAT(a.obl_reg, '-' ,a.city_reg, '-' ,a.ru_entCorpRegAddressDetail)) AS address_reg



    FROM (

        SELECT

            merchant_id,

            max(gmt_create) AS gmt_create,

            min(gmt_modified) AS gmt_modified,

            max(CASE WHEN name IN ('ru_entName','beneficiary_name_full_legal_name_or_persons_name','beneficiary_name_brief_company_name') THEN value END) AS legal_entity_name,

            max(CASE WHEN name IN ('ru_entTelephoneNum','bank_details_contact_phone_number') THEN value END) AS phone_no,

            max(CASE WHEN name IN ('ru_taxTin', 'beneficarys_details_taxpayer_identification_code') THEN REPLACE(value, ' ', '') END) AS TIN,

            max(CASE WHEN name IN ('ru_entCorpEmail','bank_details_contact_email_address','ru_entEmail') THEN value END) AS company_email,

            max(CASE WHEN name ='ru_entCorpRegAddress' THEN value ELSE NULL END) AS ru_entCorpRegAddress,

            max(CASE WHEN name ='beneficarys_details_legal_address1' THEN value ELSE NULL END) AS beneficarys_details_legal_address1,

            max(CASE WHEN name ='ru_entCorpRegAddressDetail' THEN value ELSE NULL END) AS ru_entCorpRegAddressDetail,

            max(CASE WHEN name ='ru_entRegAddress' THEN value ELSE NULL END) AS ru_entRegAddress,

            max(CASE WHEN name ='beneficarys_details_legal_address2' THEN value ELSE NULL  END) AS beneficarys_details_legal_address2,

            max(CASE WHEN name ='ru_entRegAddressDetail' THEN value ELSE NULL  END) AS ru_entRegAddressDetail,

            max(CASE WHEN name = 'ru_entCorpRegAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entCorpRegAddress[1].name') ELSE NULL END) AS obl_reg,

            max(CASE WHEN name = 'ru_entCorpRegAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entCorpRegAddress[2].name') ELSE NULL END) AS city_reg,

            max(CASE WHEN name = 'ru_entRegAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entRegAddress[1].name') ELSE NULL END) AS city2_reg,

            max(CASE WHEN name = 'ru_entRegAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entRegAddress[2].name') ELSE NULL END) AS address_reg,

      		max(CASE WHEN name IN ('ru_taxKpp','beneficarys_details_national_classification_of_enterprises_and_organizations') THEN REPLACE(value, ' ', '') END) AS legal_KPP,

      		max(CASE WHEN name IN ('beneficarys_details_business_registration_number','ru_entMersisNum') THEN REPLACE(value, ' ', '') END) AS legal_OGRN_OGRNIP,

            max(CASE WHEN name IN ('ru_entCorpName','ru_generalManager','executive_bodies_structure_and_membership_names_of_members2') THEN value END) AS legal_general_manager_name,

            max(CASE WHEN name = 'url_of_website' THEN value END) AS URL,

            max(CASE WHEN name = 'ru_paidInvoiceImage' THEN value END) AS attached_document,

            max(CASE WHEN name = 'ru_sellerId' THEN value END) AS seller_seq,

            max(CASE WHEN name = 'ru_entType' THEN value END) AS company_type,

            max(CASE WHEN name ='ru_entLegalNoticeAddress' THEN value ELSE NULL END) AS ru_entLegalNoticeAddress,

            max(CASE WHEN name ='beneficarys_details_postal_address1' THEN value ELSE NULL END) AS beneficarys_details_postal_address1,

            max(CASE WHEN name ='ru_entLegalNoticeAddressDetail' THEN value ELSE NULL END) AS ru_entLegalNoticeAddressDetail,

            max(CASE WHEN name ='ru_entMailingAddress' THEN value ELSE NULL END) AS ru_entMailingAddress,

            max(CASE WHEN name ='beneficarys_details_postal_address2' THEN value ELSE NULL  END) AS beneficarys_details_postal_address2,

            max(CASE WHEN name = 'ru_entLegalNoticeAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entLegalNoticeAddress[1].name') ELSE NULL END) AS obl_mail,

            max(CASE WHEN name = 'ru_entLegalNoticeAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entLegalNoticeAddress[2].name') ELSE NULL END) AS city_mail,

            max(CASE WHEN name = 'ru_entMailingAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entMailingAddress[1].name') ELSE NULL END) AS city2_mail,

            max(CASE WHEN name = 'ru_entMailingAddress' THEN get_json_object('{"'||name||'":'||value||'}', '$.ru_entMailingAddress[2].name') ELSE NULL END) AS address_mail



        FROM aer_ods_sg.s_ae_merchant_detail_info_v

        WHERE (name LIKE 'ru%' OR template_id = '5001')

        AND ds = '${bizdate}'

        GROUP BY merchant_id

        ) a

        LEFT JOIN aer_bi_sg.ru_region_by_tin rt ON SUBSTR(a.tin,1,2) = rt.tin

        LEFT JOIN (

                SELECT merchant_id, seller_id

                FROM aer_ods_sg.s_ae_seller_merchant_relation_v

                WHERE ds = '${bizdate}'

        ) b ON b.merchant_id = a.merchant_id

                WHERE a.tin REGEXP ('^[0-9]{12}$')

                OR a.tin REGEXP ('^[0-9]{10}$')

)

WHERE   legal_entity_name NOT IN ('тест')

AND     phone_no NOT IN ('7-9999999999')

AND     company_email NOT IN ( 'test-seller-10@yandex.ru' ,'test-seller-13@yandex.ru' ,'test.ali.seller.metro@yandex.ru' ,'fmcg.test.seller@yandex.ru' ,'logtest01@mailforspam.com' ,'logtest4@mailforspam.com' ,'scqatestseller002@yandex.ru' ,'scqatestseller010@yandex.ru' )

GROUP BY seller_id

)

INSERT OVERWRITE TABLE adm_slr_local_base_dataset_df PARTITION(ds = '${bizdate}')

SELECT

  DISTINCT

  l_reg_slr.seller_admin_seq,

  l_reg_slr.seller_admin_id,

  l_reg_slr.business_model,

  COALESCE(legal_info.merchant_id, legal_info_old.merchant_id) AS merchant_id,

  CASE WHEN seller_status.seller_status IN ('APPROVE', 'APPROVED') THEN 'APPROVED'

  ELSE seller_status.seller_status END AS seller_status,

  slr_tags.slr_tag_value AS ae_plus_tag,

  NULL AS snad_actual_30d,

  CASE WHEN onb.seller_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_new_reg_flow,

  to_date(sg_udf:bi_changetimezone(mbr_info.create_seller_time, 'PST','GMT+8'), 

                 'yyyy-mm-dd hh:mi:ss') AS create_seller_time,

  -- DATEADD(mbr_info.create_seller_time, 16, 'hh') AS create_seller_time,

  seller_status.reg_status_update_time,

  COALESCE(legal_info.tin, legal_info_old.tin) AS tin,

  COALESCE(legal_info.phone_no, mbr_info.phone_num) AS phone,

  mbr_info.email,

  mbr_info.store_id,

  mbr_info.store_name,

  mbr_info.store_link,

  utms.utm_medium,

  utms.utm_source,

  utms.utm_campaign,

  COALESCE(legal_info.legal_entity_name, legal_info_old.legal_entity_name) AS legal_entity_name,

  COALESCE(legal_info.legal_ogrn_ogrnip, legal_info_old.legal_ogrn_ogrnip) AS legal_ogrn_ogrnip,

  COALESCE(legal_info.region_by_tin_ru, rt.region_name_ru, legal_info_old.region_by_tin_ru) AS region_by_tin_ru,

  COALESCE(legal_info.region_by_tin_en, rt.region_name_en, legal_info_old.region_by_tin_en) AS region_by_tin_en,

  wh.city_by_default_wh,

  wh.region_by_default_wh,

  COALESCE(legal_info.legal_kpp, legal_info_old.legal_kpp) legal_kpp,

  CASE 

    WHEN 

        legal_info.legal_company_type ='individual_entrepreneur' 

        THEN 'ИП'

    WHEN legal_info_old.legal_company_type = 'IndividualSeller'

        AND legal_info_old.legal_ogrn_ogrnip != '000' THEN 'ИП'

    WHEN 

        COALESCE(legal_info.legal_company_type, legal_info_old.legal_company_type)

        IN ('self_employed', 'IndividualSeller') 

        THEN 'СМЗ'

    WHEN 

        COALESCE(legal_info.legal_company_type, legal_info_old.legal_company_type)

        IN ('legal_entity', 'LimitedCompany', 'PrivateCompany',

            'QuotedCompany') THEN 'ООО'

  ELSE 

    COALESCE(legal_info.legal_company_type, legal_info_old.legal_company_type)  END AS legal_company_type,

  COALESCE(legal_info.legal_address_mail, legal_info_old.legal_address_mail) legal_address_mail,

  COALESCE(legal_info.legal_address_reg, legal_info_old.legal_address_reg) legal_address_reg,

  legal_info.apply_kyc_time,

  legal_info.apply_contract_time,

  legal_info.kyc_approval_time,

  legal_info.contract_approval_time,

  CASE

  WHEN gu.contract_type ='online' THEN 'Подписал заявление'

  WHEN gu.contract_type ='diadoc' THEN 'Диадок'

  WHEN gu.contract_type ='offer' THEN 'Просто согласие с офертой' END AS contract_type,

  prime_itm_cat.prime_cat_by_online_itms AS main_cat_by_itm,

  prime_gmv_cat.prime_gmv_category AS main_cat_by_gmv,

  COALESCE(

    to_date(sg_udf:bi_changetimezone(slr_extend.fst_public_item_time, 'PST','GMT+8'), 

                    'yyyy-mm-dd hh:mi:ss'),

    to_date(sg_udf:bi_changetimezone(aer_local_item_info.fst_public_item_time, 'PST','GMT+8'), 

                    'yyyy-mm-dd hh:mi:ss')

   ) AS fst_public_item_time,

  -- DATEADD(slr_extend.fst_public_item_time, 16, 'hh') AS fst_public_item_time,

  order_flow.first_pay_order_time,

  slr.seller_status AS merchant_type,

  CASE

     WHEN slr.store_type = '1' THEN 'Мультибрендовый магазин'

     WHEN slr.store_type = '2' THEN 'Брендовый магазин'

     WHEN slr.store_type = '3' THEN 'Официальный магазин'

     WHEN slr.store_type IS NULL THEN 'Обычный магазин'

  ELSE 'Обычный магазин' END AS store_type,

  --CASE

  --  WHEN order_flow.all_finished_pord>=1000 AND order_flow.all_finished_gmv_rub>=1500000 THEN 'S3'

  --  WHEN order_flow.all_finished_pord>=100 AND order_flow.all_finished_gmv_rub>=150000 THEN 'S2'

  --  WHEN order_flow.all_finished_pord>=10 AND order_flow.all_finished_gmv_rub>=15000 THEN 'S1'

  --  WHEN order_flow.all_finished_pord>=2 THEN 'S0'

  --  WHEN order_flow.all_finished_pord=1 THEN 'R6'

  --  WHEN order_flow.first_pay_order_time IS NOT NULL THEN 'R5'

  --  WHEN (slr_extend.fst_public_item_time IS NOT NULL 

  --        AND slr_extend.fst_public_item_time <> '-911') THEN 'R4'

  --  WHEN legal_info.kyc_approval_time IS NOT NULL THEN 'R3'

  --  WHEN legal_info.apply_kyc_time IS NOT NULL THEN 'R2'

  --  ELSE 'R1' END AS funnel_status,

  CASE 

    --WHEN cnt_orders>=1000 AND all_finished_gmv_rub>=1500000 THEN 'S3'

    --WHEN cnt_orders>=100 AND all_finished_gmv_rub>=150000 THEN 'S2'

    WHEN (order_flow.all_finished_pord>=1000 OR order_flow.all_finished_gmv_rub>=1500000) THEN 'S3'

    WHEN (order_flow.all_finished_pord>=100 OR order_flow.all_finished_gmv_rub>=300000) THEN 'S2'

    WHEN order_flow.all_finished_pord>=10 AND order_flow.all_finished_gmv_rub>=15000 THEN 'S1'

    WHEN order_flow.all_finished_pord>=2 THEN 'S0'

    WHEN order_flow.all_finished_pord =1 THEN 'R6'

    WHEN order_flow.first_pay_order_time IS NOT NULL THEN 'R5'

    WHEN COALESCE(slr_extend.fst_public_item_time, 

                  aer_local_item_info.fst_public_item_time) IS NOT NULL 

    THEN 'R4'

    WHEN legal_info.kyc_approval_time IS NOT NULL THEN 'R3'

    WHEN legal_info.apply_kyc_time IS NOT NULL THEN 'R2'

    ELSE 'R1'

  END funnel_status,

  gu.guide_state AS guide_progress,

  COALESCE(qty.online_item_qty, 0) AS online_itm_cnt,

  COALESCE(qty.online_item_w_stock_qty, 0) AS in_stock_itm_cnt,

  COALESCE(qty.offline_item_qty, 0) AS offline_itm_cnt,

  COALESCE(evals.avg_desc_eval, 0) AS avg_desc_eval,

  mbr_info.havana_id,

  COALESCE(evals.avg_service_eval, 0) AS avg_service_eval,

  COALESCE(evals.avg_shipping_eval, 0) AS avg_shipping_eval,

  COALESCE(order_flow.all_finished_pord, 0) AS all_finished_pord,

  COALESCE(order_flow.all_finished_gmv_rub, 0) AS all_finished_gmv_rub,

  COALESCE(order_flow.all_finished_gmv_usd, 0) AS all_finished_gmv_usd,

  COALESCE(order_flow.30d_paid_pord, 0) AS 30d_paid_pord,

  COALESCE(order_flow.90d_paid_pord, 0) AS 90d_paid_pord,

  COALESCE(order_flow.30d_div_payable_amount / order_flow.30d_paid_pord, 0) AS 30d_paid_aov,

  COALESCE(sub_accounts.sub_accounts, 0) AS sub_accounts,

  NULL AS phone_approved,

  CASE WHEN lock_s.lock_type = 'MANUAL' 

    THEN TRUE ELSE FALSE END AS is_local_manually_blocked,

  lock_s.lock_type AS block_type,

  lock_s.locked_at AS block_time,

  lock_s.unlocked_at AS unblock_time,

  gu.contract_state AS contract_status,

  gu.gmt_modified AS contract_last_status_update,

  prime_itm_cat.pcate_leaf_id_all_itms AS pcate_leaf_id_all_itms,

  prime_itm_cat.pcate_leaf_id_online_itms AS pcate_leaf_id_online_itms,

  prime_gmv_cat.pcate_leaf_id AS main_cat_by_gmv_leaf_id

 FROM l_reg_slr

 LEFT JOIN legal_info ON legal_info.seller_id = l_reg_slr.seller_admin_seq

    AND legal_info.r_n = 1

 LEFT JOIN legal_info_old ON legal_info_old.seller_id = l_reg_slr.seller_admin_seq

 LEFT JOIN seller_status ON l_reg_slr.seller_admin_seq = seller_status.member_admin_seq 

    AND seller_status.r_n = 1

 LEFT JOIN aer_ads_sg.adm_ae_jv_aeplus_slr_tags_v slr_tags 

    ON slr_tags.seller_id = l_reg_slr.seller_admin_seq

    AND slr_tags.ds = '${bizdate}'

 LEFT JOIN wh ON wh.seller_id = l_reg_slr.seller_admin_id AND wh.r_n = 1

 LEFT JOIN aer_ods_sg.s_onboarding onb 

    ON onb.seller_id = l_reg_slr.seller_admin_seq

    AND onb.ds = '${bizdate}'

 LEFT JOIN aer_bi_sg.aer_local_sellers_mbr_info mbr_info 

    ON mbr_info.seller_admin_id = l_reg_slr.seller_admin_id

    AND mbr_info.ds = '${bizdate}'

 LEFT JOIN contracts gu ON gu.seller_id = l_reg_slr.seller_admin_seq 

    AND gu.r_n = 1

 LEFT JOIN aer_bi_sg.aer_local_sellers_prime_itm_cat prime_itm_cat

    ON prime_itm_cat.seller_admin_id = l_reg_slr.seller_admin_id 

    AND prime_itm_cat.ds = '${bizdate}'

 LEFT JOIN aer_bi_sg.aer_local_sellers_prime_gmv_cat prime_gmv_cat

    ON prime_gmv_cat.seller_admin_id = l_reg_slr.seller_admin_id

    AND prime_gmv_cat.ds = '${bizdate}'

 LEFT JOIN order_flow

    ON order_flow.seller_admin_id = l_reg_slr.seller_admin_id

 LEFT JOIN aer_dwh_sg.dim_ae_slr_v slr 

    ON slr.seller_id = l_reg_slr.seller_admin_id 

    AND slr.ds = '${bizdate}'

 LEFT JOIN qty ON qty.seller_admin_id = l_reg_slr.seller_admin_id

 LEFT JOIN evals ON evals.seller_admin_seq = l_reg_slr.seller_admin_seq

 LEFT JOIN sub_accounts ON sub_accounts.seller_admin_seq = l_reg_slr.seller_admin_seq

 LEFT JOIN lock_s 

      ON lock_s.seller_id = l_reg_slr.seller_admin_seq 

      AND lock_s.r_n = 1

 LEFT JOIN aer_ads_sg.adm_slr_utms_df utms 

    ON utms.seller_admin_id = l_reg_slr.seller_admin_id

    AND utms.ds = MAX_PT("aer_ads_sg.adm_slr_utms_df")

 LEFT JOIN aer_dwh_sg.dim_ae_slr_extend_v slr_extend 

    ON l_reg_slr.seller_admin_seq = slr_extend.seller_admin_seq 

    AND slr_extend.ds = '${bizdate}'

    AND slr_extend.is_admin_seller = 'Y'

    AND slr_extend.fst_public_item_time <> '-911'

 LEFT JOIN (

    SELECT  seller_id

        , MIN(create_item_time) AS fst_public_item_time

    FROM    aer_bi_sg.aer_local_item_info

    WHERE   ds = '${bizdate}'

    GROUP BY seller_id

    ) AS aer_local_item_info

      ON l_reg_slr.seller_admin_id = aer_local_item_info.seller_id

 LEFT JOIN aer_bi_sg.ru_region_by_tin rt ON SUBSTR(legal_info.tin,1,2) = rt.tin

 ;