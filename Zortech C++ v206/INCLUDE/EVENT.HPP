// EVENT.HPP - Classes Event and Event_queue and
// related definitions

#ifndef EVENT_HPP
#define EVENT_HPP
#include <stdlib.h>
#include <msmouse.h>
#include <bios.h>
#include <assert.h>
#include <string.h>
#include <int.h>

//. This is written so that it can be compiled for either text based or
//. graphics oriented applications.
#ifdef GRAPHICS
    #include <fg.h>
#else
    #include <disp.h>
#endif

//. Figurative constants are provided for the various possible mouse
//. events,  and for the 'special keys' on the keyboard,  that is the
//. keys which return a zero character value.
// Mouse events
#define MOUSE_move	-1
#define MOUSE_leftdn	-2
#define MOUSE_leftup	-3
#define MOUSE_rightdn	-4
#define MOUSE_rightup	-5
#define MOUSE_middledn	-6
#define MOUSE_middleup	-7

// Keyboard events
#define KEY_up		0x4800
#define KEY_down	0x5000
#define KEY_left	0x4B00
#define KEY_right	0x4D00
#define KEY_pgup	0x4900
#define KEY_pgdn	0x5100
#define KEY_home	0x4700
#define KEY_end		0x4F00
#define KEY_insert	0x5200
#define KEY_del		0x5300
#define KEY_ctrlhome	0x7700
#define KEY_ctrlend	0x7500
#define KEY_ctrlright	0x7400
#define KEY_ctrlleft	0x7300

#define KEY_F1		0x3B00
#define KEY_F2		0x3C00
#define KEY_F3		0x3D00
#define KEY_F4		0x3E00
#define KEY_F5		0x3F00
#define KEY_F6		0x4000
#define KEY_F7		0x4100
#define KEY_F8		0x4200
#define KEY_F9		0x4300
#define KEY_F10		0x4400

#define KEY_ShiftF1	0x5400
#define KEY_ShiftF2	0x5500
#define KEY_ShiftF3	0x5600
#define KEY_ShiftF4	0x5700
#define KEY_ShiftF5	0x5800
#define KEY_ShiftF6	0x5900
#define KEY_ShiftF7	0x5A00
#define KEY_ShiftF8	0x5B00
#define KEY_ShiftF9	0x5C00
#define KEY_ShiftF10	0x5D00

#define KEY_CtrlF1	0x5E00
#define KEY_CtrlF2	0x5F00
#define KEY_CtrlF3	0x6000
#define KEY_CtrlF4	0x6100
#define KEY_CtrlF5	0x6200
#define KEY_CtrlF6	0x6300
#define KEY_CtrlF7	0x6400
#define KEY_CtrlF8	0x6500
#define KEY_CtrlF9	0x6600
#define KEY_CtrlF10	0x6700

#define KEY_AltF1	0x6800
#define KEY_AltF2	0x6900
#define KEY_AltF3	0x6A00
#define KEY_AltF4	0x6B00
#define KEY_AltF5	0x6C00
#define KEY_AltF6	0x6D00
#define KEY_AltF7	0x6E00
#define KEY_AltF8	0x6F00
#define KEY_AltF9	0x7000
#define KEY_AltF10	0x7100

#define KEY_AltA	0x2200
#define KEY_AltB	0x3000
#define KEY_AltC	0x2E00
#define KEY_AltD	0x2000
#define KEY_AltE	0x1200
#define KEY_AltF	0x2100
#define KEY_AltG	0x2200
#define KEY_AltH	0x2300
#define KEY_AltI	0x1700
#define KEY_AltJ	0x2400
#define KEY_AltK	0x2500
#define KEY_AltL	0x2600
#define KEY_AltM	0x3200
#define KEY_AltN	0x3100
#define KEY_AltO	0x1800
#define KEY_AltP	0x1900
#define KEY_AltQ	0x1000
#define KEY_AltR	0x1300
#define KEY_AltS	0x1F00
#define KEY_AltT	0x1400
#define KEY_AltU	0x1600
#define KEY_AltV	0x2F00
#define KEY_AltW	0x1100
#define KEY_AltX	0x2D00
#define KEY_AltY	0x1500
#define KEY_AltZ	0x2C00

//. Class Event also enumerates the types of event with which we are
//. concerned,  mouse, keboard, timer, kbdint,  and a further useful
//. constant, any,  which represents all of the events.
typedef int coord_t;

enum event_t {
    non_event = 0,
    mouse = 1,
    keyboard = 2,
    timer = 4,
    kbdint = 8,
    any = 0xff
};

class Event {
    friend class Event_queue;
public:
    Event(event_t = non_event, coord_t  = 0,
            coord_t = 0, int = 0);
    int is() { return type; }
    int value() { return val; }
    coord_t x() { return cx; }
    coord_t y() { return cy; }
private:
    void set(event_t, coord_t, coord_t, int = 0);
    event_t type;   // type of event
    int val;        // actual event value
    coord_t cx,cy;  // mouse position when event ocurred
};

//. Class Event provides a constructor and a set of access functions to
//. reflect the fact that an event is a historic fact,  something which
//. has a definate set of values.  The private set function allows the
//. Event_queue class only to mess about with event private data.

//. Class Event_queue provides the specified public functions,  get,
//. lookahead, putback, flush, set_timer,  and a constructor and
//. destructor.  The get and lookahead can qualify thieir operation
//. with an optional argument which describes what sort of events to look
//. for.  A static data member is used to ensure that only one Event_queue
//. is constructed.
class Event_queue {
public:
    Event_queue();
    ~Event_queue();
    Event& get(event_t which = any);
//    Event& get(int which = (int) any);
                    // Wait for an event of specified type.
    Event& lookahead(event_t which = any);
                    // Take a look at anything which is pending.
    int putback(Event&);
                    // Park an event back on the queue,
                    // only one putback allowed.
    void flush(event_t which = any);
                    // Dump some or all parked events.
    unsigned long set_timer(unsigned long t);
                    // Initiate a timer event t ticks from now.
    int buttons() { return lastbuttons; }
private:
    int counting;
                    // Timing in progress
    static int sentinel;
                    // Protects against multiple event queues
    int pushed;     // Classifies any putback event
    Event pushed_event;
                    // Last event which was put back
    coord_t lastx, lasty;
    unsigned lastbuttons;
                    // Private variables for tracking mouse
    int mouse_avail;// Got a previewed mouse event
    Event mouse_event, current;
                    // Place to park a peeked mouse event
                    // and the event we have
    event_t pending(event_t which = any);
                    // Has some event of interest happened?
    int mevent();   // Function to analyse msm_status
    int timed_out();// Is current timer period expired.
};

extern Event_queue eq;
    
#endif /* EVENT_HPP */

