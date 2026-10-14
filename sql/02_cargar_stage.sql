-- =====================================================================
-- 02_cargar_stage.sql
-- Carga en Stage 21 clientes SINTÉTICOS inspirados en Northwind.
-- Las últimas 9 filas son anomalías sembradas a propósito (ver README).
-- =====================================================================
USE GobiernoMini;
GO
SET NOCOUNT ON;

INSERT INTO Stage.Cliente (CustomerID, CompanyName, ContactName, City, Country, Phone)
VALUES
    (N'ALFKI', N'Alfreds Futterkiste', N'Maria Anders', N'Berlin', N'Germany', N'030-0074321'),
    (N'ANATR', N'Ana Trujillo Emparedados y helados', N'Ana Trujillo', N'México D.F.', N'Mexico', N'(5) 555-4729'),
    (N'ANTON', N'Antonio Moreno Taquería', N'Antonio Moreno', N'México D.F.', N'Mexico', N'(5) 555-3932'),
    (N'AROUT', N'Around the Horn', N'Thomas Hardy', N'London', N'UK', N'(171) 555-7788'),
    (N'BERGS', N'Berglunds snabbköp', N'Christina Berglund', N'Luleå', N'Sweden', N'0921-12 34 65'),
    (N'BLAUS', N'Blauer See Delikatessen', N'Hanna Moos', N'Mannheim', N'Germany', N'0621-08460'),
    (N'BLONP', N'Blondesddsl père et fils', N'Frédérique Citeaux', N'Strasbourg', N'France', N'88.60.15.31'),
    (N'BOLID', N'Bólido Comidas preparadas', N'Martín Sommer', N'Madrid', N'Spain', N'(91) 555 22 82'),
    (N'BONAP', N'Bon app''', N'Laurence Lebihan', N'Marseille', N'France', N'91.24.45.40'),
    (N'BOTTM', N'Bottom-Dollar Markets', N'Elizabeth Lincoln', N'Tsawassen', N'Canada', N'(604) 555-4729'),
    (N'BSBEV', N'B''s Beverages', N'Victoria Ashworth', N'London', N'UK', N'(171) 555-1212'),
    (N'CACTU', N'Cactus Comidas para llevar', N'Patricio Simpson', N'Buenos Aires', N'Argentina', N'(1) 135-5555'),
    (N'ALFKI', N'Alfreds Futterkiste (registro repetido)', N'Maria Anders', N'Berlin', N'Germany', N'030-0074321'),
    (N'ANATR', N'Ana Trujillo Emparedados y helados', N'Ana Trujillo', N'México D.F.', N'Mexico', N'(5) 555-4729'),
    (N'CENTC', N'Centro comercial Moctezuma', NULL, N'México D.F.', N'Mexico', N'(5) 555-3392'),
    (N'CHOPS', N'Chop-suey Chinese', NULL, N'Bern', N'Switzerland', N'0452-076545'),
    (N'COMMI', N'Comércio Mineiro', NULL, N'São Paulo', N'Brazil', N'(11) 555-7647'),
    (N'CONSH1', N'Consolidated Holdings', N'Elizabeth Brown', N'London', N'UK', N'(171) 555-2282'),
    (N'fissa', N'FISSA Fabrica Inter. Salchichas', N'Diego Roel', N'Madrid', N'Spain', N'(91) 555 94 44'),
    (N'DRACD', N'Drachenblut Delikatessen', N'Sven Ottlieb', N'Aachen', N'Alemania', N'0241-039123'),
    (N'EASTC', N'Eastern Connection', N'Ann Devon', N'London', N'U.K.', N'(171) 555-0297');

PRINT '>> Stage.Cliente cargada con datos de prueba (incluye anomalías intencionales).';
SELECT COUNT(*) AS Filas_En_Stage FROM Stage.Cliente;
