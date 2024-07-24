      $set ans85 mf noosvs
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989,1991              *
      *                                                          *
      *                     SQLDEMO.CBL                          *
      *                                                          *
      *    This program demonstrates the use of SQL from within  *
      *    a COBOL program.                                      *
      *                                                          *
      *    The program SQLPREP must be compiled and run before   *
      *    this program is compiled to allow successful          *
      *    compilation.                                          *
      *                                                          *
      ************************************************************
       working-storage section.
       78 no-data            value 100.
      *SQLCODE for no data available
       01 y-or-n             pic x.
       01 display-line.
           03 disp-id        pic z(5).
           03 filler         pic x.
           03 disp-name      pic x(9).
           03 filler         pic x.
           03 disp-dept      pic z(5).
           03 filler         pic x.
           03 disp-job       pic x(5).
           03 filler         pic x.
           03 disp-years     pic z(5).
           03 yrs-nul-val redefines disp-years pic x(5).
           03 filler         pic x.
           03 disp-salary    pic z(7).9(2).
           03 filler         pic x.
           03 disp-comm      pic z(7).9(2).
           03 com-nul-val redefines disp-comm pic x(10).
       01 disp-n60         pic zz9.9.

      * An SQLCA is needed to communicate with database manager
       exec sql include sqlca end-exec

      * Host variables for database interrogation
       exec sql begin declare section end-exec
       01 wsid             pic s9(4) packed-decimal.
      * You may use comp-3, comp-5 or packed-decimal for host variables
       01 nme              pic x(9).
       01 dept             pic s9(4) packed-decimal.
       01 job              pic x(5).
       01 years            pic s9(4) packed-decimal.
       01 salary           pic s9(5)v9(2) packed-decimal.
       01 comm             pic s9(5)v9(2) packed-decimal.
       01 location         pic x(13).
       01 deptname         pic x(14).
       01 car              pic x(20).
       01 n60              pic s9(3)v9 packed-decimal.
       01 avalue           pic s9(4) packed-decimal.
      * Now two indicator variables are needed because years and comm
      * may have null values. Indicator variables must be comp-5.
       01 yrsnul           pic s9(4) comp-5.
       01 commnul          pic s9(4) comp-5.
      * Now the base string for the prepare example
       01 prep             pic x(34).
       exec sql end declare section end-exec

       procedure division.
           perform sub-select
           perform select-with-cursor
           perform full-select
           perform view-example
           perform insert-example
           perform prepare-example
           stop run.

       sub-select.
      * This example is a straight forward select statement
      * Note the use of indicator variables yrsnul and commnul they
      * are negative if the relevant value from the database is null
      *
           display
              "This demo will select from table STAFF of the sample SQL"
           display
             "database. The selection will be based on the value of the"
           display
           "column 'ID', the entry with ID equal to the value you enter"
           display
               "will be displayed"
           display "Enter value (table values go from 10 - 350)"
           accept avalue

           exec sql
               select id, name, dept, job, years, salary, comm
                   into :wsid, :nme, :dept, :job, :years:yrsnul,
                        :salary, :comm:commnul
                   from staff
                   where id = :avalue
           end-exec

           if sqlcode = zero
               perform make-line
               display display-line
           else
               if sqlcode = no-data
                   display "No row with that ID"
               else
                  perform sql-err
               end-if
           end-if.

       select-with-cursor.
           display spaces
           display
              "This demo will select from table STAFF of the sample SQL"
           display
             "database. The selection will be based on the value of the"
           display
            "column ID, all entries with a value greater than the value"
           display "you enter will be displayed."
           display "Enter cutoff value (table values go from 10 - 350)"
           accept avalue

      * Must use a cursor as many values are expected
           exec sql
               declare c1 cursor for
               select id, name, dept, job, years, salary, comm
                   from staff
                   where id > :avalue
           end-exec

      * Open the cursor to process the database entries
           exec sql
               open c1
           end-exec

           perform until sqlcode not = zero
      * SQLCODE will be zero as long as it has successfully fetched data
               exec sql
                   fetch c1 into :wsid , :nme, :dept, :job,
                                 :years:yrsnul, :salary, :comm:commnul
               end-exec
               if sqlcode = zero
                   perform make-line
                   display display-line
               end-if
           end-perform.

       full-select.
      * This example uses a cursor to handle the data extracted by two
      * select statements joined by an intersect statement, other set
      * operations may be substituted
      *
           display spaces
           display
              "This demo shows the usage of intersect across two tables"
           display
             "in the same database, the data extracted is the DEPT from"
           display "STAFF and the DEPTNUMB from ORG"
           perform wait-accept

           exec sql
               declare c2 cursor for
               select dept from staff
               intersect
               select deptnumb from org
           end-exec

           exec sql
               open c2
           end-exec

           perform until sqlcode not = zero
               exec sql
                   fetch c2 into :dept
               end-exec
               if sqlcode = zero
                   move dept to disp-dept
                   display disp-dept
               end-if
           end-perform.

       view-example.
      * This example uses the view PEOPLE_LOC created by DEMO1
           display spaces
           display
              "This demo will create a view over the two tables ORG and"
           display
            "STAFF then will extract all data from the view. The result"
           display
               "of the view is a list of all employees (from STAFF) and"
           display "their place of work (from ORG)"
           perform wait-accept

      * Once the view is created it may be treated just like a table
           exec sql
               declare c3 cursor for
                   select name,location from people_loc
           end-exec

           exec sql
               open c3
           end-exec

           perform until sqlcode not = zero
               exec sql
                   fetch c3 into :nme,:location
               end-exec
               if sqlcode = zero
                   display nme" "location
               end-if
           end-perform.

       insert-example.
      * This example inserts a row into MF_TABLE which is created by
      * SQLPREP. The row is then queried and deleted to prevent any
      * problems which could be caused if the program was run a second
      * time with identical rows in the table. The select would then
      * fail as the resultant data would comprise more than one row
      * which would require a cursor. Note the use of apostrophe (')
      * instead of quotes (") to delimit the SQL character data.
           display spaces
           display
             "This demo will insert a row into the table MF_TABLE which"
           display
           "is created by DEMO1 and then will query the row. The values"
           display "inserted are: Roger, Ferrari 328 GTB, 6.4"
           perform wait-accept

           exec sql
               insert into mf_table (name, car, nto60)
                   values ('Roger','Ferrari 328 GTB',6.4)
           end-exec

           exec sql
               select name,car,nto60
                   into :nme,:car,:n60
                   from mf_table
                   where name='Roger'
           end-exec

           if sqlcode = zero
               move n60 to disp-n60
               display nme" "car" "disp-n60
           else
               perform sql-err
           end-if

      * Now to delete the row
           exec sql
               delete from mf_table
                   where name='Roger'
           end-exec.

       prepare-example.
      * This example inserts data into MF-TABLE (created by SQLPREP)
      * by use of the SQL PREPARE and EXECUTE statements. Note the use
      * of the parameter markers '?' which are replaced by the actual
      * data during the EXECUTE statement
      *
           display spaces
           display
           "This example inserts one row into MF_TABLE using a prepared"
           display
              "SQL statement, then reads it back. The row inserted is:-"
           display "Elaine, Lamborghini, 4.9"
           perform wait-accept
           move "insert into mf_table values(?,?,?)" to prep
           exec sql
               prepare prep_stat from :prep
           end-exec
           if sqlcode not = zero
               perform sql-err
           else
               move "Elaine" to nme
               move "Lamborghini" to car
               move 4.9 to n60
               exec sql
                   execute prep_stat using :nme, :car, :n60
               end-exec
           end-if

           exec sql
               select name,car,nto60
                   into :nme, :car, :n60
                   from mf_table
                   where name='Elaine'
           end-exec
           if sqlcode = zero
               move n60 to disp-n60
               display nme" "car" "disp-n60
           else
               perform sql-err
           end-if
      * Now to delete row
           exec sql
               delete from mf_table
                   where name='Elaine'
           end-exec.

       sql-err.
           display "SQL error SQLCODE="sqlcode.

       make-line.
           move spaces to display-line
           move wsid to disp-id
           move nme to disp-name
           move dept to disp-dept
           move job to disp-job
           move salary to disp-salary
      * Now check for null values and handle accordingly
           if yrsnul < 0
               move "NULL" to yrs-nul-val
           else
               move years to disp-years
           end-if
           if commnul < 0
               move "NULL" to com-nul-val
           else
               move comm to disp-comm
           end-if.

       wait-accept.
           display "Press return to run demo"
           accept y-or-n.
