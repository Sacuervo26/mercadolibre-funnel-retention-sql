# Análisis de embudo y retención para MercadoLibre

## Descripción del proyecto

Este proyecto analiza el comportamiento de usuarios en un flujo de compra tipo e-commerce, basado en un escenario de negocio inspirado en MercadoLibre.

El objetivo principal es identificar en qué etapas del embudo de conversión se pierden más usuarios y cómo se comporta la retención después del registro. El análisis permite detectar puntos críticos del journey y proponer acciones para mejorar la conversión, la retención y la experiencia de usuario.

## Datos simulados

Este repositorio incluye dos CSV simulados para que el proyecto pueda ejecutarse localmente:

- `data/raw/mercadolibre_funnel.csv`
- `data/raw/mercadolibre_retention.csv`

Los datos son ficticios y fueron creados con la misma estructura del ejercicio original, únicamente con fines educativos y de portafolio.

## Preguntas de negocio

- ¿En qué etapa del proceso de compra se pierden más usuarios?
- ¿Cuál es la tasa de conversión entre cada etapa del embudo?
- ¿Cómo varía la conversión por país?
- ¿Qué tan bien se retienen los usuarios después del registro?
- ¿Cómo cambia la retención en D7, D14, D21 y D28?

## Herramientas utilizadas

- SQL
- PostgreSQL
- DBeaver / pgAdmin / VS Code
- CTEs
- CASE WHEN
- COUNT DISTINCT
- LEFT JOIN
- Análisis de funnel
- Análisis de cohortes

## Estructura del repositorio

```text
mercadolibre-funnel-retention-sql/
│
├── data/
│   └── raw/
│       ├── mercadolibre_funnel.csv
│       └── mercadolibre_retention.csv
│
├── docs/
├── images/
├── sql/
│   ├── 00_create_tables_postgresql.sql
│   ├── 01_exploracion.sql
│   ├── 02_funnel_conversion.sql
│   ├── 03_funnel_por_pais.sql
│   ├── 04_retencion_por_pais.sql
│   └── 05_retencion_por_cohorte.sql
│
├── README.md
├── .gitignore
└── LICENSE
```

## Cómo ejecutar el proyecto

1. Crear una base de datos en PostgreSQL.
2. Ejecutar `sql/00_create_tables_postgresql.sql`.
3. Cargar los CSV ubicados en `data/raw/`.
4. Ejecutar las consultas SQL en orden:
   - `01_exploracion.sql`
   - `02_funnel_conversion.sql`
   - `03_funnel_por_pais.sql`
   - `04_retencion_por_pais.sql`
   - `05_retencion_por_cohorte.sql`

## Principales hallazgos esperados

- La mayor fuga ocurre entre `select_item` y `add_to_cart`.
- Muchos usuarios muestran interés, pero no avanzan hacia una intención clara de compra.
- La retención inicial en D7 es alta, pero disminuye considerablemente hacia D28.
- Existen diferencias por país que pueden orientar estrategias específicas de mejora.

## Recomendaciones

- Optimizar la experiencia entre selección de producto y carrito.
- Revisar precios, costos de envío y claridad de promociones.
- Implementar recordatorios para usuarios que seleccionan productos pero no agregan al carrito.
- Diseñar campañas de retención entre D7 y D28.
- Crear dashboards de monitoreo para conversión y retención.

## Skills demostradas

- SQL
- CTEs
- Joins
- COUNT DISTINCT
- CASE WHEN
- Análisis de funnel
- Análisis de cohortes
- Retención de usuarios
- Pensamiento de negocio
