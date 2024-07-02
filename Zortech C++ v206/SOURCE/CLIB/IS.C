/*_ is.c   Sat Sep 10 1988   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright */
/* All rights reserved */

#include	<ctype.h>

#undef toascii
#undef isprint
#undef isgraph
#undef isascii
#undef isupper
#undef ispunct
#undef islower
#undef isdigit
#undef isxdigit
#undef isalnum
#undef isspace
#undef isalpha
#undef iscntrl

#ifdef Atoascii
toascii(c)	{ return c & 0x7F;	}
#endif

#ifdef Atoupper
toupper(c)	{ return (c >= 'a' && c <= 'z') ? c - ('a' - 'A') : c;	}
#endif

#ifdef Atolower
tolower(c)	{ return (c >= 'A' && c <= 'Z') ? c + ('a' - 'A') : c;	}
#endif

#ifdef Aisprint
isprint(c)	{ return _ctype[c + 1] & (_UC|_LC|_DIG|_PNC|_BLK);	}
#endif

#ifdef Aisgraph
isgraph(c)	{ return _ctype[c + 1] & (_UC|_LC|_DIG|_PNC);	}
#endif

#ifdef Aisascii
isascii(c)	{ return (unsigned) c < 0x80;	}
#endif

#ifdef Aisupper
isupper(c)	{ return _ctype[c + 1] & _UC;	}
#endif

#ifdef Aispunct
ispunct(c)	{ return _ctype[c + 1] & _PNC;	}
#endif

#ifdef Aislower
islower(c)	{ return _ctype[c + 1] & _LC;	}
#endif

#ifdef Aisdigit
isdigit(c)	{ return _ctype[c + 1] & _DIG;	}
#endif

#ifdef Aisxdigit
isxdigit(c)	{ return _ctype[c + 1] & _HEX;	}
#endif

#ifdef Aisalnum
isalnum(c)	{ return _ctype[c + 1] & (_UC|_LC|_DIG);	}
#endif

#ifdef Aisspace
isspace(c)	{ return _ctype[c + 1] & _SPC;	}
#endif

#ifdef Aisalpha
isalpha(c)	{ return _ctype[c + 1] & (_UC|_LC);	}
#endif

#ifdef Aiscntrl
iscntrl(c)	{ return _ctype[c + 1] & _CTL;	}
#endif

