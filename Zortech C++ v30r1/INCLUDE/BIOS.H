/*_ bios.h   Tue Jul 25 1989   Modified by: Dave Mansell */

#ifndef __BIOS_H
#define __BIOS_H

#if __cplusplus
extern "C" {
#endif

/* keyboard services */

#define _KEYBRD_READ        0   /* read next character from keyboard */
#define _KEYBRD_READY       1   /* check for keystroke */
#define _KEYBRD_SHIFTSTATUS 2   /* get current shift key status */

unsigned short _cdecl _bios_keybrd(int);
unsigned short _cdecl bioskey(int);

#if M_UNIX || M_XENIX

void _cdecl _bios_keybrd_close(void);
int _cdecl _bios_keybrd_open(void);

#else /* M_UNIX || M_XENIX */
/* struct used to send and receive information to and from */
/* the BIOS (int 0x13) disk services */

struct diskinfo_t {
    unsigned drive;
    unsigned head;
    unsigned track;
    unsigned sector;
    unsigned nsectors;
    void _far *buffer;
    };

/* manifest constants for BIOS services */

/* serial port services */

#define _COM_INIT       0   /* init serial port */
#define _COM_SEND       1   /* send character */
#define _COM_RECEIVE    2   /* receive character */
#define _COM_STATUS     3   /* get serial port status */

/* serial port initializers.  One constant from each of the following */
/* four groups must be specified in the initialization byte. */

/* character size */

#define _COM_CHR7       2   /* 7 bits characters */
#define _COM_CHR8       3   /* 8 bits characters */

/* stop bit values */

#define _COM_STOP1      0   /* 1 stop bit */
#define _COM_STOP2      4   /* 2 stop bits */

/*  parity */

#define _COM_NOPARITY   0   /* no parity */
#define _COM_ODDPARITY  8   /* odd parity */
#define _COM_EVENPARITY 24  /* even parity */

/*  baud rate */

#define _COM_110        0       /* 110 baud */
#define _COM_150        32      /* 150 baud */
#define _COM_300        64      /* 300 baud */
#define _COM_600        96      /* 600 baud */
#define _COM_1200       128     /* 1200 baud */
#define _COM_2400       160     /* 2400 baud */
#define _COM_4800       192     /* 4800 baud */
#define _COM_9600       224     /* 9600 baud */

/* disk services */

#define _DISK_RESET     0   /* reset disk controller */
#define _DISK_STATUS    1   /* get disk status */
#define _DISK_READ      2   /* read disk sectors */
#define _DISK_WRITE     3   /* write disk sectors */
#define _DISK_VERIFY    4   /* verify disk sectors */
#define _DISK_FORMAT    3   /* format disk track */

/* printer services */

#define _PRINTER_WRITE  0   /* write character to printer */
#define _PRINTER_INIT   1   /* intialize printer */
#define _PRINTER_STATUS 2   /* get printer status */

/* time of day services */

#define _TIME_GETCLOCK  0   /* get current clock count */
#define _TIME_SETCLOCK  1   /* set current clock count */

/* Function prototypes for Bios services */

int _cdecl _bios_equiplist(void);
int _cdecl _bios_memsize(void);
int _cdecl _bios_printer(unsigned, unsigned, unsigned);
int _cdecl _bios_serialcom(unsigned, unsigned, unsigned);
int _cdecl _bios_timeofday(unsigned, long *);
int _cdecl _bios_disk(unsigned, struct diskinfo_t *);
#endif

#if __cplusplus
}
#endif

#endif /* __BIOS_H */

