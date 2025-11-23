INSERT INTO dbo.DimDate (
    DateSK, 
    FullDate, 
    [Year], 
    [Month], 
    [Day], 
    DayOfWeek, 
    MonthName, 
    QuarterName, 
    IsWeekend, 
    IsHoliday, 
    Season
)
VALUES (
    1,                    -- DateSK
    '1900-01-01',        -- FullDate
    1900,                -- [Year]
    1,                   -- [Month]
    1,                   -- [Day]
    2,                   -- DayOfWeek (Monday, assuming @@DATEFIRST 7)
    'January',           -- MonthName
    'Q1',                -- QuarterName
    0,                   -- IsWeekend (Monday is not a weekend)
    1,                   -- IsHoliday (assuming New Year's Day is a holiday)
    'Winter'             -- Season
);