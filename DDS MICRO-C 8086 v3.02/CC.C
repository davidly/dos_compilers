/*
 * DDS MICRO-C Command Coordinator
 *
 * This program integrates the various commands required to compile a
 * program into a single command. It is currently set up for the PC/8086
 * compiler (using MASM and LINK).
 *
 * The following command switches are used with MASM and LINK:
 *
 *  MASM: /t = Terse (no messages)  /ml = Upper/Lower case sensitive
 *	LINK: /noi = Do not ignore case (Upper/Lower case sensitive)
 *
 * If your version(s) of MASM/LINK (or compatible) does not work with
 * the command lines hard coded in this program, do the following:
 *
 * - Modify CC.C and LC.BAT (if necessary) to use acceptable commands
 * - Compile CC.C to CC.ASM using: CC CC -afo
 * - Assemble with your assembler
 * - Link to a new CC.COM with: LC CC
 *
 * If either your assembler OR linker does not support case sensitive
 * operation, run BOTH of them in case insensitive mode, and be sure
 * not to use any global symbols which differ only in case.
 *
 * Copyright 1990-1994 Dave Dunfield
 * All rights reserved.
 *
 * Compile command: cc cc -fop
 */
#include <stdio.h>

#define	NOFILE	2		/* EXEC return code for file not found */
#define	NOPATH	3		/* EXEC return code for path not found */

char mcdir[65], temp[65], ofile[65], tail[150], mcparm[80];
char oasm = -1, opt = 0, pre = 0, tiny = -1, link = -1, verb = -1,
	del = -1, com = 0, fold = 0, *fnptr, *mptr = &mcparm;

/*
 * Main program, process options & invoke appropriate commands
 */
main(argc, argv)
	int argc;
	char *argv[];
{
	int i;
	char ifile[65], *ptr, c;

	/* Get default directories from environment */
	if(!getenv("MCDIR", mcdir))		/* Get MICRO-C directory */
		strcpy(mcdir,"\\MC");
	if(!getenv("MCTMP", temp))		/* Get temporary directory */
		strcpy(temp,"$");

/* parse for command line options. */
	for(i=2; i < argc; ++i) {
		if(*(ptr = argv[i]) == '-') {		/* Enable switch */
			while(*++ptr) {
				switch(toupper(*ptr)) {
					case 'A' : oasm = 0;	continue;
					case 'C' : com = -1;	continue;
					case 'F' : fold = -1;	continue;
					case 'K' : del = 0;		continue;
					case 'L' : link = 0;	continue;
					case 'O' : opt = -1;	continue;
					case 'P' : pre = -1;	continue;
					case 'Q' : verb = 0;	continue;
					case 'S' : tiny = 0;	continue; }
				goto badopt; }
			continue; }

		if(*(ptr+1) == '=') switch(toupper(*ptr)) {
			case 'H' : strcpy(mcdir, ptr+2);	continue;
			case 'T' : strcpy(temp, ptr+2);		continue; }

		*mptr++ = ' ';
		c = 0;
		while(*mptr++ = *ptr++) {
			if(*ptr == '=')
				c = pre; }
		if(c)
			continue;

	badopt:
		fprintf(stderr,"Invalid option: %s\n", argv[i]);
		exit(-1); }

	message("DDS MICRO-C 8086 Compiler v3.02\n");

	if(argc < 2)
		abort("\nUse: CC <name> [-acfklopqs h=homedir t=tmpdir] [symbol=value]\n\nCopyright 1990-1994 Dave Dunfield\nAll rights reserved.\n");

	/* Parse filename & extension from passed path etc. */
	fnptr = ptr = argv[1];
	while(c = *ptr) {
		if(c == '.')
			goto noext;
		++ptr;
		if((c == ':') || (c == '\\'))
			fnptr = ptr; }
	strcpy(ptr, ".C");
noext:
	strcpy(ifile, argv[1]);
	message(fnptr);
	message(": ");
	*mptr = *ptr = 0;

	/* Pre-process to source file */
	if(pre) {
		message("Preprocess... ");
		sprintf(ofile,"%s%s.CP", temp, fnptr);
		sprintf(tail,"%s %s l=%s -q -l%s", ifile, ofile, mcdir, mcparm);
		docmd("MCP");
		strcpy(ifile, ofile); }

	/* Compile to assembly language */
	message("Compile... ");
	sprintf(ofile,"%s%s.%s", (oasm||opt) ? temp : "", fnptr,
		opt ? "CO" : "ASM");
	sprintf(tail,"%s %s -q%s%s%s", ifile, ofile, pre ? " -l" : "",
		com ? " -c" : "", fold ? " -f" : "");
	docmd("MCC");
	if(pre)
		erase(ifile);
	strcpy(ifile, ofile);

	/* Optimize the assembly language */
	if(opt) {
		message("Optimize... ");
		sprintf(ofile,"%s%s.ASM", oasm ? temp : "", fnptr);
		sprintf(tail, "%s %s -q", ifile, ofile);
		docmd("MCO");
		erase(ifile);
		strcpy(ifile, ofile); }

	/* Assemble into object module */
	if(oasm) {
		message("Assemble... ");
		sprintf(ofile,"%s%s.OBJ", link ? temp : "", fnptr);
		sprintf(tail,"/t/ml %s,%s;", ifile, ofile);
		docmd("MASM");
		erase(ifile);
		strcpy(ifile, ofile);

	/* Link into executable program */
		if(link) {
			sprintf(ofile,"%s.EXE", fnptr);
			message(tiny ? "Link TINY...\n" : "Link SMALL...\n");
			sprintf(tail,"/NOI %s\\PC86RL_%c %s,%s,NUL,%s\\MCLIB;",
				mcdir, tiny ? 'T' : 'S', ifile, ofile, mcdir);
			docmd("LINK");
			erase(ifile);
			if(tiny) {
				strcpy(ifile, ofile);
				message("Convert... ");
				sprintf(tail,"%s %s.COM", ofile, fnptr);
				docmd("EXE2BIN");
				erase(ofile); } } }

	message("All done.\n");
}

/*
 * Execute a command, looking for it in the MICRO-C directory,
 * and also in any directories found in the PATH environment
 * variable. Operands to the command have been previously
 * defined in the global variable 'tail'.
 */
docmd(cmd)
	char *cmd;
{
	int rc;
	char command[65], path[300], *ptr, *ptr1, *delim, c;

	ptr = mcdir;						/* First try MC home dir */
	if(!getenv("PATH", ptr1 = path))	/* And then search  PATH */
		ptr1 = "";

	do {	/* Search MCDIR & PATH for commands */
		delim = "\\"+(ptr[strlen(ptr)-1] == '\\');
		sprintf(command,"%s%s%s.COM", ptr, delim, cmd);
		if((rc = exec(command, tail)) == NOFILE) {
			sprintf(command,"%s%s%s.EXE", ptr, delim, cmd);
			rc = exec(command, tail); }
		ptr = ptr1;						/* Point to next directory */
		while(c = *ptr1) {				/* Advance to end of entry */
			++ptr1;
			if(c == ';') {
				*(ptr1 - 1) = 0;		/* Zero terminate */
				break; } } }
	while(((rc == NOFILE) || (rc == NOPATH)) && *ptr);
	if(rc) {
		fprintf(stderr,"%s failed (%d)\n", cmd, rc);
		exit(-1); }
}

/*
 * Output an informational message (verbose mode only)
 */
message(ptr)
	char *ptr;
{
	if(verb)
		fputs(ptr, stderr);
}

/*
 * Erase temporary file (if enabled)
 */
erase(file)
	char *file;
{
	if(del)
		delete(file);
}
