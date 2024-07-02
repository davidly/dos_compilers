#include <stream.hpp>
#include <stdlib.h>

int _allocerr = 0;

void default_error(int n,char *s)
{
    cerr << "(" << n << ") " << s << "\n";
    exit(1);
}
