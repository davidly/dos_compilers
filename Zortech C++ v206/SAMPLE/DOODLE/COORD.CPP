#include "coord.hpp"

coord::coord() { x = y = 0; }

coord::coord(int a, int b) :x(a), y(b) {}

coord::coord(coord &a) : x(a.x), y(a.y) {}

coord& coord::operator+=(coord& a)
{
    x += a.x; y += a.y;
    return *this;
}

coord& coord::operator*=(double a)
{
    x *= a; y *= a;
    return *this;
}
