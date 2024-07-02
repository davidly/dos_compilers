#include <disp.h>
#include <bios.h>
#include <stdlib.h>
#include <rtc.hpp>

foo()
{
    rt_clock another(0,72,7);
    disp_move(12,0);
    disp_eeol();
    disp_puts("Clock at rop right in normal video - press a key\n");
    bioskey(0);
}

main()
{
    rt_clock clock;
    disp_open();
    disp_move(0,0);
    disp_eeop();
    disp_move(12,0);
    disp_puts(
"Clock at bottom right (default position) in normal video\
 - press a key\n");
    bioskey(0);
    foo();
    clock.off();
    disp_move(12,0);
    disp_eeol();
    disp_puts("Clock turned off - press a key\n");
    bioskey(0);
    clock.on();
    disp_move(12,0);
    disp_eeol();
    disp_puts("Clock reverts to that defined in main - press a key\n");
    bioskey(0);
    clock.off();
    disp_move(0,0);
    disp_eeop();
    disp_close();
}
