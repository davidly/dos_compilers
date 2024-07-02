// stack2.h:    A Stack class derived from the List class

#include "list.h"

class Stack : public List
{
   int top;

public:
   Stack() {top = 0;};
   Stack(int n) : List(n) {top = 0;};
   int push(int elem);
   int pop(int& elem);
   void print();
};
