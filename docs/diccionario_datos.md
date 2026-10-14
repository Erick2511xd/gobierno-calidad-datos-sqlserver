# Diccionario de datos: `DW.Dim_Cliente`

> Grano: **una fila por cliente** (clave de negocio `Cliente_Codigo`). Dimensión tipo 1 (si el dato cambia, se sobrescribe; no guarda historia).
> Fuente: `Stage.Cliente` (datos sintéticos inspirados en la tabla `Customers` de Northwind).
> Este diccionario se verifica contra la base con `sql/05_verificar_diccionario.sql`.

## 1. Ficha técnica

| # | Columna | Tipo | Permite nulos | Definición de negocio |
| - | --- | --- | --- | --- |
| 1 | `Cliente_SKey` | `INT IDENTITY` | NO | Clave sustituta autogenerada. Identifica la fila dentro del DW; no tiene significado de negocio. |
| 2 | `Cliente_Codigo` | `CHAR(5)` | NO | Código del cliente en el sistema origen: exactamente 5 letras mayúsculas. Único (restricción `UQ_Dim_Cliente_Codigo`). |
| 3 | `Cliente_Compania` | `NVARCHAR(40)` | NO | Razón social o nombre comercial de la empresa cliente. |
| 4 | `Cliente_Contacto` | `NVARCHAR(30)` | SÍ | Persona de contacto en la empresa. Opcional en el origen. |
| 5 | `Cliente_Ciudad` | `NVARCHAR(15)` | SÍ | Ciudad de la sede del cliente. |
| 6 | `Cliente_Pais` | `NVARCHAR(15)` | NO | País del cliente, estandarizado en inglés según la lista oficial (ver `DQ_04`). |
| 7 | `Cliente_Telefono` | `VARCHAR(24)` | SÍ | Teléfono de contacto, tal como llega del origen (sin normalizar). |
| 8 | `Fecha_Carga` | `DATETIME2` | NO | Fecha y hora en que la fila entró al DW. Campo de auditoría. |

## 2. Linaje y transformaciones (Origen → Stage → DW)

| Columna DW | Columna Stage | Columna en Northwind (`Customers`) | Regla de transformación |
| --- | --- | --- | --- |
| `Cliente_Codigo` | `CustomerID` | `CustomerID` | Copia. Se rechaza si no son 5 letras mayúsculas (T1) o si está repetido (T2). |
| `Cliente_Compania` | `CompanyName` | `CompanyName` | `LTRIM(RTRIM())`. |
| `Cliente_Contacto` | `ContactName` | `ContactName` | `NULLIF(LTRIM(RTRIM()), '')`: el texto vacío pasa a `NULL`. |
| `Cliente_Ciudad` | `City` | `City` | Copia. |
| `Cliente_Pais` | `Country` | `Country` | Estandarización (T3): `Alemania` → `Germany`, `U.K.` → `UK`. |
| `Cliente_Telefono` | `Phone` | `Phone` | Copia. |
| `Cliente_SKey`, `Fecha_Carga` | — | — | Generadas en el DW (`IDENTITY` y `SYSDATETIME()`). |

**Columnas del origen que NO se cargan:** `ContactTitle`, `Address`, `Region`, `PostalCode`, `Fax`. Motivo: fuera del alcance de este proyecto (no se usan en ninguna regla de calidad).

## 3. Gobierno: dueños, CDE y calidad

| Columna | Data Owner (rol) | Data Steward (rol) | ¿CDE? | Justificación | Reglas DQ |
| --- | --- | --- | --- | --- | --- |
| `Cliente_Codigo` | Gerencia Comercial | Steward de Datos Comerciales | **SÍ** | Es la clave de negocio: si está mal, se duplican o se pierden clientes en todo reporte. | DQ_01, DQ_03, DQ_05 |
| `Cliente_Compania` | Gerencia Comercial | Steward de Datos Comerciales | **SÍ** | Identifica al cliente ante el negocio y en facturas. | DQ_05 |
| `Cliente_Pais` | Gerencia Comercial | Steward de Datos Comerciales | **SÍ** | Se usa para segmentar ventas por país; un valor inconsistente parte un mismo país en dos grupos. | DQ_04 |
| `Cliente_Contacto` | Gerencia Comercial | Steward de Datos Comerciales | NO | Dato complementario y opcional. | DQ_02 (umbral 15%) |
| `Cliente_Ciudad` | Gerencia Comercial | Steward de Datos Comerciales | NO | Dato descriptivo. | — |
| `Cliente_Telefono` | Gerencia Comercial | Steward de Datos Comerciales | NO | Dato de contacto, sin uso analítico. | — |
| `Cliente_SKey`, `Fecha_Carga` | Equipo de Datos (TI) | Steward de Datos Comerciales | NO | Campos técnicos generados por el DW. | — |

**Criterio de CDE usado:** una columna es CDE si (1) identifica al cliente, o (2) se usa para agrupar o filtrar reportes de ventas, y (3) un error en ella cambia un número que ve la gerencia.

> Los roles son **simulados** para este proyecto de portafolio; no corresponden a una organización real.
