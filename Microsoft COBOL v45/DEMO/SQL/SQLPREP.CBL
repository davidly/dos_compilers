      $set ans85 mf noosvs
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     SQLPREP.CBL                          *
      *                                                          *
      *    This program sets up the environment for SQLDEMO.CBL. *
      *    Both programs demonstrate the use of SQL from within  *
      *    a COBOL program.                                      *
      *                                                          *
      ************************************************************
      * This program should be run before sqldemo. It creates
      * the database objects needed by sqldemo. sqldemo cannot
      * create then use the object, since, at compile time, the
      * object will not exist. Hence, any references to the
      * object will be invalid.
      ************************************************************
       working-storage section.
       01 y-or-n              pic x value "n".
       78 object-exists value -601.

      *SQL error code for database object exists
       01 created-var         pic x value "n".
         88 created           value "y".

       exec sql include sqlca end-exec

       procedure division.
           perform until created
               exec sql
                   create view people_loc as
                   select name,location
                   from staff,org
                   where dept=deptnumb
               end-exec
               if not (sqlcode = object-exists or zero)
                   perform sql-error
               end-if
               if sqlcode = object-exists
                   display
           "View PEOPLE_LOC exists in DB, Delete it and re-create Y/[N]"
                   accept y-or-n
                   if y-or-n = "y" or "Y"
                       exec sql
                           drop view people_loc
                       end-exec
                       if sqlcode = zero
                           move "n" to created-var
                       else
                           perform sql-error
                       end-if
                   else
                       move "y" to created-var
                   end-if
               else
                   move "y" to created-var
               end-if
           end-perform

      *Now create table mf_table
           move "n" to created-var
           perform until created
               exec sql
                   create table mf_table
                      (name           char(9),
                       car            char(20),
                       nto60           decimal(3,1))
               end-exec
               if not (sqlcode = object-exists or zero)
                   perform sql-error
               end-if
               if sqlcode = object-exists
                   display
           "Table MF_TABLE exists in DB, Delete it and re-create Y/[N]"
                   accept y-or-n
                   if y-or-n = "y" or "Y"
                       exec sql
                           drop table mf_table
                       end-exec
                       if sqlcode = zero
                           move "n" to created-var
                       else
                           perform sql-error
                       end-if
                   else
                       move "y" to created-var
                   end-if
               else
                   move "y" to created-var
               end-if
           end-perform
           stop run.

       sql-error.
           display "SQL error SQLCODE="sqlcode
           stop run.
