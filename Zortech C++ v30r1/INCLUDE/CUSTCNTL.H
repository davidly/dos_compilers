/*
 * CUSTOM CONTROL LIBRARY - HEADER FILE
 *
 */

/* general size definitions */
#define 	CTLTYPES		12				/* number of control types */
#define 	CTLDESCR		22				/* size of control menu name */
#define		CTLCLASS	  	20			  	/* max size of class name */
#define		CTLTITLE	  	94			  	/* max size of control text */

/**/

/*
 * CONTROL STYLE DATA STRUCTURE
 *
 * This data structure is used by the class style dialog function
 * to set and/or reset various control attributes.
 *
 */

typedef struct {
	WORD			wX;					 		/* x origin of control */
	WORD			wY;					 		/* y origin of control */
	WORD			wCx;							/* width of control */
	WORD			wCy;							/* height of control */
	WORD			wId;							/* control child id */
	DWORD			dwStyle;						/* control style */
	char			szClass[CTLCLASS];  		/* name of control class */
	char			szTitle[CTLTITLE];  		/* control text */
} CTLSTYLE;

typedef CTLSTYLE *		PCTLSTYLE;
typedef CTLSTYLE FAR *		LPCTLSTYLE;

/**/

/*
 * CONTROL DATA STRUCTURE
 *
 * This data structure is returned by the control options function
 * when enquiring about the capabilities of a particular control.
 * Each control may contain various types (with predefined style
 * bits) under one general class.
 *
 * The width and height fields are used to provide the host
 * application with a suggested size.  The values in these fields
 * could be either in pixels or in rc coordinates.  If it is in pixel,
 * the most sigificant bit(MSB) is on.  If the MSB is off, it is in rc
 * coordinates.
 *
 * The cursor and bitmap handles reference objects which can be
 * used by the dialog editor in the placement and definition of
 * new, user-defined control classes.  However, dialog editor in win30
 * does not use these fields.
 *
 */

typedef struct {
	WORD			wType;						/* type style */
	WORD			wWidth;						/* suggested width */
	WORD			wHeight;						/* suggested height */
	DWORD			dwStyle;						/* default style */
	char			szDescr[CTLDESCR];  		/* menu name */
} CTLTYPE;

typedef struct {
	WORD			wVersion;					/* control version */
	WORD			wCtlTypes;					/* control types */
	char			szClass[CTLCLASS];  		/* control class name */
	char			szTitle[CTLTITLE];  		/* control title */
	char			szReserved[10];			/* reserved for future use */
	CTLTYPE 		Type[CTLTYPES]; 		/* control type list */
} CTLINFO;

typedef CTLINFO *		PCTLINFO;
typedef CTLINFO FAR *		LPCTLINFO;

/* These two function prototypes are used by dialog editor */
typedef DWORD			(FAR PASCAL *LPFNSTRTOID)( LPSTR );
typedef WORD			(FAR PASCAL *LPFNIDTOSTR)( WORD, LPSTR, WORD );
