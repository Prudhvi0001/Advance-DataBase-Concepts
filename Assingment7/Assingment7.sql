-- Creating database with my initials
CREATE DATABASE pvajja7;

--Connecting database 
\c pvajja7; 

\qecho '1a'

drop table r;
create table R (a int, b int, c int);
insert into R values (1,2,3), (4,5,6), (1,2,4);
table R;

drop table encodingofR;
create table encodingofR (key text, value jsonb);
insert into encodingofR select 'R' as Key, 
json_build_object('a', r.a, 'b', r.b)::jsonb as Value from R r;
table encodingofR;


-- Map function
drop function Map; Drop function Reduce;
CREATE OR REPLACE FUNCTION Map(KeyIn text, ValueIn jsonb)
RETURNS TABLE(KeyOut jsonb, ValueOut int) AS
$$
    SELECT ValueIn::jsonb, 1 as one;
$$ LANGUAGE SQL;

-- Reduce function
CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValuesIn int[])
RETURNS TABLE(KeyOut text, ValueOut jsonb) AS
$$
    SELECT 'R'::text, KeyIn;
$$ LANGUAGE SQL;

-- Simulate MapReduce Program and decode
\qecho 'Projection of R(a,b)'
WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfR, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT r.valueOut->'a' as A,r.valueOut->'b' as B FROM Reduce_Phase r;


\qecho '1b'

drop table R; drop table S;

create table R(a int); create table S(a int);

insert into R values (1),(2),(3),(4);
insert into S values (2),(4),(5);

table r;
table s;

drop table EncodingOfRandS;
create table EncodingOfRandS(key text, value jsonb);

insert into EncodingOfRandS
   select 'R' as Key, json_build_object('a', a)::jsonb as Value
   from   R
   union
   select 'S' as Key, json_build_object('a', a)::jsonb as Value
   from   S order by 1;

table EncodingOfRandS;


-- Map function
drop function Map; Drop function reduce;
CREATE OR REPLACE FUNCTION Map(KeyIn text, ValueIn jsonb)
RETURNS TABLE(KeyOut jsonb, ValueOut jsonb) AS
$$
    SELECT ValueIn::jsonb, json_build_object('RelName', KeyIn::text)::jsonb;
$$ LANGUAGE SQL;

-- Reduce function
CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValuesIn jsonb[])
RETURNS TABLE(KeyOut text, ValueOut jsonb) AS
$$
    SELECT 'R Difference S'::text, KeyIn WHERE NOT
            array['{"RelName": "S"}']::jsonb[] <@ ValuesIn::jsonb[];
$$ LANGUAGE SQL;

-- Simulate MapReduce Program and decode
\qecho 'R-S'

WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfRandS, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT valueOut->'a' as A FROM Reduce_Phase order by 1;



\qecho '1c'


drop table R; drop table S;

create table R(a int, b int); create table S(b int, c int);

insert into R values (1,1),(2,2),(3,3),(4,4);
insert into S values (2,3),(4,3),(5,6),(1,4);

table R;
table S;


drop table EncodingOfRandS;
create table EncodingOfRandS(key text, value jsonb);

insert into EncodingOfRandS
   select 'R' as Key, json_build_object('a', a, 'b', b)::jsonb as Value
   from   R
   union
   select 'S' as Key, json_build_object('b', b, 'c', c)::jsonb as Value
   from   S order by 1;

table EncodingOfRandS;


-- Map function
drop function Map;
Drop function reduce;

CREATE OR REPLACE FUNCTION Map(KeyIn text, ValueIn jsonb)
RETURNS TABLE(KeyOut jsonb, ValueOut jsonb) AS
$$
    SELECT json_build_object('b',ValueIn->'b')::jsonb, json_build_object(keyIn,ValueIn)::jsonb;
$$ LANGUAGE SQL;

-- Reduce function
CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValueIn jsonb[])
RETURNS TABLE(KeyOut jsonb, ValueOut int) AS
$$
    SELECT unnest(ValueIn) , cardinality(ValueIn) where cardinality(ValueIn) = 2;
$$ LANGUAGE SQL;

-- Simulate MapReduce Program and decode
\qecho 'Semi Join of R $\ltimes$ S'
WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfRandS, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
SELECT r.keyout->'R'->'a' as A, r.keyout->'R'->'b' as B  FROM Reduce_Phase r where r.valueout = 2 
and r.keyout->'R'->'a' is not null;



\qecho '1d'


drop table R; drop table S; drop table T;

create table R(a int); create table S(a int); create table T(a int);

insert into R values (1),(2),(3),(4),(5);
insert into S values (3);
insert into T values (4);

drop table EncodingOfRandSandT;
create table EncodingOfRandSandT(key text, value jsonb);

insert into EncodingOfRandSandT
   select 'R' as Key, json_build_object('a', a)::jsonb as Value
   from   R
   union
   select 'S' as Key, json_build_object('a', a)::jsonb as Value
   from   S
   union
   select 'T' as Key, json_build_object('a', a)::jsonb as Value
   from   T;

table EncodingOfRandSandT;


-- Map function
drop function Map;
Drop function Reduce;



CREATE OR REPLACE FUNCTION Map(KeyIn text, ValueIn jsonb)
RETURNS TABLE(KeyOut jsonb, ValueOut jsonb) AS
$$    
SELECT ValueIn::jsonb, json_build_object('RelName', KeyIn::text)::jsonb;
$$ LANGUAGE SQL;

-- Reduce function 
CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValuesIn jsonb[])
RETURNS TABLE(KeyOut text, ValueOut jsonb) AS
$$
SELECT 'R - S(U)T'::text, KeyIn WHERE 
 array['{"RelName": "R"}']::jsonb[] = ValuesIn::jsonb[] 
$$ LANGUAGE SQL;

-- Simulate MapReduce Program and decode
\qecho 'R − (S ∪ T )'

WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfRandSandT, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)
select * from Reduce_Phase r;




\qecho '2'

drop table r;
create table r(a int, b int);
insert into r values(1,2),(2,3),(3,4),(5,6),(1,3),(3,5),(2,2);

drop table encodingofR;
create table encodingofR (key text, value jsonb);
insert into encodingofR select 'R' as Key, 
json_build_object('a', r.a, 'b', r.b)::jsonb as Value from R r;

table encodingofR;


-- Map function
drop function Map; Drop function Reduce;

CREATE OR REPLACE FUNCTION Map(KeyIn text, ValueIn jsonb)
RETURNS TABLE(KeyOut jsonb, ValueOut jsonb) AS
$$
    SELECT json_build_object('a', ValueIn->'a')::jsonb, ValueIn->'b';
$$ LANGUAGE SQL;

-- Reduce function
CREATE OR REPLACE FUNCTION Reduce(KeyIn jsonb, ValuesIn jsonb[])
RETURNS TABLE(KeyOut jsonb, ValueOut jsonb[]) AS
$$
    SELECT KeyIn, ValuesIn;
$$ LANGUAGE SQL;

-- Simulate MapReduce Program and decode

WITH
Map_Phase AS (
    SELECT m.KeyOut, m.ValueOut 
    FROM   encodingOfR, LATERAL(SELECT KeyOut, ValueOut FROM Map(key, value)) m
),
Group_Phase AS (
    SELECT KeyOut, array_agg(Valueout) as ValueOut
    FROM   Map_Phase
    GROUP  BY (KeyOut)
),
Reduce_Phase AS (
    SELECT r.KeyOut, r.ValueOut
    FROM   Group_Phase gp, LATERAL(SELECT KeyOut, ValueOut FROM Reduce(gp.KeyOut, gp.ValueOut)) r
)select r.keyout->'a' as a, r.valueout, cardinality(r.valueout) 
from Reduce_Phase r where cardinality(r.valueout) >= 2;



\qecho '3a'

drop table r; drop table s;

create table R(k int, v int); create table S(k int, w int);
insert into R values(1,1),(1,2),(2,1),(3,3);
insert into S values(1,1),(1,3),(3,2),(4,1),(4,4);

drop view R_CoGroup_S;

create view R_CoGroup_S as
select r.k, r.RV_values, s.SW_values from 
(select r.K, ARRAY_AGG(r.V) AS RV_values FROM R r GROUP BY (r.K)
 union 
 SELECT s.K, '{}' AS RV_VALUES FROM S s WHERE s.K NOT IN (SELECT r.K FROM R r)) r
natural join
(SELECT s.K, ARRAY_AGG(s.W) AS SW_values FROM S s GROUP BY (s.K)
union
SELECT r.K, '{}' AS RV_VALUES FROM R r WHERE r.K NOT IN (SELECT s.K FROM S s)) s;

select r.k,(r.RV_values, r.SW_values) as cogroup from R_CoGroup_S r;


\qecho '3b'

select r.k, unnest(r.rv_values) as V from R_CoGroup_S r 
where not r.RV_values = '{}' and not r.SW_values = '{}';


\qecho '3c'

SELECT distinct r.K as rK, s.K as sK
FROM R r, S s
WHERE ARRAY(SELECT r1.V
FROM R r1
WHERE r1.K = r.K) <@ ARRAY(SELECT s1.W
FROM S s1
WHERE s1.K = s.K);

-- Using View
select distinct r1.k,r2.k from R_CoGroup_S r1, R_CoGroup_S r2 where r1.rv_values <@ r2.sw_values
and not r1.RV_values = '{}' and not r2.SW_values = '{}';

drop view r_cogroup_s;


\qecho '4a'


drop table A; drop table B;

create table A(a int); create table B(a int);

insert into A values(1),(2),(3),(4),(5);
insert into B values(3),(5),(1);

drop table R; drop table S;

create table R(k int, v int);
create table S(k int, w int);

insert into R select a, a from A;
insert into S select a, a from B;

-- Normal AcogroupB
WITH Kvalues AS (SELECT r.K FROM R r UNION SELECT s.K FROM S s),
R_K AS (SELECT r.K, ARRAY_AGG(r.V) AS RV_values FROM R r GROUP BY (r.K)
		UNION
		SELECT k.K, '{}' AS RV_VALUES FROM Kvalues k WHERE 
		k.K NOT IN (SELECT r.K FROM R r)),
S_K AS (SELECT s.K, ARRAY_AGG(s.W) AS SW_values FROM S s GROUP BY (s.K) 
		UNION
		SELECT k.K, '{}' AS SW_VALUES FROM Kvalues k 
		WHERE k.K NOT IN (SELECT s.K FROM S s)),
AcogroupB as (SELECT K, RV_values, SW_values FROM R_K NATURAL JOIN S_K)
select A.k as AnB from AcogroupB a where not a.sw_values = '{}';


-- A cougroup B using View
create view AcogroupB as
select r.K, r.RV_values, s.SW_values from 
(select r.K, ARRAY_AGG(r.V) AS RV_values FROM R r GROUP BY (r.K)
 union 
 SELECT s.K, '{}' AS RV_VALUES FROM S s WHERE s.K NOT IN (SELECT r.K FROM R r)) r
natural join
(SELECT s.K, ARRAY_AGG(s.W) AS SW_values FROM S s GROUP BY (s.K)
union
SELECT r.K, '{}' AS RV_VALUES FROM R r WHERE r.K NOT IN (SELECT s.K FROM S s)) s;

select A.k as AnB from AcogroupB a where a.RV_VALUES = a.SW_VALUES;


\qecho '4b'

\qecho 'Using Normal query:'

(select a from a
except
select a from b)
union
(select a from b
except
select a from a);

\qecho 'Using AcogroupB:'

select a.k from AcogroupB a where a.sw_values = '{}'
union 
select a.k from AcogroupB a where a.rv_values = '{}';

drop view AcogroupB;


\qecho '5 Load Tables Defined in class' 

create table student 
(sid text,
sname text,
major text,
byear int,
PRIMARY KEY(sid));

create table course 
(cno text,
cname text,
dept text,
PRIMARY KEY(cno));

create table enroll
(sid text,
cno text,
grade text,
FOREIGN KEY(sid) REFERENCES student(sid),
FOREIGN KEY(cno) REFERENCES course(cno)
);

CREATE TABLE major (sid text, major text);



insert into student values('s100','Eric','CS',1987),('s101','Nick','Math',1990),('s102','Chris','Biology',1976),
('s103','Dinska','CS',1977),('s104','Zanna','Math',2000);

INSERT INTO major VALUES ('s100','French'),('s100','Theater'),('s100', 'CS'),('s102', 'CS'),
('s103', 'CS'),('s103', 'French'),('s104', 'Dance'),('s105', 'CS');


insert into course values
('c200','PL','CS'), ('c201','Calculus','Math'), ('c202','Dbs','CS'), ('c301','AI','CS'),
('c302','Logic','Philosophy');

insert into enroll values      
('s100','c200', 'A'),('s100','c201', 'B'), ('s100','c202', 'A'), ('s101','c200', 'B'), ('s101','c201', 'A'),     
('s102','c200', 'B'), ('s103','c201', 'A'),('s101','c202', 'A'), ('s101','c301', 'C'), ('s101','c302', 'A'),     
('s102','c202', 'A'), ('s102','c301', 'B'), ('s102','c302', 'A'), ('s104','c201', 'D');


-- Discussed with Akshay:
\qecho '5a'


CREATE TYPE studentType AS (sid text);
CREATE TYPE gradeStudentsType AS (grade text, students studentType[ ]);
CREATE TABLE courseGrades(cno text, gradeInfo gradeStudentsType[ ]);


insert into courseGrades
with e as 	(select cno, grade, array_agg(row(sid)::studentType) as students
			from enroll
			group by (cno, grade)),
f as (select cno, array_agg(row(grade, students)::gradeStudentsType) as gradeInfo
	  from e
	  group by (cno))
select * from f order by cno;


select * from courseGrades;


\qecho '5b'

CREATE TYPE courseType AS (cno text);
CREATE TYPE gradeCoursesType AS (grade text, courses courseType[]);
CREATE TABLE studentGrades(sid text, gradeInfo gradeCoursesType[]);


insert into studentGrades
with e as (select sid, grade, array_agg(row(cno)::courseType) as courses
from courseGrades cg,UNNEST(cg.gradeInfo) g,UNNEST(g.students) s
group by((s.sid,grade))),

f as (select sid, array_agg(row(grade, courses)::gradeCoursesType) as gradeInfo
	  from e
	  group by (sid))
select * from f order by sid;


select * from studentGrades;



\qecho '5c'

CREATE TABLE jcourseGrades (gradeInfo JSONB);


insert into jcourseGrades

with E as 	(select e.cno as cno, e.grade as grade, array_to_json(array_agg(json_build_object('sid',e.sid))) as students
			from enroll e
			group by (cno, grade) order by 1),

F as (select json_build_object('cno', cno, 'studentgradeInfo', 
array_to_json(array_agg
(json_build_object('grade', grade, 'students', students)))) as gradeInfo from E
group by (cno))
select * from F;


select * from jcourseGrades;



\qecho '5d'


CREATE TABLE jstudentGrades (gradeInfo JSONB);
insert into jstudentGrades

with e as (select s->'sid' as sid, g -> 'grade' as grade, 
		   array_to_json(array_agg(json_build_object('cno',cg.gradeInfo->'cno'))) as courses
from jcourseGrades cg,jsonb_array_elements(cg.gradeInfo -> 'studentgradeInfo') g,
		   jsonb_array_elements(g -> 'students') s
group by((s->'sid',g -> 'grade')) order by 1),

f as (select json_build_object('sid', sid, 'studentcourseInfo', 
array_to_json(array_agg(json_build_object('grade', grade, 'courses', courses)))) as gradeInfo
	  from e
	  group by (e.sid))
select * from f ;


select * from jstudentGrades;



\qecho '5e'

WITH E AS (SELECT sg.gradeInfo->'sid' as sid, sc->'cno' as cno
		   FROM jstudentGrades sg , jsonb_array_elements(sg.gradeInfo -> 'studentcourseInfo') g,
		   jsonb_array_elements(g -> 'courses') sc),

F AS (select sid as sid,dept as dept, 
	  array_to_json(array_agg(json_build_object('e.cno',e.cno,'cname',to_jsonb(cname)))) as courses
		from E join Course
		on (E.cno = to_jsonb(Course.cno))
		GROUP BY(sid, dept))
SELECT to_jsonb(sid), to_jsonb(sname), 
array_to_json(ARRAY( SELECT json_build_object('dept',dept,'courses',courses)
FROM F
WHERE to_jsonb(s.sid) = F.sid)) as courseInfo
FROM student s
WHERE sid IN (SELECT sid
FROM major m
WHERE major = 'CS');



--Connect to default database
\c postgres;

--Drop database which you created
DROP DATABASE pvajja7;







