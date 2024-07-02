/* Copyright (C) 1982 by Manx Software Systems */

struct fcb {
	char f_driv;
	char f_name[8];
	char f_type[3];
	char f_ext;
	char f_resv[2];
	char f_rc;
	char f_sydx[16];
	char f_cr;
	unsigned f_record; char f_overfl;
};

#define	OPNFIL	15
#define CLSFIL	16
#define DELFIL	19
#define READSQ	20
#define WRITSQ	21
#define MAKFIL	22
#define SETDMA	26
#define GETUSR	32
#define READRN	33
#define WRITRN	34
#define FILSIZ	35
#define SETREC	36

