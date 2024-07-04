/* bios.h - BIOS functions
 * $Version: 1.2 $
 * Copyright 1990,91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _biosh
#define _biosh

#pragma fixedparams("_bios_disk",    "_bios_equiplist", "_bios_keybrd")
#pragma fixedparams("_bios_memsize", "_bios_printer",   "_bios_serialcom") 
#pragma fixedparams("_bios_timeofday")

/* BIOS COM port configuration constants */
#define _COM_INIT       0x00            /* Initialize the com port           */
#define _COM_SEND       0x01            /* Send a byte to the com port       */
#define _COM_RECEIVE    0x02            /* Get a byte from the com port      */
#define _COM_STATUS     0x03            /* Get status from the com port      */

#define _COM_110        0x00            /* Baud rate: 110                    */
#define _COM_150        0x20            /* Baud rate: 150                    */
#define _COM_300        0x40            /* Baud rate: 300                    */
#define _COM_600        0x60            /* Baud rate: 600                    */
#define _COM_1200       0x80            /* Baud rate: 1200                   */
#define _COM_2400       0xA0            /* Baud rate: 2400                   */
#define _COM_4800       0xC0            /* Baud rate: 4800                   */
#define _COM_9600       0xE0            /* Baud rate: 9600                   */

#define _COM_CHR7       0x02            /* Seven data bits per character     */
#define _COM_CHR8       0x03            /* Eight data bits per character     */

#define _COM_NOPARITY   0x00            /* No parity check                   */
#define _COM_ODDPARITY  0x08            /* Check for odd parity              */
#define _COM_EVENPARITY 0x18            /* Check for even parity             */

#define _COM_STOP1      0x00            /* One stop bit                      */
#define _COM_STOP2      0x04            /* Two stop bits                     */

/* BIOS disk operations */
#define _DISK_RESET     0x00            /* Reset the disk controller         */
#define _DISK_STATUS    0x01            /* Get status from the disk          */
#define _DISK_READ      0x02            /* Read sectors from the disk        */
#define _DISK_WRITE     0x03            /* Write sectors to the disk         */
#define _DISK_VERIFY    0x04            /* Verify disk sectors               */
#define _DISK_FORMAT    0x05            /* Format a disk track               */

#ifndef _FAR
#define _FAR
#define _HUGE
#define _NEAR
#endif

/* BIOS disk structure */
#ifndef _diskinfo_t
#pragma align (diskinfo_t)
struct diskinfo_t {
   unsigned short drive;
   unsigned short head;
   unsigned short track;
   unsigned short sector;
   unsigned short nsectors;
   void _FAR     *buffer;
};
#define _diskinfo_t
#define _DISKINFO_T_DEFINED
#endif  /* _diskinfo_t */

/* BIOS keyboard operations */
#define _KEYBRD_READ            0x00    /* Get next character from keyboard  */
#define _KEYBRD_READY           0x01    /* See if a keystroke is ready       */
#define _KEYBRD_SHIFTSTATUS     0x02    /* Get status of shift key           */

/* BIOS enhanced keyboards operations */
#define _NKEYBRD_READ           0x10    /* Get next character from keyboard  */
#define _NKEYBRD_READY          0x11    /* See if a keystroke is ready       */
#define _NKEYBRD_SHIFTSTATUS    0x12    /* Get status of Shift key           */

/* BIOS printer operations */
#define _PRINTER_WRITE          0x00    /* Write characters to the printer   */
#define _PRINTER_INIT           0x01    /* Initialize the printer            */
#define _PRINTER_STATUS         0x02    /* Get status from the printer       */

/* BIOS clock operations */
#define _TIME_GETCLOCK          0x00    /* Get the clock counter             */
#define _TIME_SETCLOCK          0x01    /* Set the clock counter             */

/* Registers union - overlay the DWORD, WORD, and BYTE register
 * structures into the same memory area.  Declaration of "eax" and "ax"
 * entries the same (unsigned) for ease of porting code using "ax". Also,
 * note the optional 16-bit implementation of 'x' field.
 */
#ifndef _regs
#pragma align (DWORDREGS)
#pragma align (WORDREGS)
#pragma align (BYTEREGS)
union REGS {
  struct DWORDREGS {unsigned  eax, ebx, ecx, edx, esi,
                              edi, cflag, eflags, ebp;} w;

  struct WORDREGS  {unsigned  ax, bx, cx, dx, si,
                              di, cflag, flags, bp;} x;

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486

  struct BYTEREGS  {unsigned  al:8, ah:8, :16, bl:8, bh:8, :16,
                              cl:8, ch:8, :16, dl:8, dh:8, :16;} h;
#else
  struct BYTEREGS  {unsigned  al:8, ah:8, bl:8, bh:8,
                              cl:8, ch:8, dl:8, dh:8;} h;
#endif

};

/* Selector/Segment register structure */
#pragma align (SREGS)
struct SREGS {unsigned short es, cs, ss, ds, fs, gs;};

#define _regs
#endif  /* _regs */

/*
 * Function prototypes
 */
unsigned int _bios_disk(unsigned, struct diskinfo_t *);
unsigned int _bios_equiplist(void);
unsigned int _bios_keybrd(unsigned);
unsigned int _bios_memsize(void);
unsigned int _bios_printer(unsigned, unsigned, unsigned);
unsigned int _bios_serialcom(unsigned, unsigned, unsigned);
unsigned int _bios_timeofday(unsigned, long *);

#endif /* _biosh */
