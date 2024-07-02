// list.h:   A Integer List Class
// from Chapter 6 of User's Guide
const int Max_elem = 10;

class List
{
   int *list;        // An array of integers
   int nmax;         // The dimension of the array
   int nelem;        // The number of elements

public:
   List(int n = Max_elem) {list = new int[n]; nmax = n; nelem = 0;};
   ~List() {delete list;};
   int put_elem(int, int);
   int get_elem(int&, int);
   void setn(int n) {nelem = n;};
   int getn() {return nelem;};
   void incn() {if (nelem < nmax) ++nelem;};
   int getmax() {return nmax;};
   void print();
};
