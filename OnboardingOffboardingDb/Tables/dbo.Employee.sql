CREATE TABLE [dbo].[Employee]
(
[Id] [int] NOT NULL,
[NetId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RcpId] [int] NULL,
[Lastname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Firstname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateTimeCreated] [datetime] NOT NULL CONSTRAINT [DF_Employee_DateTimeCreated] DEFAULT (getdate()),
[DateTimeUpdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
