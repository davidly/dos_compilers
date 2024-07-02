#include <stdio.h>
#include <string.h>
#include <disp.h>
#include <text.hpp>

main()
{
    FILE *fp;
    char buf[82], *p = buf;
    disp_open();
    disp_box(0,7,3,3,21,61);
    text ct(4,4,20,60,7);
    fp = fopen("test.txt","r");
    while (fgets(buf,80,fp)) {
        p = strchr(buf,'\n');
        *p = '\0';
        if (!ct.addline(buf))
            exit(1);
    }
    ct.topof();
    ct.textedit();
    disp_move(0,0);
    disp_eeop();
    ct.moveit(2,10);
    disp_box(0,7,1,9,19,67);
    ct.getline(2);
    ct.repaint(0);
    int n = ct.textedit();
    disp_move(24,0);
    disp_printf(
"Make sure printer is ready - %u lines of text created - press a key",n);
    bioskey(0);
    pline q;
    while ((q = ct.extract()) != NULL) {
        fprintf(stdprn,"%s\n",q->body);
        delete q;
    }
    disp_move(0,0);
    disp_eeop();
    disp_close();
}
