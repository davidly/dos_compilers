c       DEMOEXEC.FOR - demonstration program for calling C library functions
c
c       Microsoft FORTRAN77 release 3.30 can call large model C functions.
c       Please read FOREXEC.INC for more details on interlanguage calling.
c
c       To compile and link DEMOEXEC.FOR
c
c       for1 demoexec;
c       pas2
c       link demoexec,,,cexec;          (must search CEXEC.LIB)

$include : 'forexec.inc'

c       declare return types of the 2 C functions

	integer*2 system, spawn

c       invoke command.com with a command line
c
c               dir *.for

	i = system('dir *.for'c)
	write (*,*) 'system return code = ',i
	write (*,*)

c       invoke a child process
c
c               exemod          (display usage line only)

	i = spawn(0,loc('exemod'c),loc('exemod'c),
     +          int4(0))
	write (*,*) 'spawn return code =',i
	write (*,*)

c       invoke an overlay process (chaining)
c
c               exemod demoexec.exe

	i = spawn(2,loc('exemod'c),loc('exemod'c),
     +          loc('demoexec.exe'c),int4(0))

c       we should never see this if spawn (overlay) is successful

	write (*,*) 'spawn return code =',i
	write (*,*)

	end
