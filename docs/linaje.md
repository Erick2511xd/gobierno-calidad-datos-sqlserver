# Linaje de datos

```mermaid
graph LR
    A["Northwind<br/>Customers"] --> B["Stage.Cliente<br/>(copia cruda)"]
    B -->|"T1 formato ID<br/>T2 sin duplicados<br/>T3 país estándar"| C["DW.Dim_Cliente"]
    B -->|"IDs inválidos y duplicados"| D["Gobierno.Rechazado"]
    B -->|"5 reglas DQ"| E["Gobierno.Resultado_DQ"]
    C -->|"DQ_05 reconciliación"| E
    D -->|"DQ_05 reconciliación"| E
```

El detalle columna por columna (Origen → Stage → DW) está en [`diccionario_datos.md`](diccionario_datos.md), sección 2.

> Nota: los datos de este proyecto son **sintéticos** (inspirados en Northwind); no se leen de una base Northwind real.
