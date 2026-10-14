-- =====================================================================
-- 04_reglas_calidad.sql
-- Ejecuta las 5 reglas de calidad y guarda el resultado en Gobierno.Resultado_DQ.
-- Marco: DAMA-DMBOK2, capítulo 13 (Calidad de Datos).
-- Estados: APROBADO (error <= umbral) | FALLO (error > umbral) | SIN_DATOS (tabla vacía)
-- Ejecutar DESPUÉS de 01, 02 y 03.
-- =====================================================================
USE GobiernoMini;
GO
SET NOCOUNT ON;

DECLARE @Lote  DATETIME2 = SYSDATETIME();
DECLARE @Total INT = (SELECT COUNT(*) FROM Stage.Cliente);

;WITH r AS (
    -- DQ_01 Unicidad: CustomerID repetido en Stage (la clave de negocio debe ser única)
    SELECT 'DQ_01' AS Codigo, 'Unicidad' AS Dimension, 'Stage.Cliente.CustomerID' AS Objeto,
           CAST(0.00 AS DECIMAL(5,2)) AS Umbral,
           (SELECT COUNT(*) - COUNT(DISTINCT CustomerID) FROM Stage.Cliente) AS Errores
    UNION ALL
    -- DQ_02 Completitud: ContactName vacío o nulo (campo opcional: se tolera hasta 15%)
    SELECT 'DQ_02', 'Completitud', 'Stage.Cliente.ContactName', 15.00,
           (SELECT COUNT(*) FROM Stage.Cliente
            WHERE ContactName IS NULL OR LTRIM(RTRIM(ContactName)) = N'')
    UNION ALL
    -- DQ_03 Validez: CustomerID debe ser exactamente 5 letras MAYÚSCULAS
    SELECT 'DQ_03', 'Validez', 'Stage.Cliente.CustomerID (formato)', 0.00,
           (SELECT COUNT(*) FROM Stage.Cliente
            WHERE CustomerID IS NULL
               OR CustomerID COLLATE Latin1_General_BIN NOT LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z]')
    UNION ALL
    -- DQ_04 Consistencia: Country debe pertenecer a la lista oficial de países
    SELECT 'DQ_04', 'Consistencia', 'Stage.Cliente.Country', 0.00,
           (SELECT COUNT(*) FROM Stage.Cliente
            WHERE Country IS NULL OR Country NOT IN (N'Germany', N'Mexico', N'UK', N'Sweden', N'France', N'Spain', N'Canada', N'Argentina', N'Switzerland', N'Brazil'))
    UNION ALL
    -- DQ_05 Reconciliación: cada fila de Stage debe estar en DW o en Rechazado (diferencia = 0)
    SELECT 'DQ_05', 'Reconciliacion', 'Stage vs DW + Rechazado', 0.00,
           ABS(@Total - ((SELECT COUNT(*) FROM DW.Dim_Cliente)
                       + (SELECT COUNT(*) FROM Gobierno.Rechazado)))
)
INSERT INTO Gobierno.Resultado_DQ
    (Fecha_Ejecucion, Codigo_Regla, Dimension_DQ, Objeto_Evaluado, Volumen, Errores, Pct_Error, Umbral_Pct, Estado)
SELECT @Lote, Codigo, Dimension, Objeto, @Total, Errores,
       CAST(100.0 * Errores / NULLIF(@Total, 0) AS DECIMAL(5,2)),
       Umbral,
       CASE WHEN @Total = 0 THEN 'SIN_DATOS'
            WHEN 100.0 * Errores / @Total <= Umbral THEN 'APROBADO'
            ELSE 'FALLO' END
FROM r;

-- Resultado de ESTA ejecución (es lo que va en la captura de evidencia)
SELECT Codigo_Regla, Dimension_DQ, Objeto_Evaluado, Volumen, Errores, Pct_Error, Umbral_Pct, Estado
FROM Gobierno.Resultado_DQ
WHERE Fecha_Ejecucion = @Lote
ORDER BY Codigo_Regla;

-- Detalle de lo rechazado y por qué
SELECT Stage_ID, CustomerID, CompanyName, Motivo FROM Gobierno.Rechazado ORDER BY Stage_ID;
