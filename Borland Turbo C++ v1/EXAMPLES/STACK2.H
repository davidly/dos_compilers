// stack2.h:   A Stack class derived from the List class
// from Chapter 6 of User's Guide
#include "list2.h"

class Stack : public List                  // line 5
{
   int top;

public:
   Stack() {top = 0;};
   Stack(int n) : List(n) {top = 0;};      // line 11
   int push(int elem);
   int pop(int& elem);
   void print();
};
