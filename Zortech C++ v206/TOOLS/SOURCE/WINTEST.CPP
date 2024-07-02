#include <window.hpp>

window_set ws1(1);
window_set ws2(0);

main()
{
    char buf[30];
    window w1(&ws1,2,2,12,30,0x70,0), w2(&ws1,6,15,16,43,0x70,0),
                w3(&ws1,4,24,14,52,0x70,1), dialog(&ws2,21,30,23,78,7,2);
    *buf = '\0';
    dialog.title("Example Dialog Box");
    dialog.puts("Press a key to suspend w3");
    bioskey(0);
    w3.suspend();
    dialog.clear();
    dialog.puts("Press a key to suspend w2");
    bioskey(0);
    w2.suspend();
    dialog.clear();
    dialog.puts("Press a key to suspend w1");
    bioskey(0);
    w1.suspend();
    dialog.clear();
    dialog.puts("Press a key");
    bioskey(0);
    w1.select();
    dialog.clear();
    dialog.puts("And again");
    bioskey(0);
    w2.select();
    bioskey(0);
    w3.select();
    dialog.suspend();
    w3.puts("Enter some text");
    w3.locate(1,0);
    w3.gets(buf);
    w2.puts(
"This should be too long for the width of the window\n\nPress a key");
    bioskey(0);  
    w1.printf("Jack and Gill ran\n");
    w1.printf("up the hill\n");
    w1.printf("to fetch a pail\n");
    w1.printf("of water\n\n");
    w1.printf("Press a key");
    bioskey(0);
    w3.select();
    w3.clear();
    w3.puts("Press a key to\nchange this window");
    bioskey(0);
    w3.modify(7,0);
    w3.locate(5,0);
    w3.printf("%d number in a\n window\n\nPress a key",22);
    bioskey(0);
    dialog.clear();
    dialog.puts("Thats all - key to quit");
    bioskey(0);
}
