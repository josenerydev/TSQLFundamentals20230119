---------------------------------------------------------------------
-- T-SQL Fundamentals Fourth Edition
-- Chapter 11 - SQL Graph
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Creating tables
---------------------------------------------------------------------

USE TSQLV6;
GO
CREATE SCHEMA Norm; -- schema for traditional modeling
GO
CREATE SCHEMA Graph; -- schema for graph modeling
GO

---------------------------------------------------------------------
-- Traditional modeling
---------------------------------------------------------------------

-- Accounts
CREATE TABLE Norm.Accounts
(
  accountid        INT          NOT NULL,
  accountname      NVARCHAR(50) NOT NULL,
  joindate         DATE         NOT NULL
    CONSTRAINT DFT_Accounts_joindate DEFAULT(SYSDATETIME()),
  reputationpoints INT          NOT NULL
    CONSTRAINT DFT_Accounts_reputationpoints DEFAULT(0),
  CONSTRAINT PK_Accounts PRIMARY KEY(accountid)
);

INSERT INTO Norm.Accounts
  (accountid, accountname, joindate, reputationpoints) VALUES
  (641, N'Inka'  , '20200801',  5),
  ( 71, N'Miko'  , '20210514',  8),
  (379, N'Tami'  , '20211003',  5),
  (421, N'Buzi'  , '20210517',  8),
  (661, N'Alma'  , '20210119', 13),
  (  2, N'Orli'  , '20220202',  2),
  (941, N'Stav'  , '20220105',  1),
  (953, N'Omer'  , '20220315',  0),
  (727, N'Mitzi' , '20200714',  3),
  (883, N'Yatzek', '20210217',  3),
  (199, N'Lilach', '20220112',  1);

-- Posts
CREATE TABLE Norm.Posts
(
  postid       INT            NOT NULL,
  parentpostid INT            NULL,
  accountid    INT            NOT NULL,
  dt           DATETIME2(0)   NOT NULL
    CONSTRAINT DFT_Posts_dt DEFAULT(SYSDATETIME()),
  posttext     NVARCHAR(1000) NOT NULL,
  CONSTRAINT PK_Posts PRIMARY KEY(postid),
  CONSTRAINT FK_Posts_Accounts FOREIGN KEY(accountid)
    REFERENCES Norm.Accounts(accountid),
  CONSTRAINT FK_Posts_Posts FOREIGN KEY(parentpostid)
    REFERENCES Norm.Posts(postid)
);

INSERT INTO Norm.Posts
  (postid, parentpostid, accountid, dt, posttext) VALUES
  (  13, NULL, 727,  '20200921 13:09:46' ,
   N'Got a new kitten. Any suggestions for a name?'),
  ( 109, NULL,  71,  '20210515 17:00:00' ,
   N'Starting to hike the PCT today. Wish me luck!'),
  ( 113, NULL, 421,  '20210517 10:21:33' ,
   N'Buzi here. This is my first post.'),
  ( 149, NULL, 421,  '20210519 14:05:45' ,
   N'Buzi here. This is my second post.'
     + N' Aren''t my posts exciting?'),
  ( 179, NULL, 421,  '20210520 09:12:17' ,
   N'Buzi here. Guess what; this is my third post!'),
  ( 199, NULL,  71,  '20210802 15:56:02' ,
   N'Made it to Oregon!'),
  ( 239, NULL, 883,  '20220219 09:31:23' ,
   N'I''m thinking of growing a mustache,'
     + N' but am worried about milk drinking...'),
  ( 281, NULL, 953,  '20220318 08:14:24' ,
   N'Burt Shavits: "A good day is when no one shows up'
     + N' and you don''t have to go anywhere."'),
  ( 449,   13, 641,  '20200921 13:10:30' ,
   N'Maybe Pickle?'),
  ( 677,   13, 883,  '20200921 13:12:22' ,
   N'Ambrosius?'),
  ( 857,  109, 883,  '20210515 17:02:13' ,
   N'Break a leg. I mean, don''t!'),
  ( 859,  109, 379,  '20210515 17:04:21' ,
   N'The longest I''ve seen you hike was...'
     + N'wait, I''ve never seen you hike ;)'),
  ( 883,  109, 199,  '20210515 17:23:43' ,
   N'Ha ha ha!'),
  (1021,  449,   2,  '20200921 13:44:17' ,
   N'It does look a bit sour faced :)'),
  (1031,  449, 379,  '20200921 14:02:03' ,
   N'How about Gherkin?'),
  (1051,  883,  71,  '20210515 17:24:35' ,
   N'Jokes aside, is 95lbs reasonable for my backpack?'),
  (1061, 1031, 727,  '20200921 14:07:51' ,
   N'I love Gherkin!'),
  (1151, 1051, 379,  '20210515 18:40:12' ,
   N'Short answer, no! Long answer, nooooooo!!!'),
  (1153, 1051, 883,  '20210515 18:47:17' ,
   N'Say what!?'),
  (1187, 1061, 641,  '20200921 14:07:52' ,
   N'So you don''t like Pickle!? I''M UNFRIENDING YOU!!!'),
  (1259, 1151,  71,  '20210515 19:05:54' ,
   N'Did I say that was without water?');

-- Publications
CREATE TABLE Norm.Publications
(
  pubid   INT          NOT NULL,
  pubdate DATE         NOT NULL,
  title   NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_Publications PRIMARY KEY(pubid)
);

INSERT INTO Norm.Publications(pubid, pubdate, title) VALUES
  (23977, '20200912' , N'When Mitzi met Inka'),
  ( 4967, '20210304' , N'When Mitzi left Inka'),
  (27059, '20210401' , N'It''s actually Inka who left Mitzi'),
  (14563, '20210802' ,
   N'Been everywhere, seen it all; there''s no place like home!'),
  (46601, '20220119' , N'Love at first second');

-- Friendships
CREATE TABLE Norm.Friendships
(
  accountid1 INT  NOT NULL,
  accountid2 INT  NOT NULL,
  startdate  DATE NOT NULL
    CONSTRAINT DFT_Friendships_startdate DEFAULT(SYSDATETIME()),
  CONSTRAINT PK_Friendships PRIMARY KEY(accountid1, accountid2),
  -- undirected graph; don't allow mirrored pair
  CONSTRAINT CHK_Friendships_act1_lt_act2
    CHECK(accountid1 < accountid2),
  CONSTRAINT FK_Friendships_Accounts_act1 FOREIGN KEY(accountid1)
    REFERENCES Norm.Accounts(accountid),
  CONSTRAINT FK_Friendships_Accounts_act2 FOREIGN KEY(accountid2)
    REFERENCES Norm.Accounts(accountid)
);

INSERT INTO Norm.Friendships
  (accountid1, accountid2, startdate) VALUES
  (  2, 379, '20220202'),
  (  2, 641, '20220202'),
  (  2, 727, '20220202'),
  ( 71, 199, '20220112'),
  ( 71, 379, '20211003'),
  ( 71, 661, '20210514'),
  ( 71, 883, '20210514'),
  ( 71, 953, '20220315'),
  (199, 661, '20220112'),
  (199, 883, '20220112'),
  (199, 941, '20220112'),
  (199, 953, '20220315'),
  (379, 421, '20211003'),
  (379, 641, '20211003'),
  (421, 661, '20210517'),
  (421, 727, '20210517'),
  (641, 727, '20200801'),
  (661, 883, '20210217'),
  (661, 941, '20220105'),
  (727, 883, '20210217'),
  (883, 953, '20220315');

-- Followings
CREATE TABLE Norm.Followings
(
  accountid1 INT  NOT NULL,
  accountid2 INT  NOT NULL,
  startdate  DATE NOT NULL
    CONSTRAINT DFT_Followings_startdate DEFAULT(SYSDATETIME()),
  CONSTRAINT PK_Followings PRIMARY KEY(accountid1, accountid2),
  CONSTRAINT FK_Followings_Accounts_act1 FOREIGN KEY(accountid1)
    REFERENCES Norm.Accounts(accountid),
  CONSTRAINT FK_Followings_Accounts_act2 FOREIGN KEY(accountid2)
    REFERENCES Norm.Accounts(accountid)
);

INSERT INTO Norm.Followings
  (accountid1, accountid2, startdate) VALUES
  (641, 727, '20200802'),
  (883, 199, '20220113'),
  ( 71, 953, '20220316'),
  (661, 421, '20210518'),
  (199, 941, '20220114'),
  ( 71, 883, '20210516'),
  (199, 953, '20220317'),
  (661, 941, '20220106'),
  (953,  71, '20220316'),
  (379,   2, '20220202'),
  (421, 661, '20210518'),
  (661,  71, '20210516'),
  (  2, 727, '20220202'),
  (  2, 379, '20220203'),
  (379, 641, '20211004'),
  (941, 199, '20220112'),
  (727, 421, '20210518'),
  (379,  71, '20211005'),
  (941, 661, '20220105'),
  (641,   2, '20220204'),
  (953, 199, '20220316'),
  (727, 883, '20210218'),
  (421, 379, '20211004'),
  ( 71, 379, '20211004'),
  (641, 379, '20211003'),
  (199, 883, '20220114'),
  (727,   2, '20220203'),
  (199,  71, '20220113'),
  (953, 883, '20220317'),
  ( 71, 661, '20210514');

-- Likes
CREATE TABLE Norm.Likes
(
  accountid INT          NOT NULL,
  postid    INT          NOT NULL,
  dt        DATETIME2(0) NOT NULL
    CONSTRAINT DFT_Likes_dt DEFAULT(SYSDATETIME()),
  CONSTRAINT PK_Likes PRIMARY KEY(accountid, postid),
  CONSTRAINT FK_Likes_Accounts FOREIGN KEY(accountid)
    REFERENCES Norm.Accounts(accountid),
  CONSTRAINT FK_Likes_Posts FOREIGN KEY(postid)
    REFERENCES Norm.Posts(postid)
);

INSERT INTO Norm.Likes(accountid, postid, dt) VALUES
  (  2,   13, '2020-09-21 15:33:46'),
  (199,  109, '2021-05-16 03:24:00'),
  (379,  109, '2021-05-15 21:48:00'),
  (379,  113, '2021-05-19 04:45:33'),
  (661,  113, '2021-05-17 21:33:33'),
  (727,  113, '2021-05-18 09:33:33'),
  (379,  179, '2021-05-21 10:00:17'),
  (661,  179, '2021-05-20 22:00:17'),
  (727,  179, '2021-05-21 00:24:17'),
  (199,  199, '2021-08-02 22:20:02'),
  ( 71,  239, '2022-02-20 07:55:23'),
  (199,  239, '2022-02-21 04:43:23'),
  (661,  239, '2022-02-19 12:43:23'),
  (727,  239, '2022-02-20 21:31:23'),
  (  2,  449, '2020-09-21 20:22:30'),
  (379,  449, '2020-09-22 12:22:30'),
  (727,  449, '2020-09-21 19:34:30'),
  ( 71,  677, '2020-09-23 08:24:22'),
  (199,  677, '2020-09-23 12:24:22'),
  (661,  677, '2020-09-23 05:12:22'),
  (727,  677, '2020-09-21 17:12:22'),
  (953,  677, '2020-09-23 11:36:22'),
  ( 71,  857, '2021-05-16 09:50:13'),
  (199,  857, '2021-05-17 00:14:13'),
  (661,  857, '2021-05-16 08:14:13'),
  (727,  857, '2021-05-17 07:26:13'),
  (953,  857, '2021-05-16 11:26:13'),
  (  2,  859, '2021-05-15 21:52:21'),
  ( 71,  859, '2021-05-17 05:04:21'),
  (421,  859, '2021-05-17 11:28:21'),
  ( 71,  883, '2021-05-17 03:47:43'),
  (379, 1021, '2020-09-22 20:56:17'),
  (641, 1021, '2020-09-23 04:56:17'),
  (  2, 1031, '2020-09-21 16:26:03'),
  ( 71, 1031, '2020-09-23 00:26:03'),
  (421, 1031, '2020-09-23 10:02:03'),
  (199, 1051, '2021-05-17 12:36:35'),
  (  2, 1061, '2020-09-22 08:31:51'),
  (421, 1061, '2020-09-23 06:07:51'),
  (641, 1061, '2020-09-21 18:55:51'),
  (883, 1061, '2020-09-21 20:31:51'),
  (  2, 1151, '2021-05-17 13:04:12'),
  ( 71, 1151, '2021-05-16 22:40:12'),
  (421, 1151, '2021-05-16 01:04:12'),
  (641, 1151, '2021-05-15 22:40:12'),
  (  2, 1187, '2020-09-23 13:19:52'),
  (379, 1187, '2020-09-22 13:19:52');

-- AuthorsPublications
CREATE TABLE Norm.AuthorsPublications
(
  accountid INT NOT NULL,
  pubid     INT NOT NULL,
  CONSTRAINT PK_AuthorsPublications PRIMARY KEY(pubid, accountid),
  CONSTRAINT FK_AuthorsPublications_Accounts FOREIGN KEY(accountid)
    REFERENCES Norm.Accounts(accountid),
  CONSTRAINT FK_AuthorsPublications_Publications FOREIGN KEY(pubid)
    REFERENCES Norm.Publications(pubid)
);

INSERT INTO Norm.AuthorsPublications(accountid, pubid) VALUES
  (727, 23977),
  (641, 23977),
  (727,  4967),
  (641, 27059),
  (883, 14563),
  (883, 46601),
  (199, 46601);

---------------------------------------------------------------------
-- Graph modeling
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Creating node tables
---------------------------------------------------------------------

-- Account
CREATE TABLE Graph.Account
(
  accountid        INT          NOT NULL,
  accountname      NVARCHAR(50) NOT NULL,
  joindate         DATE         NOT NULL
    CONSTRAINT DFT_Account_joindate DEFAULT(SYSDATETIME()),
  reputationpoints INT          NOT NULL
    CONSTRAINT DFT_Account_reputationpoints DEFAULT(0),
  CONSTRAINT PK_Account PRIMARY KEY(accountid)
) AS NODE;

INSERT INTO Graph.Account
  (accountid, accountname, joindate, reputationpoints) VALUES
  (641, N'Inka'  , '20200801',  5),
  ( 71, N'Miko'  , '20210514',  8),
  (379, N'Tami'  , '20211003',  5),
  (421, N'Buzi'  , '20210517',  8),
  (661, N'Alma'  , '20210119', 13),
  (  2, N'Orli'  , '20220202',  2),
  (941, N'Stav'  , '20220105',  1),
  (953, N'Omer'  , '20220315',  0),
  (727, N'Mitzi' , '20200714',  3),
  (883, N'Yatzek', '20210217',  3),
  (199, N'Lilach', '20220112',  1);

SELECT * FROM Graph.Account;

/*
$node_id_778BA26000F9442194D5F7A4EFC932A0                   
----------------------------------------------------------- 
{"type":"node","schema":"Graph","table":"Account","id":5}   
{"type":"node","schema":"Graph","table":"Account","id":1}   
{"type":"node","schema":"Graph","table":"Account","id":10}  
{"type":"node","schema":"Graph","table":"Account","id":2}   
{"type":"node","schema":"Graph","table":"Account","id":3}   
{"type":"node","schema":"Graph","table":"Account","id":0}   
{"type":"node","schema":"Graph","table":"Account","id":4}   
{"type":"node","schema":"Graph","table":"Account","id":8}   
{"type":"node","schema":"Graph","table":"Account","id":9}   
{"type":"node","schema":"Graph","table":"Account","id":6}   
{"type":"node","schema":"Graph","table":"Account","id":7}   

accountid  accountname  joindate   reputationpoints
---------- ------------ ---------- ----------------
2          Orli         2022-02-02 2
71         Miko         2021-05-14 8
199        Lilach       2022-01-12 1
379        Tami         2021-10-03 5
421        Buzi         2021-05-17 8
641        Inka         2020-08-01 5
661        Alma         2021-01-19 13
727        Mitzi        2020-07-14 3
883        Yatzek       2021-02-17 3
941        Stav         2022-01-05 1
953        Omer         2022-03-15 0
*/

-- Post
CREATE TABLE Graph.Post
(
  postid    INT            NOT NULL,
  dt        DATETIME2(0)   NOT NULL
    CONSTRAINT DFT_Post_dt DEFAULT(SYSDATETIME()),
  posttext  NVARCHAR(1000) NOT NULL,
  CONSTRAINT PK_Post PRIMARY KEY(postid)
) AS NODE;

INSERT INTO Graph.Post(postid, dt, posttext) VALUES
  (  13, '20200921 13:09:46' ,
   N'Got a new kitten. Any suggestions for a name?'),
  ( 109, '20210515 17:00:00' ,
   N'Starting to hike the PCT today. Wish me luck!'),
  ( 113, '20210517 10:21:33' ,
   N'Buzi here. This is my first post.'),
  ( 149, '20210519 14:05:45' ,
   N'Buzi here. This is my second post.'
     + N' Aren''t my posts exciting?'),
  ( 179, '20210520 09:12:17' ,
   N'Buzi here. Guess what; this is my third post!'),
  ( 199, '20210802 15:56:02' ,
   N'Made it to Oregon!'),
  ( 239, '20220219 09:31:23' ,
   N'I''m thinking of growing a mustache,'
     + N' but am worried about milk drinking...'),
  ( 281, '20220318 08:14:24' ,
   N'Burt Shavits: "A good day is when no one shows up'
     + N' and you don''t have to go anywhere."'),
  ( 449, '20200921 13:10:30' ,
   N'Maybe Pickle?'),
  ( 677, '20200921 13:12:22' ,
   N'Ambrosius?'),
  ( 857, '20210515 17:02:13' ,
   N'Break a leg. I mean, don''t!'),
  ( 859, '20210515 17:04:21' ,
   N'The longest I''ve seen you hike was...'
     + N'wait, I''ve never seen you hike ;)'),
  ( 883, '20210515 17:23:43' ,
   N'Ha ha ha!'),
  (1021, '20200921 13:44:17' ,
   N'It does look a bit sour faced :)'),
  (1031, '20200921 14:02:03' ,
   N'How about Gherkin?'),
  (1051, '20210515 17:24:35' ,
   N'Jokes aside, is 95lbs reasonable for my backpack?'),
  (1061, '20200921 14:07:51' ,
   N'I love Gherkin!'),
  (1151, '20210515 18:40:12' ,
   N'Short answer, no! Long answer, nooooooo!!!'),
  (1153, '20210515 18:47:17' ,
   N'Say what!?'),
  (1187, '20200921 14:07:52' ,
   N'So you don''t like Pickle!? I''M UNFRIENDING YOU!!!'),
  (1259, '20210515 19:05:54' ,
   N'Did I say that was without water?');

-- Publication
CREATE TABLE Graph.Publication
(
  pubid   INT          NOT NULL,
  pubdate DATE         NOT NULL,
  title   NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_Publication PRIMARY KEY(pubid)
) AS NODE;

INSERT INTO Graph.Publication(pubid, pubdate, title) VALUES
  (23977, '20200912' , N'When Mitzi met Inka'),
  ( 4967, '20210304' , N'When Mitzi left Inka'),
  (27059, '20210401' , N'It''s actually Inka who left Mitzi'),
  (14563, '20210802' ,
   N'Been everywhere, seen it all; there''s no place like home!'),
  (46601, '20220119' , N'Love at first second');

---------------------------------------------------------------------
-- Creating edge tables
---------------------------------------------------------------------

-- Edge constraints require SQL Server 2019 or later, or Azure SQL Database
-- Remove those from edge table definitions if using SQL Server 2017

-- IsReplyTo
CREATE TABLE Graph.IsReplyTo
(
  CONSTRAINT EC_IsReplyTo CONNECTION (Graph.Post TO Graph.Post)
    ON DELETE NO ACTION
) AS EDGE;

-- Add UNIQUE constraint
-- (can't be PRIMARY KEY since columns are NULLable)
ALTER TABLE Graph.IsReplyTo
  ADD CONSTRAINT UNQ_IsReplyTo_fromid_toid UNIQUE($from_id, $to_id);

-- Extract $node_id values individually per key
INSERT INTO Graph.IsReplyTo($from_id, $to_id) VALUES
  ( (SELECT $node_id FROM Graph.Post WHERE postid =  449),
      (SELECT $node_id FROM Graph.Post WHERE postid =   13) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid =  677),
      (SELECT $node_id FROM Graph.Post WHERE postid =   13) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid =  857),
      (SELECT $node_id FROM Graph.Post WHERE postid =  109) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid =  859),
      (SELECT $node_id FROM Graph.Post WHERE postid =  109) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid =  883),
      (SELECT $node_id FROM Graph.Post WHERE postid =  109) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1021),
      (SELECT $node_id FROM Graph.Post WHERE postid =  449) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1031),
      (SELECT $node_id FROM Graph.Post WHERE postid =  449) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1051),
      (SELECT $node_id FROM Graph.Post WHERE postid =  883) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1061),
      (SELECT $node_id FROM Graph.Post WHERE postid = 1031) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1151),
      (SELECT $node_id FROM Graph.Post WHERE postid = 1051) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1153),
      (SELECT $node_id FROM Graph.Post WHERE postid = 1051) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1187),
      (SELECT $node_id FROM Graph.Post WHERE postid = 1061) ),
  ( (SELECT $node_id FROM Graph.Post WHERE postid = 1259),
      (SELECT $node_id FROM Graph.Post WHERE postid = 1151) );

SELECT * FROM Graph.IsReplyTo;

/*
$edge_id_8C951A35BF65467D9DC10CFB020A005B                     
------------------------------------------------------------- 
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":0}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":1}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":2}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":3}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":4}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":5}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":6}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":7}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":8}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":9}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":10}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":11}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":12}  

$from_id_6B162D7BAC56496E8F5D005313C07BEC                
-------------------------------------------------------- 
{"type":"node","schema":"Graph","table":"Post","id":8}   
{"type":"node","schema":"Graph","table":"Post","id":9}   
{"type":"node","schema":"Graph","table":"Post","id":10}  
{"type":"node","schema":"Graph","table":"Post","id":11}  
{"type":"node","schema":"Graph","table":"Post","id":12}  
{"type":"node","schema":"Graph","table":"Post","id":13}  
{"type":"node","schema":"Graph","table":"Post","id":14}  
{"type":"node","schema":"Graph","table":"Post","id":15}  
{"type":"node","schema":"Graph","table":"Post","id":16}  
{"type":"node","schema":"Graph","table":"Post","id":17}  
{"type":"node","schema":"Graph","table":"Post","id":18}  
{"type":"node","schema":"Graph","table":"Post","id":19}  
{"type":"node","schema":"Graph","table":"Post","id":20}  

$to_id_2EBB26F1CACA47AE8F0278E019472C7F
--------------------------------------------------------
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":12}
{"type":"node","schema":"Graph","table":"Post","id":14}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":16}
{"type":"node","schema":"Graph","table":"Post","id":17}
*/

-- Use a join
TRUNCATE TABLE Graph.IsReplyTo;

INSERT INTO Graph.IsReplyTo($from_id, $to_id)
  SELECT FP.$node_id AS fromid, TP.$node_id AS toid
  FROM (VALUES( 449,   13),
              ( 677,   13),
              ( 857,  109),
              ( 859,  109),
              ( 883,  109),
              (1021,  449),
              (1031,  449),
              (1051,  883),
              (1061, 1031),
              (1151, 1051),
              (1153, 1051),
              (1187, 1061),
              (1259, 1151)) AS D(frompostid, topostid)
    INNER JOIN Graph.Post AS FP
      ON D.frompostid = FP.postid
    INNER JOIN Graph.Post AS TP
      ON D.topostid = TP.postid;

SELECT * FROM Graph.IsReplyTo;

/*
$edge_id_9638455E25A24E77B56C525D5B51294F                     
------------------------------------------------------------- 
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":13}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":14}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":15}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":16}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":17}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":18}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":19}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":20}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":21}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":22}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":23}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":24}  
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":25}  

$from_id_88C5F44AF3614A819FA26AFD5302DFF2                
-------------------------------------------------------- 
{"type":"node","schema":"Graph","table":"Post","id":8}   
{"type":"node","schema":"Graph","table":"Post","id":9}   
{"type":"node","schema":"Graph","table":"Post","id":10}  
{"type":"node","schema":"Graph","table":"Post","id":11}  
{"type":"node","schema":"Graph","table":"Post","id":12}  
{"type":"node","schema":"Graph","table":"Post","id":13}  
{"type":"node","schema":"Graph","table":"Post","id":14}  
{"type":"node","schema":"Graph","table":"Post","id":15}  
{"type":"node","schema":"Graph","table":"Post","id":16}  
{"type":"node","schema":"Graph","table":"Post","id":17}  
{"type":"node","schema":"Graph","table":"Post","id":18}  
{"type":"node","schema":"Graph","table":"Post","id":19}  
{"type":"node","schema":"Graph","table":"Post","id":20}  

$to_id_AE36188F967349FE85D008F44EEFCC49
--------------------------------------------------------
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":12}
{"type":"node","schema":"Graph","table":"Post","id":14}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":16}
{"type":"node","schema":"Graph","table":"Post","id":17}
*/

-- Migrate from traditional representation
TRUNCATE TABLE Graph.IsReplyTo;

INSERT INTO Graph.IsReplyTo($from_id, $to_id)
  SELECT FP.$node_id AS fromid, TP.$node_id AS toid
  FROM Norm.Posts AS P
    INNER JOIN Graph.Post AS FP
      ON P.postid = FP.postid
    INNER JOIN Graph.Post AS TP
      ON P.parentpostid = TP.postid;

SELECT * FROM Graph.IsReplyTo;

/*
$edge_id_9638455E25A24E77B56C525D5B51294F                      
-------------------------------------------------------------- 
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":26}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":27}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":28}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":29}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":30}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":31}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":32}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":33}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":34}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":35}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":36}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":37}   
{"type":"edge","schema":"Graph","table":"IsReplyTo","id":38}   

$from_id_88C5F44AF3614A819FA26AFD5302DFF2                
-------------------------------------------------------- 
{"type":"node","schema":"Graph","table":"Post","id":8}   
{"type":"node","schema":"Graph","table":"Post","id":9}   
{"type":"node","schema":"Graph","table":"Post","id":10}  
{"type":"node","schema":"Graph","table":"Post","id":11}  
{"type":"node","schema":"Graph","table":"Post","id":12}  
{"type":"node","schema":"Graph","table":"Post","id":13}  
{"type":"node","schema":"Graph","table":"Post","id":14}  
{"type":"node","schema":"Graph","table":"Post","id":15}  
{"type":"node","schema":"Graph","table":"Post","id":16}  
{"type":"node","schema":"Graph","table":"Post","id":17}  
{"type":"node","schema":"Graph","table":"Post","id":18}  
{"type":"node","schema":"Graph","table":"Post","id":19}  
{"type":"node","schema":"Graph","table":"Post","id":20}  

$to_id_AE36188F967349FE85D008F44EEFCC49
--------------------------------------------------------
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":0}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":1}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":8}
{"type":"node","schema":"Graph","table":"Post","id":12}
{"type":"node","schema":"Graph","table":"Post","id":14}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":15}
{"type":"node","schema":"Graph","table":"Post","id":16}
{"type":"node","schema":"Graph","table":"Post","id":17}
*/

-- Posted
CREATE TABLE Graph.Posted
(
  CONSTRAINT EC_Posted CONNECTION (Graph.Account TO Graph.Post)
    ON DELETE NO ACTION
) AS EDGE;

ALTER TABLE Graph.Posted
  ADD CONSTRAINT UNQ_Posted_fromid_toid UNIQUE($from_id, $to_id);

INSERT INTO Graph.Posted($from_id, $to_id)
  SELECT A.$node_id AS fromid, P.$node_id AS toid
  FROM (VALUES(727,   13),
              ( 71,  109),
              (421,  113),
              (421,  149),
              (421,  179),
              ( 71,  199),
              (883,  239),
              (953,  281),
              (641,  449),
              (883,  677),
              (883,  857),
              (379,  859),
              (199,  883),
              (  2, 1021),
              (379, 1031),
              ( 71, 1051),
              (727, 1061),
              (379, 1151),
              (883, 1153),
              (641, 1187),
              ( 71, 1259)) AS D(accountid, postid)
    INNER JOIN Graph.Account AS A
      ON D.accountid = A.accountid
    INNER JOIN Graph.Post AS P
      ON D.postid = P.postid;

-- IsFriendOf
CREATE TABLE Graph.IsFriendOf
(
  startdate  DATE NOT NULL
    CONSTRAINT DFT_Friendships_startdate DEFAULT(SYSDATETIME()),
  CONSTRAINT EC_IsFriendOf CONNECTION (Graph.Account TO Graph.Account)
    ON DELETE NO ACTION
) AS EDGE;

ALTER TABLE Graph.IsFriendOf
  ADD CONSTRAINT UNQ_IsFriendOf_fromid_toid UNIQUE($from_id, $to_id);

INSERT INTO Graph.IsFriendOf($from_id, $to_id, startdate)
  SELECT A1.$node_id AS fromid, A2.$node_id AS toid, D.startdate
  FROM (VALUES(  2, 379, '20220202'),
              (  2, 641, '20220202'),
              (  2, 727, '20220202'),
              ( 71, 199, '20220112'),
              ( 71, 379, '20211003'),
              ( 71, 661, '20210514'),
              ( 71, 883, '20210514'),
              ( 71, 953, '20220315'),
              (199, 661, '20220112'),
              (199, 883, '20220112'),
              (199, 941, '20220112'),
              (199, 953, '20220315'),
              (379, 421, '20211003'),
              (379, 641, '20211003'),
              (421, 661, '20210517'),
              (421, 727, '20210517'),
              (641, 727, '20200801'),
              (661, 883, '20210217'),
              (661, 941, '20220105'),
              (727, 883, '20210217'),
              (883, 953, '20220315'),
              (379,   2, '20220202'),
              (641,   2, '20220202'),
              (727,   2, '20220202'),
              (199,  71, '20220112'),
              (379,  71, '20211003'),
              (661,  71, '20210514'),
              (883,  71, '20210514'),
              (953,  71, '20220315'),
              (661, 199, '20220112'),
              (883, 199, '20220112'),
              (941, 199, '20220112'),
              (953, 199, '20220315'),
              (421, 379, '20211003'),
              (641, 379, '20211003'),
              (661, 421, '20210517'),
              (727, 421, '20210517'),
              (727, 641, '20200801'),
              (883, 661, '20210217'),
              (941, 661, '20220105'),
              (883, 727, '20210217'),
              (953, 883, '20220315'))
         AS D(accountid1, accountid2, startdate)
    INNER JOIN Graph.Account AS A1
      ON D.accountid1 = A1.accountid
    INNER JOIN Graph.Account AS A2
      ON D.accountid2 = A2.accountid;

-- Follows
CREATE TABLE Graph.Follows
(
  startdate  DATE NOT NULL
    CONSTRAINT DFT_Follows_startdate DEFAULT(SYSDATETIME()),
  CONSTRAINT EC_Follows CONNECTION (Graph.Account TO Graph.Account)
    ON DELETE NO ACTION
) AS EDGE;

ALTER TABLE Graph.Follows
  ADD CONSTRAINT UNQ_Follows_fromid_toid UNIQUE($from_id, $to_id);

INSERT INTO Graph.Follows($from_id, $to_id, startdate)
  SELECT A1.$node_id AS fromid, A2.$node_id AS toid, D.startdate
  FROM (VALUES(641, 727, '20200802'),
              (883, 199, '20220113'),
              ( 71, 953, '20220316'),
              (661, 421, '20210518'),
              (199, 941, '20220114'),
              ( 71, 883, '20210516'),
              (199, 953, '20220317'),
              (661, 941, '20220106'),
              (953,  71, '20220316'),
              (379,   2, '20220202'),
              (421, 661, '20210518'),
              (661,  71, '20210516'),
              (  2, 727, '20220202'),
              (  2, 379, '20220203'),
              (379, 641, '20211004'),
              (941, 199, '20220112'),
              (727, 421, '20210518'),
              (379,  71, '20211005'),
              (941, 661, '20220105'),
              (641,   2, '20220204'),
              (953, 199, '20220316'),
              (727, 883, '20210218'),
              (421, 379, '20211004'),
              ( 71, 379, '20211004'),
              (641, 379, '20211003'),
              (199, 883, '20220114'),
              (727,   2, '20220203'),
              (199,  71, '20220113'),
              (953, 883, '20220317'),
              ( 71, 661, '20210514'))
         AS D(accountid1, accountid2, startdate)
    INNER JOIN Graph.Account AS A1
      ON D.accountid1 = A1.accountid
    INNER JOIN Graph.Account AS A2
      ON D.accountid2 = A2.accountid;

-- Likes
CREATE TABLE Graph.Likes
(
  dt DATETIME2(0) NOT NULL
    CONSTRAINT DFT_Likes_dt DEFAULT(SYSDATETIME()),
  CONSTRAINT EC_Likes CONNECTION (Graph.Account TO Graph.Post)
    ON DELETE NO ACTION
) AS EDGE;

ALTER TABLE Graph.Likes
  ADD CONSTRAINT UNQ_Likes_fromid_toid UNIQUE($from_id, $to_id);

INSERT INTO Graph.Likes($from_id, $to_id, dt)
  SELECT A.$node_id AS fromid, P.$node_id AS toid, D.dt
  FROM (VALUES(  2,   13, '2020-09-21 15:33:46'),
              (199,  109, '2021-05-16 03:24:00'),
              (379,  109, '2021-05-15 21:48:00'),
              (379,  113, '2021-05-19 04:45:33'),
              (661,  113, '2021-05-17 21:33:33'),
              (727,  113, '2021-05-18 09:33:33'),
              (379,  179, '2021-05-21 10:00:17'),
              (661,  179, '2021-05-20 22:00:17'),
              (727,  179, '2021-05-21 00:24:17'),
              (199,  199, '2021-08-02 22:20:02'),
              ( 71,  239, '2022-02-20 07:55:23'),
              (199,  239, '2022-02-21 04:43:23'),
              (661,  239, '2022-02-19 12:43:23'),
              (727,  239, '2022-02-20 21:31:23'),
              (  2,  449, '2020-09-21 20:22:30'),
              (379,  449, '2020-09-22 12:22:30'),
              (727,  449, '2020-09-21 19:34:30'),
              ( 71,  677, '2020-09-23 08:24:22'),
              (199,  677, '2020-09-23 12:24:22'),
              (661,  677, '2020-09-23 05:12:22'),
              (727,  677, '2020-09-21 17:12:22'),
              (953,  677, '2020-09-23 11:36:22'),
              ( 71,  857, '2021-05-16 09:50:13'),
              (199,  857, '2021-05-17 00:14:13'),
              (661,  857, '2021-05-16 08:14:13'),
              (727,  857, '2021-05-17 07:26:13'),
              (953,  857, '2021-05-16 11:26:13'),
              (  2,  859, '2021-05-15 21:52:21'),
              ( 71,  859, '2021-05-17 05:04:21'),
              (421,  859, '2021-05-17 11:28:21'),
              ( 71,  883, '2021-05-17 03:47:43'),
              (379, 1021, '2020-09-22 20:56:17'),
              (641, 1021, '2020-09-23 04:56:17'),
              (  2, 1031, '2020-09-21 16:26:03'),
              ( 71, 1031, '2020-09-23 00:26:03'),
              (421, 1031, '2020-09-23 10:02:03'),
              (199, 1051, '2021-05-17 12:36:35'),
              (  2, 1061, '2020-09-22 08:31:51'),
              (421, 1061, '2020-09-23 06:07:51'),
              (641, 1061, '2020-09-21 18:55:51'),
              (883, 1061, '2020-09-21 20:31:51'),
              (  2, 1151, '2021-05-17 13:04:12'),
              ( 71, 1151, '2021-05-16 22:40:12'),
              (421, 1151, '2021-05-16 01:04:12'),
              (641, 1151, '2021-05-15 22:40:12'),
              (  2, 1187, '2020-09-23 13:19:52'),
              (379, 1187, '2020-09-22 13:19:52'))
         AS D(accountid, postid, dt)
    INNER JOIN Graph.Account AS A
      ON D.accountid = A.accountid
    INNER JOIN Graph.Post AS P
      ON D.postid = P.postid;

-- Authored
CREATE TABLE Graph.Authored
(
  CONSTRAINT EC_Authored CONNECTION
    (Graph.Account TO Graph.Publication)
    ON DELETE NO ACTION
) AS EDGE;

ALTER TABLE Graph.Authored
  ADD CONSTRAINT UNQ_Authored_fromid_toid UNIQUE($from_id, $to_id);

INSERT INTO Graph.Authored($from_id, $to_id)
  SELECT A.$node_id AS fromid, P.$node_id AS toid
  FROM (VALUES(727, 23977),
              (641, 23977),
              (727,  4967),
              (641, 27059),
              (883, 14563),
              (883, 46601),
              (199, 46601)) AS D(accountid, pubid)
    INNER JOIN Graph.Account AS A
      ON D.accountid = A.accountid
    INNER JOIN Graph.Publication AS P
      ON D.pubid = P.pubid;
GO

---------------------------------------------------------------------
-- Querying metadata
---------------------------------------------------------------------

-- Identify node and edge tables
SELECT SCHEMA_NAME(schema_id) + N'.' + name AS tablename,
  CASE
    WHEN is_node = 1 THEN 'NODE'
    WHEN is_edge = 1 THEN 'EDGE'
    ELSE 'Not SQLGraph table'
  END AS tabletype
FROM sys.tables
WHERE is_node = 1 OR is_edge = 1;

/*
tablename          tabletype
------------------ ----------
Graph.Account      NODE
Graph.Post         NODE
Graph.Publication  NODE
Graph.IsReplyTo    EDGE
Graph.Posted       EDGE
Graph.IsFriendOf   EDGE
Graph.Follows      EDGE
Graph.Likes        EDGE
Graph.Authored     EDGE
*/

-- Column info
SELECT name, TYPE_NAME(user_type_id) AS typename, max_length,
  graph_type, graph_type_desc
FROM sys.columns
WHERE object_id = OBJECT_ID('Graph.Account');

/*
name                                       
------------------------------------------ 
graph_id_E386DEE1CFDA4AF7B5384DF1581D3EB7  
$node_id_C3736967DCB2474D966CA368C2D8AD4A  
accountid                                  
accountname                                
joindate                                   
reputationpoints                           

typename  max_length graph_type  graph_type_desc
--------- ---------- ----------- ------------------
bigint    8          1           GRAPH_ID
nvarchar  2000       2           GRAPH_ID_COMPUTED
int       4          NULL        NULL
nvarchar  100        NULL        NULL
date      3          NULL        NULL
int       4          NULL        NULL
*/

SELECT name, TYPE_NAME(user_type_id) AS typename, max_length,
  graph_type, graph_type_desc
FROM sys.columns
WHERE object_id = OBJECT_ID('Graph.Posted');

/*
name                                          
--------------------------------------------- 
graph_id_C6C5CC1CFB91488AB15F67A888B8B019     
$edge_id_9402E3E10FEB4C2097023334CDD93EFD     
from_obj_id_921F3A63A5BD4363A7BF162B36E42F15  
from_id_73466ABF0B1348C8A2A20706E0BFEAAA      
$from_id_ED1EDE58038C45489E5A8346676CE7C6     
to_obj_id_C8CD294E3DDF45308E3594490186AA69    
to_id_91D22669EFCC4AF4A6C2A6877F28E1AA        
$to_id_EB455237A45E4194A933F5F00B376C93       

typename  max_length graph_type  graph_type_desc
--------- ---------- ----------- ----------------------
bigint    8          1           GRAPH_ID
nvarchar  2000       2           GRAPH_ID_COMPUTED
int       4          4           GRAPH_FROM_OBJ_ID
bigint    8          3           GRAPH_FROM_ID
nvarchar  2000       5           GRAPH_FROM_ID_COMPUTED
int       4          7           GRAPH_TO_OBJ_ID
bigint    8          6           GRAPH_TO_ID
nvarchar  2000       8           GRAPH_TO_ID_COMPUTED
*/

-- System functions
/*
OBJECT_ID_FROM_NODE_ID	Extract the object_id from a node_id
GRAPH_ID_FROM_NODE_ID	Extract the graph_id from a node_id
NODE_ID_FROM_PARTS	Construct a node_id from an object_id and a graph_id
OBJECT_ID_FROM_EDGE_ID	Extract object_id from edge_id
GRAPH_ID_FROM_EDGE_ID	Extract identity from edge_id
EDGE_ID_FROM_PARTS	Construct edge_id from object_id and identity
*/

-- Extract object ID and graph ID from $node_id of nodes in the Account table
SELECT $node_id,
  OBJECT_ID_FROM_NODE_ID($node_id) AS obj_id,
  GRAPH_ID_FROM_NODE_ID($node_id) AS graph_id
FROM Graph.Account;

/*
$node_id_40D6A9476A244872A6BFC576723DC0E8                   obj_id      graph_id
----------------------------------------------------------- ----------- ---------
{"type":"node","schema":"Graph","table":"Account","id":0}   1275151588  0
{"type":"node","schema":"Graph","table":"Account","id":1}   1275151588  1
{"type":"node","schema":"Graph","table":"Account","id":2}   1275151588  2
{"type":"node","schema":"Graph","table":"Account","id":3}   1275151588  3
{"type":"node","schema":"Graph","table":"Account","id":4}   1275151588  4
{"type":"node","schema":"Graph","table":"Account","id":5}   1275151588  5
{"type":"node","schema":"Graph","table":"Account","id":6}   1275151588  6
{"type":"node","schema":"Graph","table":"Account","id":7}   1275151588  7
{"type":"node","schema":"Graph","table":"Account","id":8}   1275151588  8
{"type":"node","schema":"Graph","table":"Account","id":9}   1275151588  9
{"type":"node","schema":"Graph","table":"Account","id":10}  1275151588  10
*/

-- Identify the account whose graph ID value is 3
SELECT $node_id, accountid, accountname
FROM Graph.Account
WHERE GRAPH_ID_FROM_NODE_ID($node_id) = 3;

/*
$node_id_40D6A9476A244872A6BFC576723DC0E8                  accountid   accountname
---------------------------------------------------------- ----------- ------------
{"type":"node","schema":"Graph","table":"Account","id":3}  421         Buzi
*/

-- Build a node ID from given object ID and graph ID values
SELECT NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Account'), 3);

/*
{"type":"node","schema":"Graph","table":"Account","id":3}
*/

---------------------------------------------------------------------
-- Querying data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Using the MATCH clause
---------------------------------------------------------------------

-- Accounts and their posts

-- Traditional modeling
SELECT A.accountid, A.accountname, P.postid, P.posttext
FROM Norm.Accounts AS A
  INNER JOIN Norm.Posts AS P
    ON A.accountid = P.accountid;

/*
accountid  accountname  postid  posttext
---------- ------------ ------- --------------------------------------
727        Mitzi        13      Got a new kitten. Any suggestions f...
71         Miko         109     Starting to hike the PCT today. Wis...
421        Buzi         113     Buzi here. This is my first post.
421        Buzi         149     Buzi here. This is my second post. ...
421        Buzi         179     Buzi here. Guess what; this is my t...
71         Miko         199     Made it to Oregon!
883        Yatzek       239     I'm thinking of growing a mustache,...
953        Omer         281     Burt Shavits: "A good day is when n...
641        Inka         449     Maybe Pickle?
883        Yatzek       677     Ambrosius?
883        Yatzek       857     Break a leg. I mean, don't!
379        Tami         859     The longest I've seen you hike was....
199        Lilach       883     Ha ha ha!
2          Orli         1021    It does look a bit sour faced :)
379        Tami         1031    How about Gherkin?
71         Miko         1051    Jokes aside, is 95lbs reasonable fo...
727        Mitzi        1061    I love Gherkin!
379        Tami         1151    Short answer, no! Long answer, nooo...
883        Yatzek       1153    Say what!?
641        Inka         1187    So you don't like Pickle!? I'M UNFR...
71         Miko         1259    Did I say that was without water?
*/

-- Graph modeling
SELECT accountid, accountname, postid, posttext
FROM Graph.Account, Graph.Posted, Graph.Post
WHERE MATCH(Account-(Posted)->Post);

-- Using a table alias
SELECT accountid, accountname, postid, posttext
FROM Graph.Account AS Act, Graph.Posted, Graph.Post
WHERE MATCH(Act-(Posted)->Post);

-- Closer logical equivalent against the traditional data model
SELECT A.accountid, A.accountname, P.postid, P.posttext
FROM Norm.Posts AS P
  LEFT OUTER JOIN Norm.Accounts AS A
    ON P.accountid = A.accountid;

-- Actual equivalent against the graph objects
SELECT
  Account.accountid, Account.accountname,
  Post.postid, Post.posttext
FROM Graph.Posted
  LEFT OUTER JOIN Graph.Account
    ON Posted.$from_id = Account.$node_id
  LEFT OUTER JOIN Graph.Post
    ON Posted.$to_id = Post.$node_id;

-- Accounts and their publications

-- Traditional modeling
SELECT A.accountid, A.accountname, P.pubid, P.title
FROM Norm.Accounts AS A
  INNER JOIN Norm.AuthorsPublications AS AP
    ON A.accountid = AP.accountid
  INNER JOIN Norm.Publications AS P
    ON AP.pubid = P.pubid;

/*
accountid  accountname  pubid  
---------- ------------ ------ 
727        Mitzi        4967   
883        Yatzek       14563  
641        Inka         23977  
727        Mitzi        23977  
641        Inka         27059  
199        Lilach       46601  
883        Yatzek       46601  

title
---------------------------------------------------------
When Mitzi left Inka
Been everywhere, seen it all; there's no place like home!
When Mitzi met Inka
When Mitzi met Inka
It's actually Inka who left Mitzi
Love at first second
Love at first second
*/

-- Graph modeling
SELECT accountid, accountname, pubid, title
FROM Graph.Account, Graph.Authored, Graph.Publication
WHERE MATCH(Account-(Authored)->Publication);

-- Actual logical equivalent
SELECT A.accountid, A.accountname, P.pubid, P.title
FROM Norm.AuthorsPublications AS AP
  LEFT OUTER JOIN Norm.Accounts AS A
    ON AP.accountid = A.accountid
  LEFT OUTER JOIN Norm.Publications AS P
    ON AP.pubid = P.pubid;
GO

-- Temporarily disable edge constraint
ALTER TABLE Graph.Authored NOCHECK CONSTRAINT EC_Authored;

-- Insert edges with nonexisting nodes
INSERT INTO Graph.Authored($from_id, $to_id)
  VALUES(NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Account'), -1),
         NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Publication'), -1));
INSERT INTO Graph.Authored($from_id, $to_id)
  VALUES(NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Account'), -1),
         NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Publication'), 0));
INSERT INTO Graph.Authored($from_id, $to_id)
  VALUES(NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Account'), 0),
         NODE_ID_FROM_PARTS(OBJECT_ID(N'Graph.Publication'), -1));

SELECT accountid, accountname, pubid, title
FROM Graph.Account, Graph.Authored, Graph.Publication
WHERE MATCH(Account-(Authored)->Publication);

/*
accountid  accountname  pubid       
---------- ------------ ----------- 
NULL       NULL         NULL        
NULL       NULL         23977       
641        Inka         NULL        
641        Inka         23977       
641        Inka         27059       
727        Mitzi        23977       
727        Mitzi        4967        
883        Yatzek       14563       
883        Yatzek       46601       
199        Lilach       46601       

title
---------------------------------------------------------
NULL
When Mitzi met Inka
NULL
When Mitzi met Inka
It's actually Inka who left Mitzi
When Mitzi met Inka
When Mitzi left Inka
Been everywhere, seen it all; there's no place like home!
Love at first second
Love at first second
*/

-- Cleanup
DELETE FROM Graph.Authored
WHERE -1 IN (GRAPH_ID_FROM_NODE_ID($from_id),
               GRAPH_ID_FROM_NODE_ID($to_id));

-- Enable constraint
ALTER TABLE Graph.Authored WITH CHECK CHECK CONSTRAINT EC_Authored;
GO

-- Posts and replies
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2) -- white spaces are ignored
ORDER BY Post.dt, Post.postid, Reply.dt;

/*
account1   posttext
  account2   replytext
---------- ---------------------------------------------------
Mitzi      Got a new kitten. Any suggestions for a name?      
  Inka       Maybe Pickle?
Mitzi      Got a new kitten. Any suggestions for a name?      
  Yatzek     Ambrosius?
Inka       Maybe Pickle?                                      
  Orli       It does look a bit sour faced :)
Inka       Maybe Pickle?                                      
  Tami       How about Gherkin?
Tami       How about Gherkin?                                 
  Mitzi      I love Gherkin!
Mitzi      I love Gherkin!                                    
  Inka       So you don't like Pickle!? I'M UNFRIENDING YOU!!!
Miko       Starting to hike the PCT today. Wish me luck!      
  Yatzek     Break a leg. I mean, don't!
Miko       Starting to hike the PCT today. Wish me luck!      
  Tami       The longest I've seen you hike was...wait, 
             I've never seen you hike ;)
Miko       Starting to hike the PCT today. Wish me luck!      
  Lilach     Ha ha ha!
Lilach     Ha ha ha!                                          
  Miko       Jokes aside, is 95lbs reasonable for my backpack?
Miko       Jokes aside, is 95lbs reasonable for my backpack?  
  Tami       Short answer, no! Long answer, nooooooo!!!
Miko       Jokes aside, is 95lbs reasonable for my backpack?  
  Yatzek     Say what!?
Tami       Short answer, no! Long answer, nooooooo!!!         
  Miko       Did I say that was without water?
*/

-- Expressing relationships as conjunction
-- with ANDs using one MATCH clause
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post
        AND Account2-(RepliedWith)->Reply
        AND Reply-(IsReplyTo)->Post)
ORDER BY Post.dt, Post.postid, Reply.dt;

-- Separate MATCH clauses
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post)
  AND MATCH(Account2-(RepliedWith)->Reply)
  AND MATCH(Reply-(IsReplyTo)->Post)
ORDER BY Post.dt, Post.postid, Reply.dt;

-- Posts and replies
-- Only if account who replies follows account who posts
-- Notice Account1 appears here twice; that's OK
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo, Graph.Follows
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2-(Follows)->Account1)
ORDER BY Post.dt, Post.postid, Reply.dt;

-- Similar to join-based query (using inner joins for simplicity)
-- Shown for comparison purposes
-- Notice amount of code required here
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1
  INNER JOIN Graph.Posted
    ON Posted.$from_id = Account1.$node_id
  INNER JOIN Graph.Post
    ON Posted.$to_id = Post.$node_id
  INNER JOIN Graph.IsReplyTo
    ON IsReplyTo.$to_id = Post.$node_id
  INNER JOIN Graph.Post AS Reply
    ON IsReplyTo.$from_id = Reply.$node_id
  INNER JOIN Graph.Posted AS RepliedWith
    ON RepliedWith.$to_id = Reply.$node_id
  INNER JOIN Graph.Account AS Account2
    ON RepliedWith.$from_id = Account2.$node_id
  INNER JOIN Graph.Follows
    ON Follows.$from_id = Account2.$node_id
    AND Follows.$to_id = Account1.$node_id
ORDER BY Post.dt, Post.postid, Reply.dt;

-- The MATCH clause supports only the AND operator
-- It doesn't support OR and NOT
-- That's the case both inside the MATCH clause
--   and when mixing multiple MATCH clauses
-- How to deal with the need for OR and NOT?
-- Can add traditional T-SQL constructs
--   like set operators, EXISTS/NOT EXISTS

-- Posts and replies
-- Only if account who replies follows account who posts
--   or is friends of account who posts

-- Tempting to use set operators and repeat a lot of logic like so
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo, Graph.Follows
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2-(Follows)->Account1)

UNION

SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo, Graph.IsFriendOf
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2-(IsFriendOf)->Account1);

-- Much easier to use EXISTS, like so
-- Notice in the subqueries the reference
--   to outer nodes Account1 and Account2
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2)
  AND (EXISTS (SELECT * FROM Graph.Follows
               WHERE MATCH(Account2-(Follows)->Account1))
       OR
       EXISTS (SELECT * FROM Graph.IsFriendOf 
               WHERE MATCH(Account2-(IsFriendOf)->Account1)));

-- Posts and replies
-- Only if account who replied didn't also like the post

-- Tempting to use set operators and repeat a lot of logic like so
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2)

EXCEPT

SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo, Graph.Likes
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2-(Likes)->Post);

-- Much easier to use NOT EXISTS, like so
-- Notice in the subquery the reference
--   to outer nodes Account2 and Post
SELECT Account1.accountname AS account1, Post.posttext,
  Account2.accountname AS account2, Reply.posttext AS replytext
FROM Graph.Account AS Account1, Graph.Posted, Graph.Post,
  Graph.Account AS Account2, Graph.Posted AS RepliedWith,
  Graph.Post AS Reply, Graph.IsReplyTo
WHERE MATCH(Account1-(Posted)->Post<-(IsReplyTo)-Reply
  <-(RepliedWith)-Account2)
  AND NOT EXISTS
    (SELECT *
     FROM Graph.Likes
     WHERE MATCH(Account2-(Likes)->Post));
GO

---------------------------------------------------------------------
-- Recursive queries
---------------------------------------------------------------------

-- Return all posts in a thread starting with input post
-- Following not supported
DECLARE @postid AS INT = 13;

WITH C AS
(
  SELECT NULL AS parentpostid, postid, posttext
  FROM Graph.Post
  WHERE postid = @postid

  UNION ALL

  SELECT ParentPost.postid AS parentpostid,
    ChildPost.postid, ChildPost.posttext
  FROM C AS ParentPost, Graph.IsReplyTo, Graph.Post AS ChildPost
  WHERE MATCH(ChildPost-(IsReplyTo)->ParentPost)
)
SELECT parentpostid, postid, posttext
FROM C;
GO

/*
Msg 13940, Level 16, State 1, Line 1373
Cannot use a derived table 'ParentPost' in a MATCH clause.
*/

-- Possible solution
-- Can use recursive reference as proxy for parent node,
-- but requires adding a table representing parent node to the query
DECLARE @postid AS INT = 13;

WITH C AS
(
  SELECT NULL AS parentpostid, postid, posttext
  FROM Graph.Post
  WHERE postid = @postid

  UNION ALL

  SELECT ParentPost.postid AS parentpostid,
    ChildPost.postid, ChildPost.posttext
  FROM C, Graph.Post AS ParentPost, Graph.IsReplyTo,
    Graph.Post AS ChildPost
  WHERE ParentPost.postid = C.postid -- recursive ref used as proxy
    AND MATCH(ChildPost-(IsReplyTo)->ParentPost)
)
SELECT parentpostid, postid, posttext
FROM C;
GO

/*
parentpostid postid      posttext
------------ ----------- ------------------------------------------------
NULL         13          Got a new kitten. Any suggestions for a name?
13           449         Maybe Pickle?
13           677         Ambrosius?
449          1021        It does look a bit sour faced :)
449          1031        How about Gherkin?
1031         1061        I love Gherkin!
1061         1187        So you don't like Pickle!? I'M UNFRIENDING YOU!!!
*/

-- Can always use traditional joins
-- but then you miss the point about using graph syntax
DECLARE @postid AS INT = 13;

WITH C AS
(
  SELECT $node_id AS nodeid, NULL AS parentpostid, postid, posttext
  FROM Graph.Post
  WHERE postid = @postid

  UNION ALL

  SELECT CP.$node_id AS nodeid, PP.postid AS parentpostid,
    CP.postid, CP.posttext
  FROM C AS PP -- parent post
    INNER JOIN Graph.IsReplyTo AS R
      ON R.$to_id = PP.nodeid
    INNER JOIN Graph.Post AS CP -- child post
      ON R.$from_id = CP.$node_id
)
SELECT parentpostid, postid, posttext
FROM C;
GO

---------------------------------------------------------------------
-- Adding sorting and indentation
---------------------------------------------------------------------

-- Sorting and indentation
DECLARE @postid AS INT = 13;

WITH C AS
(
  SELECT NULL AS parentpostid, postid, posttext,
    0 AS lvl,
    CAST('.' AS VARCHAR(MAX)) AS sortkey
  FROM Graph.Post
  WHERE postid = @postid

  UNION ALL

  SELECT ParentPost.postid AS parentpostid,
    ChildPost.postid, ChildPost.posttext,
    C.lvl + 1 AS lvl,
    CONCAT(C.sortkey, ChildPost.postid, '.') AS sortkey
  FROM C, Graph.Post AS ParentPost, Graph.IsReplyTo,
    Graph.Post AS ChildPost
  WHERE ParentPost.postid = C.postid -- recursive ref used as proxy
    AND MATCH(ChildPost-(IsReplyTo)->ParentPost)
)
SELECT
  REPLICATE(' | ', lvl) + posttext AS post
FROM C
ORDER BY sortkey;
GO

/*
post
-------------------------------------------------------------
Got a new kitten. Any suggestions for a name?
 | Maybe Pickle?
 |  | It does look a bit sour faced :)
 |  | How about Gherkin?
 |  |  | I love Gherkin!
 |  |  |  | So you don't like Pickle!? I'M UNFRIENDING YOU!!!
 | Ambrosius?
*/

---------------------------------------------------------------------
-- Using the SHORTEST_PATH option
---------------------------------------------------------------------

-- SHORTEST_PATH requires SQL Server 2019 or later, or Azure SQL Database

-- Shortest path from a single source to related nodes

-- Orli's direct friends
SELECT Account1.accountname AS account1,
  Account2.accountname AS account2
FROM Graph.Account AS Account1, Graph.IsFriendOf,
  Graph.Account AS Account2
WHERE MATCH(Account1-(IsFriendOf)->Account2)
  AND Account1.accountname = N'Orli';

/*
account1    account2
----------- -----------
Orli        Inka
Orli        Tami
Orli        Mitzi
*/

-- Following query fails
SELECT Account1.accountname, Account2.accountname
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+))
  AND Account1.accountname = N'Orli';

/*
Msg 13961, Level 16, State 1, Line 1571
The alias or identifier 'Account2.accountname' cannot be used in the select list, order by, group by, or having context.
*/

-- Shortest path from Orli to all her friends, and friends of friends
-- Notice indirect friendship with oneself also returned
SELECT
  Account1.accountname + N'->'
    + STRING_AGG(Account2.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS friendships
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+))
  AND Account1.accountname = N'Orli';

/*
friendships
------------------------------
Orli->Inka
Orli->Tami
Orli->Mitzi
Orli->Tami->Miko
Orli->Tami->Buzi
Orli->Mitzi->Orli
Orli->Mitzi->Yatzek
Orli->Tami->Buzi->Alma
Orli->Tami->Miko->Omer
Orli->Mitzi->Yatzek->Lilach
Orli->Tami->Buzi->Alma->Stav
*/

-- Shortest path from Orli to all her friends, and friends of friends, up to 2 levels
-- Restricted quantifier must start with 1
SELECT
  Account1.accountname + N'->'
    + STRING_AGG(Account2.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS friendships
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2){1, 2}))
  AND Account1.accountname = N'Orli';

/*
friendships
------------------------------
Orli->Inka
Orli->Tami
Orli->Mitzi
Orli->Tami->Miko
Orli->Tami->Buzi
Orli->Mitzi->Orli
Orli->Mitzi->Yatzek
*/

-- Shortest paths to Orli
SELECT
  Account2.accountname + N'<-'
    + STRING_AGG(Account1.accountname, N'<-')
      WITHIN GROUP(GRAPH PATH) AS friendships
FROM
  Graph.Account FOR PATH AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account AS Account2
WHERE MATCH(SHORTEST_PATH((Account1-(IFO)->)+Account2))
  AND Account2.accountname = N'Orli';

/*
friendships
------------------------------
Orli<-Inka
Orli<-Tami
Orli<-Mitzi
Orli<-Tami<-Miko
Orli<-Tami<-Buzi
Orli<-Mitzi<-Orli
Orli<-Mitzi<-Yatzek
Orli<-Tami<-Miko<-Alma
Orli<-Mitzi<-Yatzek<-Omer
Orli<-Mitzi<-Yatzek<-Lilach
Orli<-Tami<-Miko<-Alma<-Stav
*/

-- Shortest path between two nodes

-- Direct friendship between Orli and Stav
SELECT Account1.accountname AS account1,
  Account2.accountname AS account2
FROM Graph.Account AS Account1, Graph.IsFriendOf,
  Graph.Account AS Account2
WHERE MATCH(Account1-(IsFriendOf)->Account2)
  AND Account1.accountname = N'Orli'
  AND Account2.accountname = N'Stav';
GO

/*
account1    account2
----------- -----------

(0 rows affected)
*/

-- Direct or indirect friendship between Orli and Stav

-- Following fails
SELECT
  Account1.accountname + N'->'
    + STRING_AGG(Account2.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS friendships
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+))
  AND Account1.accountname = N'Orli'
  AND Account2.accountname = N'Stav'; -- not allowed
GO

/*
Msg 13961, Level 16, State 1, Line 1573
The alias or identifier 'Account2.accountname' cannot be used in the select list, order by, group by, or having context.
*/

-- Solution, use a table expression
WITH C AS
(
  SELECT
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode -- to access last node
  FROM
    Graph.Account AS Account1,
    Graph.IsFriendOf FOR PATH AS IFO, 
    Graph.Account FOR PATH AS Account2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+))
    AND Account1.accountname = N'Orli'
)
SELECT friendships
FROM C
WHERE lastnode = N'Stav';

/*
friendships
------------------------------
Orli->Tami->Buzi->Alma->Stav
*/

-- Shortest paths to Orli, with correct graph path order
WITH C AS
(
  SELECT
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode
  FROM
    Graph.Account AS Account1,
    Graph.IsFriendOf FOR PATH AS IFO, 
    Graph.Account FOR PATH AS Account2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+)) 
)
SELECT friendships
FROM C
WHERE lastnode = N'Orli';

/*
friendships
-----------------------------
Inka->Orli
Tami->Orli
Mitzi->Orli
Miko->Tami->Orli
Buzi->Tami->Orli
Orli->Mitzi->Orli
Yatzek->Mitzi->Orli
Alma->Miko->Tami->Orli
Omer->Yatzek->Mitzi->Orli
Lilach->Yatzek->Mitzi->Orli
Stav->Alma->Miko->Tami->Orli
*/

-- Multiple source nodes to multiple target nodes
SELECT
  Account1.accountname + N'->'
    + STRING_AGG(Account2.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS friendships
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+));

/*
friendships
------------------------------
Inka->Tami
Inka->Orli
Inka->Mitzi
...
Inka->Orli->Inka
Inka->Tami->Miko
Inka->Tami->Buzi
Inka->Mitzi->Yatzek
Miko->Tami->Inka
Miko->Tami->Miko
Miko->Alma->Buzi
Miko->Tami->Orli
Miko->Alma->Stav
Miko->Yatzek->Mitzi
...
Stav->Alma->Miko->Tami->Inka
Stav->Alma->Buzi->Mitzi->Orli

(121 rows affected)
*/

-- Transitive closure
SELECT
  Account1.accountname AS firstnode,
  LAST_VALUE(Account2.accountname)
    WITHIN GROUP (GRAPH PATH) AS lastnode
FROM
  Graph.Account AS Account1,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Account FOR PATH AS Account2
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+));

/*
firstnode  lastnode
---------- ---------
Inka       Tami
Inka       Orli
Inka       Mitzi
Miko       Tami
Miko       Alma
Miko       Omer
Miko       Yatzek
Miko       Lilach
Tami       Inka
Tami       Miko
...
Inka       Inka
Inka       Miko
Inka       Buzi
Inka       Yatzek
Miko       Inka
Miko       Miko
Miko       Buzi
Miko       Orli
Miko       Stav
Miko       Mitzi
...
Omer       Inka
Omer       Buzi
Omer       Orli
Mitzi      Stav
Lilach     Inka
Lilach     Orli
Inka       Stav
Orli       Stav
Stav       Inka
Stav       Orli

(121 rows affected)
*/

-- Transitive closure (remove self-pairs and mirrored pairs)
WITH C AS
(
  SELECT
    Account1.accountname AS firstnode,
    COUNT(Account2.accountid)
      WITHIN GROUP(GRAPH PATH) AS hops,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode
  FROM
    Graph.Account AS Account1,
    Graph.IsFriendOf FOR PATH AS IFO, 
    Graph.Account FOR PATH AS Account2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+))
)
SELECT firstnode AS account1, lastnode AS account2, hops
FROM C
WHERE firstnode < lastnode;

/*
account1    account2    hops
----------- ----------- -----
Inka        Tami        1
Inka        Orli        1
Inka        Mitzi       1
Miko        Tami        1
Miko        Omer        1
Miko        Yatzek      1
Buzi        Tami        1
Buzi        Mitzi       1
Alma        Miko        1
Alma        Buzi        1
Alma        Stav        1
Alma        Yatzek      1
Alma        Lilach      1
Orli        Tami        1
Omer        Yatzek      1
Mitzi       Orli        1
Mitzi       Yatzek      1
Lilach      Miko        1
Lilach      Stav        1
Lilach      Omer        1
Lilach      Yatzek      1
Inka        Miko        2
Inka        Yatzek      2
Miko        Orli        2
Miko        Stav        2
Miko        Mitzi       2
Tami        Yatzek      2
Buzi        Inka        2
Buzi        Miko        2
Buzi        Orli        2
Buzi        Stav        2
Buzi        Yatzek      2
Buzi        Lilach      2
Alma        Tami        2
Alma        Omer        2
Alma        Mitzi       2
Orli        Yatzek      2
Stav        Yatzek      2
Omer        Tami        2
Omer        Stav        2
Mitzi       Tami        2
Mitzi       Omer        2
Lilach      Tami        2
Lilach      Mitzi       2
Inka        Omer        3
Inka        Lilach      3
Buzi        Omer        3
Alma        Inka        3
Alma        Orli        3
Stav        Tami        3
Omer        Orli        3
Mitzi       Stav        3
Lilach      Orli        3
Inka        Stav        4
Orli        Stav        4
*/

---------------------------------------------------------------------
-- Using the LAST_NODE function
---------------------------------------------------------------------

-- Identify the shortest friendship chain 
-- going from Orli to Yatzek through Stav,
-- not including Orli or Yatzek as intermediaries.
-- The first path starts with Orli and ends with Stav, not including Yatzek as an intermediary.
-- The second path starts with Stav and ends with Yatzek, not including Orli as an intermediary.
WITH C AS
(
  SELECT
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) + N'->'
      + STRING_AGG(Account3.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS midnode,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode
  FROM
    Graph.Account AS Account1,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Yatzek' ) FOR PATH AS Account2,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Orli') FOR PATH AS Account3,
    Graph.IsFriendOf FOR PATH AS IFO1, 
    Graph.IsFriendOf FOR PATH AS IFO2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO1)->Account2)+)
              AND SHORTEST_PATH(LAST_NODE(Account2)(-(IFO2)->Account3)+))
    AND Account1.accountname = N'Orli'
)
SELECT friendships
FROM C
WHERE midnode = N'Stav'
  AND lastnode = N'Yatzek';

/*
friendships
---------------------------------------------
Orli->Tami->Buzi->Alma->Stav->Lilach->Yatzek
*/

-- Identify the shortest friendship chains 
-- connecting Orli and Yatzek through the same account,
-- not including Orli or Yatzek as intermediaries
WITH C AS
(
  SELECT
    Account1.accountname AS firstnode,
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) + N'->'
      + STRING_AGG(Account3.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS midnode,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode
  FROM
    Graph.Account AS Account1,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Yatzek' ) FOR PATH AS Account2,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Orli') FOR PATH AS Account3,
    Graph.IsFriendOf FOR PATH AS IFO1, 
    Graph.IsFriendOf FOR PATH AS IFO2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO1)->Account2)+)
              AND SHORTEST_PATH(LAST_NODE(Account2)(-(IFO2)->Account3)+))
    AND Account1.accountname = N'Orli'
)
SELECT friendships, midnode
FROM C
WHERE lastnode = N'Yatzek'
  AND midnode NOT IN (firstnode, lastnode);

/*
friendships                                   midnode
--------------------------------------------- --------
Orli->Tami->Miko->Yatzek                      Miko
Orli->Tami->Buzi->Alma->Yatzek                Alma
Orli->Tami->Miko->Omer->Yatzek                Omer
Orli->Mitzi->Yatzek                           Mitzi
Orli->Mitzi->Yatzek->Lilach->Yatzek           Lilach
Orli->Inka->Mitzi->Yatzek                     Inka
Orli->Tami->Miko->Yatzek                      Tami
Orli->Tami->Buzi->Alma->Yatzek                Buzi
Orli->Tami->Buzi->Alma->Stav->Lilach->Yatzek  Stav
*/

-- Identify the shortest friendship chains 
-- connecting both Orli and Yatzek to the same account
-- With arrows going towards midnode from both sides
WITH C AS
(
  SELECT
    Account1.accountname AS firstnode1,
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) + N'<-'
      + STRING_AGG(Account3.accountname, N'<-')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS midnode,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS firstnode2
  FROM
    Graph.Account AS Account1,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Yatzek' ) FOR PATH AS Account2,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Orli') FOR PATH AS Account3,
    Graph.IsFriendOf FOR PATH AS IFO1, 
    Graph.IsFriendOf FOR PATH AS IFO2
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO1)->Account2)+)
              AND SHORTEST_PATH((Account3-(IFO2)->)+LAST_NODE(Account2)))
    AND Account1.accountname = N'Orli'
)
SELECT friendships, midnode
FROM C
WHERE firstnode2 = N'Yatzek'
  AND midnode NOT IN (firstnode1, firstnode2);
GO

/*
friendships                                   midnode
--------------------------------------------- --------
Orli->Tami->Miko<-Yatzek                      Miko
Orli->Tami->Buzi->Alma<-Yatzek                Alma
Orli->Tami->Miko->Omer<-Yatzek                Omer
Orli->Mitzi<-Yatzek                           Mitzi
Orli->Mitzi->Lilach<-Yatzek                   Lilach
Orli->Inka<-Mitzi<-Yatzek                     Inka
Orli->Tami<-Miko<-Yatzek                      Tami
Orli->Tami->Buzi<-Alma<-Yatzek                Buzi
Orli->Tami->Buzi->Alma->Stav<-Lilach<-Yatzek  Stav
*/

-- Return follow relationships between Orli and Yatzek 
-- through the same intermediate account, 
-- without Orli or Yatzek being intermediaries
WITH C AS
(
  SELECT
    Account1.accountname AS firstnode,
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) + N'->'
      + STRING_AGG(Account3.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS followings,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS midnode,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode
  FROM
    Graph.Account AS Account1,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Yatzek' ) FOR PATH AS Account2,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Orli') FOR PATH AS Account3,
    Graph.Follows FOR PATH AS Follows1, 
    Graph.Follows FOR PATH AS Follows2
  WHERE MATCH(SHORTEST_PATH(Account1(-(Follows1)->Account2)+)
              AND SHORTEST_PATH(LAST_NODE(Account2)(-(Follows2)->Account3)+))
    AND Account1.accountname = N'Orli'
)
SELECT followings, midnode
FROM C
WHERE lastnode = N'Yatzek'
  AND midnode NOT IN (firstnode, lastnode);

/*
followings                                     midnode
---------------------------------------------- --------
Orli->Tami->Miko->Yatzek                       Miko
Orli->Tami->Miko->Omer->Yatzek                 Omer
Orli->Mitzi->Yatzek                            Mitzi
Orli->Mitzi->Lilach->Yatzek                    Lilach
Orli->Tami->Inka->Mitzi->Yatzek                Inka
Orli->Tami->Miko->Yatzek                       Tami
Orli->Mitzi->Buzi->Alma->Miko->Yatzek          Alma
Orli->Mitzi->Buzi->Alma->Stav->Lilach->Yatzek  Stav
Orli->Mitzi->Buzi->Tami->Miko->Yatzek          Buzi
*/

-- Return pairs of shortest follow relationships, 
-- one starting with Orli and the other with Yatzek, 
-- both ending with the same account, 
-- without Orli or Yatzek being intermediaries
WITH C AS
(
  SELECT
    Account1.accountname AS firstnode1,
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) + N'<-'
      + STRING_AGG(Account3.accountname, N'<-')
          WITHIN GROUP(GRAPH PATH) AS followings,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS midnode,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS firstnode2
  FROM
    Graph.Account AS Account1,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Yatzek' ) FOR PATH AS Account2,
    ( SELECT * FROM Graph.Account
      WHERE accountname <> N'Orli') FOR PATH AS Account3,
    Graph.Follows FOR PATH AS Follows1, 
    Graph.Follows FOR PATH AS Follows2
  WHERE MATCH(SHORTEST_PATH(Account1(-(Follows1)->Account2)+)
              AND SHORTEST_PATH((Account3-(Follows2)->)+LAST_NODE(Account2)))
    AND Account1.accountname = N'Orli'
)
SELECT followings, midnode
FROM C
WHERE firstnode2 = N'Yatzek'
  AND midnode NOT IN (firstnode1, firstnode2);

/*
followings                                     midnode
---------------------------------------------- --------
Orli->Mitzi->Lilach<-Yatzek                    Lilach
Orli->Tami->Miko<-Lilach<-Yatzek               Miko
Orli->Mitzi->Buzi->Alma->Stav<-Lilach<-Yatzek  Stav
Orli->Tami->Miko->Omer<-Lilach<-Yatzek         Omer
Orli->Tami<-Miko<-Lilach<-Yatzek               Tami
Orli->Mitzi->Buzi->Alma<-Miko<-Lilach<-Yatzek  Alma
Orli->Tami->Inka<-Tami<-Miko<-Lilach<-Yatzek   Inka
Orli->Mitzi->Buzi<-Alma<-Miko<-Lilach<-Yatzek  Buzi
Orli->Mitzi<-Inka<-Tami<-Miko<-Lilach<-Yatzek  Mitzi
*/

-- Return pairs of shortest friendship and follow relationship chains
-- that start and end with the same pair of accounts, 
-- and return for both their respective account name paths from left to right
SELECT
  Account1.accountname + N'->'
    + STRING_AGG(Account2.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS friendships,
  Account1.accountname + N'->'
    + STRING_AGG(Account3.accountname, N'->')
        WITHIN GROUP(GRAPH PATH) AS followings,
  Account1.accountname AS firstnode
FROM
  Graph.Account AS Account1,
  Graph.Account FOR PATH AS Account2,
  Graph.Account FOR PATH AS Account3,
  Graph.IsFriendOf FOR PATH AS IFO, 
  Graph.Follows FOR PATH AS FLO
WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+)
            AND SHORTEST_PATH(Account1(-(FLO)->Account3)+)
            AND LAST_NODE(Account2) = LAST_NODE(Account3));

/*
friendships                    followings
------------------------------ ----------------------------------------
Inka->Tami                     Inka->Tami
Inka->Orli                     Inka->Orli
Inka->Mitzi                    Inka->Mitzi
Miko->Tami                     Miko->Tami
Miko->Alma                     Miko->Alma
Miko->Omer                     Miko->Omer
Miko->Yatzek                   Miko->Yatzek
Tami->Inka                     Tami->Inka
Tami->Miko                     Tami->Miko
Tami->Orli                     Tami->Orli
...
Orli->Tami->Buzi->Alma->Stav   Orli->Tami->Miko->Alma->Stav
Stav->Alma->Miko->Tami->Inka   Stav->Alma->Miko->Tami->Inka
Stav->Alma->Buzi->Mitzi->Orli  Stav->Alma->Miko->Tami->Orli
Omer->Yatzek->Mitzi            Omer->Miko->Tami->Inka->Mitzi
Yatzek->Mitzi->Inka            Yatzek->Lilach->Miko->Tami->Inka
Yatzek->Alma->Buzi             Yatzek->Lilach->Miko->Alma->Buzi
Yatzek->Mitzi->Orli            Yatzek->Lilach->Miko->Tami->Orli
Lilach->Yatzek->Mitzi          Lilach->Miko->Tami->Inka->Mitzi
Stav->Alma->Buzi->Mitzi        Stav->Alma->Miko->Tami->Inka->Mitzi
Yatzek->Mitzi                  Yatzek->Lilach->Miko->Tami->Inka->Mitzi

(121 rows affected)
*/

-- Without the LAST_NODE function
WITH C AS
(
  SELECT
    Account1.accountname + N'->'
      + STRING_AGG(Account2.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS friendships,
    Account1.accountname + N'->'
      + STRING_AGG(Account3.accountname, N'->')
          WITHIN GROUP(GRAPH PATH) AS followings,
    Account1.accountname AS firstnode,
    LAST_VALUE(Account2.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode1,
    LAST_VALUE(Account3.accountname)
      WITHIN GROUP (GRAPH PATH) AS lastnode2
  FROM
    Graph.Account AS Account1,
    Graph.Account FOR PATH AS Account2,
    Graph.Account FOR PATH AS Account3,
    Graph.IsFriendOf FOR PATH AS IFO, 
    Graph.Follows FOR PATH AS FLO
  WHERE MATCH(SHORTEST_PATH(Account1(-(IFO)->Account2)+)
              AND SHORTEST_PATH(Account1(-(FLO)->Account3)+))
)
SELECT friendships, followings
FROM C
WHERE lastnode1 = lastnode2;

---------------------------------------------------------------------
-- Querying features that are still missing
---------------------------------------------------------------------

-- Weighted shortest path searches
-- This syntax is not supported
WITH C AS
(
  SELECT
    Location1.locationname + N'->'
      + STRING_AGG(location2.locationname, N'->')
          WITHIN GROUP(GRAPH PATH) AS route,
    LAST_VALUE(location2.locationname)
      WITHIN GROUP (GRAPH PATH) AS lastlocation
  FROM
    Location AS Location1,
    Road FOR PATH AS IsConnectedTo, 
    Location FOR PATH AS Location2
  WHERE
    MATCH(SHORTEST_PATH(
      Location1(-(IsConnectedTo WEIGHT BY SUM(distance))->Location2)+))
    AND Location1.locationname = N'Seattle'
)
SELECT route
FROM C
WHERE lastlocation = N'San Francisco';
GO

-- Using arbitrary length patterns that are not related to shortest path searches

-- Return all direct and indirect replies to some input post

-- The long solution using a recursive query that is currently supported
DECLARE @postid AS INT = 13;

WITH C AS
(
  SELECT ParentPost.postid AS parentpostid,
    ChildPost.postid, ChildPost.posttext
  FROM Graph.Post AS ChildPost, Graph.IsReplyTo,
    Graph.Post AS ParentPost
  WHERE ParentPost.postid = @postid
    AND MATCH(ChildPost-(IsReplyTo)->ParentPost)

  UNION ALL

  SELECT ParentPost.postid AS parentpostid,
    ChildPost.postid, ChildPost.posttext
  FROM Graph.Post AS ChildPost, Graph.IsReplyTo,
    C, Graph.Post AS ParentPost
  WHERE ParentPost.postid = C.postid
    AND MATCH(ChildPost-(IsReplyTo)->ParentPost)
)
SELECT parentpostid, postid, posttext
FROM C;
GO

-- This syntax is not supported
DECLARE @postid AS INT = 13;

SELECT ParentPost.postid AS parentpostid,
  ChildPost.postid, ChildPost.posttext
FROM Graph.Post AS ChildPost, Graph.IsReplyTo,
  (SELECT * FROM Graph.Post WHERE postid = @postid) AS ParentPost
WHERE MATCH((ChildPost-(IsReplyTo)->)+ParentPost);
GO

---------------------------------------------------------------------
-- Data modification considerations
---------------------------------------------------------------------

-- Inserts covered earlier in section about creating tables

---------------------------------------------------------------------
-- Deleting and updating data
---------------------------------------------------------------------

-- Current follower relationships where 
-- Alma is the follower
SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND Account1.accountid = 661; -- follower is Alma
GO

/*
actid1  actname1  actid2      actname2  startdate
------- --------- ----------- --------- ----------
661     Alma      71          Miko      2021-05-16
661     Alma      421         Buzi      2021-05-18
661     Alma      941         Stav      2022-01-06
*/

-- Updating data

-- Delete follow relationship represented by 
-- @actid1 = 661 (Alma), @actid2 = 421 (Buzi)

-- The long way

-- Note: Using transaction here for demo purposes only
-- Apply change, query to verify change,
-- then rollback the change to revert to original state
BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 421;

DELETE FROM Graph.Follows
WHERE $from_id = (SELECT $node_id FROM Graph.Account
                  WHERE accountid = @actid1)
  AND $to_id = (SELECT $node_id FROM Graph.Account
                WHERE accountid = @actid2);

SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND Account1.accountid = 661;

ROLLBACK TRAN;
GO

/*
actid1  actname1  actid2      actname2  startdate
------- --------- ----------- --------- ----------
661     Alma      71          Miko      2021-05-16
661     Alma      941         Stav      2022-01-06
*/

-- The MATCH way
BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 421;

DELETE FROM Follows
FROM Graph.Account AS Account1, Graph.Account AS Account2,
  Graph.Follows
WHERE MATCH(Account1-(Follows)->Account2)
  AND Account1.accountid = @actid1
  AND Account2.accountid = @actid2;

SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND Account1.accountid = 661;

ROLLBACK TRAN;
GO

/*
actid1  actname1  actid2      actname2  startdate
------- --------- ----------- --------- ----------
661     Alma      71          Miko      2021-05-16
661     Alma      941         Stav      2022-01-06
*/

-- Updating data

-- Update follow relationship represented by 
-- @actid1 = 661 (Alma), @actid2 = 421 (Buzi)
-- Setting startdate to @startdate (use '20210802' as example)

-- The long way
BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 421,
  @startdate AS DATE = '20210802';

UPDATE Graph.Follows
  SET startdate = @startdate
OUTPUT deleted.startdate AS olddate, inserted.startdate AS newdate
WHERE $from_id = (SELECT $node_id FROM Graph.Account
                  WHERE accountid = @actid1)
  AND $to_id = (SELECT $node_id FROM Graph.Account
                WHERE accountid = @actid2);

ROLLBACK TRAN;
GO

/*
olddate    newdate
---------- ----------
2021-05-18 2021-08-02
*/

-- The MATCH way
BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 421,
  @startdate AS DATE = '20210802';

UPDATE Follows
  SET startdate = @startdate
OUTPUT deleted.startdate AS olddate, inserted.startdate AS newdate
FROM Graph.Account AS Account1, Graph.Account AS Account2,
  Graph.Follows
WHERE MATCH(Account1-(Follows)->Account2)
  AND Account1.accountid = @actid1
  AND Account2.accountid = @actid2;

ROLLBACK TRAN;
GO

/*
olddate    newdate
---------- ----------
2021-05-18 2021-08-02
*/

---------------------------------------------------------------------
-- Merging data
---------------------------------------------------------------------

-- Using MATCH in MERGE predicate requires SQL Server 2019 or later,
-- or Azure SQL Database

-- Current follower relationships where 
-- Alma is the follower or Yatzek is the followee
SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND (Account1.accountid = 661 -- follower is Alma
       OR Account2.accountid = 883); -- followee is Yatzek
GO

/*
actid1  actname1  actid2 actname2  startdate
------- --------- ------ --------- ----------
661     Alma      421    Buzi      2021-05-18
71      Miko      883    Yatzek    2021-05-16
661     Alma      941    Stav      2022-01-06
661     Alma      71     Miko      2021-05-16
727     Mitzi     883    Yatzek    2021-02-18
199     Lilach    883    Yatzek    2022-01-14
953     Omer      883    Yatzek    2022-03-17

(7 rows affected)
*/

-- Merge follow relationship represented by 
-- @actid1 = 661 (Alma), @actid2 = 421 (Buzi), @startdate = '20210802'

BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 421,
  @startdate AS DATE = '20210802';

MERGE INTO Graph.Follows
USING (SELECT @actid1, @actid2, @startdate)
      AS SRC(actid1, actid2, startdate)
  INNER JOIN Graph.Account AS Account1
    ON SRC.actid1 = Account1.accountid
  INNER JOIN Graph.Account AS Account2
    ON SRC.actid2 = Account2.accountid
  ON MATCH(Account1-(Follows)->Account2)
WHEN MATCHED THEN UPDATE
  SET startdate = SRC.startdate
WHEN NOT MATCHED THEN INSERT($from_id, $to_id, startdate)
  VALUES(Account1.$node_id, Account2.$node_id, SRC.startdate);

SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND (Account1.accountid = 661 
       OR Account2.accountid = 883); 

ROLLBACK TRAN;
GO

/*
actid1  actname1  actid2 actname2  startdate
------- --------- ------ --------- ----------
661     Alma      421    Buzi      2021-08-02
71      Miko      883    Yatzek    2021-05-16
661     Alma      941    Stav      2022-01-06
661     Alma      71     Miko      2021-05-16
727     Mitzi     883    Yatzek    2021-02-18
199     Lilach    883    Yatzek    2022-01-14
953     Omer      883    Yatzek    2022-03-17

(7 rows affected)
*/

-- Merge follow relationship represented by 
-- @actid1 = 661 (alma), @actid2 = 883 (Yatzek), @startdate = '20210802'
BEGIN TRAN;

DECLARE @actid1 AS INT = 661, @actid2 AS INT = 883,
  @startdate AS DATE = '20210802';

MERGE INTO Graph.Follows
USING (SELECT @actid1, @actid2, @startdate)
      AS SRC(actid1, actid2, startdate)
  INNER JOIN Graph.Account AS Account1
    ON SRC.actid1 = Account1.accountid
  INNER JOIN Graph.Account AS Account2
    ON SRC.actid2 = Account2.accountid
  ON MATCH(Account1-(Follows)->Account2)
WHEN MATCHED THEN UPDATE
  SET startdate = SRC.startdate
WHEN NOT MATCHED THEN INSERT($from_id, $to_id, startdate)
  VALUES(Account1.$node_id, Account2.$node_id, SRC.startdate);

SELECT
  Account1.accountid AS actid1, Account1.accountname AS actname1,
  Account2.accountid AS actid2, Account2.accountname AS actname2,
  Follows.startdate
FROM Graph.Account AS Account1, Graph.Follows,
  Graph.Account AS Account2
WHERE MATCH(Account1-(Follows)->Account2)
  AND (Account1.accountid = 661 
       OR Account2.accountid = 883); 

ROLLBACK TRAN;
GO

/*
actid1  actname1  actid2 actname2  startdate
------- --------- ------ --------- ----------
661     Alma      421    Buzi      2021-05-18
71      Miko      883    Yatzek    2021-05-16
661     Alma      941    Stav      2022-01-06
661     Alma      71     Miko      2021-05-16
727     Mitzi     883    Yatzek    2021-02-18
199     Lilach    883    Yatzek    2022-01-14
953     Omer      883    Yatzek    2022-03-17
661     Alma      883    Yatzek    2021-08-02

(8 rows affected)
*/

---------------------------------------------------------------------
-- Cleanup 
---------------------------------------------------------------------

-- When you're done reading the module and working on the exercises
-- run the following code for cleanup 
DROP TABLE IF EXISTS
  Norm.Friendships,
  Norm.Followings,
  Norm.Likes,
  Norm.AuthorsPublications,
  Norm.Posts,
  Norm.Accounts,
  Norm.Publications;

DROP TABLE IF EXISTS
  Graph.IsReplyTo,
  Graph.IsFriendOf,
  Graph.Follows,
  Graph.Posted,
  Graph.Likes,
  Graph.Authored,
  Graph.Post,
  Graph.Account,
  Graph.Publication;
GO

DROP SCHEMA IF EXISTS Norm;
DROP SCHEMA IF EXISTS Graph;
GO
