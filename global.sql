CREATE TABLE AppUser(
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[username] [nvarchar](50) NULL UNIQUE,
	[password] [nvarchar](50) NULL,
) ;

CREATE TABLE Organisation(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[password] [nvarchar](50) NULL,
	[creatorID] [int] FOREIGN KEY REFERENCES AppUser(id),
);

CREATE TABLE OrganisationMember(
	[userID] [int] FOREIGN KEY REFERENCES AppUser(id),
	[organisationID] [int] FOREIGN KEY REFERENCES Organisation(id),
	[deleted] [bit] NULL,
	[id] [int] IDENTITY(1,1) PRIMAEY KEY,
);

CREATE TABLE ProjectMember(
	[id] [int] IDENTITY(1,1) PRIMARY KEY,
	[projectID] [int] NULL,
	[organisationMemberID] [int] FOREIGN KEY REFERENCES OrganisationMember(id),
	[deleted] [bit] DEFAULT(0)
);

CREATE TABLE Project(
	[id] [int] IDENTITY(1,1) PRIMARY KEY,
	[title] [nvarchar](255) NULL,
	[decription] [nvarchar](255) NULL,
	[startDate] [date] NULL,
	[endDate] [date] NULL,
	[isDone] [bit] NULL,
	[creatorID] [int] NULL,
);

ALTER TABLE ProjectMember  ADD FOREIGN KEY(projectID)
REFERENCES Project (id)

ALTER TABLE Project ADD FOREIGN KEY(creatorID)
REFERENCES ProjectMember (id)

CREATE TABLE SubTask(
	[id] [int] IDENTITY(1,1) PRIMARY KEY,
	[parent] [int] NULL,
	[projectID] [int] FOREIGN KEY REFERENCES Project(id),
	[title] [nvarchar](50) NULL,
	[isDone] [bit] NULL,
	[isTotallyDone] [bit] DEFAULT(0),
);

CREATE TABLE SubTaskExecutor(
	[id] [int] IDENTITY(1,1) PRIMARY KEY,
	[subTaskID] [int] FOREIGN KEY REFERENCES SubTask(id),
	[executorID] [int] FOREIGN KEY REFERENCES ProjectMember(id),
);
