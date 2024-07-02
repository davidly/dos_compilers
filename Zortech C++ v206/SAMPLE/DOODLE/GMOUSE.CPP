#include "gmouse.hpp"
#include <stdio.h>
#include <bios.h>
#include <stdlib.h>
#include <dos.h>

graphics_mouse::graphics_mouse()
{
    int display = fg_init_all();
    if (display == FG_HERCHALF || display == FG_HERCFULL) {
        display = 6;    // Microsoft mouse does not provide
                        // automatic support for Hercules
        poke(0x40,0x49,&display,1);
    }
    msm_init();
}

int graphics_mouse::waitpress(coord& c)
{
    unsigned x, y, d;
    int rv;
    for (;;) {
        if (bioskey(1))
            if (bioskey(0) == 0x011b) {
                msm_term();
                fg_term();
                exit(0);
            }
        int status = msm_getstatus(&x,&y), s2;
        if (status & LEFT_BUTTON) {
            rv = LEFT_BUTTON;
            while ((s2 = msm_getstatus(&d,&d)) & LEFT_BUTTON) {
                if (s2 & RIGHT_BUTTON) {
                    rv = LEFT_BUTTON | RIGHT_BUTTON;
                    break;
                }
            }
            break;
        }
        if (status & RIGHT_BUTTON) {
            rv = RIGHT_BUTTON;
            while ((s2 = msm_getstatus(&d,&d)) & RIGHT_BUTTON) {
                if (s2 & LEFT_BUTTON) {
                    rv = LEFT_BUTTON | RIGHT_BUTTON;
                    break;
                }
            }
            break;
        }
    }
    while (msm_getstatus(&d,&d) & (LEFT_BUTTON | RIGHT_BUTTON)) ;
    c.x = x; c.y = y;
    xlate(c);
    return rv;
}
