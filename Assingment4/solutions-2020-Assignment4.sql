-------------------------------- Problem 1 -------------------------------------------
CREATE TABLE IF NOT EXISTS Student (sid int, sname text);
CREATE TABLE IF NOT EXISTS Course(cno int, cname text, total int, max int);
CREATE TABLE IF NOT EXISTS Prerequisite(cno int, prereq int);
CREATE TABLE IF NOT EXISTS HasTaken(sid int, cno int);

/* The following relation is crucial for the solution*/

CREATE TABLE IF NOT EXISTS EnrollWait(sid int, cno int, location int);

/* 

We define the table EnrollWait which simulateneously stores
information about (student,course) enrollment records as well as
(student, course) waitlist records

We consider two kinds of records in EnrollWait:

   When (s,c,0) is in EnrollWait, it means that (s,c) is in Enroll

   When (s,c,l) is in Enrollwait and "l > 0" then "l" designates the
   location on the waitlist for a waitlisted pair (s,c) E.g, (s,c,5)
   means that student "s" is in location 5 on the waitlist to enroll
   in course "c"

   We will maintain the waitlist for a course as a queue.  For a
   course "c", the front student "s" in the waitlist for "c" is such
   that (s,c,l) is in EnrollWait and l is the smallest location among
   triples of the form (s',c,l').  In other words, that student "s"
   can be determined as follows:

   select  sid
   from    EnrollWaitList
   where   cno = c and
           location = (select min(location)
                       from EnrollWaitList 
                       where cno = c)

   In addition, when we need to add a new student "s" for course "c" to
   the waitlist we must find the triple (s',c,l') with l' the maximum
   location l and then insert the tuple (s,c,l+1) in EnrollWait.
   To find this location for course "c" we can use the following query:

   select  location
   from    EnrollWaitList
   where   cno = c and
           location = (select max(location)
                       from   EnrollWaitList 
                       where  cno = c)

Given EnrollWait, we can then define two views: The first for the
Enroll records, and the second for the Waitlist records.

Once this is done, we can define triggers on these views to insert and
delete enrollment/waitlist records with the constraints specified in
the problem.  

In summary, the EnrollWait relation can be interpreted as a combined
materialized views for Enroll and Waitlist

*/

CREATE OR REPLACE VIEW Enroll AS 
      SELECT sid, cno
      FROM   EnrollWait 
      WHERE  location = 0 order by 1,2;

CREATE OR REPLACE VIEW Waitlist AS
      SELECT sid, cno, location
      FROM   EnrollWait 
      WHERE  location > 0 order by 2,3,1;

/* We will also create a table called "EnrollmentOpen" which represents
a boolean value.  If EnrollmentOpen is "false" then no information can
be inserted/deleted in Enroll but information can be inserted/deleted
in HasTaken.  If EnrollmentOpen is "true" then information can be
inserted/deleted in Enroll, but inserted/deleted in HasTaken becomes
frozen.  */

CREATE TABLE IF NOT EXISTS EnrollmentOpen(value boolean);
INSERT INTO EnrollmentOpen VALUES (false);


CREATE OR REPLACE FUNCTION IsEnrollmentOpen() RETURNS boolean AS
$$
SELECT value FROM EnrollmentOpen;
$$ LANGUAGE SQL;


/* The following triggers deal with constraint verrification */

CREATE OR REPLACE FUNCTION check_course_key_constraint() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.cno IN (SELECT cno FROM course) THEN
       RAISE EXCEPTION 'course cno value already exist';
       END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER check_course_cno_key_constraint 
       BEFORE INSERT
       ON course
       FOR EACH ROW
       EXECUTE PROCEDURE check_course_key_constraint();


CREATE OR REPLACE FUNCTION check_student_key_constraint() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.sid IN (SELECT sid FROM student) THEN
       RAISE EXCEPTION 'student sid value already exist';
       END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER check_student_sid_key_constraint 
       BEFORE INSERT
       ON student
       FOR EACH ROW
       EXECUTE PROCEDURE check_student_key_constraint();

/* Checking for foreign key constraint */

CREATE OR REPLACE FUNCTION check_HasTaken_foreign_key_constraint() RETURNS TRIGGER AS
   $$
   BEGIN
      IF NOT(NEW.sid IN (SELECT sid FROM student) AND NEW.cno IN (SELECT cno FROM course)) THEN
        RAISE EXCEPTION 'foreign key constraint violation';
      END IF;
      RETURN NEW;
   END;
   $$ LANGUAGE 'plpgsql';


CREATE TRIGGER check_HasTaken_FK_constraints
       BEFORE INSERT on HasTaken
       FOR EACH ROW
       EXECUTE PROCEDURE check_HasTaken_foreign_key_constraint();


CREATE OR REPLACE FUNCTION check_PreRequisite_foreign_key_constraint() RETURNS TRIGGER AS
   $$
   BEGIN
      IF IsEnrollmentOpen() THEN 
        RAISE EXCEPTION 'Enrollment is open.  No changes to Prerequisite can be made.';
      END IF;


      IF NOT(NEW.cno IN (SELECT cno FROM Course) AND NEW.prereq IN (SELECT cno FROM course)) THEN
        RAISE EXCEPTION 'foreign key constraint violation';
      END IF;
      RETURN NEW;
   END;
   $$ LANGUAGE 'plpgsql';


CREATE TRIGGER check_Prerequisite_FK_constraints
       BEFORE INSERT 
       ON Prerequisite
       FOR EACH ROW
       EXECUTE PROCEDURE check_PreRequisite_foreign_key_constraint();

CREATE OR REPLACE FUNCTION delete_course_cascade() RETURNS TRIGGER AS
   $$
   BEGIN
      IF IsEnrollmentOpen() 
      THEN 
           DELETE FROM Enroll WHERE cno = OLD.cno;
      ELSE
           DELETE FROM HasTaken WHERE cno = OLD.cno;
           DELETE FROM Prerequisite WHERE cno = OLD.cno;
           DELETE FROM Prerequisite WHERE prereq = OLD.cno;
      END IF;
     
      RETURN OLD;
   END;
   $$ LANGUAGE 'plpgsql';

CREATE TRIGGER delete_from_course
    AFTER DELETE ON Course
    FOR EACH ROW
    EXECUTE PROCEDURE delete_course_cascade();


CREATE OR REPLACE FUNCTION delete_student_cascade() RETURNS TRIGGER AS
   $$
   BEGIN
      IF IsEnrollmentOpen() 
      THEN
          DELETE FROM Enroll WHERE sid = OLD.sid;
      ELSE
          DELETE FROM HasTaken WHERE sid = OLD.sid;    
      END IF;

      RETURN OLD;
   END;
   $$ LANGUAGE 'plpgsql';

CREATE TRIGGER delete_from_student
    AFTER DELETE ON Student
    FOR EACH ROW
    EXECUTE PROCEDURE delete_student_cascade();




-------------------------------- Problem 2 -------------------------------------------
/*
Develop appropriate TRIGGERs to permit (1) inserts and deletes in the
Enroll relation and (2) deletes in the Waitlist governed by the
following constraints:
*/

/*
A student can only enroll in a course if he or she has taken all the prerequisites
for that course.  If the enrollment succeeds, the total enrollment for that course
needs to be incremented by $1$.
*/

/* A student can only enroll in a course if his or her enrollment does
not exceed the maximum enrollment for that course.  However, the
student must then be placed at the next available position on the
waitlist for that course.
*/

/*
A student can drop a course.   When this happens and if there are students on the waitlist
for that course, then the student who is at the first position gets enrolled and removed from the
waitlist.  If there are no students on the waitlist, then the total enrollment for that course needs
to decrease by $1$.
*/

/* A student may remove himself or herself from the waitlist for a
course.  When this happens, the positions of the other students who
are waitlisted for that course need to be adjusted.
*/


INSERT INTO student values(1, 'John'), (2, 'Mary'), (3,'Nick');

INSERT INTO course values(100, 'DiscreteMath', 0, 2), 
                         (101, 'PL', 0, 2), 
                         (102, 'Calculus', 0, 2),
                         (201, 'Topology', 0, 2), 
                         (202, 'Databases', 0, 2), 
                         (300, 'AI', 0, 2);

INSERT INTO prerequisite values (102,100),
                                (201, 100), 
                                (201, 102), 
                                (202, 100), 
                                (202, 101), 
                                (300, 202);

INSERT INTO hastaken values(1,100), 
                           (1,101), 
                           (1,102),
                           (2,100), 
                           (2,101),
                           (3,100), 
                           (3,101),
                           (3,102), 
                           (3,201),
                           (3,202);

/* The following trigger function and trigger accomplish the insertion
in the relation HasTaken*/


CREATE OR REPLACE FUNCTION insertInHasTaken() RETURNS TRIGGER AS
$$
BEGIN
    IF IsEnrollmentOpen()
    THEN
       RAISE EXCEPTION 'Enrollment is open.  No changes can be made to HasTaken';
    END IF;

    -- foreign key constraint check
    IF NOT(NEW.sid IN (SELECT sid FROM student) AND NEW.cno IN (SELECT cno FROM course)) THEN
      RAISE EXCEPTION 'foreign key constraint violation';
    END IF;
   
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER insert_into_HasTaken
    BEFORE INSERT ON HasTaken
    FOR EACH ROW
    EXECUTE PROCEDURE insertInHasTaken();


/* The following trigger function and trigger accomplish the deletion
in the HasTaken relation */

CREATE OR REPLACE FUNCTION deleteFromHasTaken() RETURNS TRIGGER AS
$$
BEGIN
  IF IsEnrollmentOpen()
  THEN
      RAISE EXCEPTION 'Enrollment is open.  No changes can be made to HasTaken';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER delete_from_HasTaken
    BEFORE DELETE ON HasTaken
    FOR EACH ROW
    EXECUTE PROCEDURE deleteFromHasTaken();


-- capacityReached checks if the maximum capicity is reached for a course

CREATE OR REPLACE FUNCTION capacityReached(course int) RETURNS BOOLEAN AS
$$
SELECT c.total >= c.max
FROM   Course c
WHERE  c.cno = course;
$$ LANGUAGE SQL;


/* The function "frontLocation" determines the front location of the
waitlist queue associated with a course.
*/

CREATE OR REPLACE FUNCTION frontLocation(course int) RETURNS int AS
$$
SELECT CASE WHEN EXISTS (SELECT 1
                         FROM   EnrollWait w 
                         WHERE  w.cno = course and w.location > 0) 
                      THEN (SELECT MIN(w.location)
                            FROM   EnrollWait w
                            WHERE  w.cno = course and w.location > 0)
                      ELSE (SELECT 0)
       END;
$$ LANGUAGE SQL;

/* The function "tailLocation" determines the tail location of the
waitlist queue associated with a course.
*/


CREATE OR REPLACE FUNCTION tailLocation(course int) RETURNS int AS
$$
SELECT CASE WHEN EXISTS (SELECT 1
                         FROM   EnrollWait w 
                         WHERE  w.cno = course and w.location > 0) 
                      THEN (SELECT MAX(w.location)
                            FROM   EnrollWait w
                            WHERE  w.cno = course and w.location > 0)
                      ELSE (SELECT 0)
       END;
$$ LANGUAGE SQL;


/*
The function "HasTakenPrerequisitites" determine if "student" has taken
all the prerequisites for "course".
In other words, it checks if there does not exists a prerequisite
for "course" that is not in the course taken by "student"
*/

CREATE OR REPLACE FUNCTION HasTakenPrerequisites(student int, course int) 
     RETURNS boolean AS
$$
SELECT NOT EXISTS (SELECT prereq
                   FROM   Prerequisite 
                   WHERE  cno = course AND
                          prereq NOT IN(SELECT cno
                                        FROM   Hastaken
                                        WHERE  sid = student));
$$ LANGUAGE SQL;


/* The following trigger function and trigger accomplish the insertion
in the view Enroll*/


CREATE OR REPLACE FUNCTION insertInEnrollOrWaitlist() RETURNS TRIGGER AS
$$
BEGIN
    IF NOT(IsEnrollmentOpen()) 
    THEN
       RAISE EXCEPTION 'Enrollment is closed';
    END IF;

    -- foreign key constraint check
    IF NOT(NEW.sid IN (SELECT sid FROM student) AND NEW.cno IN (SELECT cno FROM course)) THEN
      RAISE EXCEPTION 'foreign key constraint violation';
    END IF;
 
   -- proceed to insert
   IF HasTakenPrerequisites(NEW.sid, NEW.cno)
    THEN 
       IF NOT capacityReached(NEW.cno)
       THEN
          INSERT INTO EnrollWait VALUES (NEW.sid, NEW.cno, 0);
          UPDATE Course SET total = total +1 WHERE cno = NEW.cno;
       ELSE
          INSERT INTO EnrollWait VALUES (NEW.sid, NEW.cno, (SELECT tailLocation(NEW.cno)) + 1);
       END IF;
    ELSE RAISE EXCEPTION 'student does not have prerequisite courses';
    END IF;
   
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER insert_into_Enroll_or_Waitlist
    INSTEAD OF INSERT ON Enroll
    FOR EACH ROW
    EXECUTE PROCEDURE insertInEnrollOrWaitlist();


/* The following trigger function and trigger accomplish the deletion
in the view Enroll*/

CREATE OR REPLACE FUNCTION deleteFromEnrollOrWaitlist() RETURNS TRIGGER AS
$$
BEGIN
  IF NOT(IsEnrollmentOpen()) 
  THEN
      RAISE EXCEPTION 'Enrollment is closed';
  END IF;

  IF NOT capacityReached(OLD.cno)
  THEN 
     DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
     UPDATE Course SET total = total - 1 WHERE cno = OLD.cno;
  ELSE
     IF NOT EXISTS (SELECT 1
                    FROM   EnrollWait
                    WHERE  cno = OLD.cno AND location >= 1)
     THEN 
       DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
       UPDATE Course SET total = total - 1 WHERE cno=OLD.cno;
     ELSE 
       DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
       UPDATE EnrollWait SET location = 0 WHERE location = (SELECT frontLocation(OLD.cno)); 
     END IF;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER delete_from_Enroll_or_Waitlist
    INSTEAD OF DELETE ON Enroll
    FOR EACH ROW
    EXECUTE PROCEDURE deleteFromEnrollOrWaitlist();













--------------------------------- Problem 3 -------------------------------------------

DROP TABLE IF EXISTS ExpectationVariance;
CREATE TABLE ExpectationVariance(numberOfThrows int, expectation float, variance float);
INSERT INTO ExpectationVariance VALUES (0, 0.0, 0.0);

DROP TABLE IF EXISTS Throw;
CREATE TABLE Throw(dice1 int, dice2 int, dice3 int);


CREATE OR REPLACE FUNCTION ExpectationVarianceUpdate() RETURNS trigger AS
$$
DECLARE T int := NEW.dice1 + NEW.dice2 + NEW.dice3;
BEGIN
  UPDATE ExpectationVariance
         SET expectation = (expectation*numberOfThrows + T)/(numberOfThrows+1)::float,
             variance = (variance*numberOfThrows +  T*T)/(numberOfThrows+1)::float,
             numberOfThrows = numberOfThrows + 1;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ThrowExperiment
 BEFORE INSERT ON Throw
 FOR EACH ROW
 EXECUTE PROCEDURE ExpectationVarianceUpdate();


CREATE OR REPLACE FUNCTION runExperiment(n int) 
RETURNS TABLE (expectation float, standardDeviation float) AS
$$
DECLARE i int;

BEGIN
DROP TABLE IF EXISTS ExpectationVariance;
CREATE TABLE ExpectationVariance(numberOfThrows int, expectation float, variance float);
INSERT INTO ExpectationVariance VALUES (0, 0.0, 0.0);

FOR i IN 1..n LOOP
    INSERT INTO Throw VALUES(floor(random()*6)+1, floor(random()*6)+1, floor(random()*6)+1);
END LOOP;

RETURN QUERY SELECT  e.expectation, 
                     sqrt(e.variance - e.expectation * e.expectation)
             FROM    ExpectationVariance e;
END;
$$ LANGUAGE plpgsql;



SELECT * FROM runExperiment(10);
SELECT * FROM runExperiment(100);
SELECT * FROM runExperiment(1000);
SELECT * FROM runExperiment(10000);
SELECT * FROM runExperiment(100000);


