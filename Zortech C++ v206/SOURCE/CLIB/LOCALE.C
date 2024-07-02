/*_ locale.c   Thu Sep 28 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Walter Bright */
/* All rights reserved */

#include	<locale.h>
#include	<limits.h>
#include	<string.h>

#if Asetlc

extern struct lconv __current_lconv;

/* Some strings to reduce redundancy	*/
static char NA[] = "";		/* not available			*/
static char DOT[] = ".";

static struct
{   char *locale;		/* locale string			*/
    struct lconv locdata;	/* values for this locale		*/
} locale_data[_LOCALE_MAX] =
{
    {	"C",
	{ DOT,NA,NA,NA,NA,NA,NA,
	  CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	  { _LOCALE_C,_LOCALE_C,_LOCALE_C,
	    _LOCALE_C,_LOCALE_C,_LOCALE_C
	  }
	}
    },
    {	"USA",
	{ DOT, ",", "USA ", "$", DOT, ",", "-",
	  2,1,0,1,0,0,
	  { _LOCALE_NATIVE,_LOCALE_NATIVE,_LOCALE_NATIVE,
	    _LOCALE_NATIVE,_LOCALE_NATIVE,_LOCALE_NATIVE
	  }
	}
    },
    {	"Italy",
	{ DOT,",","ITL.","L.",NA,DOT,"-",
	  0,1,0,1,0,1,
	  { _LOCALE_ITALY,_LOCALE_ITALY,_LOCALE_ITALY,
	    _LOCALE_ITALY,_LOCALE_ITALY,_LOCALE_ITALY
	  }
	}
    },
    {	"Netherlands",
	{ DOT,",","NLG ","F",",",DOT,"-",
	  2,1,1,1,1,4,
	  { _LOCALE_NETHERLANDS,_LOCALE_NETHERLANDS,_LOCALE_NETHERLANDS,
	    _LOCALE_NETHERLANDS,_LOCALE_NETHERLANDS,_LOCALE_NETHERLANDS
	  }
	}
    },
    {	"Norway",
	{ DOT,",","NOK ","kr",",",DOT,"-",
	  2,1,0,1,0,2,
	  { _LOCALE_NORWAY,_LOCALE_NORWAY,_LOCALE_NORWAY,
	    _LOCALE_NORWAY,_LOCALE_NORWAY,_LOCALE_NORWAY
	  }
	}
    },
    {	"Switzerland",
	{ DOT,",","CHF ","SFrs.",DOT,",","C",
	  2,1,0,1,0,2,
	  { _LOCALE_SWITZERLAND,_LOCALE_SWITZERLAND,_LOCALE_SWITZERLAND,
	    _LOCALE_SWITZERLAND,_LOCALE_SWITZERLAND,_LOCALE_SWITZERLAND
	  }
	}
    },
    {	"UK",
	{ DOT,NA,NA,NA,NA,NA,NA,
	  CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	  { _LOCALE_UK,_LOCALE_UK,_LOCALE_UK,
	    _LOCALE_UK,_LOCALE_UK,_LOCALE_UK
	  }
	}
    },
    {	"Japan",
	{ DOT,NA,NA,NA,NA,NA,NA,
	  CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	  { _LOCALE_JAPAN,_LOCALE_JAPAN,_LOCALE_JAPAN,
	    _LOCALE_JAPAN,_LOCALE_JAPAN,_LOCALE_JAPAN
	  }
	}
    },
    {	"Korea",
	{ DOT,NA,NA,NA,NA,NA,NA,
	  CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	  { _LOCALE_KOREA,_LOCALE_KOREA,_LOCALE_KOREA,
	    _LOCALE_KOREA,_LOCALE_KOREA,_LOCALE_KOREA
	  }
	}
    },
    {	"China",
	{ DOT,NA,NA,NA,NA,NA,NA,
	  CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	  { _LOCALE_CHINA,_LOCALE_CHINA,_LOCALE_CHINA,
	    _LOCALE_CHINA,_LOCALE_CHINA,_LOCALE_CHINA
	  }
	}
    },
};

/**********************************
 */

char *setlocale(int category, const char *locale)
{   enum _LOCALE n;
    struct lconv near *pconv;

    if (locale)
    {
	if (*locale == 0)		/* if native environment	*/
	    n = _LOCALE_NATIVE;
	else
	{
	    for (n = 0; 1; n++)
	    {   if (n == _LOCALE_MAX)	/* if locale is not found	*/
		    return 0;		/* selection cannot be honored	*/
		if (strcmpl(locale,locale_data[n].locale) == 0)
		    break;		/* found it			*/
	    }
	}
	pconv = &(locale_data[n].locdata);
	__current_lconv.lc[category] = n;
	switch (category)
	{   case LC_ALL:
		__current_lconv = *pconv;
		break;
#if 0
	    case LC_COLLATE:
	    case LC_CTYPE:
	    case LC_TIME:
		break;
#endif
	    case LC_MONETARY:
		memcpy(&__current_lconv.int_curr_symbol,
			&(pconv->int_curr_symbol),
			sizeof(struct lconv) - 2 * sizeof(char *) -
			sizeof(__current_lconv.lc));
		break;
	    case LC_NUMERIC:
		memcpy(&__current_lconv,pconv,2 * sizeof(char *));
		break;
	}
    }
    return locale_data[n].locale;
}

#endif

#if Alconv

/* Some strings to reduce redundancy	*/
static char NA[] = "";		/* not available			*/
static char DOT[] = ".";

/* At program startup, this is initialized to the "C" locale	*/
struct lconv __current_lconv =
{	DOT,NA,NA,NA,NA,NA,NA,
	CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,CHAR_MAX,
	{ _LOCALE_C,_LOCALE_C,_LOCALE_C,
	  _LOCALE_C,_LOCALE_C,_LOCALE_C
	}
};


/*************************************
 * Return pointer to current state of locale.
 */

struct lconv *localeconv(void)
{
    return &__current_lconv;
}

#endif
