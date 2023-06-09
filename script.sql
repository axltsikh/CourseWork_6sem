USE [master]
GO
/****** Object:  Database [CourseWorkDatabase]    Script Date: 02.05.2023 10:08:01 ******/
CREATE DATABASE [CourseWorkDatabase]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CourseWorkDatabase', FILENAME = N'D:\SQLServer\MSSQL16.MSSQLSERVER\MSSQL\DATA\CourseWorkDatabase.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CourseWorkDatabase_log', FILENAME = N'D:\SQLServer\MSSQL16.MSSQLSERVER\MSSQL\DATA\CourseWorkDatabase_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [CourseWorkDatabase] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CourseWorkDatabase].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CourseWorkDatabase] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET ARITHABORT OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CourseWorkDatabase] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CourseWorkDatabase] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CourseWorkDatabase] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CourseWorkDatabase] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET RECOVERY FULL 
GO
ALTER DATABASE [CourseWorkDatabase] SET  MULTI_USER 
GO
ALTER DATABASE [CourseWorkDatabase] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CourseWorkDatabase] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CourseWorkDatabase] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CourseWorkDatabase] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CourseWorkDatabase] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CourseWorkDatabase] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'CourseWorkDatabase', N'ON'
GO
ALTER DATABASE [CourseWorkDatabase] SET QUERY_STORE = ON
GO
ALTER DATABASE [CourseWorkDatabase] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [CourseWorkDatabase]
GO
/****** Object:  Table [dbo].[Organisation]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organisation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[password] [nvarchar](50) NULL,
	[creatorID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrganisationMember]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganisationMember](
	[userID] [int] NULL,
	[organisationID] [int] NULL,
	[deleted] [bit] NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[getOrganisationsView]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[getOrganisationsView] as select Organisation.creatorID,Organisation.id,Organisation.name,Organisation.password,OrganisationMember.userID from Organisation inner join OrganisationMember on 
Organisation.id = OrganisationMember.organisationID and OrganisationMember.deleted!=1
GO
/****** Object:  Table [dbo].[AppUser]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](50) NULL,
	[password] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Project]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Project](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[decription] [nvarchar](50) NULL,
	[startDate] [date] NULL,
	[endDate] [date] NULL,
	[isDone] [bit] NULL,
	[creatorID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProjectMember]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProjectMember](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[projectID] [int] NULL,
	[organisationMemberID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubTask]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubTask](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parent] [int] NULL,
	[projectID] [int] NULL,
	[title] [nvarchar](50) NULL,
	[isDone] [bit] NULL,
	[isTotallyDone] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubTaskExecutor]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubTaskExecutor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[subTaskID] [int] NULL,
	[executorID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SubTask] ADD  DEFAULT ((0)) FOR [isTotallyDone]
GO
ALTER TABLE [dbo].[Organisation]  WITH CHECK ADD FOREIGN KEY([creatorID])
REFERENCES [dbo].[AppUser] ([id])
GO
ALTER TABLE [dbo].[OrganisationMember]  WITH CHECK ADD FOREIGN KEY([organisationID])
REFERENCES [dbo].[Organisation] ([id])
GO
ALTER TABLE [dbo].[OrganisationMember]  WITH CHECK ADD FOREIGN KEY([userID])
REFERENCES [dbo].[AppUser] ([id])
GO
ALTER TABLE [dbo].[Project]  WITH CHECK ADD FOREIGN KEY([creatorID])
REFERENCES [dbo].[ProjectMember] ([id])
GO
ALTER TABLE [dbo].[ProjectMember]  WITH CHECK ADD FOREIGN KEY([organisationMemberID])
REFERENCES [dbo].[OrganisationMember] ([id])
GO
ALTER TABLE [dbo].[ProjectMember]  WITH CHECK ADD FOREIGN KEY([projectID])
REFERENCES [dbo].[Project] ([id])
GO
ALTER TABLE [dbo].[SubTask]  WITH CHECK ADD FOREIGN KEY([projectID])
REFERENCES [dbo].[Project] ([id])
GO
ALTER TABLE [dbo].[SubTaskExecutor]  WITH CHECK ADD FOREIGN KEY([executorID])
REFERENCES [dbo].[ProjectMember] ([id])
GO
ALTER TABLE [dbo].[SubTaskExecutor]  WITH CHECK ADD FOREIGN KEY([subTaskID])
REFERENCES [dbo].[SubTask] ([id])
GO
/****** Object:  StoredProcedure [dbo].[AddExistingProjectMember]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddExistingProjectMember] @id int,@projectID int as
begin try
	insert into ProjectMember(projectID,organisationMemberID) values(@projectID,@id)
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[AddProjectMember]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddProjectMember] @id int as
begin try
	insert into ProjectMember(projectID,organisationMemberID) values(IDENT_CURRENT('Project'),@id)
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[ChangePassword]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[ChangePassword] @id int, @password nvarchar(50) as 
begin try
update AppUser set AppUser.password = @password where AppUser.id=@id
return 1
end try
begin catch
	return 0
end catch
GO
/****** Object:  StoredProcedure [dbo].[cleanProj]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[cleanProj] as
update Project set Project.creatorID=null
update ProjectMember set ProjectMember.projectID = null
delete from Project
delete from ProjectMember
GO
/****** Object:  StoredProcedure [dbo].[CommitChanges]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[CommitChanges] @SubTaskID int,@isDone bit as 
begin try
	if @isDone = 1
	begin
		update SubTask set SubTask.isTotallyDone =1 where SubTask.id=@SubTaskID
		update SubTask set SubTask.isDone = 1 where SubTask.id=@SubTaskID
	end
	else if @isDone = 0
		update SubTask set SubTask.isDone = 0 where SubTask.id = @SubTaskID
	return 1
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[CreateOrganisation]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CreateOrganisation] @organisationName nvarchar(50),@organisationPassword nvarchar(50),@creatorID int as
begin try
insert into Organisation(name,password,creatorID) values(@organisationName,@organisationPassword,@creatorID)
insert into OrganisationMember(userID,organisationID,deleted) values(@creatorID,IDENT_CURRENT('Organisation'),0)
return 1
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[CreateProject]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CreateProject] @title nvarchar(50), @description nvarchar(50),@startDate date,@endDate date,@organisationMemberID int as
begin try
insert into Project(title,decription,startDate,endDate,isDone) values(@title,@description,@startDate,@endDate,0)
insert into ProjectMember(projectID,organisationMemberID) values(IDENT_CURRENT('Project'),@organisationMemberID)
update Project set creatorID = IDENT_CURRENT('ProjectMember') where Project.id = IDENT_CURRENT('Project')
return 1
end try
begin catch
return 0
end catch
GO
/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[CreateUser]
	@name nvarchar(50),
	@password nvarchar(50)
as
begin try
insert into AppUser(username,password) values (@name,@password)
return 1
end try
begin catch
	return 0
end catch
GO
/****** Object:  StoredProcedure [dbo].[DeleteOrganisationMember]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DeleteOrganisationMember] @memberID int as 
begin try
update OrganisationMember set deleted = 1 where OrganisationMember.id = @memberID
return 1
end try
begin catch
return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[GetAllChildSubTasks]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetAllChildSubTasks] @projectID int as 
select * From SubTask where SubTask.projectID =1012 and SubTask.parent is not null
GO
/****** Object:  StoredProcedure [dbo].[GetAllChildSubTasksExecutors]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetAllChildSubTasksExecutors] as 
select SubTaskExecutor.id,SubTaskExecutor.subTaskID,AppUser.username from SubTaskExecutor inner join ProjectMember on ProjectMember.id=SubTaskExecutor.executorID inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID
inner join AppUser on AppUser.id=OrganisationMember.userID
GO
/****** Object:  StoredProcedure [dbo].[GetAllOrganisations]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetAllOrganisations] as 
select * from Organisation
GO
/****** Object:  StoredProcedure [dbo].[GetAllParentTasks]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetAllParentTasks] @projectID int as 
select * from SubTask where projectID=@projectID and parent IS NULL
GO
/****** Object:  StoredProcedure [dbo].[GetAllProjectMembers]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetAllProjectMembers] @projectID int as 
select ProjectMember.id,AppUser.username,OrganisationMember.id as organisationID from ProjectMember inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID and OrganisationMember.deleted=0 inner join AppUser on 
AppUser.id = OrganisationMember.userID where projectID = @projectID
GO
/****** Object:  StoredProcedure [dbo].[GetAllUserProjects]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetAllUserProjects] @userID int as 
select Project.id,Project.title,Project.creatorID,Project.decription as Description,Project.endDate,Project.isDone,Project.startDate
From Project inner join ProjectMember on Project.id = ProjectMember.projectID inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID
where OrganisationMember.userID=@userID and OrganisationMember.deleted=0
GO
/****** Object:  StoredProcedure [dbo].[GetChildSubTasksInfo]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetChildSubTasksInfo] @projectID int as 
select SubTaskExecutor.id as subTaskExecutorID,SubTaskExecutor.subTaskID ,AppUser.username,SubTask.title,SubTask.isDone,SubTask.parent,SubTask.isTotallyDone from SubTaskExecutor 
inner join ProjectMember on ProjectMember.id=SubTaskExecutor.executorID 
inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID
inner join AppUser on AppUser.id=OrganisationMember.userID 
inner join SubTask on SubTask.id = SubTaskExecutor.subTaskID and SubTask.projectID=@projectID and SubTask.parent is not null
GO
/****** Object:  StoredProcedure [dbo].[GetOrganisationMemberIDByUserID]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[GetOrganisationMemberIDByUserID] @userID int as
select * from OrganisationMember WHERE OrganisationMember.userID=@userID and OrganisationMember.deleted=0
GO
/****** Object:  StoredProcedure [dbo].[GetOrganisationMembers]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetOrganisationMembers] @userID int as
select OrganisationMember.id,AppUser.username from OrganisationMember inner join AppUser on AppUser.id = OrganisationMember.userID
where  OrganisationMember.organisationID = (Select OrganisationMember.organisationID from OrganisationMember 
where OrganisationMember.userID = @userID and OrganisationMember.deleted = 0) and OrganisationMember.userID!=@userID and OrganisationMember.deleted = 0
GO
/****** Object:  StoredProcedure [dbo].[GetProjectCreatorUserID]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetProjectCreatorUserID] @projectID int as 
select AppUser.id,AppUser.username,AppUser.password from Project inner join ProjectMember on Project.creatorID = ProjectMember.id inner join OrganisationMember on OrganisationMember.id = ProjectMember.organisationMemberID
inner join AppUser on AppUser.id = OrganisationMember.userID where Project.id = @projectID
GO
/****** Object:  StoredProcedure [dbo].[getUserOrganisation]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[getUserOrganisation] @userID int as 
select * from getOrganisationsView where getOrganisationsView.userID = @userID
GO
/****** Object:  StoredProcedure [dbo].[GetUserOrganisationByID]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[GetUserOrganisationByID] @userID int,@organisationName nvarchar(50) as
select * from Organisation where Organisation.creatorID = @userID and Organisation.name=@organisationName
GO
/****** Object:  StoredProcedure [dbo].[InsertChildSubTask]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[InsertChildSubTask] @title nvarchar(50), @projectID int,@parentID int as 
begin try
	insert into SubTask(parent,projectID,title,isDone) values (@parentID,@projectID,@title,0)
	return IDENT_CURRENT('SubTask')
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[InsertParentSubTask]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[InsertParentSubTask] @title nvarchar(50), @projectID int as 
begin try
	insert into SubTask(parent,projectID,title,isDone) values (null,@projectID,@title,0)
	return 1
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[InsertSubTaskExecutor]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[InsertSubTaskExecutor] @subTaskID int,@executorID int as 
begin try
	insert into SubTaskExecutor(subTaskID,executorID) values (@subTaskID,@executorID)
	return 1
end try
begin catch
	return -1
end catch
GO
/****** Object:  StoredProcedure [dbo].[JoinOrganisation]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[JoinOrganisation] @organisationID int, @userID int as 
begin try
if exists (select * from OrganisationMember where OrganisationMember.userID = @userID and OrganisationMember.organisationID = @organisationID and OrganisationMember.deleted=1)
begin
	update OrganisationMember set OrganisationMember.deleted = 0 where OrganisationMember.userID=@userID and OrganisationMember.organisationID=@organisationID and OrganisationMember.deleted=1
end
else
begin
	insert into OrganisationMember(organisationID,userID,deleted) values (@organisationID, @userID, 0)
end
return 1
end try
begin catch
return 0
end catch
GO
/****** Object:  StoredProcedure [dbo].[LeaveOrganisation]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[LeaveOrganisation] @userID int as 
update OrganisationMember set OrganisationMember.deleted = 1 where OrganisationMember.userID = @userID
GO
/****** Object:  StoredProcedure [dbo].[Login]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Login] @name nvarchar(50)
as
select AppUser.password,AppUser.id from AppUser where AppUser.username=@name
GO
/****** Object:  StoredProcedure [dbo].[OfferChanges]    Script Date: 02.05.2023 10:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[OfferChanges] @SubTaskID int,@isDone bit as 
begin try
	update SubTask set isDone=@isDone where SubTask.id=@SubTaskID
	return 1
end try
begin catch
	return -1
end catch
GO
USE [master]
GO
ALTER DATABASE [CourseWorkDatabase] SET  READ_WRITE 
GO
