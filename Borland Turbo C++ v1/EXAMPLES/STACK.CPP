// stack.cpp:   Implementation of the Stack class
// from Chapter 6 of User's Guide
#include <iostream.h>
#include "stack.h"

int Stack::push(int elem)
{
   int m = getmax();
   if (top < m)
   {
      put_elem(elem,top++);
      return 0;
   }
   else
      return -1;
}

int Stack::pop(int& elem)
{
   if (top > 0)
   {
      get_elem(elem,--top);
      return 0;
   }
   else
      return -1;
}

void Stack::print()
{
   int elem;

   for (int i = top-1; i >= 0; --i)
   {  // Print in LIFO order
      get_elem(elem,i);
      cout << elem << "\n";
   }
}
