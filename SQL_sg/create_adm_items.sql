CREATE TABLE IF NOT EXISTS temp_adm_items
(
    item_id                       STRING COMMENT 'item_id',
    item_url                      STRING COMMENT 'item_url',
    seller_admin_id               STRING COMMENT 'seller_admin_id',
    seller_admin_seq              BIGINT COMMENT 'seller_admin_seq',
    business_model                STRING COMMENT 'business_model (TMALL 1P/TMALL MKTP/AE MKTP/Cross border)',
    store_id                      BIGINT COMMENT 'store_id',
    create_item_time              STRING COMMENT 'create_item_time',
    modify_item_time              STRING COMMENT 'modify_item_time',
    image_cnt                     STRING COMMENT 'image_cnt',
    subject                       STRING COMMENT 'subject, item title',
    item_type                     STRING COMMENT 'item_type',
    item_status                   STRING COMMENT 'item_status, 1=online, -1 removed by seller, -2 removed, -3 removed by administrator, -4 removed by manager',
    is_online                     STRING COMMENT 'is item online Y/N',
    min_item_price                BIGINT COMMENT 'The lowest price in the global offer of commodity sku',
    max_item_price                BIGINT COMMENT 'The highest price in the global offer of commodity sku',
    item_price                    BIGINT COMMENT 'Commodity global quotation',
    is_first_online               STRING COMMENT 'is_first_online Y/N',
    is_reonline                   STRING COMMENT 'is_reonline Y/N',
    fst_online_item_time          STRING COMMENT 'fst_online_item_time',
    lst_online_item_time          STRING COMMENT 'lst_online_item_time',
    is_expire_offline             STRING COMMENT 'is_expire_offline Y/N',
    offline_item_time             STRING COMMENT 'offline_item_time',
    brand_value_id                STRING COMMENT 'brand_value_id',
    brand_value                   STRING COMMENT 'brand_value',
    currency_code                 STRING COMMENT 'currency_code',
    original_locale               STRING COMMENT 'Native language, formatted as en_US',
    slr_register_country_id       STRING COMMENT 'seller_country',
    item_is_approved              STRING COMMENT 'is item has passed rewiev Y/N',
    stock                         BIGINT COMMENT 'stock',
    stock_chehov                  BIGINT COMMENT 'stock in Chehov',
    is_item_in_stock              STRING COMMENT 'is item in stock Y/N',
    is_item_in_chehov_stock       STRING COMMENT 'is item in Chehov stock Y/N',
    sku_cnt                       BIGINT COMMENT 'unique number of sku',
    sku_online_cnt                BIGINT COMMENT 'unique number of sku online',
    sku_stock_cnt                 BIGINT COMMENT 'unique number of sku in stock',
    is_owh_item                   STRING COMMENT 'is_owh_item Y/N',
    pcate_leaf_id                 STRING COMMENT 'pcate_leaf_id',
    local_cate_lv1_id             STRING COMMENT 'local_cate_lv1_id',
    local_cate_lv1_desc           STRING COMMENT 'local_cate_lv1_desc',
    local_cate_lv2_id             STRING COMMENT 'local_cate_lv2_id',
    local_cate_lv2_desc           STRING COMMENT 'local_cate_lv2_desc',
    local_cate_lv3_id             STRING COMMENT 'local_cate_lv3_id',
    local_cate_lv3_desc           STRING COMMENT 'local_cate_lv3_desc',
    local_cate_lv4_id             STRING COMMENT 'local_cate_lv4_id',
    local_cate_lv4_desc           STRING COMMENT 'local_cate_lv4_desc',
    local_department_1            STRING COMMENT 'local_department_1',
    local_department_2            STRING COMMENT 'local_department_2',
    item_import_source            STRING COMMENT 'item_import_source',
    grade_avg_180d                DOUBLE COMMENT 'average grade for last 180d',
    exposure_7d                   BIGINT COMMENT 'exposure_7d',
    exposure_30d                  BIGINT COMMENT 'exposure_30d',
    ipv_7d                        BIGINT COMMENT 'ipv_7d',
    ipv_30d                       BIGINT COMMENT 'ipv_30d',
    exposure_mbr_uv_7d            BIGINT COMMENT 'exposure_mbr_uv_7d',
    exposure_mbr_uv_30d           BIGINT COMMENT 'exposure_mbr_uv_30d',
    ipv_mbr_uv_7d                 BIGINT COMMENT 'ipv_mbr_uv_7d',
    ipv_mbr_uv_30d                BIGINT COMMENT 'ipv_mbr_uv_30d',
    buynow_7d                     BIGINT COMMENT 'buynow_7d',
    buynow_30d                    BIGINT COMMENT 'buynow_30d',
    addwishlist_7d                BIGINT COMMENT 'addwishlist_7d',
    addwishlist_30d               BIGINT COMMENT 'addwishlist_30d',
    addcart_7d                    BIGINT COMMENT 'addcart_7d',
    addcart_30d                   BIGINT COMMENT 'addcart_30d',
    search_exposure_7d            BIGINT COMMENT 'search_exposure_7d',
    search_exposure_30d           BIGINT COMMENT 'search_exposure_30d',
    search_min_pos_7d             BIGINT COMMENT 'search_min_pos_7d',
    search_min_pos_30d            BIGINT COMMENT 'search_min_pos_30d',
    search_max_pos_7d             BIGINT COMMENT 'search_max_pos_7d',
    search_max_pos_30d            BIGINT COMMENT 'search_max_pos_30d',
    search_avg_pos_7d             DOUBLE COMMENT 'search_avg_pos_7d',
    search_avg_pos_30d            DOUBLE COMMENT 'search_avg_pos_30d',
    freight_template_id           STRING COMMENT 'freight_template_id',
    freight_template_name         STRING COMMENT 'freight_template_name',
    snapshot_id                   STRING COMMENT 'snapshot_id',
    first_mile                    STRING COMMENT 'first_mile',
    provider_name                 STRING COMMENT 'provider_names',
    is_fba_item                   STRING COMMENT 'is_fba_item',
    is_free_delivery              STRING COMMENT 'is free delivery availibale Y/N',
    package_height                DOUBLE COMMENT 'package_height, cm',
    package_length                DOUBLE COMMENT 'package_length, cm',
    package_width                 DOUBLE COMMENT 'package_width, cm',
    package_volume                DOUBLE COMMENT 'package_volume',
    gross_weight                  DOUBLE COMMENT 'gross weight, kg',
    package_size_type             STRING COMMENT 'package_size XS/S/M/L/XL based on volume and gross weight',
    is_gi                         STRING COMMENT 'is golden item Y/N',
    trd_pay_gmv_usd_7d            DOUBLE COMMENT 'gmv_usd_last_7d',
    trd_pay_gmv_usd_30d           DOUBLE COMMENT 'gmv_usd_last_30d',
    trd_pay_gmv_usd_90d           DOUBLE COMMENT 'gmv_usd_last_90d',
    trd_pay_gmv_usd_180d          DOUBLE COMMENT 'gmv_usd_last_180d',
    trd_pay_gmv_usd_365d          DOUBLE COMMENT 'gmv_usd_last_365d',
    trd_pay_gmv_rub_7d            DOUBLE COMMENT 'gmv_rub_last_7d',
    trd_pay_gmv_rub_30d           DOUBLE COMMENT 'gmv_rub_last_30d',
    trd_pay_gmv_rub_90d           DOUBLE COMMENT 'gmv_rub_last_90d',
    trd_pay_gmv_rub_180d          DOUBLE COMMENT 'gmv_rub_last_180d',
    trd_pay_gmv_rub_365d          DOUBLE COMMENT 'gmv_rub_last_365d',
    trd_pay_pord_7d               BIGINT COMMENT 'pord_last_7d',
    trd_pay_pord_30d              BIGINT COMMENT 'pord_last_30d',
    trd_pay_pord_90d              BIGINT COMMENT 'pord_last_90d',
    trd_pay_pord_180d             BIGINT COMMENT 'pord_last_180d',
    trd_pay_pord_365d             BIGINT COMMENT 'pord_last_365d',
    trd_pay_itm_qty_7d            BIGINT COMMENT 'qty_last_7d',
    trd_pay_itm_qty_30d           BIGINT COMMENT 'qty_last_30d',
    trd_pay_itm_qty_90d           BIGINT COMMENT 'qty_last_90d',
    trd_pay_itm_qty_180d          BIGINT COMMENT 'qty_last_180d',
    trd_pay_itm_qty_365d          BIGINT COMMENT 'qty_last_365d',
    is_global_block               STRING COMMENT 'is_global_block Y/N',
    global_block_rule_level1_name STRING COMMENT 'global_block_rule_level1_name',
    global_block_rule_level2_name STRING COMMENT 'global_block_rule_level2_name',
    global_block_rule_level3_name STRING COMMENT 'global_block_rule_level3_name',
    cate_id_trade_rate            DOUBLE COMMENT 'cate_id_trade_rate',
    cate_id_logistic_rate         DOUBLE COMMENT 'cate_id_logistic_rate',
    freight_template_type         STRING COMMENT 'freight_template_type',
    ds                            STRING COMMENT 'ds'
)