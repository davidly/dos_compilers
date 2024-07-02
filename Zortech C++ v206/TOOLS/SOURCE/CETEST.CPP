#include <stream.hpp>
#include <io.h>
#include <disp.h>
#include <criterr.hpp>

static errors, lastcode;

int user_handler1(int drive, int errcode)
{
    ++errors;
    lastcode = errcode;
    return CE_IGNORE;
}

int user_handler2(int drive, int errcode)
{
    disp_printf("\nError accessing drive %c - errorcode %d\n",drive,
                        errcode);
    disp_flush();   // use direct screen output - no DOS operations
    return CE_ABORT;        // during interrupt
}

foo()
{
    ce_handler for_foo(user_handler2);
    open("a:any.old",0);    // see there is no disc in drive a
}

main()
{
    ce_handler for_main(user_handler1);

    disp_open();
    for (;;) {
        disp_printf("Print or Quit P/Q: ");
        disp_flush();
        char c = bdos(8,0,0);
        if (c == 'Q' || c == 'q')
            break;
        for (;;) {
            fprintf(stdprn,"Turn me off I am wasting paper!\n");
            fflush(stdprn);
            if (errors) {
                bdos(6,7,0);
                errors = 0;
                disp_printf("\nPrinter fault\n");
                break;
            }
        }
    }
    foo();
    disp_printf("\nIf we got here there were no fatal errors\n");
    disp_close();
}
