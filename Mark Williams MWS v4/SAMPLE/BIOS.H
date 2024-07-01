/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * bios.h
 * IBM PC ROM BIOS information.
 * Cf. "I.B.M. PC Technical Reference", Appendix A, pp. 2-4.
 * Using this information guarantees that your program will NOT be portable.
 */

/*
 * Standard system pointer.
 */
struct seg {
	unsigned short offs;
	unsigned short segv;
};

/*
 * Item in keyboard buffer.
 */
struct creg {
	char	scan_code;
	char	ascii;
};

/*
 * ROM BIOS data area starts at location 0.
 */
struct rom_data {			/* emulated ROM BIOS data area	*/
	struct seg int_vect[0x100];	/* interrupt vectors		*/
	short	rs232_base[4];		/* addresses of rs232 adapters	*/
	short	printer_base[4];	/* addresses of printers	*/
	short	equip_flag;		/* installed hardware		*/
	char	mfg_tst;		/* initialization flag		*/
	short	memory_size;		/* memory size in Kbytes	*/
	short	io_ram_size;		/* memory in I/O channel	*/
	/*
	 * Keyboard data areas.
	 */
	char	kb_flag;		/* shift flags			*/
	char	kb_flag_1;		/* second byte of kb status	*/
	char	alt_input;		/* alternate keypad		*/
	short	buffer_head;		/* pointer to head of kbd buff	*/
	short	buffer_tail;		/* pointer to tail of kbd buff	*/
	struct creg kb_buffer[16];
	/*
	 * Diskette data areas.
	 */
	char	seek_status;		/* drive recalibration status	*/
	char	motor_status;		/* bit 3-0 drive 3-0 currently running */
	char	motor_count;		/* timeout counter for drive turn off */
	char	diskette_status;
	char	nec_status[7];		/* status bytes from NEC	*/
	/*
	 * Video display area.
	 */
	char	crt_mode;
	short	crt_cols;		/* number of cols on screen	*/
	short	crt_len;		/* length of CRT region in bytes */
	short	crt_start;		/* start of crt buffer (SEG ADDR) */
	short	cursor_posn[8]; 	/* cursor position for 8 pages	*/
	short	cursor_mode;		/* current cursor mode setting	*/
	char	active_page;		/* current page being displayed	*/
	short	addr_6845;		/* base addr of active display card */
	char	crt_mode_set;		/* current setting of 3*8 register */
	char	crt_palette;		/* current palette setting color card */
	/*
	 * Cassette data area.
	 */
	short	edge_cnt;
	short	crc_reg;
	char	last_val;
	/*
	 * Timer data area.
	 */
	short	timer_low;		/* low word of timer count	*/
	short	timer_hi;		/* hi word of timer count	*/
	char	timer_ofl;		/* timer has rolled over since last read */
	/*
	 * System data area.
	 */
	char	bios_break;		/* bit 7 = 1 if break key depressed */
	short	reset_flag;		/* 0x1234 if kb reset underway	*/
	/*
	 * Fixed disk data area.
	 */
	short	fixed_disk_data[2];
	/*
	 * Timeout counters.
	 */
	char	prt_tim_out;
	char	rs232_tim_out;
};
/*
 * Shift flag equates within kb_flag.
 */
#define INS_STATE	0x80
#define CAPS_STATE	0x40
#define NUM_STATE	0x20
#define SCROLL_STATE	0x10
#define ALT_SHIFT	0x08
#define CTL_SHIFT	0x04
#define LEFT_SHIFT	0x02
#define RIGHT_SHIFT	0x01
/*
 * Shift flag equates within kb_flag1.
 */
#define INS_SHIFT	0x80
#define CAPS_SHIFT	0x40
#define NUM_SHIFT	0x20
#define SCROLL_SHIFT	0x10
#define HOLD_STATE	0x08		/* hold state has been toggled	*/

/*
 * Diskette_status flags. 
 */
#define TIME_OUT	0x80
#define BAD_SEEK	0x40
#define BAD_NEC		0x20		/* NEC Controller has failed	*/
#define BAD_CRC		0x10		/* bad CRC on diskette read	*/
#define DMA_BOUNDARY	0x09		/* DMA across DMA boundary	*/
#define BAD_DMA		0x08		/* DMA Overrun			*/
#define RECORD_NOT_FND	0x04		/* requested sector not found	*/
#define WRITE_PROTECT	0x03		/* write protect violation	*/
#define BAD_ADDR_MARK	0x02		/* address mark not found	*/
#define BAD_COMMAND	0x01		/* bad command to diskette I/O	*/

/*
 * Timer equates.
 * Approximations of 1193180/65536 counts/sec.
 */
#define COUNTS_SEC	18
#define COUNTS_MIN	1092
#define COUNTS_HOUR	65543L
#define COUNTS_DAY	0x1800B0L

/*
 * Port addresses.
 */
#define KB_DATA		0x60		/* keyboard scan code port	*/
#define KB_CTL		0x61		/* control bits for kbd sense data */

#define TIMER		0x40		/* 8253/timer counter		*/
#define TIM_CTL		0x43		/* 8253/timer control port	*/

#define DMA08		0x08		/* DMA status reg port		*/
#define DMA		0x00		/* DMA channel 0 addr reg port	*/

/* end of bios.h */
