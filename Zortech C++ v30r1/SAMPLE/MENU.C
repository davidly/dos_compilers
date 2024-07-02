/*_ menu.c   Thu May 12 1988   Modified by: Walter Bright */

#include	<stdlib.h>
#include	<disp.h>
#include	<msmouse.h>
#include	<dos.h>
#include	"menu.h"

/* Attributes for various components of a menu	*/
unsigned attrbox = DISP_NORMAL | DISP_INTENSITY;
unsigned attrenabled = DISP_NORMAL | DISP_INTENSITY;
unsigned attrdisabled = DISP_NORMAL;
unsigned attrhighlight = DISP_REVERSEVIDEO | DISP_INTENSITY;

/***************************
 * Return !=0 if key is available.
 */

static int key_avail()
{
    return kbhit();
}

/***************************
 * Wait for next key, then return it.
 */

static unsigned key_read()
{   unsigned short key;

    key = bioskey(0);
    if ((key & 0xff) == 0)           /* if extended key code     */
        return key;
    else
        return key & 0xff;
}

/*******************************
 * Convert from strange Microsoft coordinates to proper cursor coordinates.
 */

static mouse_tocursor(px,py)
unsigned *px,*py;
{
    if (disp_mode == 0 || disp_mode == 1)	/* if 40 column mode	*/
	*px /= 16;
    else
	*px /= 8;
    *py /= 8;
}

/***************************
 * Write out a row of text in the menu.
 * Input:
 *	row,col		Upper left corner of menu
 */

static void menu_dorow(menu_t *m,int item,unsigned attr,unsigned row,unsigned col)
{   char *p;
    unsigned rcol;

    msm_hidecursor();
    p = m->items[item].text;
    row += item + 1;
    rcol = col + m->width  + 1;
    attr *= 256;
    for (; ++col < rcol; )
    {   unsigned char ch;

	if (*p)
	    ch = *(unsigned char *)p++;
	else
	    ch = ' ';
	disp_pokew(row,col,attr + ch);
    }
    msm_showcursor();
} 

/***************************
 * Show row item in menu as being selected.
 */

static void menu_select(menu_t *m,unsigned char item,unsigned row,unsigned col)
{
    if (m->selected != item)
    {
	/* Switch currently selected row back to regular display	*/
	if (m->selected < m->nitems)
	{   unsigned attr = (m->items[m->selected].flags & MENU_enabled) ?
		attrenabled : attrdisabled;

	    menu_dorow(m,m->selected,attr,row,col);
	}

	/* Display new selected line	*/
	if (item < m->nitems)
	    menu_dorow(m,item,attrhighlight,row,col);
	m->selected = item;
    }
}

/****************************
 * Select next item in menu.
 * Input:
 *	inc	Which direction to go (+1 = down, -1 = up)
 */

static void menu_next(menu_t *m,unsigned row,unsigned col,int inc)
{   int item;
    unsigned u;

    item = m->selected;
    for (u = 0; u < m->nitems; u++)
    {
	item += inc;
	if (item < 0)
	    item = m->nitems - 1;
	else if (item >= m->nitems)
	    item = 0;
	if (m->items[item].flags & MENU_enabled)
	{   menu_select(m,item,row,col);
	    break;
	}
    }
}

/******************************
 * Track position of mouse as long as left button is down.
 * Returns:
 *	!= 0	Left button selected something
 *	0	Do nothing
 */

static int menu_mousetracker(menu_t *m,unsigned row,unsigned col)
{   unsigned r,c;
    unsigned char newitem;

    while (msm_getstatus(&c,&r) & 1)	/* while left button is down	*/
    {	mouse_tocursor(&c,&r);		/* convert to cursor coords	*/
	if (r <= row || r > row + m->nitems ||
	    c <= col || c > col + m->width)
	    newitem = -1;		/* mouse is not on an item	*/
	else
	{   newitem = r - row - 1;
	    if (!(m->items[newitem].flags & MENU_enabled))
		newitem = -1;		/* item is disabled		*/
	}
	if (newitem != m->selected)	/* if different item is selected */
	    menu_select(m,newitem,row,col);
    }
    return (unsigned) m->selected < (unsigned) m->nitems;
}

/***************************/

int menu_enter(menu_t *m,int row,int col)
{
    int i;
    int brow,rcol;
    unsigned r,c;
    unsigned short *save;
    int result;
    unsigned rbup = 0;

    /* Adjust menu so it will fit on the screen	*/
    if (col + m->width + 2 > disp_numcols)
	col = disp_numcols - (m->width + 2);
    if (row + m->nitems + 2 > disp_numrows)
	row = disp_numrows - (m->nitems + 2);

    /* Compute bottom right corner	*/
    brow = row + m->nitems + 1;
    rcol = col + m->width  + 1;

    msm_hidecursor();

    /* Save area under where cursor will go	*/
    save = malloc((m->nitems + 2) * (m->width * 2) * sizeof(*save));
    if (!save)
	return 0;
    disp_peekbox(save,row,col,brow,rcol);

    /* Draw the menu	*/
    disp_box(0,attrbox,row,col,brow,rcol);
    for (i = 0; i < m->nitems; i++)
    {	unsigned attr;

	attr = (i == m->selected) ? attrhighlight :
		(m->items[i].flags & MENU_enabled) ? attrenabled : attrdisabled;
	menu_dorow(m,i,attr,row,col);
    }

    msm_showcursor();

    /* Main loop	*/
loop:
    while (1)
    {	unsigned key;
	unsigned status;

	disp_flush();			/* bring display up-to-date	*/

	status = msm_getstatus(&c,&r);
	if (status & 2)			/* if right button is down	*/
	{   if (rbup)			/* if right button was up	*/
		goto abort;
	}
	else
	    rbup = 1;			/* right button was up		*/

	/* If left button went down and tracker selected something	*/
	if (status & 1 && menu_mousetracker(m,row,col))
	    goto select;

	if (key_avail())
	{   int inc;

        key = key_read();
	    switch (key)
	    {   case 0x1B:
		    goto abort;
		case '\r':
		    goto select;
		case 0x4800:		/* Up arrow key			*/
		    inc = -1;
		    goto L1;
		case 0x5000:		/* Down arrow key		*/
		    inc = 1;
		L1: menu_next(m,row,col,inc);
		    break;
		default:
		    {	unsigned u;

			/* Convert key to upper case	*/
			if (key >= 'a' && key <= 'z')
			    key -= 'a' - 'A';

			/* Search through menu items for a match with key */
			for (u = 0; u < m->nitems; u++)
			    if (m->items[u].key == key &&
				m->items[u].flags & MENU_enabled)
			    {	menu_select(m,u,row,col);
				goto select;
			    }
		    }
		    break;
	    }
	}
    }
select:
    /* First make sure that something is selected and it's enabled	*/
    if ((unsigned) m->selected >= (unsigned) m->nitems ||
        !(m->items[m->selected].flags & MENU_enabled))
	goto loop;

    {	menu_item_t *mi;
	mi = &m->items[m->selected];

	result = mi->result;
	if (mi->func)
	    result = (*mi->func)(mi->value,row,col);
	if (result == 0)
	    goto loop;
    }
    goto ret;

abort:
    result = 0;

ret:
    /* Restore screen to what it was before menu popped in	*/
    msm_hidecursor();
    disp_pokebox(save,row,col,brow,rcol);
    msm_showcursor();
    free(save);

    /* Wait for any down buttons to go back up.	Doing this after the	*/
    /* display is restored makes for a 'crisper' response.		*/
    while (msm_getstatus(&c,&r) & 3)
	;
    return result;
}

/************** TEST PROGRAM AND DEMO *******************/

#if TEST

menu_item_t items2[] =
{
	{ "submenu B",1,'A',MENU_enabled },
	{ "submenu F2",2,0x3C00,MENU_enabled },
	{ "submenu 3 +",3,'+' },
	{ "bufblah 4",4,0,MENU_enabled },
	{ "abcblah 4",5,0,MENU_enabled },
};

menu_t submenu = { 1,12,sizeof(items2)/sizeof(items2[0]),items2 };

int fsubmenu(int i,unsigned row,unsigned col)
{
    return menu_enter(&submenu,row+i,col+2);
}

menu_item_t items[] =
{
	{ "line 1 A",6,'A',MENU_enabled },
	{ "subm 2 F1",7,0x3B00,MENU_enabled,fsubmenu,3 },
	{ "line 3 +",8,'+' },
	{ "subm 4",9,0,MENU_enabled,fsubmenu,5 },
	{ "blah 4",10,0,MENU_enabled },
};

menu_t testmenu = { 1,10,sizeof(items)/sizeof(items[0]),items };

main()
{   unsigned x,y;
    int result;

    disp_open();			/* initialize display		*/
    msm_init();				/* initialize mouse		*/

    /* Mouse driver sometimes gets the number of screen rows wrong,	*/
    /* so here we force it to whatever disp_open() discovered.		*/
    msm_setareay(0,(disp_numrows - 1) * 8);

    msm_showcursor();			/* turn mouse cursor on		*/

    result = 0;
    do
    {
	if (key_avail())		/* wait for keyboard input	*/
	{   key_read();			/* throw away key value		*/
	    result = menu_enter(&testmenu,10,10);
	}

	if (msm_getstatus(&x,&y) & 2)	/* if right button is down	*/
	{   mouse_tocursor(&x,&y);	/* translate to cursor coords	*/
	    result = menu_enter(&testmenu,y,x);
	}
    } while (result == 0);

    msm_hidecursor();			/* turn mouse cursor off	*/
    msm_term();				/* terminate use of mouse	*/
    disp_printf("Value returned is %d\n",result);
    disp_close();			/* terminate use of display	*/
}

#endif /* TEST */
