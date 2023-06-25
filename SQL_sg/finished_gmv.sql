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
        ON TO_CHAR( TO_DATE(ord.ds,'yyyymmdd'),'yyyy-mm-dd') = ex_rate.rate_date
      --ON TO_CHAR( ord.pay_order_time,'yyyymmdd')=TO_CHAR( dateadd(TO_DATE(ex_rate.rate_date,'yyyymmdd'),1,'dd'),'yyyymmdd')
    WHERE TRUE
    AND is_risk = 'N'
    AND is_success_pay = 'Y'
    AND CAST(gmt_create_order_time AS DATETIME) <= TO_DATE('${bizdate}', 'YYYYMMDD')
    GROUP BY seller_admin_id
