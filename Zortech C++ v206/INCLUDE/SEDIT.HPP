#ifndef STREDITHPP
#define STREDITHPP
#include <ctype.h>
#include <bios.h>
#include <string.h>
#include <dos.h>
#include "errn.hpp"

#define WHOKNOWS -1

class string_editor {
    char *local;                // saves a copy of the string as was
    int insert;                 // insert or overtype?
public:
    int maxlength;              // of string when editing
    int howlong, where;         // reporting variables
    virtual int command_source(void) { return bioskey(0); }
    virtual int filter(char c, char *s, int pos)
        { return isprint(c); }
    virtual int convertor(int k, char *s, int pos) { return k; }
    string_editor(int = 79, int = 1);
    int edit(int, int, char *, int = 0, int = 0, int = 0);
    ~string_editor() { delete local; }
};
#endif
