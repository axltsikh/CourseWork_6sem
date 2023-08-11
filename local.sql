create table AppUser(
	id integer primary key AUTOINCREMENT,
	username text,
	password text,
	changed integer
);

create table Organisation(
	id integer primary key AUTOINCREMENT,
	name text,password text,
	creatorID integer,
	changed integer,
	foreign key(creatorID) references AppUser(id)
);

create table OrganisationMember(
	id integer primary key AUTOINCREMENT,
	userID integer references AppUser(id),
	organisationID integer REFERENCES Organisation(id),
	deleted integer,
	changed integer
);

create table Project(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title text,	
	decription text,
	startDate date,
	endDate date,
	isDone INTEGER,
	changed INTEGER
);

create table ProjectMember(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	projectID integer references Project(id),
	deleted INTEGER default 0,
	changed INTEGER
);

alter table Project add column creatorID integer references ProjectMember(id)
alter table ProjectMember add column organisationMemberID integer references OrganisationMember(id);

create table SubTask(
	id integer PRIMARY KEY AUTOINCREMENT,
	parent INTEGER null,
	projectID INTEGER REFERENCES Project(id),
	title text,
	isDone integer,
	isTotallyDone integer,
	changed INTEGER,
	weakcreated integer,
	created integer
);

create table SubTaskExecutor(
	id integer PRIMARY KEY AUTOINCREMENT,
	subTaskID integer REFERENCES SubTask(id),
	executorID integer REFERENCES ProjectMember(id),
	changed INTEGER
);
