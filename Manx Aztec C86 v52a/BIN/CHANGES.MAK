Changes to MAKE:

1/5/89
	changed stksiz.c:
		increased stack size from 4kb to 6kb,
		and decreased stack red zone size from 2kb to 1kb.
		(customer was getting STACK OVERFLOW message)

11/26/90 *jd
	relinked make to use croot that treats quoted strings as a single arg.

6/3/91 make.c *jd
	allow rules that consist of just dependencies, no commands. e.g. a makefile
	that is just
		clib: hello.o

4/9/92  --------------- Released v5.2a beta 1 ---------------------

8/28/92 jd
	make didn't correctly handle makefiles that ended in ctrl-z. Fixed bug
	in c.lib and rebuilt make.

9/9/92 jd
	make wasn't testing for malloc failure.

10/4/92  --------------- Released v5.2a beta 2 ---------------------

