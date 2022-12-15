SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- This Stored Proc captures important events (like 'New Employee', 'Department Hire', 'Termination', 'Active')  
-- that happened for all employees linked with their respective department(s)
-- which again falls under the input date range

CREATE PROCEDURE [dbo].[PROC_EmployeeDeptDifferential]
	 @s1 DATETIME = '2012-08-09'
	,@e1 DATETIME = '2014-09-30'
	--,@EmpID VARCHAR(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
	SELECT e_main.*
	, (CASE WHEN @s1 = e_main.DeptHireDate THEN 'Dept Hired'
			WHEN @s1 = e_main.DeptTerminationDate THEN 'Dept Terminated'
			WHEN @s1 < e_main.RutgersHireDate THEN 'DO NOT EXISTS IN RUTGERS'
			WHEN @s1 < e_main.DeptHireDate THEN 'DO NOT EXISTS IN DEPT'
			WHEN @s1 > e_main.RutgersTerminationDate THEN 'DO NOT EXISTS IN RUTGERS'
			WHEN @s1 > e_main.DeptEndDate THEN 'DO NOT EXISTS IN DEPT'
			WHEN @s1 > e_main.DeptHireDate AND @s1 < e_main.DeptEndDate  THEN 'ACTIVE'
	ELSE 'Unhandled' END) AS EMP_START_STATUS
	,(CASE WHEN @e1 = e_main.DeptHireDate THEN 'Dept Hired'
			WHEN @e1 = e_main.DeptTerminationDate THEN 'Dept Terminated'
			WHEN @e1 < e_main.RutgersHireDate THEN 'DO NOT EXISTS IN RUTGERS'
			WHEN @e1 < e_main.DeptHireDate THEN 'DO NOT EXISTS IN DEPT'
			WHEN @e1 > e_main.RutgersTerminationDate THEN 'DO NOT EXISTS IN RUTGERS'
			WHEN @e1 > e_main.DeptEndDate THEN 'DO NOT EXISTS IN DEPT'
			WHEN @e1 > e_main.DeptHireDate AND @s1 < e_main.DeptEndDate  THEN 'ACTIVE'
	ELSE 'Unhandled' END) AS EMP_END_STATUS
	FROM emp_dep_view e_main
	--WHERE employee_id=@EmpID
	ORDER BY employee_id,dept_code	
END





--SELECT DISTINCT TOP 20000 EMPLOYEE_ID,Dept_Code,EffDt,Effective_end_dt,Separation_date
--		,b.RutgersHireDate
--		,c.DeptHireDate
--		,d.DeptTerminationDate
--		,(CASE WHEN d.DeptTerminationDate IS NOT null THEN 'Terminated'
--		  WHEN (@s1 = c.DeptHireDate OR @e1 = c.DeptHireDate) THEN 'New Department Hire' 
--		  WHEN @s1 = b.RutgersHireDate THEN 'NewEmployee'
--		 ELSE 'Active' END ) EmployeeStatus
--		--,(CASE WHEN a.EFFDT = @s1 THEN 'On Input Start Date'
--		--  WHEN a.Effective_end_dt = @e1 THEN 'On Input End Date'
--		--  WHEN (a.EFFDT > @s1 AND a.EFFDT < @e1) THEN 'Between Start and End Date'
--		--  ELSE 'Outside Input Range' END)'Aprox Event Occurance'
--FROM [CentralDataFeed].[dbo].[HRI_NC_EMPLOYEES_HIST] a
--LEFT OUTER JOIN
----For the current record/Dept level, get any Separation Date if any
--	  (SELECT Employee_Id AS e12,DEPT_CODE AS d12,MAX(SEPARATION_DATE) AS DeptTerminationDate
--	    FROM [CentralDataFeed].[dbo].[HRI_NC_EMPLOYEES_HIST] a2
--	    WHERE 
--	    (a2.SEPARATION_DATE = @s1 OR a2.SEPARATION_DATE = @e1)
--	    AND a2.SEPARATION_DATE IS NOT NULL
--	    GROUP BY Employee_Id,DEPT_CODE) d
--	    ON (a.EMPLOYEE_ID = d.e12
--	    AND a.DEPT_CODE = d.d12
--	   )
--LEFT OUTER JOIN
---- On an employee level, get when the employee started in Rutgers
----- ie the "Brand New HIRE Date' in Rutgers	   
--(SELECT Employee_Id AS e1,MIN(EffDt) AS RutgersHireDate
--	   FROM [CentralDataFeed].[dbo].[HRI_NC_EMPLOYEES_HIST] a1
--	   GROUP BY Employee_Id
--	  ) b
--ON (b.e1 = a.EMPLOYEE_ID)
--LEFT OUTER JOIN
----For the current record/Dept level, get min(EffDt) reflecting first HireDate
----in this current dept
--(SELECT Employee_Id AS e1,DEPT_CODE AS d1,MIN(EffDt) AS DeptHireDate
--	   FROM [CentralDataFeed].[dbo].[HRI_NC_EMPLOYEES_HIST] a1
--	   GROUP BY Employee_Id,DEPT_CODE
--	  ) c 
--ON (c.e1 = a.EMPLOYEE_ID
--    AND c.d1 = a.DEPT_CODE)	  	    
--WHERE ((@s1 BETWEEN EFFDT AND EFFECTIVE_END_DT)
--     OR
--     (@e1 BETWEEN EFFDT AND EFFECTIVE_END_DT))
--     --AND a.EMPLOYEE_ID = '00000021'
--ORDER BY EMPLOYEE_ID,DEPT_CODE,EFFDT
GO
