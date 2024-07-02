// File Vectest.cpp
///////////////////////////////////////
// This is a test of the Vector data type

#include <stream.hpp>
#include "vector.hpp"

main()
{

	Vector a(4), b;

	a[0] = 1;
	a[1] = 2;
	a[2] = -5;
	a[3] = a[2];

	for (int i = 0; i < a.ub()+1; i++)
		cout << "a[" << i << "] = " << a[i] << "\n";

	b = a;

	for (i = 0; i < b.ub()+1; i++)
		cout << "b[" << i << "] = " << b[i] << "\n";

	Vector c = a;

	for (i = 0; i < c.ub()+1; i++)
		cout << "c[" << i << "] = " << c[i] << "\n";


	c = a + b;

	for (i = 0; i < c.ub()+1; i++)
		cout << "c[" << i << "] = " << c[i] << "\n";


	b[5] = a[5];
	cout << "done\n";
}

