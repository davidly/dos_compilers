#include <event.hpp>
#include <stdio.h>

main()
{
    disp_open();    // Use the display package
    disp_move(0,0);
    disp_eeop();
    disp_flush();
    msm_init();     // Initialise the mouse
    msm_showcursor();
    eq.set_timer(180);
                    // Set up for a timer event
    for (int going = 1; going;) {
        Event t = eq.get();
                    // Wait for something to happen
        switch (t.is()) {
        case mouse:
            if (t.value() == MOUSE_move)
                break;
                    // Don't bother to display mouse moves
            disp_putc('\x2');
                    // Register a button change
            if (t.x() == 0 && t.y() == 0)
                going = 0;
            break;
        case keyboard:
                    // Display the character if not zero
            disp_putc((t.value() & 0xff)?
                    t.value(): '\x3');
            if (t.value() == 0x1b)
                    // ESC to quit
                going = 0;
            break;
        case timer:
            disp_putc('\x19');
                    // Register timer event,
            eq.putback(Event(keyboard,0,0,0x54));
                    // check out putback,
            eq.set_timer(100);
                    // and set the timer again.
            break;
        case kbdint:
            disp_putc('\x4');
            break;
        }
        if (!going)
            break;
// Now the same sort of thing for the lookahead function.
        t = eq.lookahead();
        disp_setattr(0x70);
                // Pending events in inverse video
        switch (t.is()) {
        case mouse:
            if (t.value() == MOUSE_move)
                break;
            disp_putc('\x2');
            break;
        case keyboard:
            disp_putc((t.value() & 0xff)? t.value(): '\x3');
            break;
        case timer:
            disp_putc('\x19');
            break;
        case kbdint:
                // Don't bother to display this one.
            break;
        }
        disp_setattr(7);
    }
                // Clean up after.
    msm_hidecursor();
    msm_term();
    disp_move(0,0);
    disp_eeop();
    disp_close();
    puts("Hello World");
                // Make sure no ^C lurking.
}
