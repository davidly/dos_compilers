/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * biosdata.c
 * Print snapshot of ROM BIOS data area.
 */
#include <stdio.h>
#include <dos.h>
#include "bios.h"

struct rom_data d;

main()
{
	register int i;

	/* Copy ROM BIOS data. */
	_copy(PTR(&d), 0, 0, sizeof(d));

	/* Interrupt vectors. */
	printf("Interrupt vectors:\n");
	for(i = 0; i<0x100; )
	{
		printf("%02x %04x:%04x",
			i, d.int_vect[i].offs, d.int_vect[i].segv);
		if(++i % 5)
			printf("    ");
		else
			printf("\n");
	}
	printf("\n\nRS-232 adapter addrs: %04x %04x %04x %04x\n",
		d.rs232_base[0], d.rs232_base[1],
		d.rs232_base[2], d.rs232_base[3]);
	printf("Printer addresses:    %04x %04x %04x %04x\n",
		d.printer_base[0], d.printer_base[1],
		d.printer_base[2], d.printer_base[3]);

	/* Machine flags. */
	printf("\nMachine flags:\n");
	printf("equip_flag\t%04x\n", d.equip_flag);
	printf("mfg_tst\t\t%02x\n", d.mfg_tst);
	printf("memory_size\t%04x\n", d.memory_size);
	printf("io_ram_size\t%04x\n", d.io_ram_size);

	/* Keyboard data areas. */
	printf("\nKeyboard data areas:\n");
	printf("kb_flag\t\t%02x\n", d.kb_flag);
	printf("kb_flag_1\t%02x\n", d.kb_flag_1);
	printf("alt_input\t%02x\n", d.alt_input);
	printf("buffer_head\t%04x\n", d.buffer_head);
	printf("buffer_tail\t%04x\n", d.buffer_tail);
	printf("buffer scan codes ");
	for(i = 0; i < 16; i++)
		printf("%02x ", d.kb_buffer[i].scan_code);
	printf("\nbuffer ascii      ");
	for(i = 0; i < 16; i++)
		printf("%02x ", d.kb_buffer[i].ascii);

	/* Diskette data areas. */
	printf("\n\nDiskette data areas:\n");
	printf("seek_status\t%02x\n", d.seek_status);
	printf("motor_status\t%02x\n", d.motor_status);
	printf("motor_count\t%02x\n", d.motor_count);
	printf("diskette_status\t%02x\n", d.diskette_status);
	printf("NEC status bytes ");
	for(i = 0; i < 7; i++)
		printf("%02x ", d.nec_status[i]);

	/* Video display area. */
	printf("\n\nVideo display area:\n");
	printf("crt_mode\t%02x\n", d.crt_mode);
	printf("crt_cols\t%04x\n", d.crt_cols);
	printf("crt_len\t\t%04x\n", d.crt_len);
	printf("crt_start\t%04x\n", d.crt_start);
	printf("cursor_posn\t%04x\n", d.cursor_posn);
	printf("cursor_mode\t%04x\n", d.cursor_mode);
	printf("active_page\t%02x\n", d.active_page);
	printf("addr_6845\t%04x\n", d.addr_6845);
	printf("crt_mode_set\t%02x\n", d.crt_mode_set);
	printf("crt_palette\t%02x\n", d.crt_palette);

	/* Cassette data area. */
	printf("\nCassette data area:\n");
	printf("edge_cnt\t%04x\n", d.edge_cnt);
	printf("crc_reg\t\t%04x\n", d.crc_reg);
	printf("last_val\t%02x\n", d.last_val);

	/* Timer data area. */
	printf("\nTimer data area:\n");
	printf("timer_low\t%04x\n", d.timer_low);
	printf("timer_hi\t%04x\n", d.timer_hi);
	printf("timer_ofl\t%02x\n", d.timer_ofl);

	/* System data area. */
	printf("\nSystem data area:\n");
	printf("bios_break\t%02x\n", d.bios_break);
	printf("reset_flag\t%04x\n", d.reset_flag);

	/* Timeout counters. */
	printf("\nTimeout counters:\n");
	printf("prt_tim_out\t%02x\n", d.prt_tim_out);
	printf("rs232_tim_out\t%02x\n", d.rs232_tim_out);
}

/* end of biosdata.c */
