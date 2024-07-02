#include <disp.h>
#include <rtc.hpp>

rt_clock *_current_clock = 0;

rt_clock::rt_clock(int row, int col, int attr) {
    clockrow = row; clockcol = col; clockattr = attr;
    if (!disp_inited) disp_open();
    if (!_current_clock) {
        int_intercept(0x1c,&rtc,256);
    }
    state = CLOCKON;
    prev_clock = _current_clock;
    int_off();
    _current_clock = this;
    int_on();
}

rt_clock::~rt_clock() {
    if (prev_clock) {
        int_off();
        _current_clock = prev_clock;
        int_on();
    } else 
        int_restore(0x1c);
}

/*--------------------------------------*/
/* This is the interrupt handler itself */
/*--------------------------------------*/

static int cdecl rtc(struct INT_DATA *)
{
    long ticks,rem;
    unsigned int hours,mins,secs;
    int a = 256*_current_clock->clockattr;
    int tim[8], *p;

    if (_current_clock->state) {
        int_on();
        peek(0,0x46c,&ticks,4);
        p = tim;
        hours = ticks/65543;
        rem = ticks%65543;
        mins = rem/1092;
        ticks = 100*(rem%1092);
        secs = (int) (ticks/1821);
        *p++ = hours/10+'0'+a;
        *p++ = hours%10+'0'+a;
        *p++ = ':'+a;
        *p++ = mins/10+'0'+a;
        *p++ = mins%10+'0'+a;
        *p++ = ':'+a;
        *p++ = secs/10+'0'+a;
        *p++ = secs%10+'0'+a;
        for (int i = 0, j = _current_clock->clockcol; i < 8;
            disp_pokew(_current_clock->clockrow,j,tim[i]), ++i, ++j) ;
    }
    return(0);
}
