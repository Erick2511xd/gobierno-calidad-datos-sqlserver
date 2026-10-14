-- =====================================================================
-- 05_verificar_diccionario.sql
-- Saca de SQL Server los tipos y nulabilidad REALES de DW.Dim_Cliente.
-- (Longitud: caracteres en columnas de texto, bytes en int/datetime2.)
-- Compara este resultado con docs/diccionario_datos.md: deben coincidir al 100%.
-- (Así el diccionario nunca contradice a la base de datos.)
-- =====================================================================
USE GobiernoMini;
GO
SELECT c.column_id                AS Orden,
       c.name                     AS Columna,
       ty.name                    AS Tipo,
       CASE WHEN ty.name IN ('nvarchar','nchar') THEN c.max_length / 2
            ELSE c.max_length END AS Longitud,   -- caracteres en texto; bytes en el resto
       CASE c.is_nullable WHEN 1 THEN 'SI' ELSE 'NO' END AS Permite_Nulos
FROM sys.columns c
JOIN sys.types   ty ON ty.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(N'DW.Dim_Cliente')
ORDER BY c.column_id;
