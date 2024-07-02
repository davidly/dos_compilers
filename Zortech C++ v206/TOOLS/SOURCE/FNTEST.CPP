#include <stream.hpp>
#include <io.h>
#include <fname.hpp>

char *errmess[] = {
    "Drive letter out of range",
    "Drive specifier incorrect",
    "Path > 64 characters",
    "Directory names 8 chars only",
    "File name too long",
    "Extension too long",
    "Illegal character"
};

main(int argc, char *argv[])
{
    filename f;
    int x;
    long len;

    if (argc > 1) {
        if ((x = f.parse(argv[1])) != 0)
            cerr << errmess[x-1];
        else {
            len = filesize(f());
            if (len >= 0L)
                cout << "File length is " << len << "\n";
            else
                cout << "File does not exist";
        }
    } else
        cerr << "test program takes a file name argument - bad or good!";
}
