// stack.cpp:     Implementation of the Stack class

#include <iostream.h>
#include "stack2.h"

int Stack::push(int elem)
{
   if (top < nmax)
   {
      list[top++] = elem;
      return 0;
   }
   else
      return -1;
}

int Stack::pop(int& elem)
{
   if (top > 0)
   {
      elem = list[--top];
      return 0;
   }
   else
      return -1;
}

void Stack::print()
{
   for (int i = top-1; i >= 0; --i)
      cout << list[i] << "\n";
}
