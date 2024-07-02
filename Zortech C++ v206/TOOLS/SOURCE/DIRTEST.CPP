#include <stream.hpp>
#include <dir.hpp>

main()
{
    directory cd;
    pfinf p;

    for (p = cd.first(); p; p = cd.next())
        cout << p->name << "\n";
    cout << "\n" << cd.count << " Files in all\n";
}
