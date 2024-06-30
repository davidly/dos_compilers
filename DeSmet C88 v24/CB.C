/*	CBCHECK.C  --	Dumb Curley Brace Checker for C Programs
					Usage: A>cbcheck program

					This program really checks indentation. It ignores
					#include and #define and has a lot of other
					limitations. If it does not work for your style
					of programs, change it.	*/

#define TAB		9
#define LF		10
#define CR		13
#define CONTZ	26

char *nextin,*line_start,lastch,switch_level;
int  indentat[10],line,numcb;


main(argc,argv)
	int argc;
	char *argv[]; {
	int  ch;
	char col;

	if (argc < 2) error("no file name","");
	read_file(argv[1]);

	while (1) {
		line_start=nextin;
		line++;
		col=countcol();
		if (index("{}/#\r\n",*nextin) == 0 && (lastch == '{' || lastch == ';')
			&& col != indentat[numcb] && switch_level == 0) {
			if (indentat[numcb]) lerror("questionable indent");
			indentat[numcb]=col;
			}
		if (skipl() == -1) break;
		}
	printf("%d lines",line);
	}




				
/*	READ_FILE  --  open the input file and read.	*/

read_file(fil)
	char *fil; {
	int  i,filenum;
	unsigned max,numin;
	char filename[65];

	/*	get the file name. default is .C	*/

	strcpy(filename,fil);
	i=0;
	while (filename[i] && filename[i] != '.') i++;
	if (filename[i] == 0) strcat(filename,".C");

	/*	open the filename	*/

	if ((filenum=open(filename,0)) == -1) error("cannot open",filename);

	/*	read file in	*/

	nextin=_memory();	/* first free memory	*/
	max=_showsp()-nextin-1000; /* size of memory	*/
	if ((numin=read(filenum,nextin,max)) == -1)
		error("cannot read",filename);
	if (numin == max) error("file too big","");
	nextin[numin]=CONTZ;	/* plant a control Z for EOF	*/
	close(filenum);
	}




/*	COUNTCOL  --	count indentation	*/

countcol() {
	int  col;

	col=0;
	while (*nextin == ' ' || *nextin == TAB) {
		if (*nextin == ' ') col++; else col+=4;
		nextin++;
		}
	return col;
	}





/*	SKIPL  --	skip the rest of the line. take care of comments etc. */

skipl() {

	lastch=0;
	while (*nextin != LF) {
		if (*nextin != CR) lastch=*nextin;

		switch (*nextin++) {

			/* control Z means EOF	*/
			case CONTZ:		return -1;

			/* " means string	*/
			case '"':		while (*nextin != '"') {
								if (*nextin == '\\') {
									nextin++;
									if (*nextin == CR) {
										nextin++;
										line++;
										}
									}
								if (*nextin == LF || *nextin == CONTZ) {
									lerror("missing \"");
									nextin--;
									break;
									}
								nextin++;
								}
							nextin++;
							break;

			/* ' means character constant	*/
			case '\'':		skip_char();
							break;

			/* / may mean comment	*/
			case '/':		if (*nextin == '*') {
								while (*++nextin != '*' || *++nextin != '/')  {
									if (*nextin == LF) line++;
									if (*nextin == '/' && *(nextin+1) == '*')
										lerror("comments may be nested");
									if (*nextin == CONTZ) {
										lerror("missing */");
										nextin--;
										break;
										}
									}
								nextin++;
								}
							break;

			/*	a switch statement adds extra indentation	*/
			case 's':		if ((*(nextin-2) == ' ' || *(nextin-2) == TAB)
								&& *nextin == 'w' && *++nextin == 'i' &&
								*++nextin == 't' && *++nextin == 'c' &&
								*++nextin == 'h' && (*++nextin == '(' ||
								*nextin == ' ')) {
								if (switch_level == 0) switch_level=numcb;
								}
							break;

			/* { adds to curley brace count */
			case '{':		numcb++;
							break;

			/* } subtracts form curley brace count	*/
			case '}':		if (numcb) {
								numcb--;
								if (switch_level == numcb) switch_level=0;
								}
							else lerror("too many '}'s");
							break;
			}
		}
	nextin++;
	return *nextin == CONTZ ? -1: 1;
	}


 							

/*	SKIP_CHAR  -- skip a character constant.	*/

skip_char() {

	while (*nextin != '\'') {
		if (*nextin == '\\') nextin++;
		if (*nextin == LF || *nextin == CONTZ) {
			lerror("missing '");
			return;
			}
		nextin++;
		}
	nextin++;
	}



/*	LERROR  --	print an line error	*/

lerror(str)
	char *str; {
	char *ptr,col;

	printf("%5d  ",line);
	col=0;
	do {
		if (*line_start != TAB) {
			putchar(*line_start);
			col++;
			}
		else do {
			putchar(' ');
			}
		while (++col % 4);
		}
	while (*line_start != CONTZ && *line_start++ != LF);
	puts("error: ");
	puts(str);
	puts("\n");
	}




/*	ERROR  --	print an error and bail out	*/

error(stra,strb)
	char *stra,*strb; {

	puts("error: ");
	puts(stra);
	puts(" ");
	puts(strb);
	exit(2);
	}
