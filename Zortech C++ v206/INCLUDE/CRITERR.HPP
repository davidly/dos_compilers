#ifndef CRITERRHPP
#define CRITERRHPP
#include <int.h>

enum { CE_IGNORE, CE_RETRY, CE_ABORT };

class ce_handler {
    int (* predecessor)(int, int);
    void previous();
public:
    ce_handler(int (* user_handler)(int,int));
    ~ce_handler() { previous(); }
};
#endif
