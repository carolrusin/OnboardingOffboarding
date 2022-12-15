CREATE TABLE [dbo].[BatchLog]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[LogDateTime] [datetime] NOT NULL,
[Status] [int] NOT NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchLog] ADD CONSTRAINT [PK_BatchLog] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
