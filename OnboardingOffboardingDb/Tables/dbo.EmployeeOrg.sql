CREATE TABLE [dbo].[EmployeeOrg]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EmployeeId] [int] NOT NULL,
[OrgId] [int] NOT NULL,
[BeginDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NULL,
[HrBeginDateTime] [datetime] NOT NULL,
[HrEndDateTime] [datetime] NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[EmployeeOrg] ADD 
CONSTRAINT [PK_EmployeeOrg_1] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [EmployeeOrg_BeginDateTime_EndDateTime] ON [dbo].[EmployeeOrg] ([BeginDateTime], [EndDateTime]) INCLUDE ([EmployeeId]) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeOrg] ADD
CONSTRAINT [FK_EmployeeOrg_Employee] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employee] ([Id])
ALTER TABLE [dbo].[EmployeeOrg] ADD
CONSTRAINT [FK_EmployeeOrg_Org] FOREIGN KEY ([OrgId]) REFERENCES [dbo].[Org] ([Id])




GO
