CREATE TABLE [dbo].[Org]
(
[Id] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[Org] ADD 
CONSTRAINT [PK_Org] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
