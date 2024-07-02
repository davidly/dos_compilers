#ifndef RTCHPP
#define RTCHPP
#include <int.h>

#define CLOCKON 1
#define CLOCKOFF 0

class rt_clock {
    int state;
    int clockrow, clockcol;
    int clockattr;
    rt_clock *prev_clock;
    friend int cdecl rtc(struct INT_DATA *);
public:
    rt_clock(int = 24, int = 72, int = 0x70);
    void on() { state = CLOCKON; }
    void off() { state = CLOCKOFF; }
    ~rt_clock();
};
#endif
