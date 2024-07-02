#ifndef SHAPEDEF_HPP
#define SHAPEDEF_HPP
#include <stdio.h>
#include <string.h>
#include "gmouse.hpp"
#include "shapes.hpp"
#define BASELINE 45

typedef shape *pshape;

shape *shape_switch(int, coord, coord, coord);
extern const double icon_defs[];

class shape_manager {
    graphics_mouse pointer;
    pshape *sl;
    int listsize;
    int shapes, count;
    int iconh, iconw, last_icon, quit, scaler, mover;
    int get_icon();
    void jitter(coord&);
    int get_coord(coord&);
    int create_shape(int n);
    void show_icons();
    void scale(double);
    void move(coord);
public:
    shape_manager();
    ~shape_manager();
    int draw();
};
#endif
