{*      DEMOEXEC.PAS - demonstration progam for calling C library functions
 *
 *      Microsoft Pascal release 3.30 can call large model C functions.
 *      Please read PASEXEC.INC for more details on interlanguage calling.
 *
 *      To compile and link DEMOEXEC.PAS
 *
 *      pas1 demoexec;
 *      pas2
 *      link demoexec,,,cexec;          (must search CEXEC.LIB)
 *}

program demoexec(input,output);

{$include : 'pasexec.inc'}

var
	i : integer;
	NULL : integer4;

value
	NULL := 0;

begin

{*      invoke command.com with a command line
 *
 *              dir *.for
 *}
	i := system(ads('dir *.pas'*chr(0)));
	writeln (output,'system return code = ',i);
	writeln (output,' ');

{*      invoke a child process
 *
 *              exemod          (display usage line only)
 *}
	i := spawnlp(0,ads('exemod'*chr(0)),ads('exemod'*chr(0)),NULL);
	writeln (output,'spawnlp return code =',i);
	writeln (output,' ');

{*      invoke an overlay process (chaining)
 *
 *              exemod demoexec.exe
 *}
	i := spawnlp(2,ads('exemod'*chr(0)),ads('exemod'*chr(0)),
		     ads('demoexec.exe'*chr(0)),NULL);

{*      we should never see this if spawnlp (overlay) is successful
 *}
	writeln (output,'spawnlp return code =',i);
	writeln (output,' ');

end.
