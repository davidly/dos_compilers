{       PASEXEC.INC - interface file for C library routines

	This include file along with the CEXEC.LIB library has been included
	with your Pascal 3.30 to show you how easy it is to call routines
	written in our new C 3.00 release.  The CEXEC.LIB contains several
	routines from the C library which we think you will find useful in
	extending the power of your Pascal programs.

	The memory model that Pascal uses is basically medium model (16-bit
	data pointers) with some extensions for large model addressing
	(32-bit data pointers).  The CEXEC.LIB routines are from the large
	model C library.  This means that you should be careful interfacing
	to these routines.  You should use ADS or VARS instead of ADR or VAR
	so that 32-bit addressed get constructed.

	The new Microsoft FORTRAN 3.30, PASCAL 3.30, and C 3.00 releases
	have been designed so that libraries or subprograms can be written
	in any one of these languages and used in any other.

	Try compiling and running the demonstration program DEMOEXEC.PAS
	to see some actual examples.
}

{       C function

		int system(string)
			char *string;

	The system() function passes the given C string (00hex terminated)
	to the DOS command interpreter (COMMAND.COM), which interprets and
	executes the string as an MS-DOS command.  This allows MS-DOS commands
	(i.e., DIR or DEL), batch files, and programs to be executed.

	Example usage in Pascal

	i := system(ads('dir *.for'*chr(0)));

	The interface to system is given below.  The [c] attribute is given
	after the function return type.  The [varying] attribute says the
	function has an undetermined number of parameters; in this case, 1.
}

	function system : integer [c,varying]; extern;

{       C function

	int spawnlp(mode,path,arg0,arg1,...,argn)
		int mode;               /* spawn mode */
		char *path;             /* pathname of program to execute */
		char *arg0;             /* should be the same as path */
		char *arg1,...,*argn;   /* command line arguments */
					/* argn must be NULL */

	The spawnlp creates and executes a new child process.  There must be
	enough memory to load and execute the child process.  The mode
	argument determines which form of spawnlp is executed as follows:

	    Value       Action

	      0         Suspend parent program and execute the child program.
			When the child program terminates, the parent program
			resumes execution.  The return value from spawnlp is -1
			if an error has occured or if the child process has
			run, the return value is the child processes return
			code.

	      2         Overlay parent program with the child program.  The
			child program is now the running process and the
			parent process is terminated.  spawnlp only returns
			a value if there has been a recoverable error.  Some
			errors can not be recovered from and execution will
			terminate by safely returning to DOS.  This might
			happen if there is not enough memory to run the new
			process.

	The path argument specifies the file to be executed as the child
	process.  The path can specify a full path name (from the root
	directory \), a partial path name (from the current working directory),
	or just a file name.  If the path argument does not have a filename
	extension or end with a period (.), the spawnlp call first appends
	the extension ".COM" and searches for the file; if unsuccessful, the
	extension ".EXE" is tried.  The spawnlp routine will also search for
	the file in any of the directories specified in the PATH environment
	variable (using the same procedure as above).

	Example usage in Pascal

	var     NULL : integer4;
	value   NULL := 0;
	...
	i := spawnlp(0, ads('exemod'*chr(0)), ads('exemod'*chr(0)),
		     ads('demoexec.exe'*chr(0)), NULL);

	The C spawnlp function is expecting the addresses of the strings
	(not the actual characters), so we use the ADS() function to pass
	the address of the strings.  The last parameter to the spawnlp
	routine must be a C NULL pointer which is a 32-bit integer 0, so
	we use an INTEGER4 variable NULL set to 0 as the last parameter.
}

	function spawnlp : integer [c,varying]; extern;
