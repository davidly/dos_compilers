/* Copyright (C) 1984 by Manx Software Systems, Inc. */

extern int _maxx, _maxy;
extern int _xaspect, _yaspect;
extern char _color;
extern	int _plotf,_plottbl[];

mode (val)
{
	switch (val)  {
	case 'l': case 'L': case 3:
		scr_call (3);
		break;
	case 'm': case 'M': case 4:
		_plotf = _plottbl[0];
		_xaspect = 6;
		_yaspect = 5;
		_maxx = 319;
		scr_call (4);
		break;
	case 'h': case 'H': case 6:
		_plotf = _plottbl[1];
		_xaspect = 4;
		_yaspect = 1;
		_maxx = 639;
		scr_call (6);
		break;
	case 0x10: 
		_plotf = _plottbl[2];
		_xaspect = 4;
		_yaspect = 3;
		_maxx = 639;
		_maxy = 349;
		scr_call (0x10);
		break;
	case 0x11: 
		_plotf = _plottbl[2];
		_xaspect = 1;
		_yaspect = 1;
		_maxx = 639;
		_maxy = 479;
		scr_call (val);
		break;
	case 0x12: 
		_plotf = _plottbl[2];
		_xaspect = 1;
		_yaspect = 1;
		_maxx = 639;
		_maxy = 479;
		scr_call (val);
		break;
	case 0x13: 
		_plotf = _plottbl[2];
		_xaspect = 1;
		_yaspect = 1;
		_maxx = 319;
		_maxy = 199;
		scr_call (val);
		break;
	default:
		if (val < 0 || val > 6)
			return;
		scr_call (val);
		break;
	}
}

color (c)
{
	switch (c)  {
	case 'w': case 'W': case 'y': case 'Y': case 3:
		_color = 3;
		break;
	case 'm': case 'M': case 'r': case 'R': case 2:
		_color = 2;
		break;
	case 'c': case 'C': case 'g': case 'G': case 1:
		_color = 1;
		break;
	default:
		_color = c;
		break;
	}
}

palette (c)
{
	if (c)  
		scr_call (11 << 8,1<<8 | 1,0,0);
	else
		scr_call (11 << 8,1<<8 | 0,0,0);
}

ground (c)
{
	scr_call (11 << 8, 0 << 8 | c,0,0);
}

