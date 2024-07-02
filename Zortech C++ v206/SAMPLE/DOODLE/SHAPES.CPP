#include <math.h>
#include <bios.h>
#include <string.h>
#include "shapes.hpp"

#define C0 coord(0,0)

shape::shape(coord &a, coord &b, coord &c) :
            anchor(a), dp1(b), dp2(c)
{
    memmove(area,fg_displaybox,sizeof(fg_displaybox));
}

void shape::restrict(int *a)
{
    memmove(area,a,sizeof(fg_box_t));
}

void shape::scale(double f)
{
    anchor *= f;
    dp1 *= f;
    dp2 *= f;
}

void shape::move(coord &n)
{
    anchor += n;
    dp1 += n;
    dp2 += n;
}

line::line(coord &a, coord &b) : (a, b, C0) {}

void line::draw()
{
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,
        FG_LINE_SOLID,(int *) &anchor,area);
}

ellipse::ellipse(coord &a, coord &b, coord &c)
    : (a, b, c) {}

void ellipse::draw()
{
    fg_drawellipse(FG_WHITE,FG_MODE_SET,~0,
        anchor.x, anchor.y,
        abs(dp1.x-anchor.x),abs(anchor.y-dp2.y),
        0, 3600, area);
}

circle::circle(coord &a, coord &b)
    : (a, b, C0) {}

void circle::draw()
{
    double r, pixrat = ((double) fg_pixely)/fg_pixelx;
    double dx = anchor.x-dp1.x, dy = pixrat*(anchor.y-dp1.y);
    r = sqrt(dx*dx+dy*dy);
    int d1 = (int) r;
    int d2 = (int) r/pixrat;    // fudge for pixel shape
    fg_drawellipse(FG_WHITE,FG_MODE_SET,~0,
        anchor.x, anchor.y,
        d1, d2, 0, 3600, area);
}

rectangle::rectangle(coord &a, coord &b)
    : (a, b, C0) {}

void rectangle::draw()
{
    if (dp1.x < anchor.x) {
        coord t;
        t = anchor;
        anchor = dp1;
        dp1 = t;
    }
    if (dp1.y < anchor.y) {
        int t;
        t = anchor.y;
        anchor.y = dp1.y;
        dp1.y = t;
    }
    fg_drawbox(FG_WHITE,FG_MODE_SET,~0,
                FG_LINE_SOLID,(int *) &anchor,area);
}

rubout::rubout(coord &a, coord &b)
    : (a, b, C0) { dummy = 0; }

void rubout::draw()
{
    if (dummy) {
        fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,
            anchor.x,anchor.y,
            "Erase",fg_displaybox);
        dummy = 0;
    } else {
        if (dp1.x < anchor.x) {
            coord t;
            t = anchor;
            anchor = dp1;
            dp1 = t;
        }
        if (dp1.y < anchor.y) {
            int t;
            t = anchor.y;
            anchor.y = dp1.y;
            dp1.y = t;
        }
        fg_fillbox(FG_BLACK,FG_MODE_SET,~0,(int *) &anchor);
    }
}
triangle::triangle(coord &a, coord &b, coord &c)
    : (a, b, c) {}

void triangle::draw()
{
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,
        FG_LINE_SOLID,(int *) &anchor,area);
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,
        FG_LINE_SOLID,(int *) &dp1,area);
    coord t1 = dp2, t2 = anchor;
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,
        FG_LINE_SOLID,(int *) &t1,area);
}

textstring::textstring(coord &a)
    : (a, C0, C0)
{
    existing = dummy = 0;
    stp = 0;
}

void textstring::draw() {
    int clipx = fg_displaybox[FG_X2],
        clipy = fg_displaybox[FG_Y2];
    fg_box_t bb;
    bb[FG_Y1] = anchor.y;
    bb[FG_Y2] = anchor.y+14;
    if (bb[FG_Y2] > clipy) bb[FG_Y2] = clipy;
    bb[FG_X1] = anchor.x;
    bb[FG_X2] = anchor.x+9;
    if (bb[FG_X2] > clipx) bb[FG_X2] = clipx;
    
    int tx = anchor.x;
    if (dummy) {
        fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,
            anchor.x,anchor.y,
            "Text",fg_displaybox);
        dummy = 0;
    } else if (!stp) {
        char buffer[80], *p = buffer;
        fg_putc(FG_BLINK,FG_MODE_SET,~0,FG_ROT0,
                anchor.x, anchor.y, '\x15', fg_displaybox);
        for (int count = 0;;) {
            char c = bioskey(0);
            fg_fillbox(FG_BLACK,FG_MODE_SET,~0,bb);
            if (c == '\r')
                break;
            if (c == '\b') {
                if (count) {
                    --p;
                    tx -= 9;
                    bb[FG_X1] = tx;
                    bb[FG_X2] = tx+9;
                    if (bb[FG_X2] > clipx) bb[FG_X2] = clipx;
                    fg_fillbox(FG_BLACK,FG_MODE_SET,~0,bb);
                    --count;
                }
            } else if (tx < clipx) {
                fg_putc(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,
                    tx,anchor.y,c,fg_displaybox);
                tx += 9;
                bb[FG_X1] = tx;
                bb[FG_X2] = tx+9;
                if (bb[FG_X2] > clipx) bb[FG_X2] = clipx;
                *p++ = c;
                ++count;
            }
            fg_putc(FG_BLINK,FG_MODE_SET,~0,FG_ROT0,
                tx, anchor.y, '\x15', fg_displaybox);
        }
        *p = '\0';
        stp = new char[count+1];
        if (stp)
            strcpy(stp,buffer);
        existing = 1;
    } else
        if (stp) 
            fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,
                anchor.x,anchor.y,
                stp,fg_displaybox);
}

filler::filler(coord &a)
    : (a, C0, C0) { dummy = 0; }

void filler::draw()
{
    if (dummy) {
        fg_puts(FG_WHITE,FG_MODE_SET,~0,FG_ROT0,
            anchor.x,anchor.y,
            "Fill",fg_displaybox);
        dummy = 0;
    } else
        fg_fill(anchor.x,anchor.y,FG_WHITE,FG_WHITE);
}
