-- =====================================================================
-- 01_crear_objetos.sql
-- Crea la base de pruebas GobiernoMini y sus 3 esquemas:
--   Stage    -> copia cruda de la fuente (todo texto, todo permite nulos)
--   DW       -> dimensión final con restricciones
--   Gobierno -> resultados de calidad y registros rechazados
-- Es repetible: borra y recrea SOLO las 4 tablas de este proyecto.
-- Guardar/abrir con codificación UTF-8 (con BOM).
-- =====================================================================
USE master;
GO
IF DB_ID(N'GobiernoMini') IS NULL CREATE DATABASE GobiernoMini;
GO
USE GobiernoMini;
GO
IF SCHEMA_ID(N'Stage')    IS NULL EXEC(N'CREATE SCHEMA Stage');
IF SCHEMA_ID(N'DW')       IS NULL EXEC(N'CREATE SCHEMA DW');
IF SCHEMA_ID(N'Gobierno') IS NULL EXEC(N'CREATE SCHEMA Gobierno');
GO

DROP TABLE IF EXISTS Gobierno.Rechazado;
DROP TABLE IF EXISTS Gobierno.Resultado_DQ;
DROP TABLE IF EXISTS DW.Dim_Cliente;
DROP TABLE IF EXISTS Stage.Cliente;
GO

-- STAGE: copia cruda. Tipos amplios y todo NULL para que NINGÚN dato sea rechazado al cargar.
CREATE TABLE Stage.Cliente (
    Stage_ID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  NVARCHAR(10)  NULL,
    CompanyName NVARCHAR(60)  NULL,
    ContactName NVARCHAR(40)  NULL,
    City        NVARCHAR(30)  NULL,
    Country     NVARCHAR(30)  NULL,
    Phone       NVARCHAR(30)  NULL,
    Fecha_Carga DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

-- DW: dimensión final. Las restricciones hacen cumplir lo que dice el diccionario de datos.
CREATE TABLE DW.Dim_Cliente (
    Cliente_SKey     INT IDENTITY(1,1) PRIMARY KEY,
    Cliente_Codigo   CHAR(5)      NOT NULL CONSTRAINT UQ_Dim_Cliente_Codigo UNIQUE,
    Cliente_Compania NVARCHAR(40) NOT NULL,
    Cliente_Contacto NVARCHAR(30) NULL,
    Cliente_Ciudad   NVARCHAR(15) NULL,
    Cliente_Pais     NVARCHAR(15) NOT NULL,
    Cliente_Telefono VARCHAR(24)  NULL,
    Fecha_Carga      DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);

-- GOBIERNO: registros que NO pasaron al DW y por qué.
CREATE TABLE Gobierno.Rechazado (
    Rechazo_ID INT IDENTITY(1,1) PRIMARY KEY,
    Stage_ID   INT           NOT NULL,
    CustomerID NVARCHAR(10)  NULL,
    CompanyName NVARCHAR(60) NULL,
    Motivo     VARCHAR(40)   NOT NULL,
    Fecha      DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

-- GOBIERNO: resultado de cada regla de calidad en cada ejecución.
CREATE TABLE Gobierno.Resultado_DQ (
    Resultado_ID    INT IDENTITY(1,1) PRIMARY KEY,
    Fecha_Ejecucion DATETIME2    NOT NULL,
    Codigo_Regla    VARCHAR(10)  NOT NULL,
    Dimension_DQ    VARCHAR(20)  NOT NULL,
    Objeto_Evaluado VARCHAR(60)  NOT NULL,
    Volumen         INT          NOT NULL,
    Errores         INT          NOT NULL,
    Pct_Error       DECIMAL(5,2) NULL,
    Umbral_Pct      DECIMAL(5,2) NOT NULL,
    Estado          VARCHAR(10)  NOT NULL
        CONSTRAINT CK_Resultado_Estado CHECK (Estado IN ('APROBADO','FALLO','SIN_DATOS'))
);
GO
PRINT '>> Objetos creados en GobiernoMini.';
