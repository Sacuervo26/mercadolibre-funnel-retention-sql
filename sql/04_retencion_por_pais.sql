-- Retención puntual: usuarios activos en Dn / usuarios observados en Dn.
-- NULL significa que no hay observaciones elegibles; no equivale a cero.
SELECT
    country,
    COUNT(DISTINCT CASE WHEN day_after_signup = 7 THEN user_id END) AS observed_d7,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup = 7 AND active = 1 THEN user_id END)
        / NULLIF(COUNT(DISTINCT CASE WHEN day_after_signup = 7 THEN user_id END), 0), 1) AS retention_d7_pct,
    COUNT(DISTINCT CASE WHEN day_after_signup = 14 THEN user_id END) AS observed_d14,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup = 14 AND active = 1 THEN user_id END)
        / NULLIF(COUNT(DISTINCT CASE WHEN day_after_signup = 14 THEN user_id END), 0), 1) AS retention_d14_pct,
    COUNT(DISTINCT CASE WHEN day_after_signup = 21 THEN user_id END) AS observed_d21,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup = 21 AND active = 1 THEN user_id END)
        / NULLIF(COUNT(DISTINCT CASE WHEN day_after_signup = 21 THEN user_id END), 0), 1) AS retention_d21_pct,
    COUNT(DISTINCT CASE WHEN day_after_signup = 28 THEN user_id END) AS observed_d28,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup = 28 AND active = 1 THEN user_id END)
        / NULLIF(COUNT(DISTINCT CASE WHEN day_after_signup = 28 THEN user_id END), 0), 1) AS retention_d28_pct
FROM mercadolibre_retention
WHERE activity_date >= '2025-01-01' AND activity_date < '2025-09-01'
GROUP BY country
ORDER BY country;
