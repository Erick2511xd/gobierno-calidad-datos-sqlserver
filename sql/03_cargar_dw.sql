-- =====================================================================
-- 03_cargar_dw.sql
-- Stage -> DW.Dim_Cliente aplicando 3 reglas de transformación:
--   T1. Se rechaza CustomerID con formato inválido (NULL o distinto de 5 letras MAYÚSCULAS)
--   T2. Se rechaza el CustomerID repetido: se conserva la PRIMERA fila (menor Stage_ID)
--   T3. Se estandariza el país ('Alemania' -> 'Germany', 'U.K.' -> 'UK')
-- Todo lo rechazado queda en Gobierno.Rechazado con su motivo.
-- =====================================================================
USE GobiernoMini;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- T1: formato inválido (COLLATE BIN para distinguir mayúsculas de minúsculas)
    INSERT INTO Gobierno.Rechazado (Stage_ID, CustomerID, CompanyName, Motivo)
    SELECT Stage_ID, CustomerID, CompanyName, 'ID con formato invalido'
    FROM Stage.Cliente
    WHERE CustomerID IS NULL
       OR CustomerID COLLATE Latin1_General_BIN NOT LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z]';

    -- T2: duplicados (solo entre IDs válidos)
    ;WITH v AS (
        SELECT Stage_ID, CustomerID, CompanyName,
               ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY Stage_ID) AS rn
        FROM Stage.Cliente
        WHERE CustomerID COLLATE Latin1_General_BIN LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z]'
    )
    INSERT INTO Gobierno.Rechazado (Stage_ID, CustomerID, CompanyName, Motivo)
    SELECT Stage_ID, CustomerID, CompanyName, 'CustomerID duplicado'
    FROM v WHERE rn > 1;

    -- Carga a la dimensión (primera fila de cada ID válido) + T3
    ;WITH v AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY Stage_ID) AS rn
        FROM Stage.Cliente
        WHERE CustomerID COLLATE Latin1_General_BIN LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z]'
    )
    INSERT INTO DW.Dim_Cliente
        (Cliente_Codigo, Cliente_Compania, Cliente_Contacto, Cliente_Ciudad, Cliente_Pais, Cliente_Telefono)
    SELECT CustomerID,
           LTRIM(RTRIM(CompanyName)),
           NULLIF(LTRIM(RTRIM(ContactName)), N''),
           City,
           CASE LTRIM(RTRIM(Country))
                WHEN N'Alemania' THEN N'Germany'
                WHEN N'U.K.'     THEN N'UK'
                ELSE LTRIM(RTRIM(Country))
           END,
           Phone
    FROM v
    WHERE rn = 1;

    COMMIT TRANSACTION;
    PRINT '>> Carga a DW completada.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>> ERROR en la carga; se revirtió todo: ' + ERROR_MESSAGE();
    THROW;
END CATCH;

SELECT (SELECT COUNT(*) FROM Stage.Cliente)     AS Filas_Stage,
       (SELECT COUNT(*) FROM DW.Dim_Cliente)    AS Filas_DW,
       (SELECT COUNT(*) FROM Gobierno.Rechazado) AS Filas_Rechazadas;
