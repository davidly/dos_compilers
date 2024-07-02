#ifndef RTANGLE_HPP
#define RTANGLE_HPP
#include "shapes.hpp"

struct rightangle : public shape {
    rightangle(coord a, coord b, coord c) : (a, b, c) {}    // 1
    void draw();                                            // 2
    int clicks() { return 3; }                              // 3
};
#endif
