/*_ menu.h   Tue May 10 1988   Modified by: Walter Bright */

/**************************
 * One menu item per line in the menu.
 */

typedef struct
{
    char *text;			/* text of item				*/
    int result;			/* value return from menu_enter()	*/
				/* if this item is selected		*/
    unsigned key;		/* key value which will select it	*/
    unsigned char flags;
#	define MENU_enabled 1	/* set if item is enabled		*/
    int (*func)			/* semantic routine			*/
	(int,			/* value from this struct		*/
	 unsigned,		/* top row of this menu			*/
	 unsigned);		/* left column of this menu		*/
				/* Returns:				*/
				/*	0	Continue		*/
				/*	!=0	Return from menu_enter() */
    int value;			/* value to pass to func		*/
} menu_item_t;

/**************************************
	    *func is called when the menu item is selected, but before
	the menu is removed from the display. It is primarilly useful
	for going into submenus or dialog boxes. Since menu_enter()
	is reentrant, it can be used to generate submenus also. See
	the test program provided.
	    When *func returns, if the return value is 0 the original
	menu is reentered. If it is non-zero, the menu is terminated
	and that value becomes the return value of menu_enter().
	    If there is no *func, the return value of menu_enter is
	given by the result member of menu_item_t. This value must
	be non-zero (or the menu code will ignore the selection)!
	    I need to write a dialog box package too!
 */

/*************************
 * The menu itself.
 */

typedef struct MENU_T
{
    unsigned char selected;	/* which one is the selected one	*/
    unsigned char width;	/* width in chars excluding border	*/
    unsigned char nitems;	/* number of items in menu		*/
    menu_item_t *items;		/* array of items in menu		*/
} menu_t;

/*****************************
 * Bring up a menu, perform all the processing, call the selected
 * function, and exit.
 * Input:
 *	row,col		Position of upper left corner of menu
 * Returns:
 *	!=0	A function was called
 *	0	The menu was aborted
 */

int menu_enter(menu_t *,int,int);

