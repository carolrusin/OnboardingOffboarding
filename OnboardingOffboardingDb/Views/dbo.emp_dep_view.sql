SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[emp_dep_view] AS
SELECT 
c.e1 AS employee_id
,c.d1 AS dept_code
,c.DeptHireDate
,d.DeptEndDate
,b.RutgersHireDate
,e.DeptTerminationDate
,f.RutgersTerminationDate
FROM 
(SELECT Employee_Id AS e1,DEPT_CODE AS d1,MIN(EffDt) AS DeptHireDate
FROM test_HRI_NC_EMPLOYEES_HIST a1
WHERE a1.SEPARATION_DATE IS NULL
GROUP BY Employee_Id,DEPT_CODE
) c 
LEFT OUTER JOIN	  
(SELECT Employee_Id AS e1,DEPT_CODE AS d1,MAX(Effective_end_dt) AS DeptEndDate
FROM test_HRI_NC_EMPLOYEES_HIST a1
WHERE a1.SEPARATION_DATE IS NULL
GROUP BY Employee_Id,DEPT_CODE
) d ON (c.e1 = d.e1 AND c.d1= d.d1)
LEFT OUTER JOIN
(SELECT Employee_Id AS e1,MIN(EffDt) AS RutgersHireDate
FROM test_HRI_NC_EMPLOYEES_HIST a1
WHERE a1.SEPARATION_DATE IS NULL
GROUP BY Employee_Id
) b ON (c.e1 = b.e1)
LEFT OUTER JOIN
(SELECT Employee_Id AS e12,DEPT_CODE AS d12,MAX(SEPARATION_DATE) AS DeptTerminationDate
	    FROM test_HRI_NC_EMPLOYEES_HIST a2
	    WHERE a2.SEPARATION_DATE IS NOT NULL
	    GROUP BY Employee_Id,DEPT_CODE) e
	    ON (c.e1 = e.e12
	    AND c.d1 = e.d12
	   )
LEFT OUTER JOIN
(SELECT Employee_Id AS e12,MAX(SEPARATION_DATE) AS RutgersTerminationDate
	    FROM test_HRI_NC_EMPLOYEES_HIST a2
	    WHERE a2.SEPARATION_DATE IS NOT NULL
	    AND a2.EFFECTIVE_END_DT = '2999-12-31'
	    GROUP BY Employee_Id) f
	    ON (c.e1 = f.e12)	   
--WHERE c.e1='00006814'

GO
