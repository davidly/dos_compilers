#include "shapedef.hpp"

extern const double icon_defs[] = {
    0,0.3,0,0,0,0,
    0,0.3,0,0,0,0,
    0,0.3,0,0,0,0,
    0,0,1,1,0,0,
    0.5,0.5,1,0.5,0.5,0.2,
    0.5,0.5,0.5,0,0,0,
    0,0,1,1,0,0,
    0,0,1,0,0.5,1,
    -1
};

shape *shape_switch(int t, coord a, coord b, coord c)
{
    switch (t) {
    case 1:
        return new rubout(a,b);
    case 2:
        return new filler(a);
    case 3:
        return new textstring(a);
    case 4:
        return new line(a,b);
    case 5:
        return new ellipse(a,b,c);
    case 6:
        return new circle(a,b);
    case 7:
        return new rectangle(a,b);
    case 8:
        return new triangle(a,b,c);
    }
}
