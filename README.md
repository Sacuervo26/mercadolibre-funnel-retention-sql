# Embudo de conversión y retención con SQL

Caso educativo de e-commerce inspirado en MercadoLibre. **Datos simulados, sin relación oficial con MercadoLibre ni resultados comerciales reales.**

Analizo dónde cae la conversión y cómo cambia la actividad de los usuarios después del registro. El proyecto demuestra CTEs, joins, agregaciones condicionales, manejo de denominadores y comunicación de hallazgos, no una implementación en producción.

## Reproducir el análisis

Requisitos: PostgreSQL 16 y cliente `psql`. Ejecutar desde la raíz del repositorio en una **base exclusiva para este ejercicio**:

```bash
createdb portfolio_demo
psql -d portfolio_demo -f scripts/run.psql
```

Para un servidor remoto, agregar `-h HOST -U USUARIO` a ambos comandos. No guardar contraseñas en el repositorio. `run.psql` importa los CSV y ejecuta las consultas en una transacción, deteniéndose ante errores. **El script elimina y recrea las dos tablas del ejercicio:** no ejecutarlo en bases de negocio ni con datos que deban conservarse.

En DBeaver/pgAdmin: ejecutar `sql/00_create_tables_postgresql.sql`, importar los CSV en sus tablas usando la primera fila como encabezado y ejecutar `01` a `05`. Los comandos con `\\` son exclusivos de psql.

## Datos y alcance

| Archivo | Filas | Grano |
|---|---:|---|
| `data/raw/mercadolibre_funnel.csv` | 26.165 | Evento de usuario/sesión |
| `data/raw/mercadolibre_retention.csv` | 30.000 | Usuario y día observado desde su registro |

Los archivos son dos conjuntos de simulación; **no se unen entre sí**. Los CSV tienen encabezado UTF-8 con BOM. No sumar precios de países diferentes sin conversión de moneda.

### Definiciones de métricas

- Ventana: desde el 1 de enero hasta el 31 de agosto de 2025 inclusive. Se usa un límite superior exclusivo (`< 2025-09-01`) para no perder eventos con hora del último día.
- Funnel: usuarios distintos con `first_visit` y presencia de todas las etapas anteriores. `select_item` y `select_promotion` representan la misma etapa. Las conversiones se calculan respecto a `first_visit`, **no respecto a la etapa anterior**.
- Las consultas global y por país utilizan la misma lógica anidada. Por país, las etapas deben pertenecer al mismo país. Un usuario que visite varios países puede aparecer en varios grupos.
- Este es un funnel de **presencia de eventos durante la ventana**, no un funnel secuencial por sesión: no exige que los timestamps de las etapas estén ordenados. No interpretarlo como prueba de un recorrido de compra individual.
- Retención puntual Dn: usuarios activos exactamente en el día n / usuarios con una observación disponible para ese día. `observed_dn` muestra el denominador. Un usuario sin observación no cuenta como inactivo; sin elegibles el resultado es `NULL`.
- Cohorte: mes de registro. Las tasas dependen de la cobertura de observaciones y no equivalen a retención acumulada o rolling retention. La columna simulada `prob_active` no es una predicción entrenada.

## Resultados de la muestra

El funnel contiene 12.000 visitantes, 9.725 usuarios con selección, 1.449 con carrito y 507 con todas las etapas hasta compra. La mayor reducción de usuarios entre etapas ocurre entre selección y carrito (8.276).

Estas cifras describen únicamente la simulación. No permiten concluir que exista una causa específica como precios o envíos, ni demostrar impacto de una intervención. Ver [resumen ejecutivo](docs/resumen_ejecutivo.md).

## Estructura

- `data/raw/`: dos CSV simulados versionados.
- `sql/00_*`: esquema; `01_*`: exploración; `02_*` y `03_*`: funnel; `04_*` y `05_*`: retención.
- `scripts/run.psql`: importación y ejecución reproducible para PostgreSQL.
- `tests/test_analysis.py`: pruebas sin dependencias externas.
- `.github/workflows/validate.yml`: pruebas y smoke test PostgreSQL 16.

## Validación

```bash
python -m unittest discover -s tests -v
```

Las cuatro pruebas portables usan SQLite para validar CSV, consultas, fin de ventana, etapas faltantes, retención puntual, cobertura y denominadores vacíos. **No sustituyen las pruebas del motor PostgreSQL**; el workflow ejecuta además la carga y todas las consultas con PostgreSQL 16. Puede haber diferencias de redondeo entre motores; los porcentajes oficiales deben obtenerse con PostgreSQL.

## Siguientes mejoras

Funnel temporal por sesión, pruebas nativas con fixtures en PostgreSQL, visualización de cohortes y comparación de periodos. Las acciones sugeridas deben validarse con datos reales autorizados y experimentos, no presentarse como resultados ya obtenidos.
