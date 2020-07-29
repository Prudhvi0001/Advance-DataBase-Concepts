create database pvajja;
\c pvajja;

create table student(sid int, sname text, major text, primary key(sid));
create table Course(cno int, cname text, total int, max int, primary key(cno));
create table Prerequisite(cno int, prereq int, foreign key(cno) references Course(cno), foreign key(prereq) references Course(cno));
create table HasTaken(sid int,cno int, foreign key(sid) references student(sid), foreign key(cno) references Course(cno));
create table Enroll(sid int,cno int, foreign key(sid) references student(sid), foreign key(cno) references Course(cno));
create table Waitlist(sid int,cno int, position int, foreign key(sid) references student(sid), foreign key(cno) references Course(cno));


\qecho 'Question 1'
-- Question 1 Part A:

-- Raise Exception if Cno is already present in Course
CREATE OR REPLACE FUNCTION Insert_new_Cno_on_Course() RETURNS trigger AS
$$
BEGIN
IF NEW.cno IN (SELECT cno FROM Course) THEN
RAISE EXCEPTION 'Cno Already Exists In Course';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--  Raise Exception if sid is already present in Student
CREATE OR REPLACE FUNCTION Insert_new_Sid_on_Student() RETURNS trigger AS
$$
BEGIN
IF NEW.sid IN (SELECT sid FROM Student) THEN
RAISE EXCEPTION 'Sid Already Exists In Student';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Trigger Cno Contraint before inserting new cno in Course
CREATE TRIGGER Course_Cno_Primary_Constraint 
BEFORE INSERT 
ON Course 
FOR EACH ROW 
EXECUTE PROCEDURE Insert_new_Cno_on_Course();

-- Trigger sid Contraint before inserting new sid in Student
CREATE TRIGGER Student_Sid_Primary_Constraint 
BEFORE INSERT 
ON Student 
FOR EACH ROW 
EXECUTE PROCEDURE Insert_new_Sid_on_Student();

-- Check Student Triggers with Data:
INSERT INTO student values(1, 'Prudhvi', 'DataScience');

INSERT INTO student values(1, 'Akhil', 'DataScience');

INSERT INTO student values(2, 'Akhil', 'DataScience'),
(3,'Vijay','DataScience'),(4, 'Rutvik', 'ComputerScience');

-- Check Course trigger with Data:
INSERT INTO Course values(650, 'ADC', 6, 10);

INSERT INTO Course values(650, 'AA', 4, 10);

INSERT INTO Course values(651, 'AA', 4, 10),
(652, 'EDA', 10, 10),(550, 'stat', 10, 10),
(551, 'BA', 7, 10);


--  Question 1 Part B:

--  Prerequisite Table Foreign Key Constarint Check:

CREATE OR REPLACE FUNCTION Prerequisite_Table_FK_Constarint() RETURNS trigger AS
$$
BEGIN
IF NEW.cno NOT IN (SELECT cno FROM Course) THEN
RAISE EXCEPTION 'Cno Doesnot Exists In Course:';
ELSIF NEW.prereq NOT IN (SELECT cno FROM Course) THEN
RAISE EXCEPTION 'prereq Doesnot Exists In Course:';
ELSIF NEW.cno = NEW.prereq THEN
RAISE EXCEPTION 'Both Course and Prereq Cannot Same:';
ELSIF (NEW.cno,NEW.prereq) IN (SELECT cno,prereq FROM Prerequisite) THEN
RAISE EXCEPTION 'This data is already present in the Table:';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create Trigger for the Prerequisite table
CREATE TRIGGER Prerequisite_FK_Constraint 
BEFORE INSERT 
ON Prerequisite 
FOR EACH ROW 
EXECUTE PROCEDURE Prerequisite_Table_FK_Constarint();

-- Check Trigger With Data:

Insert into Prerequisite values(651,765);

Insert into Prerequisite values(764,651);

Insert into Prerequisite values(651,551),(652,550),(650,651),(650,550);

Insert into Prerequisite values(651,551);

-- Check Forign Key Constarint for HasTaken Table:

CREATE OR REPLACE FUNCTION HasTaken_Table_FK_Constraint() RETURNS trigger AS
$$
BEGIN
IF NEW.sid NOT IN (SELECT sid FROM Student) THEN
RAISE EXCEPTION 'Sid Doesnot Exists In Students:';
ELSIF NEW.cno NOT IN (SELECT cno FROM course) THEN
RAISE EXCEPTION 'Cno Doesnot Exists in Course:';
ELSIF (NEW.sid,NEW.cno) IN (SELECT sid,cno FROM HasTaken) THEN
RAISE EXCEPTION 'This data is already present in the Table:';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- HasTaken Foreign Key Constraint:
CREATE TRIGGER HasTaken_FK_Constraint 
BEFORE INSERT 
ON HasTaken 
FOR EACH ROW 
EXECUTE PROCEDURE HasTaken_Table_FK_Constraint();

-- Check With Data:

INSERT INTO HasTaken VALUES(1,700);

INSERT INTO HasTaken Values(6,651);

INSERT INTO HasTaken Values(1,550),(2,550),(3,550),(1,651),(4,651);

INSERT INTO Hastaken values(1,550);

-- Enroll FK Constarint:

CREATE OR REPLACE FUNCTION Enroll_Table_FK_Constraint() RETURNS trigger AS
$$
BEGIN
IF NEW.sid NOT IN (SELECT sid FROM Student) THEN
RAISE EXCEPTION 'Sid Doesnot Exists In Students:';
ELSIF NEW.cno NOT IN (SELECT cno FROM course) THEN
RAISE EXCEPTION 'Cno Doesnot Exists in Course:';
ELSIF (NEW.sid,NEW.cno) IN (SELECT sid,cno FROM Enroll) THEN
RAISE EXCEPTION 'This data is already present in the Table:';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Enroll Foreign Key Constraint
CREATE TRIGGER Enroll_FK_Constraint 
BEFORE INSERT 
ON Enroll 
FOR EACH ROW 
EXECUTE PROCEDURE Enroll_Table_FK_Constraint();

INSERT INTO Enroll values(6,651);

INSERT INTO Enroll values(2,700);

INSERT INTO Enroll values(2,651),(3,652);

INSERT INTO Enroll values(2,651);

-- Foreign Key Constarint check for waitlist table:
CREATE OR REPLACE FUNCTION Waitlist_Table_FK_Constraint() RETURNS trigger AS
$$
BEGIN
IF NEW.sid NOT IN (SELECT sid FROM Student) THEN
RAISE EXCEPTION 'Sid Doesnot Exists In Students:';
ELSIF NEW.cno NOT IN (SELECT cno FROM course) THEN
RAISE EXCEPTION 'Cno Doesnot Exists in Course:';
ELSIF (NEW.sid,NEW.cno,NEW.position) IN (SELECT sid,cno,position FROM Waitlist) THEN
RAISE EXCEPTION 'This data is already present in the Table:';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create trigger for waitlist Insertion:
CREATE TRIGGER Waitlist_FK_Constraint 
BEFORE INSERT 
ON Waitlist 
FOR EACH ROW 
EXECUTE PROCEDURE Waitlist_Table_FK_Constraint();

INSERT INTO waitlist VALUES(5,550,1);

INSERT INTO waitlist VALUES(1,691,1);

INSERT INTO waitlist VALUES(2,652,1),(4,551,1);

INSERT INTO waitlist VALUES(2,652,1);

-- Delete Functions for Cascade Delete for Student and Course:
CREATE OR REPLACE FUNCTION Delete_Cascading_Rows_Of_Sids() RETURNS trigger AS
$$
BEGIN
IF OLD.sid IN(SELECT sid from student) THEN
-- DELETE FROM HasTaken h where h.sid = OLD.sid;
DELETE FROM Enroll e where e.sid = OLD.sid;
DELETE FROM Waitlist w where w.sid = OLD.sid;
END IF;
RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION Delete_Cascading_Rows_Of_Cnos() RETURNS trigger AS
$$
BEGIN
IF OLD.cno IN(SELECT cno FROM Course) THEN
-- DELETE FROM Prerequisite p where p.cno = OLD.cno or p.prereq = OLD.cno;
-- DELETE FROM HasTaken h where h.cno = OLD.cno;
DELETE FROM Enroll e where e.Cno = OLD.cno;
DELETE FROM Waitlist w where w.cno = OLD.cno;
END IF;
RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';


-- Create Trigger from Casade Delete of Sid and Cno:
CREATE TRIGGER Delete_Cascading_Rows_of_Student 
BEFORE DELETE 
ON Student 
FOR EACH ROW 
EXECUTE PROCEDURE Delete_Cascading_Rows_Of_Sids();

CREATE TRIGGER Delete_Cascading_Rows_of_Course
BEFORE DELETE 
ON Course 
FOR EACH ROW 
EXECUTE PROCEDURE Delete_Cascading_Rows_Of_Cnos();

INSERT INTO student values(5, 'sresta', 'computerscience');

INSERT INTO Course values(700,'zoology',0,10);

INSERT INTO Enroll values(5,700);
INSERT INTO waitlist values(5,700,1);

select * from enroll;
select * from waitlist;

delete from student where sid = 5;

select * from enroll;
select * from waitlist;

INSERT INTO student values(5, 'sresta', 'computerscience');
INSERT INTO Enroll values(5,700);
INSERT INTO waitlist values(5,700,1);

select * from enroll;
select * from waitlist;

delete from Course where cno = 700;

select * from enroll;
select * from waitlist;

-- Question 1 part c:

CREATE OR REPLACE FUNCTION Delete_and_Update_on_HasTaken() RETURNS trigger AS
$$
BEGIN
RAISE EXCEPTION 'Cannot INSERT or UPDATE ON Courses that are already Taken';
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER Delete_Constraint_on_HasTaken
BEFORE DELETE 
ON HasTaken
FOR EACH ROW
EXECUTE PROCEDURE Delete_and_Update_on_HasTaken();

CREATE TRIGGER Update_Constraint_on_HasTaken
BEFORE UPDATE 
ON HasTaken
FOR EACH ROW
EXECUTE PROCEDURE Delete_and_Update_on_HasTaken();

select * from HasTaken; 

DELETE FROM HasTaken where sid = 1;

UPDATE HasTaken SET sid = 2 Where cno = 550;

--  Table to check enrollemnet status:
CREATE table enrolled(status integer);

CREATE OR REPLACE FUNCTION status_update() RETURNS TRIGGER AS
$$
BEGIN
delete from enrolled;
INSERT INTO enrolled values(0);
UPDATE enrolled SET status = 1;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER Enrollment_status_update
AFTER INSERT 
ON Enroll
FOR EACH ROW 
EXECUTE PROCEDURE status_update();


-- Check Condition for New Inserts in HasTaken:
CREATE OR REPLACE FUNCTION Insert_Constraint_on_HasTaken() RETURNS trigger AS
$$
BEGIN
IF (SELECT status FROM enrolled) = 1 THEN
RAISE EXCEPTION 'Course Enrollment has begun(U cannot enroll now!)';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create a Trigger Insert Query on HasTaken
CREATE TRIGGER Check_Insertion_on_HasTaken
BEFORE INSERT 
ON HasTaken 
FOR EACH ROW 
EXECUTE PROCEDURE Insert_Constraint_on_HasTaken();

select * from HasTaken;
select * from Enroll;
select * from enrolled;

INSERT INTO Enroll values(3,550);

INSERT INTO HasTaken VALUES (1,652);


-- Question 1 Part D:

CREATE OR REPLACE FUNCTION UPDATE_OR_DELETE_CHECK() RETURNS TRIGGER AS
$$
BEGIN
RAISE EXCEPTION 'THIS TABLE CANNOT BE UPDATED OR DELETED ONLY INSERTS:';
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER UPDATE_ON_COURSE
BEFORE UPDATE OF cno,cname
ON Course
FOR EACH ROW 
EXECUTE PROCEDURE UPDATE_OR_DELETE_CHECK();


CREATE TRIGGER UPDATE_ON_Prerequisite
BEFORE UPDATE OF cno,prereq
ON Prerequisite
FOR EACH ROW 
EXECUTE PROCEDURE UPDATE_OR_DELETE_CHECK();

CREATE TRIGGER DELETE_ON_COURSE
BEFORE DELETE 
ON Course
FOR EACH ROW 
EXECUTE PROCEDURE UPDATE_OR_DELETE_CHECK();

CREATE TRIGGER DELETE_ON_Prerquisite
BEFORE DELETE 
ON Prerequisite
FOR EACH ROW 
EXECUTE PROCEDURE UPDATE_OR_DELETE_CHECK();

-- drop trigger DELETE_ON_COURSE on course;
-- drop trigger DELETE_ON_course on Prerequisite;

select * from Prerequisite;

-- Cannot update cno or cname for a predefined course
update course set cno = 234 where cname = 'BA';

-- Can update total and max of the course 
update course set total = 5 where cno = 651 and cname = 'AA';

-- cannot delete already defined courses:
DELETE FROM Course where cno = 650;

-- Cannot delete from predefined courses:
delete from prerequisite where cno = 650;


CREATE TRIGGER Enrollment_statusdel_update
AFTER DELETE 
ON Enroll
FOR EACH ROW 
EXECUTE PROCEDURE status_update();

-- Check Condition for New Inserts on Course and Prerequisite:
CREATE OR REPLACE FUNCTION Insert_Constraint_on_Course_and_Prereq() RETURNS trigger AS
$$
BEGIN
IF (SELECT status FROM enrolled) = 1 THEN
RAISE EXCEPTION 'Course Enrollment has begun(U cannot update now!)';
END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Create a Trigger Insert Query on HasTaken
CREATE TRIGGER Check_Insertion_on_Course
BEFORE INSERT 
ON Course 
FOR EACH ROW 
EXECUTE PROCEDURE Insert_Constraint_on_Course_and_Prereq();

CREATE TRIGGER Check_Insertion_on_Prereq
BEFORE INSERT 
ON Prerequisite 
FOR EACH ROW 
EXECUTE PROCEDURE Insert_Constraint_on_Course_and_Prereq();

select * from Enrolled;
update enrolled set status = 0;

-- Insertion is possible before enrollement starts:
INSERT INTO Course VALUES (700,'DA',8,10);

--  Enrollement starts:
delete from enroll where cno = 550 and sid = 3;

--  Cannot insert after enrollmnet:
INSERT INTO Course VALUES (701,'DA2',8,10);

INSERT INTO prerequisite values(651,700);

\qecho 'Question 2'
--Question 2 :
CREATE OR REPLACE FUNCTION Check_the_Prerequisites_and_update() RETURNS trigger AS
$$
BEGIN
IF (SELECT EXISTS(SELECT p.prereq from Prerequisite p WHERE p.cno = NEW.cno and p.prereq 
				  NOT IN (SELECT h.cno from HasTaken h WHERE h.sid = NEW.sid))) THEN
	RAISE EXCEPTION 'Prerequisites of this Course are not completed Yet:';
ELSIF (SELECT c.total from Course c where c.cno = NEW.cno) < (SELECT c.max from Course c where c.cno = NEW.cno) THEN

UPDATE Course SET total = total + 1 WHERE cno = NEW.cno;
RETURN NEW;

ELSIF (SELECT c.total from Course c where c.cno = NEW.cno) = (SELECT c.max from Course c where c.cno = NEW.cno)
AND NEW.cno IN (SELECT cno FROM Waitlist) THEN

INSERT INTO Waitlist VALUES (NEW.sid, NEW.cno, (select max(w.position) + 1 from waitlist w where w.cno = NEW.cno));
RETURN NULL;

ELSIF (SELECT c.total from Course c where c.cno = NEW.cno) = (SELECT c.max from Course c where c.cno = NEW.cno)
AND NEW.cno NOT IN (SELECT cno FROM Waitlist) THEN

INSERT INTO Waitlist VALUES (NEW.sid, NEW.cno,1);
RETURN NULL;

END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER before_insert_on_enroll
BEFORE INSERT
on Enroll
FOR EACH ROW
EXECUTE PROCEDURE Check_the_Prerequisites_and_update();

--  Check the triggers with Data:
Select * from student;
Select * from course;
Select * from Prerequisite;
Select * from HasTaken;
Select * from Enroll;
Select * from Waitlist;

--  UPDATE OF COURSE TABLE:
Select * from course;
INSERT INTO ENROLL VALUES(1,700);
Select * from course;

-- UPDATE OF wailist table:
Select * from waitlist;
INSERT INTO ENROLL VALUES(1,652);
Select * from waitlist;

-- CANNOT UPDATE DUE TO PREREQUISITES:
select * from enroll;
INSERT INTO ENROLL VALUES(2,650);
select * from enroll;

Select * from student;
Select * from course;
Select * from Prerequisite;
Select * from HasTaken;
Select * from Enroll;
Select * from Waitlist;

-- Question 2 Part C:

CREATE OR REPLACE FUNCTION Drop_a_course_from_Enroll() RETURNS trigger AS
$$
BEGIN
IF OLD.cno IN (select cno from waitlist) THEN
INSERT INTO ENROLL VALUES((SELECT w.sid FROM Waitlist w WHERE w.cno = OLD.cno and w.position =1),OLD.cno);
DELETE FROM waitlist WHERE cno = OLD.cno and position = 1;
UPDATE waitlist SET position = position - 1 where cno = OLD.cno;
ELSIF OLD.cno NOT IN (select cno from waitlist) THEN
UPDATE course SET total = total - 1 WHERE cno = OLD.cno;
END IF;
RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_waitist
BEFORE DELETE 
ON enroll
FOR EACH ROW
EXECUTE PROCEDURE Drop_a_course_from_Enroll();


--  Check with the Data
UPdate waitlist set position = 1 where sid = 1;
UPdate waitlist set position = 2 where sid = 2;
select * from waitlist;
DELETE FROM ENROLL WHERE sid =3 and cno =652;
select * from waitlist;


\qecho 'Question 3'
-- Question 3
create or replace function Approximation_values() returns trigger as
$$
begin
update approximations SET E = E + (NEW.d1+NEW.d2+NEW.d3);
update approximations SET V = V + power((NEW.d1+NEW.d2+NEW.d3),2);
RETURN NEW;
end;
$$ language 'plpgsql';

create table throws(d1 int, d2 int, d3 int);
create table approximations(Number int,E numeric, V numeric);

CREATE TRIGGER approximation_update
BEFORE INSERT 
ON throws
FOR EACH ROW
EXECUTE PROCEDURE Approximation_values();

drop function runExperiment;

create or replace function runExperiment(n int,out num int,out E_T numeric, out V_T numeric)
returns setof record as
$$
declare i int;
begin
delete from throws;
delete from approximations;
insert into approximations values(n,0,0);
for i in 1..n loop
insert into throws values (floor(random()*6)+1, floor(random()*6)+1, floor(random()*6)+1);
end loop;
RETURN QUERY select a.number,ROUND(a.E/n,4) as E_T,ROUND(sqrt(a.V/n - power(a.E/n,2)),4) AS V_T from approximations a;
end;
$$ language 'plpgsql';

SELECT * from runExperiment(1000);

-- Connecting to Default database
\c postgres;

-- Drop table which is created
DROP DATABASE pvajja;


