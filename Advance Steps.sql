--USE project
-- Advance Steps 
--1. Find the Week Days only from Current Date like Mon to Fri (5 Day)
-- Skip Sat and Sunday from Current Date
 
 --Declare @Today Date =getdate()
 ----SET @Today='2025-06-25'
 -- ;WITH NextDays AS (
 --   SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
 --   UNION ALL
 --   SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
 --   FROM NextDays
 --   WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
	--)
	--SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName 
	--FROM NextDays
	--WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
	--ORDER BY DateValue

	
-- Step 2 : Update Code for AVG Prediction Qty
--2.1 Copy Avg Prediction Code remove SP and Declare manualy Variable and Commet the Weekday  

--Declare  
--@Location Varchar (20)='Mumbai'
--,@WeekDay Varchar(20)

--BEGIN
--   -- Declaration 
--	DECLARE @NoOfWeeks INT
--	SET  @NoOfWeeks =(select  count (distinct datepart(WEEK,Date)) NoOfWeek 
--					  from Employee_Attendance Where Status IN ('Present')
--					  )
--    Declare @Today Date =getdate()
--  -- End Declaration 

--	SELECT Location,WeekDay,Item,
--	(TotalQty/@NoOfWeeks) As AvgPredictionQty
--	FROM (
--			select O.Location,datename(WEEKDAY,O.Order_Date) As WeekDay
--			,O.Item,COUNT(Order_ID) AS TotalQty 
--			from Employee_Food_Orders O
--			INNER JOIN Employee_Attendance A ON O.Order_Date=A.Date AND O.Employee_ID=A.Employee_ID
--			WHERE A.Status IN ('Present')
--			and o.Location=@Location
--			--and datename(WEEKDAY,O.Order_Date)=@WeekDay
--			Group by O.Location,datename(WEEKDAY,O.Order_Date),O.Item
		
--		)Sub


--		order by Location,WeekDay,Item
--END

-- Step 2.2 Copy the Week Day Code and Insert data into Temp Table and Create CTE Table for Avg Prediction
--Declare  
--@Location Varchar (20)='Mumbai'
--,@WeekDay Varchar(20)

--BEGIN
--	-- Declartion 1 
--	Drop table if exists #TempTbl
--   -- Declaration 2
--	DECLARE @NoOfWeeks INT
--	SET  @NoOfWeeks =(select  count (distinct datepart(WEEK,Date)) NoOfWeek 
--					  from Employee_Attendance Where Status IN ('Present')
--					  )
--   -- Declaration 3
--	Declare @Today Date =getdate()
--	;WITH NextDays AS (
--	SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
--	UNION ALL
--	SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
--	FROM NextDays
--	WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
--	)
--	SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName  Into #TempTbl
--	FROM NextDays
--	WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
--	ORDER BY DateValue

--  -- End Declaration 
--  -- Main Query 
--; WITH WeeklyAVGPrediction 
--  AS
--  (
--	SELECT Location,WeekDay,Item,
--	(TotalQty/@NoOfWeeks) As AvgPredictionQty
--	FROM (
--			select O.Location,datename(WEEKDAY,O.Order_Date) As WeekDay
--			,O.Item,COUNT(Order_ID) AS TotalQty 
--			from Employee_Food_Orders O
--			INNER JOIN Employee_Attendance A ON O.Order_Date=A.Date AND O.Employee_ID=A.Employee_ID
--			WHERE A.Status IN ('Present')
--			and o.Location=@Location
--			--and datename(WEEKDAY,O.Order_Date)=@WeekDay
--			Group by O.Location,datename(WEEKDAY,O.Order_Date),O.Item
		
--		)Sub
--  )
--  select * from WeeklyAVGPrediction
--  order by Location,WeekDay,Item

--  select * from #TempTbl

--END

-- Step 3 : Find the Adjected Prediction 
--Step 3.1 : Under stand the Impact Factor Logic and Add Upcomming Holiday or Event into Event table 

--select * from Employee_Events_Holidays order by Date
--insert into Employee_Events_Holidays values('2025-06-24','Weather alert mumbai','Mumbai', -5),
--('2025-06-27','External Seesion -Gest Visit','Mumbai', 2)


--Step 3.2 : Join the Avg cte to Temp 
--Declare  
--@Location Varchar (20)='Mumbai'
--,@WeekDay Varchar(20)

--BEGIN
--	-- Declartion 1 
--	Drop table if exists #TempTbl
--   -- Declaration 2
--	DECLARE @NoOfWeeks INT
--	SET  @NoOfWeeks =(select  count (distinct datepart(WEEK,Date)) NoOfWeek 
--					  from Employee_Attendance Where Status IN ('Present')
--					  )
--   -- Declaration 3
--	Declare @Today Date =getdate()
--	;WITH NextDays AS (
--	SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
--	UNION ALL
--	SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
--	FROM NextDays
--	WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
--	)
--	SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName  Into #TempTbl
--	FROM NextDays
--	WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
--	ORDER BY DateValue

--  -- End Declaration 
--  -- Main Query 
--; WITH WeeklyAVGPrediction 
--  AS
--  (
--	SELECT Location,WeekDay,Item,
--	(TotalQty/@NoOfWeeks) As AvgPredictionQty
--	FROM (
--			select O.Location,datename(WEEKDAY,O.Order_Date) As WeekDay
--			,O.Item,COUNT(Order_ID) AS TotalQty 
--			from Employee_Food_Orders O
--			INNER JOIN Employee_Attendance A ON O.Order_Date=A.Date AND O.Employee_ID=A.Employee_ID
--			WHERE A.Status IN ('Present')
--			and o.Location=@Location
--			--and datename(WEEKDAY,O.Order_Date)=@WeekDay
--			Group by O.Location,datename(WEEKDAY,O.Order_Date),O.Item
		
--		)Sub
--  ),
--  -- Adjected Prediction
--  WeeklyADJPrediction 
--  AS
--  (

--  Select  WAP.Location
--  ,T.DateValue AS WeekDay
--  ,WAP.WeekDay AS WeekDays
--  ,WAP.Item AS Category 
--  ,WAP.AvgPredictionQty
--  ,EEH.Event_Holiday
--  ,EEH.ImpactFactor

--  from WeeklyAVGPrediction WAP
--  LEFT JOIN  #TempTbl T ON WAP.WeekDay=T.DayName
--  LEFT JOIN  Employee_Events_Holidays EEH ON T.DateValue=EEH.Date AND EEH.Location=WAP.Location
 
--    --select * from #TempTbl
--  ) 
--  select * from WeeklyADJPrediction

--END

--Step 3.3 : Write Logic for the Impact Factor Case Statement
--Declare  
--@Location Varchar (20)='Mumbai'
--,@WeekDay Varchar(20)

--BEGIN
--	-- Declartion 1 
--	Drop table if exists #TempTbl
--   -- Declaration 2
--	DECLARE @NoOfWeeks INT
--	SET  @NoOfWeeks =(select  count (distinct datepart(WEEK,Date)) NoOfWeek 
--					  from Employee_Attendance Where Status IN ('Present')
--					  )
--   -- Declaration 3
--	Declare @Today Date =getdate()
--	;WITH NextDays AS (
--	SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
--	UNION ALL
--	SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
--	FROM NextDays
--	WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
--	)
--	SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName  Into #TempTbl
--	FROM NextDays
--	WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
--	ORDER BY DateValue

--  -- End Declaration 
--  -- Main Query 
--; WITH WeeklyAVGPrediction 
--  AS
--  (
--	SELECT Location,WeekDay,Item,
--	(TotalQty/@NoOfWeeks) As AvgPredictionQty
--	FROM (
--			select O.Location,datename(WEEKDAY,O.Order_Date) As WeekDay
--			,O.Item,COUNT(Order_ID) AS TotalQty 
--			from Employee_Food_Orders O
--			INNER JOIN Employee_Attendance A ON O.Order_Date=A.Date AND O.Employee_ID=A.Employee_ID
--			WHERE A.Status IN ('Present')
--			and o.Location=@Location
--			--and datename(WEEKDAY,O.Order_Date)=@WeekDay
--			Group by O.Location,datename(WEEKDAY,O.Order_Date),O.Item
		
--		)Sub
--  ),
--  -- Adjected Prediction
--	  WeeklyADJPrediction 
--	  AS
--	  (

--	  Select  WAP.Location
--	  ,T.DateValue AS WeekDate
--	  ,WAP.WeekDay AS WeekDays
--	  ,WAP.Item AS Category 
--	  ,WAP.AvgPredictionQty
--	  ,EEH.Event_Holiday
--	  ,EEH.ImpactFactor
--	  ,CASE 
--		  WHEN EEH.ImpactFactor =-10 THEN WAP.AvgPredictionQty *(1-1.00) 
--		  WHEN EEH.ImpactFactor =-9 THEN WAP.AvgPredictionQty *(1-0.90)
--		  WHEN EEH.ImpactFactor =-8 THEN WAP.AvgPredictionQty *(1-0.80)
--		  WHEN EEH.ImpactFactor =-7 THEN WAP.AvgPredictionQty *(1-0.70)
--		  WHEN EEH.ImpactFactor =-6 THEN WAP.AvgPredictionQty *(1-0.60)
--		  WHEN EEH.ImpactFactor =-5 THEN WAP.AvgPredictionQty *(1-0.50)
--		  WHEN EEH.ImpactFactor =-4 THEN WAP.AvgPredictionQty *(1-0.40)
--		  WHEN EEH.ImpactFactor =-3 THEN WAP.AvgPredictionQty *(1-0.30)
--		  WHEN EEH.ImpactFactor =-2 THEN WAP.AvgPredictionQty *(1-0.20)
--		  WHEN EEH.ImpactFactor =-1 THEN WAP.AvgPredictionQty *(1-0.10)
--		  WHEN EEH.ImpactFactor =0  THEN WAP.AvgPredictionQty
--		  WHEN EEH.ImpactFactor =1 THEN WAP.AvgPredictionQty *(1+0.10)
--		  WHEN EEH.ImpactFactor =2 THEN WAP.AvgPredictionQty *(1+0.20)
--		  WHEN EEH.ImpactFactor =3 THEN WAP.AvgPredictionQty *(1+0.30)
--		  WHEN EEH.ImpactFactor =4 THEN WAP.AvgPredictionQty *(1+0.40)
--		  WHEN EEH.ImpactFactor =5 THEN WAP.AvgPredictionQty *(1+0.50)
--		  WHEN EEH.ImpactFactor =6 THEN WAP.AvgPredictionQty *(1+0.60)
--		  WHEN EEH.ImpactFactor =7 THEN WAP.AvgPredictionQty *(1+0.70)
--		  WHEN EEH.ImpactFactor =8 THEN WAP.AvgPredictionQty *(1+0.80)
--		  WHEN EEH.ImpactFactor =9 THEN WAP.AvgPredictionQty *(1+0.90)
--		  WHEN EEH.ImpactFactor =10 THEN WAP.AvgPredictionQty *(1+1.00)
--		  ELSE WAP.AvgPredictionQty  
--		END AS AdjQty
--		from WeeklyAVGPrediction WAP
--		LEFT JOIN  #TempTbl T ON WAP.WeekDay=T.DayName
--		LEFT JOIN  Employee_Events_Holidays EEH ON T.DateValue=EEH.Date AND EEH.Location=WAP.Location 
--  )

--  select Location,WeekDate,WeekDays,Category,AvgPredictionQty,Event_Holiday,ImpactFactor,
--  round (AdjQty,0) as AdjPredictionQty
--  from WeeklyADJPrediction
--  Order by Location,WeekDate
--END


--Step 4 : Create Procedure with Input Parameter 
--exec WeeklyFoodQtyPredictionAnalysis 'Mumbai'

alter PROCEDURE WeeklyFoodQtyPredictionAnalysis
(
@Location Varchar (20)
,@WeekDay Varchar(20)=null
)
AS

BEGIN
	-- Declartion 1 
	Drop table if exists #TempTbl
   -- Declaration 2
	DECLARE @NoOfWeeks INT
	SET  @NoOfWeeks =(select  count (distinct datepart(WEEK,Date)) NoOfWeek 
					  from Employee_Attendance Where Status IN ('Present')
					  )
   -- Declaration 3
	Declare @Today Date =getdate()
	;WITH NextDays AS (
	SELECT  CAST(@Today AS DATE) AS DateValue, 1 AS DayNumber
	UNION ALL
	SELECT DATEADD(DAY, 1, DateValue), DayNumber + 1
	FROM NextDays
	WHERE DayNumber < 10  -- Check next 10 days to ensure 5 weekdays
	)
	SELECT TOP 5  DateValue, DATENAME(WEEKDAY, DateValue) AS DayName  Into #TempTbl
	FROM NextDays
	WHERE DATEPART(WEEKDAY, DateValue) NOT IN (1, 7)  -- Exclude Sunday (1) and Saturday (7)
	ORDER BY DateValue

  -- End Declaration 
  -- Main Query 
; WITH WeeklyAVGPrediction 
  AS
  (
	SELECT Location,WeekDay,Item,
	(TotalQty/@NoOfWeeks) As AvgPredictionQty
	FROM (
			select O.Location,datename(WEEKDAY,O.Order_Date) As WeekDay
			,O.Item,COUNT(Order_ID) AS TotalQty 
			from Employee_Food_Orders O
			INNER JOIN Employee_Attendance A ON O.Order_Date=A.Date AND O.Employee_ID=A.Employee_ID
			WHERE A.Status IN ('Present')
			and o.Location=@Location
			--and datename(WEEKDAY,O.Order_Date)=@WeekDay
			Group by O.Location,datename(WEEKDAY,O.Order_Date),O.Item
		
		)Sub
  ),
  -- Adjected Prediction
	  WeeklyADJPrediction 
	  AS
	  (

	  Select  WAP.Location
	  ,T.DateValue AS WeekDate
	  ,WAP.WeekDay AS WeekDays
	  ,WAP.Item AS Category 
	  ,WAP.AvgPredictionQty
	  ,EEH.Event_Holiday
	  ,EEH.ImpactFactor
	  ,CASE 
		  WHEN EEH.ImpactFactor =-10 THEN WAP.AvgPredictionQty *(1-1.00) 
		  WHEN EEH.ImpactFactor =-9 THEN WAP.AvgPredictionQty *(1-0.90)
		  WHEN EEH.ImpactFactor =-8 THEN WAP.AvgPredictionQty *(1-0.80)
		  WHEN EEH.ImpactFactor =-7 THEN WAP.AvgPredictionQty *(1-0.70)
		  WHEN EEH.ImpactFactor =-6 THEN WAP.AvgPredictionQty *(1-0.60)
		  WHEN EEH.ImpactFactor =-5 THEN WAP.AvgPredictionQty *(1-0.50)
		  WHEN EEH.ImpactFactor =-4 THEN WAP.AvgPredictionQty *(1-0.40)
		  WHEN EEH.ImpactFactor =-3 THEN WAP.AvgPredictionQty *(1-0.30)
		  WHEN EEH.ImpactFactor =-2 THEN WAP.AvgPredictionQty *(1-0.20)
		  WHEN EEH.ImpactFactor =-1 THEN WAP.AvgPredictionQty *(1-0.10)
		  WHEN EEH.ImpactFactor =0  THEN WAP.AvgPredictionQty
		  WHEN EEH.ImpactFactor =1 THEN WAP.AvgPredictionQty *(1+0.10)
		  WHEN EEH.ImpactFactor =2 THEN WAP.AvgPredictionQty *(1+0.20)
		  WHEN EEH.ImpactFactor =3 THEN WAP.AvgPredictionQty *(1+0.30)
		  WHEN EEH.ImpactFactor =4 THEN WAP.AvgPredictionQty *(1+0.40)
		  WHEN EEH.ImpactFactor =5 THEN WAP.AvgPredictionQty *(1+0.50)
		  WHEN EEH.ImpactFactor =6 THEN WAP.AvgPredictionQty *(1+0.60)
		  WHEN EEH.ImpactFactor =7 THEN WAP.AvgPredictionQty *(1+0.70)
		  WHEN EEH.ImpactFactor =8 THEN WAP.AvgPredictionQty *(1+0.80)
		  WHEN EEH.ImpactFactor =9 THEN WAP.AvgPredictionQty *(1+0.90)
		  WHEN EEH.ImpactFactor =10 THEN WAP.AvgPredictionQty *(1+1.00)
		  ELSE WAP.AvgPredictionQty  
		END AS AdjQty
		from WeeklyAVGPrediction WAP
		LEFT JOIN  #TempTbl T ON WAP.WeekDay=T.DayName
		LEFT JOIN  Employee_Events_Holidays EEH ON T.DateValue=EEH.Date AND EEH.Location=WAP.Location 
  )

  select Location,WeekDate,WeekDays,Category,AvgPredictionQty,Event_Holiday,ImpactFactor,
  round (AdjQty,0) as AdjPredictionQty
  from WeeklyADJPrediction
  Order by Location,WeekDate
END