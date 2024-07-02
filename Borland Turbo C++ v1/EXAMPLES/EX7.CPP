// ex7.cpp:   Using the List class
// from Chapter 6 of User's Guide
#include "list.h"

main()
{
   List l(5);
   int i = 0;

   // Insert the numbers 1 through 5
   while (l.put_elem(i+1,i) == 0)
      ++i;
   l.setn(i);

   l.print();
}
