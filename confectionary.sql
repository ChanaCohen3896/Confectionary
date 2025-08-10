-- Confectionary order tracking database
-- Implements table, sample data, and reporting queries for business scenario

-- 1. Schema ---------------------------------------------------------------
DROP TABLE IF EXISTS dbo.[Order];
GO

CREATE TABLE dbo.[Order] (
    OrderID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Branch       NVARCHAR(50)  NOT NULL,
    OrderDate    DATE          NOT NULL,
    Base         NVARCHAR(50)  NOT NULL,
    Item         NVARCHAR(20)  NOT NULL, -- Cake, Cookie, or Cupcake
    Topping      NVARCHAR(50)  NULL,
    HasPicture   BIT           NOT NULL,
    Specifics    NVARCHAR(255) NULL,
    Occasion     NVARCHAR(50)  NOT NULL,
    Amount       INT           NOT NULL,
    PricePer AS (
        CASE Item
            WHEN 'Cake' THEN 50
                         + CASE WHEN Base = 'Strawberry shortcake' THEN 5 ELSE 0 END
                         + CASE WHEN HasPicture = 1 THEN 8 ELSE 0 END
            WHEN 'Cupcake' THEN 3
            WHEN 'Cookie' THEN 3.50
                         + CASE WHEN HasPicture = 1 THEN 1.50 ELSE 0 END
        END)
        PERSISTED,
    TotalPrice AS (Amount * (
        CASE Item
            WHEN 'Cake' THEN 50
                         + CASE WHEN Base = 'Strawberry shortcake' THEN 5 ELSE 0 END
                         + CASE WHEN HasPicture = 1 THEN 8 ELSE 0 END
            WHEN 'Cupcake' THEN 3
            WHEN 'Cookie' THEN 3.50
                         + CASE WHEN HasPicture = 1 THEN 1.50 ELSE 0 END
        END))
        PERSISTED,
    CONSTRAINT CHK_Item CHECK (Item IN ('Cake', 'Cookie', 'Cupcake')),
    CONSTRAINT CHK_Base CHECK (
        (Item = 'Cookie' AND Base = 'Sugar') OR
        (Item IN ('Cake', 'Cupcake') AND Base IN (
            'Chocolate', 'Vanilla', 'Coconut', 'Chocolate peanut butter', 'Banana', 'Strawberry shortcake'
        ))
    ),
    CONSTRAINT CHK_Amount CHECK (
        (Item = 'Cookie' AND Amount BETWEEN 24 AND 500) OR
        (Item = 'Cupcake' AND Amount BETWEEN 12 AND 500) OR
        (Item = 'Cake' AND Amount >= 1)
    ),
    CONSTRAINT CHK_HasPicture CHECK (Item <> 'Cupcake' OR HasPicture = 0)
);
GO

-- 2. Sample Data ---------------------------------------------------------
INSERT INTO dbo.[Order]
    (CustomerName, Branch, OrderDate, Base, Item, Topping, HasPicture, Specifics, Occasion, Amount)
VALUES
    ('Chaim Green',        'Lakewood', '2022-01-04', 'Strawberry shortcake', 'Cake',   NULL,         0, 'Please make sure they both look the same', 'Baby',            2),
    ('Rivky Shapiro',      'Lakewood', '2021-07-22', 'Chocolate',            'Cake',   'Caramel',    0, 'Write Happy birthday on cake',            'Birthday',        1),
    ('Leah Gross',         'Brooklyn', '2021-06-11', 'Sugar',                'Cookie', 'Royal icing',1, 'Graduation cap shape of picture I emailed','Graduation',      70),
    ('Baruch Goldberg',    'Brooklyn', '2021-09-12', 'Sugar',                'Cookie', 'Royal icing',0, 'Shape of a mask and write thank you for keeping everyone safe and company logo','Company logo',500),
    ('Binyamin Stein',     'Lakewood', '2021-02-15', 'Vanilla',              'Cake',   'Chocolate',  1, 'Write Happy 85th birthday on bottom of the attached photo','Birthday',3),
    ('Batsheva Golden',    'Lakewood', '2021-08-14', 'Chocolate peanut butter','Cake','Peanut butter',1,'Write Shloimy and the number 3 on pic','Birthday',1),
    ('Rena Stern',         'Brooklyn', '2021-10-11', 'Sugar',                'Cookie', 'Fondant',    0, 'Pink background with glitter and shape of balloon with word Sori','Bas mitzvah',75),
    ('Layala Katz',        'Lakewood', '2021-09-05', 'Vanilla',              'Cupcake','Strawberry', 0, 'Make it look nice!',                    'Birthday',        28),
    ('Sara Leah Levy',     'Brooklyn', '2021-05-18', 'Vanilla',              'Cupcake','Coconut',    0, 'none',                                   'Engagement',     100),
    ('Devorah Friedman',   'Brooklyn', '2021-07-04', 'Strawberry shortcake', 'Cake',   NULL,         0, 'none',                                   'Wedding',        15),
    ('Kaufman',            'Lakewood', '2021-11-09', 'Chocolate peanut butter','Cake','Chocolate', 0, 'none',                                   'Bar mitzvah',     3),
    ('Chana Cohen',        'Lakewood', '2021-07-04', 'Banana',               'Cake',   'Vanilla',    1, 'Attached photo',                         'Anniversary',     1),
    ('Ahuva Licht',        'Lakewood', '2021-06-22', 'Sugar',                'Cookie', 'Royal icing',0, 'Write Chaim and Devorah',               'Engagement',     75),
    ('Tziporah Markowitz', 'Lakewood', '2021-03-16', 'Strawberry shortcake', 'Cake',   NULL,         0, 'none',                                   'Baby',            3),
    ('David Fried',        'Lakewood', '2021-10-01', 'Chocolate peanut butter','Cake','Chocolate', 0, 'none',                                   'Bar mitzvah',     2),
    ('Moshe Abrams',       'Brooklyn', '2021-08-23', 'Vanilla',              'Cupcake','Peanut butter',0,'Write 3 on it',                         'Birthday',       150),
    ('Rachel Bernstein',   'Lakewood', '2021-02-28', 'Sugar',                'Cookie', 'Fondant',    1, 'Attached photo of daughter',            'Bas mitzvah',    80),
    ('Faiga Berg',         'Brooklyn', '2021-10-12', 'Chocolate',            'Cupcake','Chocolate', 0, 'Add a pecan on each one',                'Event',          350),
    ('Dena Bergman',       'Brooklyn', '2021-06-08', 'Sugar',                'Cookie', 'Royal icing',0, 'Write Shimon and Leah',                 'Engagement',     75),
    ('Asher Yechiel Eisen','Brooklyn', '2021-12-31', 'Sugar',                'Cookie', 'Royal icing',0, 'In shape of thirteen',                  'Bar mitzvah',    175),
    ('Mendy Fischer',      'Lakewood', '2021-07-04', 'Banana',               'Cupcake','Vanilla',    0, 'For new baby',                          'Baby',          100),
    ('Chaya Kaplan',       'Lakewood', '2021-01-01', 'Chocolate',            'Cupcake','Vanilla',    0, 'Make it taste great please',           'Birthday',      100),
    ('Sarala Schwartz',    'Brooklyn', '2021-06-09', 'Chocolate',            'Cupcake','Vanilla',    0, 'none',                                   'Baby',           50),
    ('Sarah Braunstein',   'Brooklyn', '2021-10-24', 'Sugar',                'Cookie', 'Royal icing',1, 'See attached picture of my house',      'Family party',  110);
GO

-- 3. Reports -------------------------------------------------------------

-- Report 1: Sum of how many of each type of product and base sold per branch
SELECT Branch, Item, Base, SUM(Amount) AS TotalSold
FROM dbo.[Order]
GROUP BY Branch, Item, Base
ORDER BY Branch, Item, Base;
GO

-- Report 2: Orders per season, event, and branch
SELECT
    CASE
        WHEN MONTH(OrderDate) IN (7,8) THEN 'Summer'
        WHEN MONTH(OrderDate) IN (9,10) THEN 'Holiday time'
        WHEN MONTH(OrderDate) IN (11,12,1,2,3,4) THEN 'Winter'
        WHEN MONTH(OrderDate) IN (5,6) THEN 'Spring'
    END AS Season,
    Occasion,
    Branch,
    COUNT(*) AS Orders
FROM dbo.[Order]
GROUP BY CASE
            WHEN MONTH(OrderDate) IN (7,8) THEN 'Summer'
            WHEN MONTH(OrderDate) IN (9,10) THEN 'Holiday time'
            WHEN MONTH(OrderDate) IN (11,12,1,2,3,4) THEN 'Winter'
            WHEN MONTH(OrderDate) IN (5,6) THEN 'Spring'
        END,
        Occasion,
        Branch
ORDER BY Season, Occasion, Branch;
GO

-- Report 3: Revenue per month per branch
SELECT
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    Branch,
    SUM(TotalPrice) AS Revenue
FROM dbo.[Order]
GROUP BY YEAR(OrderDate), MONTH(OrderDate), Branch
ORDER BY [Year], [Month], Branch;
GO

-- Report 4: Number of orders per month per branch
SELECT
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    Branch,
    COUNT(*) AS Orders
FROM dbo.[Order]
GROUP BY YEAR(OrderDate), MONTH(OrderDate), Branch
ORDER BY [Year], [Month], Branch;
GO

-- Earliest order date ----------------------------------------------------
SELECT MIN(OrderDate) AS EarliestOrder
FROM dbo.[Order];
GO

