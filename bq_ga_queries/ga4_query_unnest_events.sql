SELECT
e.key,
e.value.string_value,
e.value.int_value,

FROM `gtm-mc933sgm-n2m1n.analytics_314538299.events_*`, UNNEST(event_params) AS e
WHERE _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
 AND event_name = "page_view" AND e.key IN ("entrances", "session_engaged","page_location","ga_session_id")
