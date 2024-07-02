/* termio.h Modified by Joe Huffman October 17, 1990 */
/* Terminal control defines. */

#ifndef __TERMIO_H
#define __TERMIO_H 1

struct termio
{
/* input modes */
#define IGNBRK 0x1
#define BRKINT 0x2
#define IGNPAR 0x4
#define PARMRK 0x8
#define INPCK  0x10
#define ISTRIP 0x20
#define INLCR  0x40
#define IGNCR  0x80
#define ICRNL  0x100
#define IUCLC  0x200
#define IXON   0x400
#define IXANY  0x800
#define IXOFF  0x1000
  unsigned short c_iflag;

/* output modes */
#define OPOST  0x1
#define OLCUC  0x2
#define ONLCR  0x4
#define OCRNL  0x8
#define ONOCR  0x10
#define ONLRET 0x20
#define OFILL  0x40
#define OFDEL  0x80
#define NLDLY  0x100
#define NL0    0
#define NL1    0x100
#define CRDLY  0x600
#define CR0    0
#define CR1    0x200
#define CR2    0x400
#define CR3    0x600
#define TABDLY 0x1800
#define TAB0   0
#define TAB1   0x800
#define TAB2   0x1000
#define TAB3   0x1800
#define BSDLY  0x2000
#define BS0    0
#define BS1    0x2000
#define VTDLY  0x4000
#define VT0    0
#define VT1    0x4000
#define FFDLY  0x8000
#define FF0    0
#define FF1    0x8000
  unsigned short  c_oflag;

/* control modes */
#define CBAUD  0xF
#define B0     0
#define B50    0x1
#define B75    0x2
#define B110   0x3
#define B134   0x4
#define B150   0x5
#define B200   0x6
#define B300   0x7
#define B600   0x8
#define B1200  0x9
#define B1800  0xA
#define B2400  0xB
#define B4800  0xC
#define B9600  0xD
#define B19200 0xE
#define EXTA   0xE
#define B38400 0xF
#define EXTB   0xF
#define CSIZE  0x30
#define CS5    0
#define CS6    0x10
#define CS7    0x20
#define CS8    0x30
#define CSTOPB 0x40
#define CREAD  0x80
#define PARENB 0x100
#define PARODD 0x200
#define HUPCL  0x400
#define CLOCAL 0x800
  unsigned short  c_cflag;

/* stdin modes */
#define ISIG   0x1
#define ICANON 0x2
#define XCASE  0x4
#define ECHO   0x8
#define ECHOE  0x10
#define ECHOK  0x20
#define ECHONL 0x40
#define NOFLSH 0x80
#define XCLUDE 0x8000
  unsigned short  c_lflag;

  char	 c_line;    /* line discipline */

/* control char values */
#define CNSWTCH 0
#define CEOF	4     /* EOT, cntl D */
#define CERASE	8     /* BS,  cntl H */
#define CKILL	0x15  /* NAK, cntl U */
#define CSTART	0x11  /* DC1, cntl Q */
#define CSTOP	0x13  /* DC3, cntl S */
#define CSWTCH	0x1A  /* SUB, cntl Z */
#define CSUSP	0x1A  /* SUB, cntl Z - POSIX default suspend character */
#define CQUIT	0x1C  /* FS,  cntl \ */
#define CINTR	0x7FF /* DEL  cntl ? */
#define CESC	0x5C  /* escape char ('\\') */

/* control chars indexes */
#define VINTR  0
#define VQUIT  1
#define VERASE 2
#define VKILL  3
#define VEOF   4
#define VMIN   4
#define VEOL   5
#define VTIME  5
#define VEOL2  6
#define VSWTCH 7
#define NCC    8 /* Number of control characters. */
  unsigned char c_cc[NCC];
};

/* Line discipline IOCTL's. */
#define LDIOC	('D'<<8)	/* 0x4400 */
#define LDOPEN	(LDIOC|0)
#define LDCLOSE	(LDIOC|1)
#define LDCHG	(LDIOC|2)
#define LDGETT	(LDIOC|8)
#define LDSETT	(LDIOC|9)
#define LDSMAP	(LDIOC|10)
#define LDGMAP	(LDIOC|11)
#define LDNMAP	(LDIOC|12)

/* ioctls for the mouse. */
#define EVLD_IOC	(LDIOC)
#define LDEV_SETTYPE	(EVLD_IOC|13)
#define LDEV_GETEV	(EVLD_IOC|14)
#define LDEV_ATTACHQ	(EVLD_IOC|15)
#define LDEV_SETRATIO	(EVLD_IOC|16)

/* event driver ioctls */
#define	EQIOC		('Q'<<8)
#define	EQIO_GETQP	(EQIOC|1)
#define	EQIO_SETEMASK	(EQIOC|2)
#define	EQIO_GETEMASK	(EQIOC|3)
#define	EQIO_SUSPEND	(EQIOC|4)
#define	EQIO_RESUME	(EQIOC|5)
#define	EQIO_BLOCK	(EQIOC|6)

#define TIOC	('T'<<8)
#define TCGETA	(1|TIOC)
#define TCSETA	(2|TIOC)
#define TCSETAW	(3|TIOC)
#define TCSETAF	(4|TIOC)
#define TCSBRK	(5|TIOC)
#define TCXONC	(6|TIOC)
#define TCFLSH	(7|TIOC)

#endif /* __TERMIO_H */

