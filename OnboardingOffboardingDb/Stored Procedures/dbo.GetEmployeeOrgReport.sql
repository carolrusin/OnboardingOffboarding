SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Description:	Gets all EmployeeOrg records that represent differential changes between a start and end date for employee/org mappings
-- =============================================
CREATE PROCEDURE [dbo].[GetEmployeeOrgReport]
    (
      -- Add the parameters for the function here
      @start DATETIME ,
      @end DATETIME
    )
AS
    BEGIN
		DECLARE @startDateTime DATETIME = @start;
		DECLARE @endDateTime DATETIME = @end;

        WITH    records
                  AS ( SELECT   e.[Id] ,
                                e.[EmployeeId] ,
                                e.[OrgId] ,
                                e.[BeginDateTime] ,
                                e.[EndDateTime]
                       FROM     [EmployeeOrg] e
                       WHERE    -- overlaps start date (terminations)
                                ( e.BeginDateTime < @startDateTime
                                  AND ( e.EndDateTime >= @startDateTime
                                        AND e.EndDateTime <= @endDateTime
                                        AND e.EndDateTime IS NOT NULL
                                      )
                                )
				-- or overlaps end date (hirings)
                                OR ( e.BeginDateTime <= @endDateTime
                                     AND e.BeginDateTime >= @startDateTime
                                     AND ( e.EndDateTime >= @endDateTime
                                           OR e.EndDateTime IS NULL
                                         )
                                   )
                     )
            SELECT  e.[Id] ,
                    e.[EmployeeId] ,
                    e.[OrgId] ,
                    e.[BeginDateTime] ,
                    e.[EndDateTime] ,
                    o.[Name] AS OrgName ,
                    CASE WHEN past.EmployeeId IS NULL THEN 'NewEmployee'
                         ELSE CASE WHEN future.EmployeeId IS NULL
                                   THEN 'SeparatedEmployee'
                                   ELSE 'ExistingEmployeeUpdate'
                              END
                    END AS EmployeeStatus ,
                    CASE WHEN e.BeginDateTime >= @startDateTime THEN 1
                         ELSE 0
                    END AS Hire
            FROM    records e
                    LEFT OUTER JOIN ( SELECT DISTINCT
                                                e.EmployeeId
                                      FROM      [EmployeeOrg] e
                                      WHERE     e.BeginDateTime < @startDateTime
                                                AND ( e.EndDateTime IS NULL
                                                      OR e.EndDateTime >= @startDateTime
                                                    )
                                    ) past ON past.EmployeeId = e.EmployeeId
                    LEFT OUTER JOIN ( SELECT DISTINCT
                                                e.EmployeeId
                                      FROM      [EmployeeOrg] e
                                      WHERE     e.BeginDateTime <= @endDateTime
                                                AND ( e.EndDateTime > @endDateTime
                                                      OR e.EndDateTime IS NULL
                                                    )
                                    ) future ON future.EmployeeId = e.EmployeeId
                    LEFT OUTER JOIN ( SELECT    e.EmployeeId ,
                                                e.OrgId
                                      FROM      records e
                                      GROUP BY  e.EmployeeId ,
                                                e.OrgId
                                      HAVING    COUNT(*) >= 2
                                    ) nochange ON nochange.EmployeeId = e.EmployeeId
                                                  AND nochange.OrgId = e.OrgId
                    INNER JOIN Org o ON o.Id = e.OrgId
            WHERE   nochange.EmployeeId IS NULL

    END


GO
