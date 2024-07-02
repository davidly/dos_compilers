#ifndef GMOUSE_HPP
#define GMOUSE_HPP
#include <fg.h>
#include <msmouse.h>
#include "coord.hpp"

class graphics_mouse {
    void xlate(coord& c) { c.y = -c.y+fg_displaybox[FG_Y2]; }
public:
    graphics_mouse();
    ~graphics_mouse() { msm_term(); fg_term(); }
    int waitpress(coord& c);
    void on() { msm_showcursor(); }
    void off() { msm_hidecursor(); }
};
#endif
