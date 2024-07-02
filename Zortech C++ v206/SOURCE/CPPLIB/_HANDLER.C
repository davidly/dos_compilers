/*_ _handler.c   Sat Jan  2 1988   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Walter Bright */
/* All rights reserved */

extern void (*_new_handler)(void);

/******************************
 * Called to set a new value of _new_handler.
 * Returns:
 *	previous value of _new_handler.
 */

void (*set_new_handler(p))(void)
void (*p)(void);
{	void (*old_handler)(void);

	old_handler = _new_handler;
	_new_handler = p;
	return old_handler;
}
