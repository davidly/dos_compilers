// ex8.cpp:   Using the Stack Class
// from Chapter 6 of User's Guide
#include "stack.h"

main()
{
   Stack s(5);
   int i = 0;

   // Insert the numbers 1 through 5
   while (s.push(i+1) == 0)
      ++i;

   s.print();
}
