WITH base_ga AS (

SELECT

PARSE_DATE('%Y%m%d', event_date) AS data,
(SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'ga_session_id') AS session_id,
SPLIT((SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'page_location'), "?")[0] AS url_completa,
IFNULL((SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'entrances'),0) AS entrada,
(SELECT CAST(value.string_value AS NUMERIC) FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'session_engaged') AS sessao_engajada,
session_traffic_source_last_click.manual_campaign.source AS utm_source,
session_traffic_source_last_click.manual_campaign.medium AS utm_medium,
geo.region AS regiao,
geo.city AS cidade,

FROM `gtm-mc933sgm-n2m1n.analytics_314538299.events_*`
WHERE _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY))
GROUP BY ALL
HAVING url_completa IS NOT NULL
),

tratamentos AS (

SELECT

data,
EXTRACT(MONTH FROM data ) AS mes,
EXTRACT(YEAR FROM data ) AS ano,
url_completa,
REGEXP_EXTRACT(url_completa, r"https?:\/\/([^\/]+)") AS dominio,
REGEXP_EXTRACT(url_completa, r"https?://[^/]+(/.*)") AS pagina,
utm_source,
utm_medium,
CONCAT(utm_source, " / ", utm_medium) AS source_medium,
regiao,
cidade,
entrada,
entrada * LAST_VALUE(sessao_engajada) OVER (PARTITION BY session_id,url_completa ORDER BY entrada DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS sessoes_engajadas

FROM base_ga
)


SELECT
* EXCEPT(entrada,sessoes_engajadas),
SUM(entrada) AS sessoes,
SUM(sessoes_engajadas) AS sessoes_engajadas,
COUNT(url_completa) AS pageview,
FROM tratamentos
GROUP BY ALL
