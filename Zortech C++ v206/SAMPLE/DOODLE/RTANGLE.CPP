#include "rtangle.hpp"

void rightangle::draw()
{
    coord t1 = anchor, t2;
    t2.y = anchor.y; t2.x = dp1.x;
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,                // 1
        FG_LINE_SOLID,(int *) &t1, area);
    t2.x = anchor.x; t2.y = dp2.y;
    fg_drawlineclip(FG_WHITE,FG_MODE_SET,~0,                // 2
        FG_LINE_SOLID,(int *) &t1, area);
}
