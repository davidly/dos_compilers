#include <event.hpp>
#include <sound.h>

//. First we need some Mickey Mouse objects to interact with.  We can derive
//. These from a simple box class.   A box object has a constructor which
//. draws the box, an in function to determine if a point is inside the
//. box,  and a virtual process event function.
struct box {
    int tlr, tlc, wide, high;
    box(int r, int c, int w, int h);
    int in(int tr, int tc) {
        return (tr > tlr && tc > tlc) &&
            (tr < tlr+high-1 && tc < tlc+wide-1);
    }
    virtual int process_event(Event&, int);
};

box::box(int r, int c, int w, int h)
{
    tlr = r; tlc = c; wide = w; high = h;
    disp_box(1,7,tlr,tlc,tlr+h-1,tlc+w-1);
}

//. Boxes have a process_event function which just recognizes a mouse
//. click - that is a left button down - in the box.
int box::process_event(Event& e, int mbs)
{
    if (e.is() == mouse) {
        if (!in(e.y(),e.x()))
            return -1;
        if (e.value() == MOUSE_leftdn)
            return 0;
    }
    return -1;
}

//. Now from class box we can derive class button,  which is a box with
//. a prompt in it.  It just has a pointer to some static text,  and a
//. constructor.  The base class process_event will do for a button.
class button : public box {
    char *tp;
public:
    button(int r, int c, char *t);
};

button::button(int r, int c, char *t)
    : (r,c,strlen(t)+4,3)
{
    tp = t;
    disp_move(r+1,c+2);
    disp_puts(tp);
}    

//. Class ladder is a precursor for a menu class.  It has a public constructor
//. and it's own version of the virtual process_event function.  It also
//. has a private modify function which changes the attribute of a rung,
//. by default to normal video,  or if the optional second argument is
//. specified,  to inverse video.
class ladder : public box {
    char *rungtags;
    int active;
protected:
    int crung;
    void modify(int r, int hi = 0);
public:
    ladder(int r, int c, int w, int h);
    int process_event(Event&, int);
};

ladder::ladder(int r, int c, int w, int h)
                    : (r,c,w,h)
{
    crung = 0;
    active = 0;
}

//. Modify works by peeking the rung into a buffer,  modifying the
//. attribute bytes,  then poking it back.
void ladder::modify(int r, int hi)
{
    unsigned buffer[30];
    disp_peekbox(buffer,tlr+r+1,
            tlc+1,tlr+r+1,tlc+wide-1);
    char *p = (char *) buffer;
    ++p;
    for (int i = wide-2; i--;
            *p = hi? 0x70: 7, p += 2) ;
    disp_pokebox(buffer,tlr+r+1,
            tlc+1,tlr+r+1,tlc+wide-1);
}

//. The process event function for class ladder responds to either
//. keyboard or mouse events.  If it's a keyboard event,  and the
//. key is a digit,  then the corresponding rung is highlighted, and
//. the rung number is returned.  If It's a mouse event,  then either
//. the rung highlighting is changed to correspond to a mouse movement
//. or the rung number is returned.
int ladder::process_event(Event& e, int mbs)
{
    if (in(e.y(),e.x())) {
        if (!active) {
                // Highlighting not already on - wake it up,
            msm_hidecursor();
                // first turning the mouse cursor off.
            modify(crung,1);
            msm_showcursor();
            active = 1;
        }
        if (e.is() == keyboard &&
                (e.value() & 0xff)) {
                // Keyboard event and it is a character
            char c = e.value();
            if (c >= '0' && c <= '0'+high-3) {
                // If in range change to that rung number
                msm_hidecursor();
                modify(crung);
                crung = c-'0';
                modify(crung,1);
                msm_showcursor();
                return crung;
            } else {
                // Otherwise object
                sound_beep(6400);
                return -2;
            }

//. The second argument to process_event provides the state of the mouse
//. buttons prior to this event.  This is used to determine if the left
//. button is down.
        } else if (e.is() == mouse) {
            if (e.value() == MOUSE_leftdn ||
                (e.value() == MOUSE_move && (mbs & 1))) {
                // Left button down - move rung number to mouse row
                msm_hidecursor();
                modify(crung);
                crung = e.y()-tlr-1;
                modify(crung,1);
                msm_showcursor();
                return -1;
            } else if (e.value() == MOUSE_leftup)
                // Left button released - return the rung number.
                return crung;
        }
    } else {
                // Mouse not in the ladder,
        if (active) {
                // Switch highlighting off if it was on.
            modify(crung);
            active = 0;
        }
        return -1;
    }
}

main()
{
    disp_open();        // Open display package.
    disp_move(0,0);
    disp_eeop();
    box(0,0,80,22);     // Draw some boxes.
    box(22,0,80,3);
    box(2,75,4,3);
    msm_init();         // Initialize mouse.
    msm_showcursor();
    ladder ldr(4,6,12,12);
                        // Create a ladder,
    button qt(18,60,"Quit");
    button st(18,2,"set timer");
                        // and two buttons
    int tc = 1, mbs;
    for (int n = 0;;) {
        Event e;
        disp_move(23,tc);
        disp_flush();
                        // Remember the button state.
        mbs = eq.buttons();
        e = eq.get();   // Get an event
        if (e.is() == kbdint)
            break;      // If it's the keyboard interrupt quit.
        if (e.is() == timer) {
            sound_beep(1131);
            sound_beep(1600);
            continue;
        }               // If it's a time out give audible indication.
        n = ldr.process_event(e,mbs);
                        // Pass the event to the ladder for interpretation.
        if (n > -1) {
            disp_move(3,76);
            disp_printf("%2d",n);
                        // Display the result.
            continue;
        } else if (n == -2)
            continue;   // Was key but not a digit

        if (!qt.process_event(e,mbs))
                        // Pass the event to the qt button,
            break;      // quit if it matches
        if (!st.process_event(e,mbs)) {
                        // Pass the event to the st button,
            eq.set_timer(200);
                        // Set a timeout if it matches.
            continue;
        }
        if (e.is() == keyboard) {
                        // Just record the entered character
            if (e.value() & 0xff) {
                if (e.value() == '\b') {
                    if (tc > 1) {
                        disp_puts("\b \b");
                        --tc;
                    }
                } else {
                    disp_putc(e.value());
                    if (tc == 78) {
                        unsigned buf[77];
                        disp_peekbox(buf,23,2,23,78);
                        disp_pokebox(buf,23,1,23,77);
                        disp_puts("\b ");
                    } else ++tc;
                }
            }
        }
    }
    msm_term();
    disp_move(0,0);
    disp_eeop();
    disp_close();
}
