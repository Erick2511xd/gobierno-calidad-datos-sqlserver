# Reglas de calidad de datos

Marco: **DAMA-DMBOK2, capítulo 13**. Las reglas se ejecutan con `sql/04_reglas_calidad.sql` y su resultado se guarda en `Gobierno.Resultado_DQ`.

| Código | Dimensión | Qué verifica | Umbral máx. de error | Por qué ese umbral |
| --- | --- | --- | --- | --- |
| DQ_01 | Unicidad | `CustomerID` no se repite en Stage | 0% | Una clave de negocio duplicada genera clientes dobles. |
| DQ_02 | Completitud | `ContactName` no es nulo ni vacío | 15% | Campo opcional: se tolera algo de vacío, pero no una mayoría. |
| DQ_03 | Validez | `CustomerID` = exactamente 5 letras MAYÚSCULAS | 0% | Es la clave: no admite formatos distintos. |
| DQ_04 | Consistencia | `Country` pertenece a la lista oficial de 10 países | 0% | Un país escrito de dos maneras parte los reportes. |
| DQ_05 | Reconciliación | Filas en Stage = filas en DW + filas rechazadas | 0 de diferencia | Garantiza que no se perdió ninguna fila en la carga. |

**Estados:** `APROBADO` (error ≤ umbral), `FALLO` (error > umbral), `SIN_DATOS` (la tabla está vacía; evita aprobar una tabla sin filas).

**Qué pasa cuando una regla falla:** en este mini-proyecto la carga del DW ya aplica las correcciones (rechazo de IDs inválidos y duplicados, estandarización de país), y las reglas miden la calidad **de lo que llegó a Stage**. Así el resultado muestra cuánta suciedad traía la fuente.

**Limitación conocida:** las reglas se ejecutan a mano, no están automatizadas con un job.
