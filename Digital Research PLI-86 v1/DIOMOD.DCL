/******************************************************************************
*                                                                             *
*  D e c l a r a t i o n s   f o r   I B M   D O S   e n t r y   p o i n t s  *
*                                                                             *
******************************************************************************/

	declare 
		/*  F i x e d   V a l u e s  */
		dfcb0 	entry returns(pointer),
		dfcb1 	entry returns(pointer),
		dbuff 	entry returns(pointer),
		memptr	entry returns(pointer),
		memsiz	entry returns(fixed(15)),
		memwds	entry returns(fixed(15)),

/******************************************************************************
*           I B M   D O S   F u n c t i o n   D e c l a r a t i o n s         *
******************************************************************************/
/* 0  */	reboot	entry,
/* 1  */	rdcon 	entry returns(char(1)),
/* 2  */	wrcon 	entry (character(1)),
/* 3  */	rdrdr 	entry returns(char(1)),
/* 4  */	wrpun 	entry (char(1)),
/* 5  */	wrlst 	entry (char(1)),
/* 6a */	coninp	entry returns(char(1)),
/* 6b */	conout	entry (char(1)),
/* 7  */	din1	entry returns(char(1)),
/* 8  */	din2	entry returns(char(1)),
/* 9  */	wrstr 	entry (pointer),
/* 10 */	rdbuf 	entry (pointer),
/* 11 */	break 	entry returns(fixed(7)),
/* 12a */	clrkb1	entry (fixed(7)) returns(char(1)),
/* 12b */	clrkb2	entry (fixed(7),pointer),
/* 13 */	reset 	entry,
/* 14 */	select	entry (fixed(7)) returns(fixed(7)),
/* 15 */	open  	entry (pointer) returns(fixed(7)),
/* 16 */	close 	entry (pointer) returns(fixed(7)),
/* 17 */	sear  	entry (pointer) returns(fixed(7)),
/* 18 */	searn 	entry (pointer) returns(fixed(7)),
/* 19 */	delete	entry (pointer) returns(fixed(7)),
/* 20 */	rdseq 	entry (pointer) returns(fixed(7)),
/* 21 */	wrseq 	entry (pointer) returns(fixed(7)),
/* 22 */	make  	entry (pointer) returns(fixed(7)),
/* 23 */	rename	entry (pointer) returns(fixed(7)),
/* 25 */	curdsk	entry returns(fixed(7)),
/* 26 */	setdma	entry (pointer),
/* 27 */	alltbl	entry (pointer,pointer,pointer,pointer),
/* 33 */	rdran 	entry (pointer) returns(fixed(7)),
/* 34 */	wrran 	entry (pointer) returns(fixed(7)),
/* 35 */	filsiz	entry (pointer) returns(fixed(7)),
/* 36 */	setrec	entry (pointer),
/* 38 */	newseg	entry (pointer),
/* 39 */	blockrd	entry (pointer,bit(16),pointer,pointer),
/* 40 */	blockwr	entry (pointer,bit(16),pointer,pointer),
/* 41 */	parsfn	entry (pointer,pointer,fixed(7)) returns(fixed(7)),
/* 42 */	getdate	entry (pointer,pointer,pointer),
/* 43 */	setdate	entry (fixed(15),fixed(7),fixed(7)) returns(fixed(7)),
/* 44 */	gettime	entry (pointer,pointer,pointer,pointer),
/* 45 */	settime	entry (fixed(7),fixed(7),fixed(7),fixed(7))
			       returns(fixed(7)),
/* 46 */	setver	entry (fixed(7));
