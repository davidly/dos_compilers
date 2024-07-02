/*_ CONIO.H   Modified by Joe Huffman October 19, 1990 */
/* Copyright (C) 1988-1989 by Walter Bright	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#ifndef __CONIO_H
#define __CONIO_H 1

#if __cplusplus
extern "C" {
#endif

int _cdecl getche(void);
int _cdecl getch(void);
int _cdecl kbhit(void);

/****************************************************************************
The return value from getch() and getche() for the second byte if the first
byte is 0.
****************************************************************************/
#define _KB_F1	      59  /* Function key F1. */
#define _KB_F2	      60
#define _KB_F3	      61
#define _KB_F4	      62
#define _KB_F5	      63
#define _KB_F6	      64
#define _KB_F7	      65
#define _KB_F8	      66
#define _KB_F9	      67
#define _KB_F10	      68

#define _KB_HOME      71
#define _KB_UP	      72
#define _KB_PGUP      73
#define _KB_LEFT      75
#define _KB_RIGHT     77
#define _KB_END	      79
#define _KB_DOWN      80
#define _KB_PGDN      81
#define _KB_INS	      82
#define _KB_BACK_TAB  15

#define _KB_SF1	      84  /* Shift F1. */
#define _KB_SF2	      85
#define _KB_SF3	      86
#define _KB_SF4	      87
#define _KB_SF5	      88
#define _KB_SF6	      89
#define _KB_SF7	      90
#define _KB_SF8	      91
#define _KB_SF9	      92
#define _KB_SF10      93

#define _KB_CF1	      94  /* Control F1. */
#define _KB_CF2	      95
#define _KB_CF3	      96
#define _KB_CF4	      97
#define _KB_CF5	      98
#define _KB_CF6	      99
#define _KB_CF7	      100
#define _KB_CF8	      101
#define _KB_CF9	      102
#define _KB_CF10      103

#define _KB_AF1	      104  /* Alt F1. */
#define _KB_AF2	      105
#define _KB_AF3	      106
#define _KB_AF4	      107
#define _KB_AF5	      108
#define _KB_AF6	      109
#define _KB_AF7	      110
#define _KB_AF8	      111
#define _KB_AF9	      112
#define _KB_AF10      113

#define _KB_DEL	      83
#define _KB_CPGUP     132 /* Control PgUp */
#define _KB_CLEFT     115 /* Control left cursor key. */
#define _KB_CRIGHT    116 /* Control right cursor key. */
#define _KB_CEND      117 /* Control End */
#define _KB_CPGDN     118 /* Control PgDn */
#define _KB_CHOME     119 /* Control Home */
#define _KB_A1	      120 /* Alt 1 */
#define _KB_A2	      121
#define _KB_A3	      122
#define _KB_A4	      123
#define _KB_A5	      124
#define _KB_A6	      125
#define _KB_A7	      126
#define _KB_A8	      127
#define _KB_A9	      128
#define _KB_A0	      129 /* Alt 0 */
#define _KB_AMINUS    130 /* Alt keypad '-'. */
#define _KB_APLUS     131 /* Alt keypad '+'. */

#if M_UNIX || M_XENIX
extern char *ttyname(int file_handle);

/* Array of '\0' terminated strings for mapping function keys to strings. */
/* See KEYBOARD(HW) in UNIX manual. */
typedef char _strmap_t[512];
extern int _cdecl _kb_getmapstr(_strmap_t dest_map);
extern int _cdecl _kb_setmapstr(_strmap_t new_map);

#define MIOC	('k'<<8)

#define	KBIO_SETMODE	(13|MIOC)	/* Put AT keyboard into XT | AT mode */
#define	KBIO_GETMODE	(14|MIOC)	/* Get the AT/XT keyboard mode */

/* keyboard mode -- set by KBIO_{S | G}ETMODE */
#define	KBM_XT	0	/* XT keyboard mode	*/
#define	KBM_AT	1	/* AT keyboard mode	*/


#define	KIOC		('K' << 8)
#define	KDDISPTYPE	(KIOC | 1)	/* return display type to user	*/
#define KDMAPDISP	(KIOC | 2)	/* map display into user space	*/
#define KDUNMAPDISP	(KIOC | 3)	/* unmap display from user space*/
#define KDGKBMODE	(KIOC | 6)	/* get keyboard translation mode*/
#define KDSKBMODE	(KIOC | 7)	/* set keyboard translation mode*/

/* Used with KD{G | S}ETMODE */
#define K_RAW	0			/* send raw scan codes		*/
#define K_XLATE	1			/* translates scan codes to ascii*/

#define KDADDIO		(KIOC | 11)	/* add I/O address to list	*/
#define KDDELIO		(KIOC | 12)	/* delete I/O address from list	*/

#define KDDISPINFO	(KIOC | 18)	/* Get display start and size. 	*/

#define KIOCSOUND	(KIOC | 63)	/* start sound generation	*/ 
#define KDGKBTYPE	(KIOC | 64)	/* get keyboard type		*/
#define KDGETLED	(KIOC | 65)	/* get current led states	*/
#define KDSETLED	(KIOC | 66)	/* set current led states	*/

/* Use with ioctl(0,KDDISPINFO,&buf) */
struct kd_dispinfo
{	char *vaddr;
	unsigned long physaddr;
	unsigned long size;
};

/* Use with ioctl(0,KDDISPTYPE,&buf) */
struct kd_disparam
{	long type;
#define KD_MONO     1   /* Possible values for type. */
#define KD_HERCULES 2
#define KD_CGA      3
#define KD_EGA      4
#define KD_VGA      5
	char *addr;
};

/* EGA control */
#define EGAIOC	('E' << 8)
#define EGAMODE (EGAIOC | 1)
#define EGAIO	(EGAIOC | 2)
#define EGA_GET (EGAIOC | 3)
#define EGA_IOPRIVL (EGAIOC | 4)

/* VGA control */
#define VGAIOC	('E' << 8)
#define VGAMODE (VGAIOC | 65)
#define VGAIO	(VGAIOC | 66)
#define VGA_GET (VGAIOC | 67)
#define VGA_IOPRIVL (VGAIOC | 68)

/****************************************************************************
These strings are returned by default from the function keys under SCO UNIX
with fgetc(stdin).  If you use getch(), getche(), or kbhit() the keyboard
is put into raw mode and fgetc(stdin) should not be used.

getch() and getche() return DOS compatible sequences.  I.e. if a function
key the first byte will be 0 and the next will be a number corresponding 
to actual key pressed.
****************************************************************************/ 

#define _KB_F1_STR    "\033[M"	  /* Key F1 */
#define _KB_F2_STR    "\033[N"
#define _KB_F3_STR    "\033[O"
#define _KB_F4_STR    "\033[P"
#define _KB_F5_STR    "\033[Q"
#define _KB_F6_STR    "\033[R"
#define _KB_F7_STR    "\033[S"
#define _KB_F8_STR    "\033[T"
#define _KB_F9_STR    "\033[U"
#define _KB_F10_STR   "\033[V"
#define _KB_F11_STR   "\033[W"
#define _KB_F12_STR   "\033[X"

#define _KB_SF1_STR   "\033[Y"	  /* Shifted Key F1 */
#define _KB_SF2_STR   "\033[Z"
#define _KB_SF3_STR   "\033[a"
#define _KB_SF4_STR   "\033[b"
#define _KB_SF5_STR   "\033[c"
#define _KB_SF6_STR   "\033[d"
#define _KB_SF7_STR   "\033[e"
#define _KB_SF8_STR   "\033[f"
#define _KB_SF9_STR   "\033[g"
#define _KB_SF10_STR  "\033[h"
#define _KB_SF11_STR  "\033[i"
#define _KB_SF12_STR  "\033[j"

#define _KB_CF1_STR   "\033[k"	  /* Control key F1 */
#define _KB_CF2_STR   "\033[l"
#define _KB_CF3_STR   "\033[m"
#define _KB_CF4_STR   "\033[n"
#define _KB_CF5_STR   "\033[o"
#define _KB_CF6_STR   "\033[p"
#define _KB_CF7_STR   "\033[q"
#define _KB_CF8_STR   "\033[r"
#define _KB_CF9_STR   "\033[s"
#define _KB_CF10_STR  "\033[t"
#define _KB_CF11_STR  "\033[u"
#define _KB_CF12_STR  "\033[v"

#define _KB_CSF1_STR  "\033[w"	  /* Control and shifted key F1 */
#define _KB_CSF2_STR  "\033[x"
#define _KB_CSF3_STR  "\033[y"
#define _KB_CSF4_STR  "\033[z"
#define _KB_CSF5_STR  "\033[@"
#define _KB_CSF6_STR  "\033[["
#define _KB_CSF7_STR  "\033[\\"
#define _KB_CSF8_STR  "\033[]"
#define _KB_CSF9_STR  "\033[^"
#define _KB_CSF10_STR "\033[_"
#define _KB_CSF11_STR "\033[`"
#define _KB_CSF12_STR "\033[{"
#define _KB_HOME_STR  "\033[H"

#define _KB_UP_STR    "\033[A"	  /* Cursor key up arrow */
#define _KB_PGUP_STR  "\033[I"	  /* PgUp. */
#define _KB_MINUS_STR "-"	  /* Keypad '-' key. */
#define _KB_LEFT_STR  "\033[D"	  /* Cursor key left arrow */
#define _KB_5_STR     "\033[E"	  /* Keypad '5' key. */
#define _KB_RIGHT_STR "\033[C"	  /* Cursor key right arrow */
#define _KB_PLUS_STR  "+"	  /* Keypad '+' key. */
#define _KB_END_STR   "\033[F"
#define _KB_DOWN_STR  "\033[B"	  /* Cursor key down arrow */
#define _KB_PGDN_STR  "\033[G"	  /* PgDn. */
#define _KB_INS_STR   "\033[L"

#define _KB_5	      76  /* Keypad 5. */
#define _KB_PLUS      78  /* Keypad '+'. */
#define _KB_MINUS     74  /* Keypad '-'. */

#define _KB_CSF1      104 /* Control Shift F1. */
#define _KB_CSF2      105
#define _KB_CSF3      106
#define _KB_CSF4      107
#define _KB_CSF5      108
#define _KB_CSF6      109
#define _KB_CSF7      110
#define _KB_CSF8      111
#define _KB_CSF9      112
#define _KB_CSF10     113

#define _KB_F11	      133 /* F11 for Extended keyboards (101-104 keys). */
#define _KB_F12	      134
#define _KB_SF11      135 /* Shift F11 for Extended keyboards. */
#define _KB_SF12      136
#define _KB_CF11      137 /* Control F11 for Extended keyboards. */
#define _KB_CF12      138
#define _KB_CSF11     139 /* Control Shift F11 for Extended keyboards. */
#define _KB_CSF12     140

#else /* M_UNIX || M_XENIX */

/* DOS only */
unsigned char	_cdecl inp(unsigned);
unsigned char	_cdecl outp(unsigned,char);
int		_cdecl inpw(unsigned);
int		_cdecl outpw(unsigned,unsigned);

#endif	/* M_UNIX || M_XENIX */

#if __cplusplus
}
#endif
#endif /* __CONIO_H */

