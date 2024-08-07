WITH Q1 AS (
SELECT
PARSE_DATE('%Y%m%d', event_date) AS data,
user_pseudo_id,
EXTRACT(HOUR FROM TIMESTAMP_MICROS(event_timestamp) AT TIME ZONE "America/Sao_Paulo") AS hora,
EXTRACT(DAYOFWEEK FROM TIMESTAMP_MICROS(event_timestamp) AT TIME ZONE "America/Sao_Paulo") AS dia_semana,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "screen_view" AND key = 'firebase_screen') AS tela,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "screen_view" AND key = 'firebase_previous_screen') AS tela_anterior,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_userdata" AND key = 'user_type') AS tipo_usuario,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_userdata" AND key = 'user_id') AS hash_cpf,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "screen_view" AND key = 'fluxo') AS fluxo,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_interaction" AND key = 'firebase_screen') AS tela_interacao,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_interaction" AND key = 'detail') AS botoes,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_erro" AND key = 'firebase_screen') AS tela_erro,
(SELECT value.string_value FROM UNNEST(event_params) WHERE event_name = "hero_erro" AND key = 'detail') AS erros,
(SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = "screen_view" AND key = 'ga_session_id') AS session_id,
(SELECT value.int_value FROM UNNEST(event_params) WHERE event_name = "screen_view" AND key = 'ga_session_number') AS session_count,

session_traffic_source_last_click.manual_campaign.source AS utm_source,
session_traffic_source_last_click.manual_campaign.medium AS utm_medium,
session_traffic_source_last_click.manual_campaign.campaign_name AS utm_campaign,

app_info.version AS app_version,
device.operating_system AS sistema_operacional,
geo.region,
geo.city,

FROM `eai-datalake-prd.analytics_418484798.events_20240721`
WHERE REGEXP_CONTAINS(event_name, "screen_view|hero_interaction|hero_erro|hero_userdata|session_start")
GROUP BY ALL
),

ga AS (
SELECT
Q1.data,
Q1.hora,
Q1.dia_semana,
Q1.user_pseudo_id,
IFNULL(LAST_VALUE(Q1.tipo_usuario) OVER (PARTITION BY Q1.user_pseudo_id ORDER BY Q1.tipo_usuario ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), "Não Identificado") AS tipo_usuario,
IFNULL(LAST_VALUE(Q1.fluxo) OVER (PARTITION BY Q1.user_pseudo_id ORDER BY Q1.fluxo ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), "Não Identificado") AS fluxo,
IFNULL(LAST_VALUE(Q1.hash_cpf) OVER (PARTITION BY Q1.user_pseudo_id ORDER BY Q1.hash_cpf ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), "Não Identificado") AS hash_cpf,
Q1.session_id,
Q1.session_count,
Q1.tela,
Q1.tela_anterior,
CONCAT(Q1.utm_source, "/", Q1.utm_medium) AS source_medium,
Q1.utm_campaign,
Q2.botoes,
Q3.erros,
Q1.app_version,
Q1.sistema_operacional,
Q1.region,
Q1.city,

FROM Q1 LEFT JOIN Q1 AS Q2 ON Q1.user_pseudo_id = Q2.user_pseudo_id AND Q1.tela = Q2.tela_interacao  
        LEFT JOIN Q1 AS Q3 ON Q1.user_pseudo_id = Q3.user_pseudo_id AND Q1.tela = Q3.tela_erro
QUALIFY Q1.tela IS NOT NULL AND REGEXP_CONTAINS(tela, "/onboarding")
)

SELECT
ga.data,
ga.hora,
ga.dia_semana,
ga.user_pseudo_id,
ga.tipo_usuario,
ga.fluxo,
ga.hash_cpf,
cpf.decrypted_cpf,
ga.session_id,
ga.session_count,
ga.tela,
ga.tela_anterior,
ga.source_medium,
ga.utm_campaign,
ga.botoes,
ga.erros,
ga.app_version,
ga.sistema_operacional,
ga.region,
ga.city,


FROM ga LEFT JOIN `eai-datalake-data-sandbox.google_analytics.depara_cpf` AS cpf ON ga.hash_cpf = cpf.encrypted_cpf