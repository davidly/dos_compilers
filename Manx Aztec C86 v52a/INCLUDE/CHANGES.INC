Changes to include files:

4/9/92 ------------- Released v5.2a beta 1 -------------------

9/18/92 jd: time.h
	LocalFileTime() replaced by TimeFile2TM(), so replaced prototype in time.h.

	Added prototype to time.h for new function TimeTM2File()

10/4/92 ------------- Released v5.2a beta 2 -------------------

11/17/92 jd: 
  stdlib.h:
	Added prototypes for non-ANSI functions lsearch(), lfind(), lfree(),
	min(), max()
  fcntl.h:
	Added prototypes for non-ANSI functions fnsplit(), fnmerge()
  string.h:
  	Added prototype for non-ANSI function strdup()
