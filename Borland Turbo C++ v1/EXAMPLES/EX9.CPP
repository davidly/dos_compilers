// ex9.cpp:   Using the print() virtual function
// from Chapter 6 of User's Guide
#include <iostream.h>
#include "stack2.h"

main()
{
   Stack s(5);
   List l, *lp;
   int i = 0;

   // Insert the numbers 1 through 5 into the stack
   while (s.push(i+1) == 0)
      ++i;

   // Put a couple of numbers into the list
   l.put_elem(1,0);
   l.put_elem(2,1);
   l.setn(2);

   cout << "Stack:\n";
   lp = &s;           // line 22
   lp->print();       // Invoke the Stack print() method; line 23

   cout << "\nList:\n";
   lp = &l;
   lp->print();       // Invoke the List print() method; line 27
}
