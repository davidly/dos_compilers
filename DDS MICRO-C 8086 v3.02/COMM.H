/*
 * DDS MICRO-C IBM/PC Communications parameters
 *
 * Copyright 1990-1994 Dave Dunfield
 * All rights reserved.
 */

/*
 * Comm port driver control flags (Cflags)
 */
#define	RFLOW		0x80	/* Flow control received */
#define TFLOW		0x40	/* Flow control transmitted */
#define	TXOFF		0x20	/* Transmit XOFF pending */
#define	TXON		0x10	/* Transmit XON  pending */
#define	TRANSPARENT	0x08	/* Transparent mode enable */

/*
 * Common Baudrate divisors
 */
#define	_110		1047	/*   110 baud */
#define	_300		384		/*   300 baud */
#define	_1200		96		/*  1200 baud */
#define	_2400		48		/*  2400 baud */
#define	_4800		24		/*  4800 baud */
#define	_9600		12		/*  9600 baud */
#define	_19200		6		/* 19.2K baud */
#define	_38400		3		/* 38.4K baud */

/*
 * Mode bits: OR together one from each section
 */
/* Section 1 - Break control */
#define	SEND_BREAK	0x40	/* Send break */
/* Section 2 - Parity */
#define	PAR_NO		0x00	/* No parity */
#define	PAR_ODD		0x08	/* Odd parity */
#define	PAR_EVEN	0x18	/* Even parity */
#define	PAR_MARK	0x28	/* Mark parity */
#define	PAR_SPACE	0x38	/* Space parity */
/* Section 3 - Stop bits */
#define	STOP_1		0x00	/* 1 stop bit */
#define	STOP_2		0x04	/* 2 stop bits (1.5 if 5 bits) */
/* Section 4 - Data bits */
#define	DATA_5		0x00	/* 5 bits */
#define	DATA_6		0x01	/* 6 bits */
#define DATA_7		0x02	/* 7 bits */
#define	DATA_8		0x03	/* 8 bits */

/*
 * Bits in modem control register
 */
#define	LOOPBACK	0x10	/* Set loopback mode */
#define	OUTPUT_2	0x08	/* General purpose output #2 */
#define	OUTPUT_1	0x04	/* General purpose output #1 */
#define	SET_RTS		0x02	/* Assert RTS output */
#define	SET_DTR		0x01	/* Assert DTR output */

/*
 * Bits returned by Csignals()
 */
#define	CD			0x80	/* Carrier detect */
#define	RI			0x40	/* Ring indicator */
#define	DSR			0x20	/* Data set ready */
#define	CTS			0x10	/* Clear to send  */
#define	END_RING	0x04	/* Ring has just ended */
#define	DELTA_CD	0x08	/* CD  has changed since last read */
#define	DELTA_DSR	0x02	/* DSR has changed since last read */
#define DELTA_CTS	0x01	/* CTS has changed since last read */

extern char Cflags;			/* Driver control flags */
