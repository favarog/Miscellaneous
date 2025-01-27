SELECT

PARSE_DATE('%Y%m%d', event_date) AS data,
SPLIT((SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'page_location'), "?")[0] AS pagina,
IFNULL(SUM((SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'entrances')),0) AS entradas,
COUNT((SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "page_view" AND key = 'page_location')) AS pageview,
session_traffic_source_last_click.manual_campaign.source AS utm_source,
session_traffic_source_last_click.manual_campaign.medium AS utm_medium,
geo.region,
geo.city,


FROM `gtm-mc933sgm-n2m1n.analytics_314538299.events_202*`
GROUP BY ALL
HAVING pagina IS NOT NULL AND utm_medium = "organic"
