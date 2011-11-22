create table dbo.Title
(
	Id bigint IDENTITY PRIMARY KEY,
	Name nvarchar(50) not null unique,
	PushMessage nvarchar(MAX) not null,
	SiteRootPath nvarchar(MAX) not null,
	StandByPath nvarchar(MAX) not null,
)
go
create table dbo.Subscriber
(
	Id bigint IDENTITY PRIMARY KEY,
	TitleId bigint not null,
	constraint FK_Title_Subscriber foreign key (TitleId) references dbo.Title(id),
	AuthenticationKey nvarchar(100) not null unique,
	AuthScheme nvarchar(50) not null,
	LockoutUntil datetime not null
)
go
create table dbo.Token
(
	Id bigint IDENTITY PRIMARY KEY,
	SubscriberId bigint not null,
	constraint FK_Subscriber_Token foreign key (SubscriberId) references dbo.Subscriber(id),
	Body nvarchar(50) not null unique,
	PublishedDate datetime not null
)
go
create table dbo.APNs
(
	Id bigint IDENTITY PRIMARY KEY,
	SubscriberId bigint unique not null,
	constraint FK_Subscriber_APNs foreign key (SubscriberId) references dbo.Subscriber(id),
	DeviceToken nvarchar(MAX) not null,
	Failed bit not null,
	Invalid bit not null,
	UnreadRelease int not null
)
go
create table dbo.LVL
(
	Id bigint IDENTITY PRIMARY KEY,
	Nonce int not null,
	PublishedDate datetime not null
)
go
create table dbo.Credential
(
	Id bigint IDENTITY PRIMARY KEY,
	TitleId bigint not null,
	constraint FK_Title_Credential foreign key (TitleId) references dbo.Title(id),
	Kind nvarchar(50) not null,
	Body nvarchar(MAX) not null
)
go
