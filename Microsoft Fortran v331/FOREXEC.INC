c       FOREXEC.INC - interface file for C library routines

c       This include file along with the CEXEC.LIB library has been included
c       with your FORTRAN 3.30 to show you how easy it is to call routines
c       written in our new C 3.00 release.  The CEXEC.LIB contains several
c       routines from the C library which we think you will find useful in
c       extending the power of your FORTRAN programs.
c
c       The new Microsoft FORTRAN 3.30, PASCAL 3.30, and C 3.00 releases
c       have been designed so that libraries or subprograms can be written
c       in any one of these languages and used in any other.
c
c       Try compiling and running the demonstration program DEMOEXEC.FOR
c       to see some actual examples.

c       C function
c
c               int system(string)
c                       char *string;
c
c       The system() function passes the given C string (00hex terminated)
c       to the DOS command interpreter (COMMAND.COM), which interprets and
c       executes the string as an MS-DOS command.  This allows MS-DOS commands
c       (i.e., DIR or DEL), batch files, and programs to be executed.
c
c       Example usage in FORTRAN
c
c       integer*2 system                (the return type must be declared)
c       ...
c       i = system('dir *.for'c)        (notice the C literal string '...'c)
c
c       The interface to system is given below.  The [c] attribute is given
c       after the function name.  The argument string has the attribute
c       [reference] to indicate that the argument is passed by reference.
c       Normally, arguments are passed to C procedures by value.

        interface to integer*2 function system [c]
     +          (string[reference])
        character*1 string
        end


c       C function
c
c       int spawnlp(mode,path,arg0,arg1,...,argn)
c               int mode;               /* spawn mode */
c               char *path;             /* pathname of program to execute */
c               char *arg0;             /* should be the same as path */
c               char *arg1,...,*argn;   /* command line arguments */
c                                       /* argn must be NULL */
c
c       The spawnlp (to be referenced in FORTRAN as spawn) creates and
c       executes a new child process.  There must be enough memory to load
c       and execute the child process.  The mode argument determines which
c       form of spawn is executed as follows:
c
c           Value       Action
c
c             0         Suspend parent program and execute the child program.
c                       When the child program terminates, the parent program
c                       resumes execution.  The return value from spawn is -1
c                       if an error has occured or if the child process has
c                       run, the return value is the child processes return
c                       code.
c
c             2         Overlay parent program with the child program.  The
c                       child program is now the running process and the
c                       parent process is terminated.  spawn only returns
c                       a value if there has been a recoverable error.  Some
c                       errors can not be recovered from and execution will
c                       terminate by safely returning to DOS.  This might
c                       happen if there is not enough memory to run the new
c                       process.
c
c       The path argument specifies the file to be executed as the child
c       process.  The path can specify a full path name (from the root
c       directory \), a partial path name (from the current working directory),
c       or just a file name.  If the path argument does not have a filename
c       extension or end with a period (.), the spawn call first appends
c       the extension ".COM" and searches for the file; if unsuccessful, the
c       extension ".EXE" is tried.  The spawn routine will also search for
c       the file in any of the directories specified in the PATH environment
c       variable (using the same procedure as above).
c
c       Example usage in FORTRAN
c
c       integer*2 spawn                 (the return type must be declared)
c       ...
c       i = spawn(0, loc('exemod'c), loc('exemod'c),
c    +          loc('demoexec.exe'c), int4(0))          (execute as a child)
c
c       The interface to spawnlp is given below.  The [c] attribute is given
c       after the function name.  The [varying] attribute indicates that a
c       variable number of arguments may be given to the function.  The
c       [alias] attribute has to be used because the C name for the function
c       spawnlp has 7 characters.  Names in FORTRAN are only significant to
c       6 characters, so we 'alias' the FORTRAN name spawn to the actual C
c       name spawnlp.  Notice in the example above the C strings are passed
c       differently from the system function.  This is because the string
c       arguments to spawn are undeclared in the interface below and assumed
c       to be passed by value.  The C spawnlp function is expecting the
c       addresses of the strings (not the actual characters), so we use the
c       LOC() function to pass the address (remember that functions with the
c       [c] attribute pass arguments by value).  The last parameter to the
c       spawn routine must be a C NULL pointer which is a 32-bit integer 0,
c       so we use the INT4(0) function to pass this number by value as the
c       last parameter.

        interface to integer*2 function spawn
     +          [c,varying,alias:'spawnlp']
     +          (mode)
        integer*2 mode
        end
