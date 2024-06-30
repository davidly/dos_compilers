/*	CONFIG.C  --  Configuration file for SEE editor.  */

/*  This routine must be modified to match your terminal. If you have a
	supported terminal, you need only set the appropriate define to 1
	and the others to 0. The supported terminals are:		*/

#define ANSI	1   /* DEC Rainbow 100. OK for other ANSI terminals also. */
#define H1500	0	/* Hazeltine 1500. */
#define VT52	0	/* DEC VT-52 compatable.	*/
#define Z100 	0	/* Zenith Z-100 by Daniel Herteg, Jr.	*/

/*
	After modifying this routine, it must be compiled and linked to form
	a new SEE and D88. Assuming that the C compiler is on drive A: and
	that CONFIG.C and the other header and object files are on drive B:,
	the commands required are:

	A>c88 b:config
	A>bind b:see b:config
	A>bind b:d88 b:d88rest b:config
				or, if under CP/M
	A>bind b:cpmd88 b:d88rest b:config -s1000 -h -od88

	B:SEE.EXE/CMD is the new version of SEE.
	B:D88.EXE/CMD is the new version of D88.

	A CP/M bind of SEE will report _PCB_ unresolved. This is OK.

	The bind of D88 will report the three externals FLIPINIT_, SCR_SAVE_
	and SCR_REST_ as unresolved. This is OK, but the screen flipping feature
	of D88 will be dissabled. If you can read your screen and want the
	screen flip feature, modify FLIP.A for your terminal and add b:flip
	to the bind list for D88.

    If your system is rom compatable with the IBM PC (Sanyo etc.),
    assemble pcio.a instead of modifying config.c. Pcio.a is on disk 2.
	A>asm88 b:pcio
	Use pcio in the bind list instead of config.    

	The source compare program cannot be configured with config.c as
	it needs the partial scroll routines found in pcio.a. If you cannot
	use pcio.a, the following routines must be added to config.c to configure
	compare.
	SCR_SCRUP_ Scroll the screen up. The window is scrolled up nline lines.
	A zero nline will clear the window. Top left of the screen in 0,0.
	Usage: scr_scrup(nline,fromrow,fromcol,torow,tocol);
	SCR_SCRDN_ scroll the screen down. the window is scrolled down nline lines.
	A zero nline will clear the window. Top left of the screen in 0,0.
	Usage: scr_scrdn(nline,fromrow,fromcol,torow,tocol);



	note that ci() and co() are used instead of getchar() and putchar().
	the former will not cancel if the user inadvertantly hits control c. */

/* control key translations. these are the codes that D88 and SEE expect. */
#define up_char 30
#define down_char 31
#define left_char 29
#define right_char 28
#define bol_char 200
#define eol_char 201
#define pageup_char 202
#define pagedown_char 203
#define bof_char 204
#define eof_char 205
#define Ins_char 206
#define Del_char 207
#define NextWord_char 208
#define PrevWord_char 209

/* Macro Keys */

#define F1 210
#define F2 211
#define F3 212
#define F4 213
#define F5 214
#define F6 215
#define F7 216
#define F8 217
#define F9 218
#define F10 219

#define RUBOUT		0x7f
#define BS			8
#define	ESC			0x1B

#define	FALSE	0

int  scr_cols=80;			/* number of screen columns	*/
int  scr_rows=24;			/* number of screen rows	*/
char scr_scrolldown=FALSE;	/* FALSE if screen can be scrolled up. If true
								scr_scdn() will not be called.	*/
char scr_scrollup=FALSE;	/* TRUE if up scrolling (scr_scup()) causes the
								top lines to be overwritten by the next lines.
								This is only false for terminals that
								support partial scrolling, i.e. have
								delete line functions.	*/
char scr_window_top=2;		/* Top line of scroll window. Must default to 2
								for SEE.	*/
char scr_attr=7;			/* default screen attributes. */
char see_mode;				/* true if in Insert or eXchange mode */



/*						A N S I					*/

#if ANSI
/*	ANSI Configuration for SEE editor.

	This is the ANSI version of the configuration file for SEE. It was
	written for the DEC Rainbow and may have to be changed for other
	terminals claiming ANSI compatability. The keys used are:

		<arrow>		move the cursor.
		Do			used as terminator instead of ESCAPE.
		PF1			jump to start of line.
		PF2			jump to end of line.
		PF3			jump to start of file.
		PF4			jump to end of file.
		Insert		Enter insert mode (like I) or flip between
					insert and exchange mode.
		Remove		delete character under the cursor.
		<=			delete previuos character.
*/

/*	hidig and lowdig are used to convert binary 0 to 79 to ascii 1 to 80 */

char hidig[]={
	0,0,0,0,0,0,0,0,0,1,
	1,1,1,1,1,1,1,1,1,2,
	2,2,2,2,2,2,2,2,2,3,
	3,3,3,3,3,3,3,3,3,4,
	4,4,4,4,4,4,4,4,4,5,
	5,5,5,5,5,5,5,5,5,6,
	6,6,6,6,6,6,6,6,6,7,
	7,7,7,7,7,7,7,7,7,8};

char lowdig[]={
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0,
	1,2,3,4,5,6,7,8,9,0};



#define	SCR_ROWCOL	"\\e[%c%c;%c%cH", hidig[row]+'0', lowdig[row]+'0', hidig[col]+'0', lowdig[col]+'0'
#define SCR_CLR		"\\e[2J"
#define SCR_CLRL	"\\e[K"
#define	SCR_CLS		"\\e[J"
#define	SCR_SCUP	"\\e[M"
#define	SCR_SCDN	"\\e[L"

/*	SCR_CI  -- Input a character and translate function keys.	*/

scr_ci() {
	char chr;
	int  i;

	if ((chr=ci()) == ESC) {	/* ESCAPE starts special keys	*/

	/*	ESC O starts the PF keys	*/
		if ((chr=ci()) == 'O') {
			switch (chr=ci()) {
				case 'P':	chr=bol_char;	/* PF1 key	*/
							break;
				case 'Q':	chr=eol_char;	/* PF2 key	*/
							break;
				case 'R':	chr=bof_char;	/* PF3 key	*/
							break;
				case 'S':	chr=eof_char;	/* PF4 key	*/
				}
			return chr;
			}
		
		if (chr == '[') {
			switch (chr=ci()) {
				case 'A':	chr=up_char;
							break;
				case 'B':	chr=down_char;
							break;
				case 'C':	chr=right_char;
							break;
				case 'D':	chr=left_char;
							break;
				case '2':	if ((chr=ci()) == '9') {
								chr=ESC; /* use Do for ESC */
								ci();	  /* eat the tilde	*/
								}
							else chr=Ins_char;
							break;
				case '3':	chr=Del_char;
							ci();
							break;
				case '5':	chr=pageup_char;
							ci();
							break;
				case '6':	chr=pagedown_char;
							ci();
				}
			}
		}
	else if (chr == RUBOUT) chr=BS;	/* make rubout into a BS	*/
	return chr;
	}
#endif



/*					H A Z E L T I N E   1 5 0 0					*/

#if H1500

/*	H1500 Configuration for SEE editor. */

#define	SCR_ROWCOL	"\176\21%c%c", col, row
#define	SCR_CLR		"\176\34"
#define	SCR_CLRL	"\176\17"
#define	SCR_CLS		"\176\30"
#define	SCR_SCUP	"\176\23"
#define	SCR_SCDN	"\176\32"



/*	The Hazeltine 1500 has neither cursor movement keys nor function keys.
	Consequently, control keys must be used. The choice of key for a
	particular function is a matter of preference.	*/

/*	keyxlat defines the key codes that can be used at any time.	*/

struct {char inkey,means; } keyxlat[]={
	{15,up_char},		/* control O means up	*/
	{16,down_char},		/* control P means down */
	{11,left_char},		/* control K means left */
	{12,right_char},	/* control L means right */
	{26,bol_char},		/* control Z means go to beginning of line */
	{24,eol_char},		/* control X means go to end of line */
	{17,pageup_char},	/* control Q means page up */
	{1,pagedown_char},	/* control A means page down */
	{23,bof_char},		/* control W means go to top of file */
	{19,eof_char},		/* control S means go to end of file */
						/* no insert char as I will enter insert */
	{4,Del_char},		/* control D for delete a char */
	{0,0}};				/* no next or previous word */

/*	cmdxlat defines alternate command codes that can be used when SEE
	is not in insert or exchange mode.	*/

struct {char inkey,means; } cmdxlat[]={
	{'@',up_char},		/* @ means up	*/
	{';',down_char},	/* ; means down	*/
	{',',left_char},	/* , means left	*/
	{'.',right_char},	/* . means right	*/
	{':',bol_char},		/* : means go to beginning of line */
	{']',eol_char},		/* ] means go to end of line	*/
	{'[',pageup_char},	/* [ means page up	*/
	{'_',pagedown_char},/* _ means page down	*/
	{0,0}};

extern char see_mode;	/* true is in insert or exchange mode */


/*	SCR_CI  --		Input a character and translate function keys.	*/

scr_ci() {
	char chr;
	int  i;

	chr=ci();			/* get next character	*/
	for (i=0; keyxlat[i].inkey; i++)
		if (chr == keyxlat[i].inkey) {
			chr=keyxlat[i].means;
			break;
			}
	if (!see_mode) {	/* if not in exchange or insert mode, accept alternate
							command codes.	*/

		for (i=0; cmdxlat[i].inkey; i++)
			if (chr == cmdxlat[i].inkey) {
				chr=cmdxlat[i].means;
				break;
				}
		}
	return chr;
	}

#endif





/*						V T 5 2					*/

#if VT52
/*	VT52 Configuration for SEE editor.

	This is the CP/M-86 VT52 version of the configuration file for SEE.

	The input control characters are:

		^E = up	
		^X = down 
		^S = left 
		^D = right 
		^Q = go to beginning of line 
		^Z = go to end of line 
		^R = page up 
		^C = page down 
		^T = go to top of file 
		^B = go to end of file 
		^V = Insert/Xchg Toggle 
		^G = delete a char 
		^A = prev word 
		^F = next word 

	The alternate command codes that can be used when SEE is not in
	insert or exchange mode are:

		@ = up	
		; = down
		, = left
		. = right
		: = go to beginning of line
		] = go to end of line
		[ = page up
		_ = page down
*/

#define	SCR_ROWCOL	"\\eY%c%c", row + 0x20, col + 0x20
#define	SCR_CLR		"\\eE"
#define	SCR_CLRL	"\\eK"
#define	SCR_CLS		"\\eJ"
#define	SCR_SCUP	"\\eM"
#define	SCR_SCDN	"\\eL"



struct {char inkey,means; } keyxlat[]={
	{05,up_char},		/* ^E = up */
	{24,down_char},		/* ^X = down */
	{19,left_char},		/* ^S = left */
	{04,right_char},	/* ^D = right */
	{17,bol_char},		/* ^Q = go to beginning of line */
	{26,eol_char},		/* ^Z = go to end of line */
	{18,pageup_char},	/* ^R = page up */
	{03,pagedown_char},	/* ^C = page down */
	{20,bof_char},		/* ^T = go to top of file */
	{02,eof_char},		/* ^B = go to end of file */
	{22,Ins_char},		/* ^V = Insert/Xchg Toggle */
	{07,Del_char},		/* ^G = delete a char */
	{01,NextWord_char},	/* ^A = prev word */
	{06,PrevWord_char},	/* ^F = next word */
	{0,0}};

/*	cmdxlat defines alternate command codes that can be used when SEE
	is not in insert or exchange mode.	*/

struct {char inkey,means; } cmdxlat[]={
	{'@',up_char},		/* @ = up	*/
	{';',down_char},	/* ; = down	*/
	{',',left_char},	/* , = left	*/
	{'.',right_char},	/* . = right	*/
	{':',bol_char},		/* : = go to beginning of line */
	{']',eol_char},		/* ] = go to end of line	*/
	{'[',pageup_char},	/* [ = page up	*/
	{'_',pagedown_char},/* _ = page down	*/
	{0,0}};



/*	SCR_CI  --		Input a character and translate function keys.	*/

scr_ci() {
	char chr;
	int  i;

	chr=ci();			/* get next character	*/
	for (i=0; keyxlat[i].inkey; i++)
		if (chr == keyxlat[i].inkey) {
			chr=keyxlat[i].means;
			break;
			}
	if (!see_mode) {	/* if not in exchange or insert mode, accept alternate
							command codes.	*/

		for (i=0; cmdxlat[i].inkey; i++)
			if (chr == cmdxlat[i].inkey) {
				chr=cmdxlat[i].means;
				break;
				}
		}
	return chr;
	}


#endif




/* ---------------------	ZENITH Z-100	------------------------- */

#if Z100
/*	Z100 Configuration for SEE editor.


	The input control characters are:

		      Keypad 8 = up	
		      Keypad 2 = down 
		      Keypad 4 = left 
		      Keypad 6 = right 
		      Keypad 7 = go to beginning of line 
		      Keypad 1 = go to end of line 
		      Keypad 9 = page up 
		      Keypad 6 = page down 
		Shift Keypad 7 = go to top of file 
		Shift Keypad 1 = go to end of file 
		      Keypad 0 = Insert/Xchg Toggle 
		      Keypad . = delete a char 
		Shift Keypad 4 = prev word 
		Shift Keypad 6 = next word 
			  Up Arrow = up
            Down Arrow = down
            Left Arrow = left
           Right Arrow = right
            DELETE Key = delete a char
             I CHR Key = Insert/Xchg Toggle
              HOME Key = go to beginning of line
             ENTER Key = ESCAPE
			  F1 - F10 = Macro Keys


NOTE:	No alternate command codes are used.

*/

#define	SCR_CLR		"\\eE"
#define	SCR_CLRL	"\\eK"
#define	SCR_CLS		"\\eJ"
#define	SCR_CURSOFF "\\ex5"
#define	SCR_CURSON  "\\ey5" 
#define	SCR_ROWCOL	"\\eY%c%c", row + 0x20, col + 0x20
#define	SCR_SCDN	"\\eL"
#define	SCR_SCUP	"\\eM"
#define SCR_SETUP1  "\\ey?"
#define SCR_SETUP2  "\\ey@"
#define SCR_SETUP3  "\\ey1"



struct {char inkey,means; } keyxlat[]={
	{0xB8,up_char},	    	/*       Keypad 8 = up */
	{0xB2,down_char},		/*       Keypad 2 = down */
	{0xB4,left_char},		/*       Keypad 4 = left */
	{0xB6,right_char},	    /*       Keypad 6 = right */
	{0xB7,bol_char},		/*       Keypad 7 = go to beginning of line */
	{0xB1,eol_char},		/*       Keypad 1 = go to end of line */
	{0xB9,pageup_char},	    /*       Keypad 9 = page up */
	{0xB3,pagedown_char},	/*       Keypad 3 = page down */
	{0xF7,bof_char},		/* Shift Keypad 7 = go to top of file */
	{0xF1,eof_char},		/* Shift Keypad 1 = go to end of file */
	{0xB0,Ins_char},		/*       Keypad 0 = Insert/Xchg Toggle */
	{0xAE,Del_char},		/*       Keypad . = delete a char */
	{0xF6,NextWord_char},	/* Shift Keypad 6 = next word */
	{0xF4,PrevWord_char},	/* Shift Keypad 4 = prev word */
	{0xA5,up_char},	    	/*       Up Arrow = up */
	{0xA6,down_char},		/*     Down Arrow = down */
	{0xA8,left_char},		/*     Left Arrow = left */
	{0xA7,right_char},	    /*    Right Arrow = right */
	{0xA3,Ins_char},		/*      I CHR Key = Insert/Xchg Toggle */
	{0x7F,Del_char},		/*     DELETE Key = delete a char */
	{0x8D,ESC},				/*      ENTER Key = ESCAPE */
	{0xA9,bol_char},		/*       HOME Key = go to beginning of line */
	{0x97,F1},				/*           F1   = Macro # 1 */
	{0x98,F2},				/*           F2   = Macro # 2 */
	{0x99,F3},				/*           F3   = Macro # 3 */
	{0x9A,F4},				/*           F4   = Macro # 4 */
	{0x9B,F5},				/*           F5   = Macro # 5 */
	{0x9C,F6},				/*           F6   = Macro # 6 */
	{0x9D,F7},				/*           F7   = Macro # 7 */
	{0x9E,F8},				/*           F8   = Macro # 8 */
	{0x9F,F9},				/*           F9   = Macro # 9 */
	{0xA0,F10},				/*           F10  = Macro # 10 */
	{0,0}};
 

/*	SCR_CI  --		Input a character and translate function keys.	*/

scr_ci()
	{
	char chr;
	int  i;

	chr=ci();								/* get next character	*/
	for (i=0; keyxlat[i].inkey; i++)
		if (chr == keyxlat[i].inkey)
			chr = keyxlat[i].means;
	return chr;
	}


/*	SCR_CURSOFF  --		Turn Cursor Off	*/

scr_cursoff() {

	scr_putf(SCR_CURSOFF);
	}


/*	SCR_CURSON  --		Turn Cursor On	*/

scr_curson() {

	scr_putf(SCR_CURSON);
	}


#endif




/*SCR_ROWCOL  -- Move cursor to selected position. The top left corner of
						the screen is (0,0)	*/

scr_rowcol(row,col)
	char row,col; {

	scr_putf(SCR_ROWCOL);
	}


/*	SCR_CLR  --		Clear screen.	*/

scr_clr() {

	scr_putf(SCR_CLR);
	}


/*	SCR_CLRL --		Clear rest of line. */

scr_clrl() {

	scr_putf(SCR_CLRL);
	}


/*	SCR_CLS  --		Clear rest of screen.	*/

scr_cls() {

	scr_putf(SCR_CLS);
	}



/*	SCR_SCUP  --	Scroll the screen up. 
			if scr_scrollup is true, the top two lines of the
			screen must be preserved.	*/


scr_scup() {

	scr_rowcol(scr_window_top,0);	/*	go to start of window	*/
	scr_putf(SCR_SCUP);
	}


/*	SCR_SCDN  --	Scroll the screen down.
		If scr_scrolldown is true, this routine is not called. */

scr_scdn() {

	scr_rowcol(2,0);		/* go to start of third line.	*/
	scr_putf(SCR_SCDN);
	}


/*	SCR_CO  --		Output a character.	*/

scr_co(chr)
	char chr; {

	co(chr);
	}

/*	SCR_CSTS  --	return a non-zero value if key ready.	*/

scr_csts() {

	if (csts()) return scr_ci();
	return 0;
	}


/*	SCR_SETUP  --	called first to do any required initilization.	*/

scr_setup() {

#if	Z100

	scr_putf(SCR_SETUP1);
	scr_putf(SCR_SETUP2);
	scr_putf(SCR_SETUP3);

#endif

	}


/*	SCR_TERM  --	called last to do any required termination. */

scr_term() { ; }


/*	SCR_MARK  --	mark the current character fot the block and delete
					command.
					usage: scr_mark(current char);	*/

scr_mark(chr)
	char chr; {
	scr_co('X');
	}


/*	SCR_SET_CURSOR  --  set physical cursor to logical cursor. does
						nothing on a normal character but must reset
						physical cursor on a memory mapped terminal
						like the PC. */

scr_set_cursor() {
	}


/*	SCR_PUTF  --  write a formatted string to the display 
 *
 *					In general scr_putf(cp, cv) outputs the char's pointed to
 *					by cp, with the following exceptions:
 *
 *						"\e" is translated to ESC
 *
 *						"%c" selects the next char value, cv, a la printf().
 *
 *					Thus scr_putf("\\eY%c;%cH", row + 32, col + 32);
 *						will write 'ESC','Y','!',';','4','H'
 *						for row == 1 amd col == 20
 *
 *					Note that if the string ends with a '\' or a '%', the
 *					routine will continue outputing until it finds a NULL
 */

static scr_putf(cp, cv)
char *cp;
int	cv;
	{
	char c;
	int	*cvp;

	cvp = &cv;
	while(*cp)
		switch(c = *cp++)
			{
			case '\\':	co((c = *cp++) == 'e' ? ESC : c);
						break;
			case '%':	co((c = *cp++) == 'c' ? *cvp++ : c);
						break;
			default:	co(c);
			}
	}
