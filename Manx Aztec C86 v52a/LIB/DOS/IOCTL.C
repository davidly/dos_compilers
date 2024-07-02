/* Copyright (C) 1984, 1985 by Manx Software Systems */
#include <errno.h>
#include <fcntl.h>
#include <sgtty.h>

#define TIME	10		/* number of iterations of raw_rd loop */
#define MIN		1		/* minimum number of chars returned from read */

extern int _ioflg[];
extern int (*_ttrd)();
extern int (*_ttwr)();
extern char _Eol;
extern int _TTrem;
extern int __tty_rd(), __tty_wr(), __write();

static struct sgttyb Tty_ctl = { '\b', '\x18', CRMOD|ECHO };
static int raw_rd(), cr_wr();
static int ioflags, myflags, ttyfd;

ioctl(fd, cmd, arg)
struct sgttyb *arg;
{
	int flags;

#if 0	/* fd not used, so ignore it *jd 9/1/92 */
	if (!(_ioflg[fd]&O_ISTTY)) { 
		errno = ENOTTY;
		return -1;
	}
#endif
	switch (cmd) {
	case TIOCGETP:
		*arg = Tty_ctl;
		break;
	case TIOCSETP:
		do { /* use stdin, stdout, or stderr *jd 9/1/92 */
			if (_ioflg[ttyfd]&O_ISTTY)
				break;
		} while (++ttyfd<=2);
		if (ttyfd>2)
			return -1;
		if (ioflags == 0) {
			_ioctl(ttyfd, 0, &ioflags);
			ioflags &= 0xff;
		}
		Tty_ctl = *arg;
		if ((myflags = Tty_ctl.sg_flags) & RAW)
			myflags = RAW;
		if (myflags&CRMOD) {
			_Eol = '\n';
			_ttwr = __tty_wr;
		} else {
			_Eol = '\r';
			_ttwr = __write;
		}
		if (myflags&(RAW|CBREAK)) {
			_TTrem = 0;		/* clear out input buffer */
			_ttrd = raw_rd;
			ioflags |= 0x20;	/* turn on dos's raw flag */
			_ioctl(ttyfd, 1, &ioflags);
		} else {
			ioflags &= ~0x20;	/* turn off dos's raw flag */
			_ioctl(ttyfd, 1, &ioflags);
			_ttrd = __tty_rd;
		}
		break;
	}
	return 0;
}

raw_rd(fd, buff, len)
register char *buff;
{
	int i;
	register int count;

	for (count = 0 ; count < len ; ) {
		for (i = TIME ; i-- ; )
			if (_ioctl(ttyfd, 6) != 0)
				goto have_char;
		if (count < MIN)
			continue;
		break;
have_char:
		__read(ttyfd, buff, 1);
		if (*buff == '\r')
			*buff = _Eol;
		if (myflags&ECHO)
			(*_ttwr)(ttyfd, buff, 1);
		++buff;
		++count;
	}
	return count;
}
