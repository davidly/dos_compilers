#ifndef COORD_HPP
#define COORD_HPP

struct coord {
    int x, y;
    coord();
    coord(int, int);
    coord(coord&);
    coord& operator+=(coord&);
    coord& operator*=(double);
};
#endif
