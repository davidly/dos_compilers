/* Copyright 1992 Manx Software Systems, Inc. All rights reserved */

#ifndef __GRAPHICS_H
#define	__GRAPHICS_H

#define BLACK	 	0
#define BLUE	   	1
#define GREEN	   	2
#define CYAN	   	3
#define RED	   		4
#define MAGENTA		5
#define YELLOW		6
#define WHITE		7

#define BLINK	    1
#define NO_BLINK    0
#define HIGH		1
#define LOW			0

void circle(int _x, int _y, int _r);
void color(int _clr);
void ground(int _color);
void line(int _x1, int _y1, int _x2, int _y2);
void lineto(int _x2, int _y2);
void mode(int _newmode);
void palette(int _val);
void point(int _x, int _y);
void set_asp(int _x_asp, int _y_asp);

#endif	/* __GRAPHICS_H */
