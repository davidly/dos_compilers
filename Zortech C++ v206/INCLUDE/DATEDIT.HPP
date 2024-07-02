#ifndef DATEDITHPP
#define DATEDITHPP
#include "sedit.hpp"
#include <ctype.h>
#define BS 0x0e08
#define DEL 0x5300
#define LCUR 0x4b00
#define RCUR 0x4d00
#define RET 0x1c0d

extern int _usdate;

class date_editor : public string_editor {
    char loc[7];
    int month() { return _usdate? (10*(loc[0]-'0')+loc[1] - '0'):
                        (10*(loc[2]-'0')+loc[3]-'0'); }
    int day() { return _usdate? (10*(loc[2]-'0') + loc[3] - '0'):
                        (10*(loc[0]-'0')+loc[1]-'0'); }
    int year() { return 10*(loc[4]-'0') + loc[5] -'0'; }
public:
    date_editor() : (6,0) {}
    int filter(char, char *, int);
    int convertor(int k, char* s, int pos) {
        if (k == BS) k = LCUR;  if (k == DEL) k = RCUR;
        if (k == RET && strlen(s) < 6) k = 0;
        return k;
    }
};
#endif
