-- Creating Data Base with my initials 
create database pvajja;

-- Connecting to Database
\c pvajja;


create table cites(bookno int, citedbookno int);
create table book(bookno int, title text, price int);
create table student(sid int, sname text);
create table major(sid int, major text);
create table buys(sid int, bookno int);

-- Data for the student relation.
INSERT INTO student VALUES(1001,'Jean');
INSERT INTO student VALUES(1002,'Maria');
INSERT INTO student VALUES(1003,'Anna');
INSERT INTO student VALUES(1004,'Chin');
INSERT INTO student VALUES(1005,'John');
INSERT INTO student VALUES(1006,'Ryan');
INSERT INTO student VALUES(1007,'Catherine');
INSERT INTO student VALUES(1008,'Emma');
INSERT INTO student VALUES(1009,'Jan');
INSERT INTO student VALUES(1010,'Linda');
INSERT INTO student VALUES(1011,'Nick');
INSERT INTO student VALUES(1012,'Eric');
INSERT INTO student VALUES(1013,'Lisa');
INSERT INTO student VALUES(1014,'Filip');
INSERT INTO student VALUES(1015,'Dirk');
INSERT INTO student VALUES(1016,'Mary');
INSERT INTO student VALUES(1017,'Ellen');
INSERT INTO student VALUES(1020,'Ahmed');

-- Data for the book relation.
INSERT INTO book VALUES(2001,'Databases',40);
INSERT INTO book VALUES(2002,'OperatingSystems',25);
INSERT INTO book VALUES(2003,'Networks',20);
INSERT INTO book VALUES(2004,'AI',45);
INSERT INTO book VALUES(2005,'DiscreteMathematics',20);
INSERT INTO book VALUES(2006,'SQL',25);
INSERT INTO book VALUES(2007,'ProgrammingLanguages',15);
INSERT INTO book VALUES(2008,'DataScience',50);
INSERT INTO book VALUES(2009,'Calculus',10);
INSERT INTO book VALUES(2010,'Philosophy',25);
INSERT INTO book VALUES(2012,'Geometry',80);
INSERT INTO book VALUES(2013,'RealAnalysis',35);
INSERT INTO book VALUES(2011,'Anthropology',50);
INSERT INTO book VALUES(3000,'MachineLearning',40);


-- Data for the buys relation.

INSERT INTO buys VALUES(1001,2002);
INSERT INTO buys VALUES(1001,2007);
INSERT INTO buys VALUES(1001,2009);
INSERT INTO buys VALUES(1001,2011);
INSERT INTO buys VALUES(1001,2013);
INSERT INTO buys VALUES(1002,2001);
INSERT INTO buys VALUES(1002,2002);
INSERT INTO buys VALUES(1002,2007);
INSERT INTO buys VALUES(1002,2011);
INSERT INTO buys VALUES(1002,2012);
INSERT INTO buys VALUES(1002,2013);
INSERT INTO buys VALUES(1003,2002);
INSERT INTO buys VALUES(1003,2007);
INSERT INTO buys VALUES(1003,2011);
INSERT INTO buys VALUES(1003,2012);
INSERT INTO buys VALUES(1003,2013);
INSERT INTO buys VALUES(1004,2006);
INSERT INTO buys VALUES(1004,2007);
INSERT INTO buys VALUES(1004,2008);
INSERT INTO buys VALUES(1004,2011);
INSERT INTO buys VALUES(1004,2012);
INSERT INTO buys VALUES(1004,2013);
INSERT INTO buys VALUES(1005,2007);
INSERT INTO buys VALUES(1005,2011);
INSERT INTO buys VALUES(1005,2012);
INSERT INTO buys VALUES(1005,2013);
INSERT INTO buys VALUES(1006,2006);
INSERT INTO buys VALUES(1006,2007);
INSERT INTO buys VALUES(1006,2008);
INSERT INTO buys VALUES(1006,2011);
INSERT INTO buys VALUES(1006,2012);
INSERT INTO buys VALUES(1006,2013);
INSERT INTO buys VALUES(1007,2001);
INSERT INTO buys VALUES(1007,2002);
INSERT INTO buys VALUES(1007,2003);
INSERT INTO buys VALUES(1007,2007);
INSERT INTO buys VALUES(1007,2008);
INSERT INTO buys VALUES(1007,2009);
INSERT INTO buys VALUES(1007,2010);
INSERT INTO buys VALUES(1007,2011);
INSERT INTO buys VALUES(1007,2012);
INSERT INTO buys VALUES(1007,2013);
INSERT INTO buys VALUES(1008,2007);
INSERT INTO buys VALUES(1008,2011);
INSERT INTO buys VALUES(1008,2012);
INSERT INTO buys VALUES(1008,2013);
INSERT INTO buys VALUES(1009,2001);
INSERT INTO buys VALUES(1009,2002);
INSERT INTO buys VALUES(1009,2011);
INSERT INTO buys VALUES(1009,2012);
INSERT INTO buys VALUES(1009,2013);
INSERT INTO buys VALUES(1010,2001);
INSERT INTO buys VALUES(1010,2002);
INSERT INTO buys VALUES(1010,2003);
INSERT INTO buys VALUES(1010,2011);
INSERT INTO buys VALUES(1010,2012);
INSERT INTO buys VALUES(1010,2013);
INSERT INTO buys VALUES(1011,2002);
INSERT INTO buys VALUES(1011,2011);
INSERT INTO buys VALUES(1011,2012);
INSERT INTO buys VALUES(1012,2011);
INSERT INTO buys VALUES(1012,2012);
INSERT INTO buys VALUES(1013,2001);
INSERT INTO buys VALUES(1013,2011);
INSERT INTO buys VALUES(1013,2012);
INSERT INTO buys VALUES(1014,2008);
INSERT INTO buys VALUES(1014,2011);
INSERT INTO buys VALUES(1014,2012);
INSERT INTO buys VALUES(1017,2001);
INSERT INTO buys VALUES(1017,2002);
INSERT INTO buys VALUES(1017,2003);
INSERT INTO buys VALUES(1017,2008);
INSERT INTO buys VALUES(1017,2012);
INSERT INTO buys VALUES(1020,2012);

-- Data for the cites relation.
INSERT INTO cites VALUES(2012,2001);
INSERT INTO cites VALUES(2008,2011);
INSERT INTO cites VALUES(2008,2012);
INSERT INTO cites VALUES(2001,2002);
INSERT INTO cites VALUES(2001,2007);
INSERT INTO cites VALUES(2002,2003);
INSERT INTO cites VALUES(2003,2001);
INSERT INTO cites VALUES(2003,2004);
INSERT INTO cites VALUES(2003,2002);
INSERT INTO cites VALUES(2012,2005);


-- Data for the major relation.

INSERT INTO major VALUES(1001,'Math');
INSERT INTO major VALUES(1001,'Physics');
INSERT INTO major VALUES(1002,'CS');
INSERT INTO major VALUES(1002,'Math');
INSERT INTO major VALUES(1003,'Math');
INSERT INTO major VALUES(1004,'CS');
INSERT INTO major VALUES(1006,'CS');
INSERT INTO major VALUES(1007,'CS');
INSERT INTO major VALUES(1007,'Physics');
INSERT INTO major VALUES(1008,'Physics');
INSERT INTO major VALUES(1009,'Biology');
INSERT INTO major VALUES(1010,'Biology');
INSERT INTO major VALUES(1011,'CS');
INSERT INTO major VALUES(1011,'Math');
INSERT INTO major VALUES(1012,'CS');
INSERT INTO major VALUES(1013,'CS');
INSERT INTO major VALUES(1013,'Psychology');
INSERT INTO major VALUES(1014,'Theater');
INSERT INTO major VALUES(1017,'Anthropology');

\qecho 'Question 1'

with B as (SELECT sid, bookno FROM Major CROSS JOIN Book WHERE major = 'CS'
except
select sid,bookno from buys)
select bookno, title from book natural join 
(select p.sid, p.bookno from (select b1.sid,b1.bookno from B b1 
							  join B b2 on b1.sid <> b2.sid and b1.bookno = b2.bookno) p
join B b3 on b3.bookno = p.bookno and b3.sid <> p.sid) q
except 
select bookno, title from book natural join (select b1.sid,b1.bookno from B b1 
							  join B b2 on b1.sid <> b2.sid and b1.bookno = b2.bookno) p;

\qecho 'Question 2 - ii'
-- Create table E1
create table E1(x int);
insert into E1 values(1);

-- Create table E2
create table E2(x int);
insert into E2 values(2);

-- Create table F
create table F(x int);

--  If F = NULL
SELECT e1.* FROM E1 e1 CROSS JOIN (select distinct row() from F) f
UNION
(SELECT e2.* FROM E2 e2 
 EXCEPT
 SELECT e2.* FROM E2 e2 CROSS JOIN (select distinct row() from F) f);


insert into F values(1);

--  After inserting if F != NULL
SELECT e1.* FROM E1 e1 CROSS JOIN (select distinct row() from F) f
UNION
(SELECT e2.* FROM E2 e2 
 EXCEPT
 SELECT e2.* FROM E2 e2 CROSS JOIN (select distinct row() from F) f);

-- Drop Table
drop table E1;
drop table E2;
drop table F;

\qecho 'Question 3 - ii'

drop table A;
create table A(x int);

--  If A is empty :
select c.C from (select true as C) c cross join (select distinct row() from A) a
union 
select c.C from 
(select c.C from (select false as C) c
 except 
 select c.C from (select false as C) c cross join (select distinct row() from A) a) c;
 

insert into A values(1);
--  If A is not empty:
select c.C from (select true as C) c cross join (select distinct row() from A) a
union 
select c.C from 
(select c.C from (select false as C) c
 except 
 select c.C from (select false as C) c cross join (select distinct row() from A) a) c;

drop table A;

\qecho 'Question 7'

select distinct s.sid, s.sname from student s natural join buys bu natural join 
(select m.sid from major m where m.major = 'CS') p1 natural join 
(select bo.bookno from book bo where bo.price > 10) p2;

\qecho 'Question 8'

with bookplt60 as (select b.bookno as bbookno ,c.bookno as cbookno from book b join cites c
				   on b.bookno = c.citedbookno and b.price < 60)
select distinct b.bookno,b.title, b.price  from book b natural join
(select distinct b1.cbookno as bookno from bookplt60 b1 join bookplt60 b2 on 
			  b1.bbookno <> b2.bbookno and b1.cbookno = b2.cbookno) p1;

\qecho 'Question 9'

select bo.bookno, bo.title, bo.price from (
select distinct bo.bookno, bo.title, bo.price from book bo
except 
select distinct bo1.bookno, bo1.title, bo1.price from book bo1 natural join
(select bu.bookno from major m join buys bu on m.sid = bu.sid and m.major = 'Math') p1) bo;

\qecho 'Question 10'

with b1 as (select bu.sid,bo.price,bu.bookno,bo.title from buys bu natural join book bo)
select s.sid,s.sname,p1.title,p1.price from student s natural join
(select distinct b1.sid,b1.price,b1.bookno,b1.title from b1 b1
except
select distinct b1.sid,b1.price,b1.bookno,b1.title from b1 b1 join b1 b2 
on b1.sid = b2.sid and b1.price < b2.price) p1;

\qecho 'Question 11'

with bag as(select distinct b.bookno, b.title, b.price from book b join book b1 on b1.price > b.price)
select b1.bookno,b1.title,b1.price from bag b1
except
select distinct a1.bookno,a1.title,a1.price from bag a1 join bag a2 on a1.price < a2.price;

\qecho 'Question 12'

select distinct b.bookno,b.title,b.price from book b natural join (select c.bookno,c.citedbookno from cites c join 
(select b1.bookno from book b1
except 
select b1.bookno from book b1 join book b2 on not b1.price >=  b2.price) p on c.citedbookno <> p.bookno) q;

\qecho 'Question 13'

with bookplt40 as (select bu.sid from buys bu join book bo on bu.bookno = bo.bookno and bo.price < 40),
	 onemajor as (select m.sid from major m 
				 except 
				 select m1.sid from major m1 join major m2 on m1.sid = m2.sid and m1.major <> m2.major)
select s.sid,s.sname from student s natural join (select om.sid from onemajor om 
except 
select bp.sid from  bookplt40 bp) p;

\qecho 'Question 14'

with books as (select * from buys b1 natural join (
select m.sid from major m where m.major = 'CS'
intersect 
select m.sid from major m where m.major = 'Math') p1)
select b.bookno,b.title from book b natural join 
(select distinct b1.bookno from books b1 join books b2 on b1.bookno = b2.bookno
and b1.sid <> b2.sid) b3;

\qecho 'Question 15'

with bookpat70 as (select s.sid,s.sname from book bo1 natural join buys bu1 natural join student s where bo1.price >= 70),
	 booklt30 as (select s.sid,s.sname from book bo1 natural join buys bu1 natural join student s where bo1.price < 30),
	 booklt70 as (select s.sid,s.sname from book bo1 natural join buys bu1 natural join student s where bo1.price < 70)
(select distinct b3.sid,b3.sname from booklt30 b3 
intersect
select b7.sid,b7.sname from bookpat70 b7)
union 
select s.sid,s.sname from student s natural join
(select s.sid from student s
except 
select b.sid from buys b) p
union
(select bl7.sid,bl7.sname from booklt70 bl7
except
select b7.sid,b7.sname from bookpat70 b7);

\qecho 'Question 16'

with maj as (select m1.sid,m2.sid
 from major m1, major m2
 where m1.major = m2.major and m1.sid<>m2.sid),
buys1 as (select bu1.sid as sid1, bu1.bookno, s.sid as sid2
from buys bu1 cross join Student s),
buys2 as (select s.sid as sid1, bu2.bookno, bu2.sid as sid2
from Student s cross join buys bu2)
select * from maj
intersect
(select distinct sid1, sid2
from (select b1.* from buys1 b1
except
select b2.* from buys2 b2) q1
 union
select distinct sid1, sid2
from (select b2.* from buys2 b2
except
select b1.* from buys1 b1) q2
);

-- Connecting to Default database
\c postgres;

-- Drop table which is created
drop database pvajja;