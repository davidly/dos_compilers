/*	LATER.C		--	Exit with a 1 if any file has a higher create
					date than the last or if the last file does not exist.
					A 2 is returned if any other files do not exist.
					Later only works on MS-DOS V2.0.

					A>LATER FILE1.C FILE1.O
					Later will set completion code to 1 if FILE1.C was
					created after FILE1.O.

					A>LATER FILE1.C FILE1.H FILE1.O
					Later will set completion code to 1 if FILE1.C or
					FILE1.H was created after FILE1.O.	*/



main(argc,argv)
	int  argc;
	char *argv[]; {

	unsigned ifile,ofile,i;
	long odate,dateof();

	puts("LATER V1.0      ");

	if (argc < 3 ) {
		puts("need two or more arguments");
		exit(0);
		}

	if ((ofile=open(argv[argc-1],0)) == -1)
		exit(1);	/* the last file does not exist	*/

	odate=dateof(ofile);
	close(ofile);

/*	for each file see if it is later than the last one	*/

	for (i=1; i < argc-1; i++) {
		if ((ifile=open(argv[i],0)) == -1) {
			puts(argv[i]);
			puts(" does not exist");
			exit(2);	/* an early file does not exist	*/
			}
		if (dateof(ifile) > odate) exit(1);	/* found a later file */
		close(ifile);
		}

/*	none of the files are later. set completion code of zero	*/

	exit(0);
	}


/*	return a long encoding the date and time of a file	*/

long dateof(fil)
	int  fil; {
	static long ret_dt;

#asm
	mov		bx,[bp+4]				;file handle is here. only argument.
	and		bx,0ffh					;low byte of file id is MS-DOS handle.
	mov		al,0					;code to retrieve date and time.
	mov		ah,57h					;dos code for get file date and time.
	int		21h						;call dos.
	mov		word dateof_ret_dt_+2,dx;store date in high word of ret_dt.
	mov		word dateof_ret_dt_,cx	;store time in low word of ret_dt.
									;note: "dateof_" is added to name
									;because ret_dt is static.
#
	return ret_dt;
	}
