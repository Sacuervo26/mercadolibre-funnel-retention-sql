-- 02_funnel_conversion.sql
-- Embudo general y conversiones desde first_visit.

WITH first_visit AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'first_visit'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
select_item AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name IN ('select_item', 'select_promotion')
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
add_to_cart AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_to_cart'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
begin_checkout AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'begin_checkout'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
add_shipping_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_shipping_info'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
add_payment_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_payment_info'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
purchase AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'purchase'
      AND event_date >= '2025-01-01' AND event_date < '2025-09-01'
),
funnel_counts AS (
    SELECT
        COUNT(fv.user_id) AS usuarios_first_visit,
        COUNT(si.user_id) AS usuarios_select_item,
        COUNT(atc.user_id) AS usuarios_add_to_cart,
        COUNT(bc.user_id) AS usuarios_begin_checkout,
        COUNT(asi.user_id) AS usuarios_add_shipping_info,
        COUNT(api.user_id) AS usuarios_add_payment_info,
        COUNT(p.user_id) AS usuarios_purchase
    FROM first_visit fv
    LEFT JOIN select_item si ON fv.user_id = si.user_id
    LEFT JOIN add_to_cart atc ON si.user_id = atc.user_id
    LEFT JOIN begin_checkout bc ON atc.user_id = bc.user_id
    LEFT JOIN add_shipping_info asi ON bc.user_id = asi.user_id
    LEFT JOIN add_payment_info api ON asi.user_id = api.user_id
    LEFT JOIN purchase p ON api.user_id = p.user_id
)
SELECT
    *,
    ROUND(usuarios_select_item * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_select_item,
    ROUND(usuarios_add_to_cart * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_to_cart,
    ROUND(usuarios_begin_checkout * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_begin_checkout,
    ROUND(usuarios_add_shipping_info * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_shipping_info,
    ROUND(usuarios_add_payment_info * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_payment_info,
    ROUND(usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_purchase
FROM funnel_counts;
