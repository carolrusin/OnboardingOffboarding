CREATE TABLE [dbo].[EmployeeOrgReplay]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EmployeeId] [int] NOT NULL,
[OrgId] [int] NOT NULL,
[BeginDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[EmployeeOrgReplay] TO [app_batchprocess]
GRANT UPDATE ON  [dbo].[EmployeeOrgReplay] TO [app_batchprocess]
GO

CREATE NONCLUSTERED INDEX [EmployeeOrgReplay_BeginDateTime_EndDateTime] ON [dbo].[EmployeeOrgReplay] ([BeginDateTime], [EndDateTime]) INCLUDE ([EmployeeId]) ON [PRIMARY]

ALTER TABLE [dbo].[EmployeeOrgReplay] ADD 
CONSTRAINT [PK_EmployeeOrgReplay] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
ALTER TABLE [dbo].[EmployeeOrgReplay] ADD
CONSTRAINT [FK_EmployeeOrgReplay_Employee] FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[Employee] ([Id])
ALTER TABLE [dbo].[EmployeeOrgReplay] ADD
CONSTRAINT [FK_EmployeeOrgReplay_Org] FOREIGN KEY ([OrgId]) REFERENCES [dbo].[Org] ([Id])



GO
