#include <event.hpp>

//. Two interrupt handlers are required,  one to kill DOS control
//. break handling,  and one to provide the timer facility.  These need
//. to have C linkage,  and are therefore surrounded by an extern "C"
//. declaration.
extern "C"
{                   // Interrupt handlers need C linkage

    static volatile int intflag;
    static volatile unsigned long countdown;

//. The control break handler resets the biosbreak flag,  logs the interrupt,
//. then does an immediate return from interrupt.
    static int ctrl_break_handler(INT_DATA *id)
    {
        int bb = 0;
        poke(0x40,0x71,&bb,1);
        intflag = 1;
        return 1;   // Don't chain the DOS version
    }

//. The timer tick handler just decrements the volatile countdown variable
//. then returns zero so that any existing interrupt service routine on
//. the timer tick gets it's turn.
    static int timer_tick(INT_DATA *id)
    {
        if (countdown)
            countdown--;
        return 0;   // Chain the existing timer tick
    }
}

//. A constructor is provided for class event which just initializes all
//. of the private variables.  This may be useful for creating fictitious
//. events to put back on the event queue.  It uses the private function
//. set,  which is also used by class Event_queue.
Event::Event(event_t t, coord_t a,
            coord_t b, int v)
{
    set(t,a,b,v);
}

void Event::set(event_t t, coord_t a,
            coord_t b, int v)
{
    t &= any;
    int tt = t;
    int bitcount = 0;
    for (int i = 4; i--; tt >>= 1)
        bitcount += tt & 1;
    assert(bitcount <= 1);
    type = t;
    cx = a; cy = b;
    val = v;
}

//. The constructor for class Event_queue will fail if an attempt is made
//. to create more than one instance of the class.  This would not be
//. meaningful,  since there is only one keyboard,  and presumably only one
//. mouse!
Event_queue::Event_queue()
{
    assert(sentinel == 0);  // Only one event queue.
    counting = 0;
    pushed = 0;
    lastx = lasty = lastbuttons = 0;
    mouse_avail = 0;
    int_intercept(0x1b,ctrl_break_handler,128);
                            // Zap the DOS ^C
}

//. The destructor is responsible for restoring any modified interrupt
//. vectors.  If it does not get called the results will be spectacularly
//. bad,  so preferably make the single Event_queue an external object,
//. and don't use abort().
Event_queue::~Event_queue()
{
    int_restore(0x1b);
    if (counting)
        int_restore(0x1c);
}

//. Pending is a private function used by the get function to poll
//. for available events.  It uses mevent() to check for mouse activity,
//. bioskey(1) to see if there is anything in the keyboard buffer,
//. timed out to check if timing is in progress, and whether or not it
//. has counted down.  It just looks at inflag to check for control
//. break.  Only the events specified by the argument mask value which
//. are checked,  but this value is defaulted to check all of them.
event_t Event_queue::pending(event_t which)
{
    if ((which & mouse) &&
        ((pushed & mouse) || mevent()))
            return mouse;
    if ((which & keyboard) &&
        ((pushed & keyboard) || bioskey(1)))
            return keyboard;
    if ((which & timer) &&
        ((pushed & timer) || timed_out()))
            return timer;
    if ((which & kbdint) &&
        ((pushed & kbdint) || intflag))
            return kbdint;
    return non_event;
}

//. Get first checks if anything has been put back on the queue.  If
//. something has,  then a reference to the pushed event is returned.
//. Otherwise pending is called until something happens.  The event
//. is then set in the local buffer if this is neccessary,  and a
//. reference to it is returned.
Event& Event_queue::get(event_t which)
{
    if (pushed & which) {
        pushed = 0;
        return pushed_event;
    }

    event_t event;
    while ((event = pending(which)) == 0) ;

    if (event == mouse) {
        mouse_avail = 0;
            // In this case the event was set by pending.
        return mouse_event;
    }
    if (event == keyboard) {
        unsigned k = bioskey(0);
        k = (k & 0xff)? k & 0xff: k;
        current.set(keyboard, lastx, lasty, k);
        return current;
    }
    if (event == timer) {
        counting = 0;
        int_restore(0x1c);
        current.set(timer, lastx, lasty);
        return current;
    }
    if (event == kbdint) {
        bioskey(0);
    // remove dummy entry from kbd buffer
        intflag = 0;
        current.set(kbdint, lastx, lasty);
        return current;
    }
    assert(0);  // should never get here!
}

//. Lookahead checks if there is anything there without removing
//. whatever it is from the queue.  Since it has to return something,
//. if there is nothing else available it will report that the next
//. available event is a keyboard interrupt.
Event& Event_queue::lookahead(event_t which)
{
    if (which & pushed) // Event pushed back
        return pushed_event;
    if (which & mouse)
        if (mevent()) { // Check for a mouse happening,
            mouse_avail = 1;
                        // and remember we're holding one.
            return mouse_event;
        }
    int k;
    if (which & keyboard)
                        // Check for a keyboard happening
        if ((k = bioskey(1)) != 0) {
            k = (k & 0xff)? k & 0xff: k;
            current.set(keyboard,lastx,lasty,k);
            return current;
        }
    if ((which & timer) && counting)
                        // If we are counting then the
                        // next thing we know of is
                        // a timeout.
        current.set(timer,lastx,lasty);
        return current;
                        // Otherwise call int a keyboard interrupt
    current.set(kbdint,lastx,lasty);
    return current;
}

//. Putback just parks the unwanted event in the pushed_event slot.
//. and notes what sort it is.  Only one putback is permitted.
int Event_queue::putback(Event& e)
{
    if (pushed)
        return 0;
    pushed = e.is();
    pushed_event = e;
    return -1;
}

//. Flush gets rid of anything pending which matches the mask argument.
void Event_queue::flush(event_t which)
{
    pushed ^= which;
    if (which & mouse)
        mouse_avail = 0;    // Forget any previewed mouse event
    if (which & keyboard)
        bdos(0xc,0,0);      // Flush typeahead buffer
    if (which & timer) {    // Reset the timer
        int_restore(0x1c);
        counting = countdown = 0;
    }
}

//. Mevent compares the previous state of the mouse to it's state
//. now,  and constructs a corresponding event if anything has
//. changed.
int Event_queue::mevent()
{
    unsigned buttons,changes;
    coord_t x,y;

    if ((pushed & mouse) || mouse_avail)
        return 1;   // Mouse event already waiting
    buttons = msm_getstatus((unsigned *)&x,(unsigned *)&y);
                    // Retrieve mouse state
    buttons &= 7;   // ignoring all but first 3 buttons
#if GRAPHICS
    y = fg_displaybox[FG_Y2] - y;
                    // Compile it separately if required for graphics use.
#else
    if (disp_mode == 0 || disp_mode == 1)
        x /= 16;
    else            // Translate to disp package coordinates (row, col)
        x /= 8;
    y /= 8;
#endif
    if (x != lastx || y != lasty) {
        mouse_event.set(mouse,x,y,MOUSE_move);
        lastx = x;
        lasty = y;
    } else if ((changes = buttons ^ lastbuttons) != 0) {
        int tv;
        if (changes & 1)
            tv = (buttons & 1) ?
                MOUSE_leftdn : MOUSE_leftup;
        else if (changes & 2)
            tv = (buttons & 2) ?
                MOUSE_rightdn : MOUSE_rightup;
        else if (changes & 4)
            tv = (buttons & 4) ?
                MOUSE_leftdn : MOUSE_leftup;
        lastbuttons = buttons;
        mouse_event.set(mouse,x,y,tv);
    } else
        return 0;       // Nothing has changed
    return 1;           // Have a mouse event
}

//. Set timer and timed_out support timer events.  The interrupt is only
//. intercepted when it is required.
unsigned long Event_queue::set_timer(unsigned long ticks)
{
    unsigned long t = countdown;
    countdown = ticks;
    if (!counting) {
        counting = 1;
        int_intercept(0x1c,timer_tick,256);
    }
    return t;
}

int Event_queue::timed_out()
{
    return counting && !countdown;
}
