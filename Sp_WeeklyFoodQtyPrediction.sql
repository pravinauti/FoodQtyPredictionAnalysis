  use  Project        
--EXEC Sp_WeeklyFoodQtyPrediction 'Mumbai',''

ALTER PROCEDURE Sp_WeeklyFoodQtyPrediction
(
@Location Varchar(20)
,@WeekDay Varchar(20)=Null
)
AS
BEGIN 
    Drop table if exists #Temp

	Declare @NoOfWeeks Int 
	Declare @Today Date = getdate()

	Set @NoOfWeeks=(select count(distinct (DatePart(week,  a.date))) 
	from Employee_Attendance a 
	where Status='Present')
	
	-- Find only Mon to Fri Skip Sat and Sun
	;WITH NextDays AS (
    SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
    FROM NextDays
    WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
	)
	SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName Into #Temp
	FROM NextDays
	WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
	ORDER BY DateValue


;WITH WeeklyAVGPrediction AS (
	Select Location,WeekDay,Item,
	sum(OrderQty /@NoOfWeeks) as AvgQuantity
	from (
		select o.Location,
		DATENAME(WEEKDAY, o.Order_Date) As WeekDay,
		o.Item,
		count(o.Order_ID) as OrderQty
		from Employee_Food_Orders o
		Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date 
		where o.Location=@Location
		and a.Status  IN ('Late','Present')
		group by o.Location,DATENAME(WEEKDAY, o.Order_Date),o.Item
	)A
	group by Location,WeekDay,Item
	),
	
	AdjustedPrediction AS (
		SELECT 
			WFP.Location,
			T.DateValue,
			WFP.WeekDay,
			WFP.Item,
			WFP.AvgQuantity,
			H.Event_Holiday,
			H.ImpactFactor,
			CASE
			  
				WHEN H.ImpactFactor =-10   THEN WFP.AvgQuantity * (1 - 1.00) -- Reduce by 100%
				WHEN H.ImpactFactor =-9    THEN WFP.AvgQuantity * (1 - 0.90) -- Reduce by 90%
				WHEN H.ImpactFactor =-8    THEN WFP.AvgQuantity * (1 - 0.80) -- Reduce by 80%
				WHEN H.ImpactFactor =-7    THEN WFP.AvgQuantity * (1 - 0.70) -- Reduce by 70%
				WHEN H.ImpactFactor =-6    THEN WFP.AvgQuantity * (1 - 0.60) -- Reduce by 60%
				WHEN H.ImpactFactor =-5    THEN WFP.AvgQuantity * (1 - 0.50) -- Reduce by 50%
				WHEN H.ImpactFactor =-4    THEN WFP.AvgQuantity * (1 - 0.40) -- Reduce by 40%
				WHEN H.ImpactFactor =-3    THEN WFP.AvgQuantity * (1 - 0.30) -- Reduce by 30%
				WHEN H.ImpactFactor =-2    THEN WFP.AvgQuantity * (1 - 0.20) -- Reduce by 20%
				WHEN H.ImpactFactor =-1    THEN WFP.AvgQuantity * (1 - 0.10) -- Reduce by 10%
				
				WHEN H.ImpactFactor =0     THEN WFP.AvgQuantity  -- No Changes 0%
				 
				WHEN H.ImpactFactor =1    THEN WFP.AvgQuantity * (1 + 0.10) -- Increase by 10%
				WHEN H.ImpactFactor =2    THEN WFP.AvgQuantity * (1 + 0.20) -- Increase by 20%
				WHEN H.ImpactFactor =3    THEN WFP.AvgQuantity * (1 + 0.30) -- Increase by 30%
				WHEN H.ImpactFactor =4    THEN WFP.AvgQuantity * (1 + 0.40) -- Increase by 40%
				WHEN H.ImpactFactor =6    THEN WFP.AvgQuantity * (1 + 0.60) -- Increase by 60%
				WHEN H.ImpactFactor =7    THEN WFP.AvgQuantity * (1 + 0.70) -- Increase by 70%
				WHEN H.ImpactFactor =8    THEN WFP.AvgQuantity * (1 + 0.80) -- Increase by 80%
				WHEN H.ImpactFactor =9    THEN WFP.AvgQuantity * (1 + 0.90) -- Increase by 90%
				WHEN H.ImpactFactor =10  THEN WFP.AvgQuantity *  (1 + 1.00) -- Increase by 100%
				ELSE WFP.AvgQuantity -- Default growth
			END AS Predicted_FoodOrders
		
		 FROM  WeeklyAVGPrediction WFP 
		 LEFT JOIN #Temp T ON T.DayName=WFP.WeekDay
		 LEFT JOIN Employee_Events_Holidays H ON T.DateValue=H.Date AND H.Location=@Location
	)

	SELECT Location,DateValue AS WeekDate,WeekDay,Item,AvgQuantity AS AnalysisFoodOrders, Event_Holiday,ImpactFactor
	,round(Predicted_FoodOrders,0) as Predicted_FoodOrders
	FROM AdjustedPrediction 
	ORDER BY Location, WeekDate;
END