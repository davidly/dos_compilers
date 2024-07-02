// ex3.cpp:   Inline Functions
// from Chapter 6 of User's Guide
#include <iostream.h>

const float Pi = 3.1415926;

inline float area(const float r) {return Pi * r * r;}

main()
{
   float radius;

   cout << "Enter the radius of a circle: ";
   cin >> radius;
   cout << "The area is " << area(radius) << "\n";
}
