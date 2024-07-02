#include "shapedef.hpp"
#include <stdio.h>
#include <dos.h>
#include <bios.h>

void shape_manager::show_icons()
{
    pointer.off();
    for (int i = 0; i < shapes; ++i) {
        sl[i]->stylize();
        sl[i]->draw();
    }
    pointer.on();
}

shape_manager::shape_manager()
{
    int i, j;
    iconh = fg_displaybox[FG_Y2]/12;
    iconw = 5*(fg_charbox[FG_X2]+1);
    fg_box_t bound;
    memmove(bound,fg_displaybox,sizeof(fg_box_t));
    bound[FG_Y1] = iconh + fg_charbox[FG_Y2]+2;
    sl = new pshape[20];
    if (!sl) {
        puts("Out of memory");
        exit(1);
    }
    listsize = 20;
    last_icon = count = 0;
    pshape *p = sl;
    fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,0,iconh,
"Select an icon - right click to repeat,  or click on  QUIT  SCALE  MOVE",
            fg_displaybox);
    fg_drawbox(FG_WHITE,FG_MODE_SET,~0,FG_LINE_SOLID,
                    bound, fg_displaybox);
    quit = 54*(fg_charbox[FG_X2]+1);
    scaler = 60*(fg_charbox[FG_X2]+1);
    mover = 67*(fg_charbox[FG_X2]+1);
    shapes = 0;
    iconh -= 2;
    for (i = j = 0;; ++p, ++shapes) {
        if (icon_defs[i] < 0.0)
            break;
        coord a, b, c;
        a.x = int(icon_defs[i++]*iconw)+j+1;
        a.y = int(icon_defs[i++]*iconh)+1;
        b.x = int(icon_defs[i++]*iconw)+j+1;
        b.y = int(icon_defs[i++]*iconh)+1;
        c.x = int(icon_defs[i++]*iconw)+j+1;
        c.y = int(icon_defs[i++]*iconh)+1;
        *p = shape_switch(shapes+1,a,b,c);
        j += iconw+2;
    }
    iconw += 2;
    iconh += 2;
    show_icons();
    pointer.on();
}    

int shape_manager::get_icon()
{
    coord c;
    int event;
    
    for (;;) {
        if ((event = pointer.waitpress(c)) == (LEFT_BUTTON | RIGHT_BUTTON))
            return -1;
        else if (event == RIGHT_BUTTON) {
            if (!last_icon) {
                bdos(6,7,0);
                continue;
            }
            return last_icon;
        } else {
            if (c.y >= iconh+fg_charbox[FG_Y2]+1) {
                bdos(6,7,0);
                continue;
            }
            if (c.y >= iconh && c.x > quit)
                return c.x > mover? -4: c.x > scaler? -3: -2;
            last_icon = 1+c.x/iconw;
            if (last_icon > shapes) last_icon = shapes;
            return last_icon;
        }
    }
}

void shape_manager::jitter(coord& c)
{
    fg_color_t dot;
    dot = fg_readdot(c.x,c.y);
    if (dot != FG_BLACK)
        return;
    int i = c.x-2;
    int j = c.y-2;
    while (i < 0) ++i;
    while (j < iconh+fg_charbox[FG_Y2]+1) ++j;
    for (; i < fg_displaybox[FG_X2] && i < c.x+3; ++i)
        for (; j < fg_displaybox[FG_Y2] && j < c.y+3; ++j) {
            dot = fg_readdot(i,j);
            if (dot != FG_BLACK) {
                c.x = i; c.y = j;
                return;
            }
        }
    return;
}

int shape_manager::get_coord(coord& g)
{
    for (;;) {
        if (pointer.waitpress(g) == (LEFT_BUTTON | RIGHT_BUTTON))
            return -1;
        if (g.y < iconh+fg_charbox[FG_Y2]+1) {
            bdos(6,7,0);
            continue;
        }
        jitter(g);
        return 0;
    }
}
    

int shape_manager::create_shape(int t)
{
    coord a, b, c;
    int cl = sl[t-1]->clicks();
    int rv = get_coord(a);
    if (rv)
        return rv;
    if (--cl) {
        rv = get_coord(b);
        if (rv)
            return rv;
        if (--cl) {
            rv = get_coord(c);
            if (rv)
                return rv;
        }
    }
    if (shapes+count >= listsize) {
        listsize += 20;
        pshape *t = new pshape[listsize];
        if (!t) {
            fg_term();
            puts("Out of memory");
            exit(1);
        }
        memset(t,'\0',listsize*sizeof(void *));
        memmove(t,sl,(shapes+count)*sizeof(void *));
        delete sl;
        sl = t;
    }
    shape *q = shape_switch(t,a,b,c);
    if (!q) {
        fg_term();
        puts("Out of memory");
        exit(1);
    }
    fg_box_t bb;
    memmove(bb,fg_displaybox,sizeof(fg_box_t));
    bb[FG_Y1] = iconh + fg_charbox[FG_Y2]+2;
    q->restrict(bb);
    pointer.off();
    q->draw();
    pointer.on();
    sl[shapes+count] = q;
    ++count;
    return 0;
}

int shape_manager::draw()
{
    int t;
    coord c1, c2;
    double d;
    if ((t = get_icon()) < 0) {
        switch (t) {
        case -1:        // ignore both buttons
            return 0;
        case -2:
            return -1;
        case -3:
            if (get_coord(c1))
                return 0;
            if (get_coord(c2))
                return 0;
            d = double(c2.x)/c1.x;
            scale(d);
            return 0;
        case -4:
            if (get_coord(c1))
                return 0;
            if (get_coord(c2))
                return 0;
            c2.x -= c1.x;  c2.y -= c1.y;
            move(c2);
            return 0;
        }
    } else {
        create_shape(t);
        return 0;
    }
}

void shape_manager::scale(double f)
{
    pointer.off();
    fg_box_t bound;
    memmove(bound,fg_displaybox,sizeof(fg_box_t));
    bound[FG_Y1] = iconh + fg_charbox[FG_Y2]+1;
    fg_fillbox(FG_BLACK,FG_MODE_SET,~0,bound);
    fg_drawbox(FG_WHITE,FG_MODE_SET,~0,FG_LINE_SOLID,
                    bound, fg_displaybox);
    for (int i = shapes; i < shapes+count; ++i) {
        sl[i]->scale(f);
        sl[i]->draw();
    }
    pointer.on();
}

void shape_manager::move(coord d)
{
    pointer.off();
    fg_box_t bound;
    memmove(bound,fg_displaybox,sizeof(fg_box_t));
    bound[FG_Y1] = iconh + fg_charbox[FG_Y2]+1;
    fg_fillbox(FG_BLACK,FG_MODE_SET,~0,bound);
    fg_drawbox(FG_WHITE,FG_MODE_SET,~0,FG_LINE_SOLID,
                    bound, fg_displaybox);
    for (int i = shapes; i < shapes+count; ++i) {
        sl[i]->move(d);
        sl[i]->draw();
    }
    pointer.on();
}

shape_manager::~shape_manager()
{
    fg_term();
    for (int i = 0; i < shapes+count; ++i)
        delete sl[i];
    delete sl;
}
