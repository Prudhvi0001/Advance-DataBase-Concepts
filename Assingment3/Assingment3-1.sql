-- Creating Data Base with my initials 
create database pvajja;

-- Connecting to Database
\c pvajja;


create table book(bookno int, title text, price int, primary key(bookno));

create table student(sid int, sname text, primary key(sid));

create table cites(bookno int, citedbookno int, foreign  key(bookno) references book(bookno),
				   foreign  key(citedbookno) references book(bookno));

create table major(sid int, major text, foreign key(sid) references student(sid));

create table buys(sid int, bookno int, foreign key(sid) references student(sid),
				  foreign  key(bookno) references book(bookno));

DELETE FROM cites;
DELETE FROM buys;
DELETE FROM major;
DELETE FROM book;
DELETE FROM student;

-- Data for the student relation.
INSERT INTO student VALUES(1001,'Jean'),(1002,'Maria'),(1003,'Anna'),
(1004,'Chin'),(1005,'John'),(1006,'Ryan'),(1007,'Catherine'),(1008,'Emma'),
(1009,'Jan'),(1010,'Linda'),(1011,'Nick'),(1012,'Eric'),(1013,'Lisa'),
(1014,'Filip'),(1015,'Dirk'),(1016,'Mary'),(1017,'Ellen'),(1020,'Ahmed'),(1021, 'Kris');


-- Data for the book relation.
INSERT INTO book VALUES(2001,'Databases',40),(2002,'OperatingSystems',25),(2003,'Networks',20),
(2004,'AI',45),(2005,'DiscreteMathematics',20),(2006,'SQL',25),(2007,'ProgrammingLanguages',15),
(2008,'DataScience',50),(2009,'Calculus',10),(2010,'Philosophy',25),(2012,'Geometry',80),
(2013,'RealAnalysis',35),(2011,'Anthropology',50),(3000,'MachineLearning',40),
(4001, 'LinearAlgebra', 30),(4002, 'MeasureTheory', 75),(4003, 'OptimizationTheory', 30);


-- Data for the buys relation.

INSERT INTO buys VALUES(1001,2002),(1001,2007),(1001,2009),(1001,2011),
(1001,2013),(1002,2001),(1002,2002),(1002,2007),(1002,2011),(1002,2012),
(1002,2013),(1003,2002),(1003,2007),(1003,2011),(1003,2012),(1003,2013),
(1004,2006),(1004,2007),(1004,2008),(1004,2011),(1004,2012),(1004,2013),
(1005,2007),(1005,2011),(1005,2012),(1005,2013),(1006,2006),(1006,2007),
(1006,2008),(1006,2011),(1006,2012),(1006,2013),(1007,2001),(1007,2002),
(1007,2003),(1007,2007),(1007,2008),(1007,2009),(1007,2010),(1007,2011),
(1007,2012),(1007,2013),(1008,2007),(1008,2011),(1008,2012),(1008,2013),
(1009,2001),(1009,2002),(1009,2011),(1009,2012),(1009,2013),(1010,2001),
(1010,2002),(1010,2003),(1010,2011),(1010,2012),(1010,2013),(1011,2002),
(1011,2011),(1011,2012),(1012,2011),(1012,2012),(1013,2001),(1013,2011),
(1013,2012),(1014,2008),(1014,2011),(1014,2012),(1017,2001),(1017,2002),
(1017,2003),(1017,2008),(1017,2012),(1020,2012),(1001,3000),(1001,2004),
(1021, 2001),(1021, 2002),(1021, 2003),(1021, 2004),(1021, 2005),(1021, 2006),
(1021, 2007),(1021, 2008),(1021, 2009),(1021, 2010),(1021, 2011),(1021, 4003),
(1021, 4001),(1021, 4002),(1015, 2001),(1015, 2002),(1016, 2001),(1016, 2002),
(1015, 2004),(1015, 2008),(1015, 2012),(1015, 2011),(1015, 3000),(1016, 2004),
(1016, 2008),(1016, 2012),(1016, 2011),(1016, 3000),(1002, 4003),(1011, 4003),
(1015, 4003),(1015, 4001),(1015, 4002),(1016, 4001),(1016, 4002);

-- Data for the cites relation.
INSERT INTO cites VALUES(2012,2001),(2008,2011),(2008,2012),(2001,2002),
(2001,2007),(2002,2003),(2003,2001),(2003,2004),(2003,2002),(2012,2005);


-- Data for the major relation.

INSERT INTO major VALUES(1001,'Math'),(1001,'Physics'),(1002,'CS'),(1002,'Math'),
(1003,'Math'),(1004,'CS'),(1006,'CS'),(1007,'CS'),(1007,'Physics'),(1008,'Physics'),
(1009,'Biology'),(1010,'Biology'),(1011,'CS'),(1011,'Math'),(1012,'CS'),(1013,'CS'),
(1013,'Psychology'),(1014,'Theater'),(1017,'Anthropology'),(1021, 'CS'), (1021, 'Math');

\qecho 'Question 1 Part (a)'

-- Creating Tables

create table A(x integer);
insert into A values(1),(2),(3);
create table B(x integer);
insert into B values(1),(3);

SELECT not EXISTS(SELECT * FROM A EXCEPT SELECT * FROM B) AS empty_a_minus_b,
not exists(select * from B except select * from A) as empty_b_minus_a,
not exists(select * from A intersect select * from B) as empty_a_intersection_b;

\qecho 'Question 1 Part (b)'

SELECT not EXISTS(SELECT * FROM A a where a.x not in(SELECT * FROM B)) AS empty_a_minus_b,
not exists(select * from B b where b.x not in (select * from A)) as empty_b_minus_a,
not exists(select * from A a where a.x in (select * from B)) as empty_a_intersection_b;

drop table A;
drop table B;


\qecho 'Question 2'

create table p(p boolean);
create table q(q boolean);
create table r(r boolean);
insert into p values(TRUE),(FALSE),(NULL);
insert into q values(TRUE),(FALSE),(NULL);
insert into r values(TRUE),(FALSE),(NULL);

select p,q,r, not((not p) or q) or (not r)as value from p,q,r;

drop table p;
drop table q;
drop table r;

\qecho 'Question 3 Part (a)'

-- Create function to calculate distance.
CREATE FUNCTION distance(x1 FLOAT, y1 FLOAT, x2 FLOAT, y2 FLOAT)
     RETURNS FLOAT AS
     $$
          SELECT sqrt(power(x1-x2,2)+power(y1-y2,2));
     $$  LANGUAGE SQL;

create table point(pid INTEGER, x float, y float);
insert into point values(1,0,0),(2,0,1),(3,1,0);

select p3.pid as p1,p4.pid as p2 from point p3, point p4 where p3.pid <> p4.pid 
and  distance(P3.X,P3.Y,P4.X,P4.Y) <= all (SELECT distance(P1.X,P1.Y,P2.X,P2.Y) as distance
FROM Point P1, Point P2 where p1.pid <> p2.pid);

drop function distance;

\qecho 'Question 3 Part (b)'

CREATE FUNCTION area1(x1 FLOAT, y1 FLOAT, x2 FLOAT, y2 FLOAT,x3 FLOAT, 
y3 FLOAT,OUT area float) AS
$$
select (((x1-x2)*(y2-y3)) - ((x2-x3)*(y1-y2)))
$$ LANGUAGE SQL;

\qecho 'Output before adding collinear points'

select distinct p1.pid,p2.pid,p3.pid from point p1, point p2, point p3 where
p1.pid <> p2.pid and p2.pid <> p3.pid and p1.pid <> p3.pid and 
area1(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y) = 0;

insert into point values(4,1,1),(5,2,2);

\qecho 'Output after adding collinear points'

select distinct p1.pid,p2.pid,p3.pid from point p1, point p2, point p3 where
p1.pid <> p2.pid and p2.pid <> p3.pid and p1.pid <> p3.pid and 
area1(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y) = 0;

drop function area1;
drop table point;

\qecho 'Question 4 Part (a)'

create table R_primary( A integer,
			   B integer,
			   C integer);
insert into r_primary values(1,2,3),(2,3,4),(3,4,5);

SELECT not EXISTS(SELECT * FROM r_primary r1, r_primary r2 
WHERE r1.b <> r2.b AND r1.a = r2.a) AS is_a_primary;


\qecho 'Question 4 Part (b)'

create table R_not_primary( A integer,
			   B integer,
			   C integer);
insert into r_not_primary values(1,2,3),(3,3,4),(3,4,5);

select * from r_primary;
select * from R_not_primary;

SELECT not EXISTS(SELECT  * FROM r_primary r1, r_primary r2 
WHERE r1.b <> r2.b AND r1.a = r2.a) AS is_a_primary;
				  
SELECT not EXISTS(SELECT  * FROM r_not_primary r1, r_not_primary r2 
WHERE r1.b <> r2.b AND r1.a = r2.a) AS is_a_primary;

create table R(a int, b int, c int);
insert into R values(1,8,9),(2,2,4);
select * from R;

drop table R;

drop table R_primary;
drop table R_not_primary;

\qecho 'Question 5'

create table M(row INTEGER, col INTEGER, val INTEGER);
INSERT INTO M VALUES(1,1,1),(1,2,2),(1,3,3),(2,1,1),
(2,2,-3),(2,3,5),(3,1,4),(3,2,0),(3,3,-2);

with m2matrix as (select m3.row, m3.col, sum(m12.val) as val from M m3,
(select distinct m1.row as r1, m1.col as c1,m2.row as r2,m2.col as c2, m1.val*m2.val as val 
from M m1, M m2) m12 where m12.r1 = m3.row and m12.c2 = m3.col 
			   and m12.c1 = m12.r2 group by m12.r1,m12.c2,m3.row,m3.col)
select m3.row, m3.col, sum(m12.val) as val from m2matrix m3,
(select distinct m1.row as r1, m1.col as c1,m2.row as r2,m2.col as c2, m1.val*m2.val as val 
from m2matrix m1, m2matrix m2) m12 where m12.r1 = m3.row and m12.c2 = m3.col 
			   and m12.c1 = m12.r2 group by m12.r1,m12.c2,m3.row,m3.col;

drop table M;

\qecho 'Question 6'

-- Function to calculate remainder when divided by 4:

create function remainder(x INTEGER, out mod4 int)
as 
$$
select mod(x,4)
$$ LANGUAGE SQL;

create table A_rem(x integer);
insert into A_rem values(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

select remainder(a.x) as mod ,count(remainder(a.x)) as count 
from A_rem a group by remainder(a.x) order by mod;

drop function remainder;
drop table A_rem;

\qecho 'Question 7'

create table A(x integer);
insert into A values(5),(3),(3),(2),(1),(3),(5);
select a.x from A a group by a.x;

drop table A;

\qecho 'Question 8 Part(a)'

select bo.bookno, bo.title from book bo where bo.price < 40 and 
(select count(bu.sid) 
 from major m, buys bu where
 bo.bookno = bu.bookno and bu.sid = m.sid and m.major = 'CS' group by (bu.bookno)) < 3;

\qecho 'Question 8 Part(b)'

select s.sid, s.sname, q.count from student s, (SELECT bu.sid, sum(bo.price) as cost,
 count(bo.bookno) as count
FROM buys bu, book bo 
WHERE bu.bookno = bo.bookno group by(bu.sid)) q where q.cost < 200 and s.sid = q.sid;

\qecho 'Question 8 Part(c)'

with c as (SELECT bu.sid, sum(bo.price) as cost FROM buys bu, book bo 
WHERE bu.bookno = bo.bookno group by bu.sid)
select s.sid, s.sname from student s where s.sid =
(select c1.sid from c c1 where c1.cost >= all (select c2.cost from c c2));

\qecho 'Question 8 Part(d)'

select q.major, sum(q.cost) from (select m.major,(select sum(bo.price) 
from buys bu, book bo where bu.bookno = bo.bookno
and bu.sid = m.sid) as cost from major m) q group by(q.major);

\qecho 'Question 8 Part(e)'

with countbooks as 
(select bu.bookno, count(bu.sid) as count from buys bu, major m 
 where m.sid = bu.sid and m.major = 'CS' group by bu.bookno)
select c1.bookno, c2.bookno from countbooks c1, countbooks c2 where c1.bookno <> c2.bookno and c2.count = c1.count;

\qecho 'Question 9'

create view bookscostgt50 as select * from book bo where bo.price > 50;

CREATE FUNCTION books(sid INTEGER) 
RETURNS TABLE(b INTEGER) AS $$
SELECT bu.bookno 
FROM buys bu WHERE bu.sid = books.sid
$$ LANGUAGE SQL;


select s.sid,s.sname from student s where exists
(select b50.bookno from bookscostgt50 b50 where 
b50.bookno not in (select * from books(s.sid)));

drop view bookscostgt50;
drop function books;

\qecho 'Question 10'

create view csormathmajors as select m.sid from major m
 where m.major = 'CS' or m.major = 'Math';

CREATE FUNCTION buysbooks(bookno INTEGER) 
RETURNS TABLE(sid INTEGER) AS $$
SELECT bu.sid 
FROM buys bu WHERE bu.bookno = buysbooks.bookno
$$ LANGUAGE SQL;

select bo.bookno, bo.title from book bo where exists
(select * from buysbooks(bo.bookno) bb 
 where bb.sid not in (select * from csormathmajors));

drop function buysbooks;
drop view csormathmajors;

\qecho 'Question 11'

create view LeastExpensiveBook as select bo.bookno from book bo where bo.price =
   (select min(bo1.price) from book bo1);

CREATE FUNCTION buysstudent(sid INTEGER) 
RETURNS TABLE(sid INTEGER, bookno INTEGER) AS $$
SELECT bu.sid, bu.bookno  
FROM buys bu WHERE bu.sid = buysstudent.sid
$$ LANGUAGE SQL;

select s.sid, s.sname from student s where not exists
(select * from buysstudent(s.sid) bs where bs.bookno
in (select * from LeastExpensiveBook));

drop function buysstudent;
drop view LeastExpensiveBook;

\qecho 'Question 12'

create view csstudents as select m.sid from major m where m.major = 'CS';

create function sidofbookno(bookno INTEGER) 
returns table (sid INTEGER) as 
$$
select bu.sid from buys bu 
where bu.bookno = sidofbookno.bookno;
$$ LANGUAGE SQL;

select distinct bo1.bookno,bo2.bookno from book bo1, book bo2 where bo1.bookno <> bo2.bookno
and not exists
(select bu1.sid from sidofbookno(bo1.bookno) bu1 where bu1.sid in(select * from csstudents)
	except
select bu2.sid from sidofbookno(bo2.bookno) bu2 where bu2.sid in(select * from csstudents))
	and  not exists
(select bu2.sid from sidofbookno(bo2.bookno) bu2 where bu2.sid in(select * from csstudents)
	except
select bu1.sid from sidofbookno(bo1.bookno) bu1 where bu1.sid in(select * from csstudents));

drop function sidofbookno;
drop view csstudents;

\qecho 'Question 13'

create view bookscostlt50 as select * from book bo where bo.price < 50;

create function CSstudents(sid INTEGER) 
returns table (bookno INTEGER) as 
$$
select bu.bookno from buys bu 
where bu.sid = CSstudents.sid;
$$ LANGUAGE SQL;

select distinct s.sid,s.sname from student s, major m 
where m.sid = s.sid and m.major = 'CS' and (select count(1) from 
(select cs.bookno from CSstudents(s.sid) cs
 INTERSECT select b50.bookno from bookscostlt50 b50) q) < 4;
 
drop function CSstudents;
drop view bookscostlt50;

\qecho 'Question 14'

create view csstudents as select m.sid from major m where m.major = 'CS';

create function sidswhobroughtbookno(bookno INTEGER) 
returns table (sid INTEGER) as 
$$
select bu.sid from buys bu 
where bu.bookno = sidswhobroughtbookno.bookno;
$$ LANGUAGE SQL;

select bo.bookno, bo.title from book bo where (
select mod(count(1),2) from (select sb.sid from sidswhobroughtbookno(bo.bookno) sb 
where sb.sid in (select cs.sid from csstudents cs)) q) <> 0;

 
drop function sidswhobroughtbookno;
drop view csstudents;

\qecho 'Question 15'

create function booksbroughtbysid(sid INTEGER) 
returns table (bookno INTEGER) as 
$$
select bu.bookno from buys bu 
where bu.sid = booksbroughtbysid.sid;
$$ LANGUAGE SQL;

select s.sid, s.sname from student s where (
select count(1) from (select bu.bookno from booksbroughtbysid(sid) bu) q) =
(select count(distinct bo.bookno)-3 from book bo);

drop function booksbroughtbysid;

\qecho 'Question 16'

create function sidofbookno(bookno INTEGER) 
returns table (sid INTEGER) as 
$$
select bu.sid from buys bu 
where bu.bookno = sidofbookno.bookno;
$$ LANGUAGE SQL;

select distinct bo1.bookno,bo2.bookno from book bo1, book bo2 
where bo1.bookno <> bo2.bookno and 
(select count(1)from (select sb1.sid from sidofbookno(bo1.bookno) sb1 
	except
select sb2.sid from sidofbookno(bo2.bookno) sb2) q) = 0;
 
drop function sidofbookno;

-- Connecting to Default database
\c postgres;

-- Drop table which is created
drop database pvajja;