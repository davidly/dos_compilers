#include <datedit.hpp>
#include <disp.h>

char s[80] = "042188";     // string to work on

main()
{
    disp_open();                        // display package must be open
    disp_move(0,0);
    disp_eeop();                        // clear screen
    date_editor e;                    // declare an editor
    e.edit(12,0,s,1);                   // edit it - display first
    disp_move(21,0);
    disp_printf("Length was %d\nCursor position was %d\n%s",
            e.howlong, e.where, s); // display results
    disp_close();
}

