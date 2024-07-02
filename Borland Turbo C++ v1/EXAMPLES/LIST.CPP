// list.cpp:   Implementation of the List Class
// from Chapter 6 of User's Guide
#include <iostream.h>
#include "list.h"

int List::put_elem(int elem, int pos)
{
   if (0 <= pos && pos < nmax)
   {
      list[pos] = elem;    // Put an element into the list
      return 0;
   }
   else
      return -1;           // Non-zero means error
}

int List::get_elem(int& elem, int pos)
{
   if (0 <= pos && pos < nmax)
   {
      elem = list[pos];    // Retrieve a list element
      return 0;
   }
   else
      return -1;           // non-zero means error
}

void List::print()
{
   for (int i = 0; i < nelem; ++i)
      cout << list[i] << "\n";
}
