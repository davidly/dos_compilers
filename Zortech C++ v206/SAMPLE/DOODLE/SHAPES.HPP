#ifndef SHAPES_HPP
#define SHAPES_HPP
#include <fg.h>
#include <stdlib.h>
#include "coord.hpp"

class shape {
protected:
    coord anchor, dp1, dp2;
    fg_box_t area;
    shape(coord&, coord&, coord&);
public:
    virtual ~shape() {}
    void restrict(int *a);
    virtual void stylize() {}
    virtual void draw() = 0;
    virtual void scale(double);
    virtual void move(coord&);
    virtual int clicks() = 0;
};

struct line : public shape {
    line(coord &, coord &);
    void draw();
    int clicks() { return 2; }
};

struct ellipse : public shape {
    ellipse(coord&, coord&, coord&);
    void draw();
    int clicks() { return 3; }
};

struct circle : public shape {
    circle(coord&, coord&);
    void draw();
    int clicks() { return 2; }
};

struct rectangle : public shape {
    rectangle(coord&, coord&);
    void draw();
    int clicks() { return 2; }
};

class rubout : public shape {
    int dummy;
public:
    rubout(coord&, coord&);
    void stylize() { dummy = 1; }
    void draw();
    int clicks() { return 2; }
};

struct triangle : public shape {
    triangle(coord&, coord&, coord&);
    void draw();
    int clicks() { return 3; }
};

class textstring : public shape {
    int dummy;
    int existing;
    char *stp;
public:
    textstring(coord&);
    ~textstring() { delete stp; }
    void stylize() { dummy = 1; }
    void draw();
    int clicks() { return 1; }
};

class filler : public shape {
    int dummy;
public:
    filler(coord&);
    void stylize() { dummy = 1; }
    void draw();
    int clicks() { return 1; }
};
#endif
