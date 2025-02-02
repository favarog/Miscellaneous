SELECT

EXTRACT(MONTH FROM PARSE_DATE('%Y%m%d', event_date) ) AS mes,
EXTRACT(YEAR FROM PARSE_DATE('%Y%m%d', event_date) ) AS ano,
COUNT(DISTINCT user_pseudo_id) AS usuarios,

FROM `gtm-mc933sgm-n2m1n.analytics_314538299.events_*`
--WHERE _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY))
GROUP BY ALL
