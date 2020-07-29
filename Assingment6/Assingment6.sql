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


\qecho 'Question 3'
--  Makerandom R
create or replace function makerandomR(m int, n int, l int)
returns void as
$$
declare i integer;
j integer;
begin
drop table if exists Ra;
drop table if exists Rb;
drop table if exists R;
create table Ra(a int);
create table Rb(b int);
create table R(a int, b int);
for i in 1..m loop insert into Ra values(i);
end loop;
for j in 1..n loop insert into Rb values(j);
end loop;
insert into R select * from Ra a, Rb b order by random() limit(l);
end;
$$ language PLPGSQL;

-- Make Random S
create or replace function makerandomS(n integer, l integer)
returns void as
$$
declare i integer;
begin
    drop table if exists Sb;
    drop table if exists S;
    create table Sb(b int);
    create table S(b int);
for i in 1..n loop insert into Sb values(i); end loop;
    insert into S select * from Sb order by random() limit (l);
end;
$$ LANGUAGE plpgsql;

makerandomR(3,3,4);
makerandomS(3,4);

\qecho 'Question 7 a'

select distinct r1.a from R r1 natural join 
(select  distinct r2.a as b from R r2 natural join 
 (select  distinct r3.a as b from R r3) r3) r2;

\qecho 'Question 7 b,7c are in the pdf file'

\qecho 'Question 8 a'

select ra.a from Ra ra 
except 
    select distinct p.a from 
 (select r.a,r.b from R r
    except 
    select r.a,r.b from R r natural join (select distinct s.b from S s)s)p;

\qecho 'Question 8b, 8c are in the pdf file'


\qecho 'Question 9 a'

select ra.a from Ra ra 
except
select distinct p.a from 
(select ra.a,s.b from (select distinct s.b from S s) s cross join Ra ra
 except 
 select r.a,r.b from R r)p;


\qecho 'Question 9b, 9c are in the pdf file'

\qecho 'Question 10, 11 are in the pdf file'

drop function makerandomR;
drop function makerandomS;
-- Question 4

\qecho 'Question 12'

-- Union
create or replace function setunion(A anyarray, B anyarray) returns anyarray as
      $$
      select array( select unnest(A) union select unnest(B) order by 1);
      $$ language sql;

\qecho 'Question 12 a'
-- setintersection
create or replace function setintersection(A anyarray, B anyarray) returns anyarray as
      $$
      select array( select unnest(A) Intersect select unnest(B) order by 1);
      $$ language sql;

\qecho 'Question 12 b'
-- setdifference
create or replace function setdifference(A anyarray, B anyarray) returns anyarray as
      $$
      select array( select unnest(A) except select unnest(B) order by 1);
      $$ language sql;

-- Isin
create or replace function isIn(x anyelement, S anyarray)
         returns boolean as
      $$
      select x = SOME(S);
      $$ language sql;


\qecho 'Question 13'

create or replace view student_books
as
select s.sid, array(select bu.bookno from buys bu where bu.sid = s.sid) as books from student s;

select * from student_books;

\qecho 'Question 13 a'

create or replace view book_students
as
select bo.bookno, array(select bu.sid from buys bu where bu.bookno = bo.bookno) students from book bo;

select * from book_students;

\qecho 'Question 13 b'

create or replace view book_citedbooks
as
select bo.bookno, array(select c.citedbookno from cites c where c.bookno = bo.bookno) citedbooks from book bo;

select * from book_citedbooks;

\qecho 'Question 13 c'

create or replace view book_citingbooks
as
select bo.bookno, array(select c.bookno from cites c where c.citedbookno = bo.bookno) citedbooks from book bo;

select * from book_citingbooks;

\qecho 'Question 13 d'

create or replace view major_students
as
select m.major, array_agg(m.sid) as sid from major m group by m.major order by 1;

select * from major_students;

\qecho 'Question 13 e'

create or replace view student_majors
as
select s.sid, array(select m.major from major m where m.sid = s.sid) as majors from student s order by 1;

select * from student_majors;


\qecho 'Question 14'


\qecho 'Question 14 a'

select bo.bookno, bo.title from book bo 
where bo.bookno in (select bc.bookno from book_citedbooks bc where cardinality(bc.citedbooks) >= 3) and bo.price < 50;

\qecho 'Question 14 b'

with cssids as (select array(select sm.sid as sid from student_majors sm where 'CS' <> all(sm.majors)) as sid)
select bo.bookno, bo.title from book bo natural join (select bs.bookno from book_students bs, cssids cs where bs.students <@ cs.sid)p;

\qecho 'Question 14 c'

select sb.sid from student_books sb where array(select bo.bookno from book bo where bo.price >= 50) <@ sb.books;

\qecho 'Question 14 d'

select bs.bookno from book_students bs 
where cardinality(setdifference(bs.students,array(select ms.sid from major_students ms where ms.major = 'CS'))) >= 1;

\qecho 'Question 14 e'

select bo.bookno, bo.title from book bo, book_students bs where bo.bookno = bs.bookno and 
cardinality(setdifference(bs.students, array(select sb.sid from student_books sb 
where array(select b.bookno from book b where b.price > 45) <@ sb.books))) >= 1;

\qecho 'Question 14 f'

select sb.sid, bs.bookno from student_books sb, book_students bs, book_citingbooks bc where bc.bookno = bs.bookno and 
cardinality(setdifference(sb.books,bc.citedbooks)) >= 1 order by 1;

\qecho 'Question 14 g'

select bs1.bookno, bs2.bookno from book_students bs1, book_students bs2 where bs1.students <@ bs2.students and bs2.students <@ bs1.students;

\qecho 'Question 14 h'

select bs1.bookno, bs2.bookno from book_students bs1, book_students bs2 where cardinality(bs1.students) = cardinality(bs2.students);

\qecho 'Question 14 i'

select sb.sid from student_books sb where cardinality(setdifference(array(select bo.bookno from book bo),sb.books)) = 4;

\qecho 'Question 14 j'

select sb.sid from student_books sb where cardinality(sb.books) <= 
cardinality(array(select sb1.books from major_students ms, student_books sb1 where ms.major = 'Psychology' and Isin(sb1.sid,ms.sid)));

drop view student_books;

drop view book_students;

drop view book_citedbooks;

drop view book_citingbooks;

drop view major_students;

drop view student_majors;

drop function setdifference;

drop function setintersection;

drop function setunion;

drop function isIn;

-- Connecting to Default database
\c postgres;

-- Drop table which is created
drop database pvajja;


