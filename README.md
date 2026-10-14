# Proyecto de Gobierno y Calidad de Datos: dimensión Cliente

Un ejemplo pequeño y completo de **gobierno de datos** en SQL Server: diccionario de datos, linaje, dueños y custodios, y 5 reglas de calidad que se ejecutan y dejan su resultado en una tabla. Alineado a **DAMA-DMBOK2** (cap. 12 Metadatos y cap. 13 Calidad de Datos).

**Autor:** Erick Otoya · proyecto de portafolio (los roles de Data Owner y Data Steward son simulados).

## Qué demuestra

| Habilidad | Dónde verla |
| --- | --- |
| Modelado Stage → DW con restricciones (`UNIQUE`, `NOT NULL`) | [`sql/01_crear_objetos.sql`](sql/01_crear_objetos.sql) |
| ETL con deduplicación, estandarización y manejo de errores (`TRY/CATCH` + transacción) | [`sql/03_cargar_dw.sql`](sql/03_cargar_dw.sql) |
| Reglas de calidad por dimensión DAMA, con umbrales y estados | [`sql/04_reglas_calidad.sql`](sql/04_reglas_calidad.sql), [`docs/reglas_calidad.md`](docs/reglas_calidad.md) |
| Diccionario de datos, CDE, dueños y custodios | [`docs/diccionario_datos.md`](docs/diccionario_datos.md) |
| Linaje Origen → Stage → DW | [`docs/linaje.md`](docs/linaje.md) |
| Diccionario verificado contra el motor (`sys.columns`) | [`sql/05_verificar_diccionario.sql`](sql/05_verificar_diccionario.sql) |

## Cómo ejecutarlo (5 minutos)

Requisitos: SQL Server (2017 o superior) y SSMS. Abre los scripts con codificación **UTF-8**.

1. Ejecuta `sql/01_crear_objetos.sql`: crea la base de pruebas `GobiernoMini` y las tablas. Solo toca esa base; es repetible.
2. Ejecuta `sql/02_cargar_stage.sql`: carga 21 clientes sintéticos, **9 con anomalías sembradas a propósito**.
3. Ejecuta `sql/03_cargar_dw.sql`: pasa Stage → DW y registra los rechazos.
4. Ejecuta `sql/04_reglas_calidad.sql`: calcula las 5 reglas.
5. (Opcional) Ejecuta `sql/05_verificar_diccionario.sql` y compáralo con el diccionario.

## Resultado esperado

Stage recibe **21** filas; el DW queda con **17** clientes y **4** filas van a `Gobierno.Rechazado`.

| Regla | Dimensión | % error | Umbral | Errores | Estado |
| --- | --- | --- | --- | --- | --- |
| DQ_01 | Unicidad | 9.52% | 0.00% | 2 | **FALLO** |
| DQ_02 | Completitud | 14.29% | 15.00% | 3 | **APROBADO** |
| DQ_03 | Validez | 9.52% | 0.00% | 2 | **FALLO** |
| DQ_04 | Consistencia | 9.52% | 0.00% | 2 | **FALLO** |
| DQ_05 | Reconciliacion | 0.00% | 0.00% | 0 | **APROBADO** |

Las anomalías sembradas son: 2 IDs repetidos (`ALFKI`, `ANATR`), 3 contactos vacíos, 2 IDs con formato inválido (`CONSH1`, `fissa`) y 2 países mal escritos (`Alemania`, `U.K.`). `DQ_02` aprueba porque 3 de 21 (14.29%) queda por debajo del 15% tolerado; las demás fallan a propósito para que se vea la diferencia entre ambos estados.

**Evidencia de ejecución:** _(agrega aquí tu captura de SSMS con el resultado de `04_reglas_calidad.sql`, guardada en `docs/evidencias/resultado_reglas_dq.png`)_

## Estructura

```text
├── README.md
├── sql/
│   ├── 01_crear_objetos.sql
│   ├── 02_cargar_stage.sql
│   ├── 03_cargar_dw.sql
│   ├── 04_reglas_calidad.sql
│   └── 05_verificar_diccionario.sql
└── docs/
    ├── diccionario_datos.md
    ├── reglas_calidad.md
    ├── linaje.md
    └── evidencias/
```

## Alcance y límites (a propósito)

- Una sola dimensión (Cliente), sin tabla de hechos: el foco es gobierno y calidad, no el modelo dimensional.
- Los datos son **sintéticos**; no se leen de una base Northwind instalada.
- Las reglas se ejecutan a mano; no hay job ni scheduler.
- La dimensión es tipo 1 (no guarda historia).

## Próximos pasos posibles

Cargar Stage desde la base Northwind real, añadir una tabla de hechos de ventas con claves foráneas, y automatizar la ejecución de las reglas con SQL Server Agent.
