-- 00_create_tables_postgresql.sql
-- Crear tablas para cargar los CSV simulados en PostgreSQL.
-- En DBeaver: crea estas tablas y luego usa Import Data > CSV.

DROP TABLE IF EXISTS mercadolibre_funnel;
DROP TABLE IF EXISTS mercadolibre_retention;

CREATE TABLE mercadolibre_funnel (
    user_id TEXT,
    session_id TEXT,
    event_name TEXT,
    event_times BIGINT,
    country TEXT,
    device_category TEXT,
    platform TEXT,
    product_cat TEXT,
    price NUMERIC,
    currency TEXT,
    referral_source TEXT,
    event_date TIMESTAMP,
    year INTEGER
);

CREATE TABLE mercadolibre_retention (
    user_id TEXT,
    signup_date DATE,
    signup_datetime TIMESTAMP,
    country TEXT,
    device_category TEXT,
    platform TEXT,
    day_after_signup INTEGER,
    activity_date DATE,
    active INTEGER,
    prob_active NUMERIC
);

-- Si usas psql, cambia las rutas según tu computador:
-- \copy mercadolibre_funnel FROM 'data/raw/mercadolibre_funnel.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
-- \copy mercadolibre_retention FROM 'data/raw/mercadolibre_retention.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
