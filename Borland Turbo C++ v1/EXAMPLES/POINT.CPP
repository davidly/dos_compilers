/* POINT.CPP illustrates a simple Point class */

#include <iostream.h>	// needed for C++ I/O

class Point {		// define Point class
   int X;               // X and Y are private by default
   int Y;
public:
   Point(int InitX, int InitY) {X = InitX; Y = InitY;}
   int GetX() {return X;}  // public member functions
   int GetY() {return Y;}
};

int main()
{
   int YourX, YourY;

   cout << "Set X coordinate: ";  // screen prompt
   cin >> YourX;                  // keyboard input to YourX

   cout << "Set Y coordinate: ";  // another prompt
   cin >> YourY;                  // key value for YourY

   Point YourPoint(YourX, YourY);  // declaration calls constructor

   cout << "X is " << YourPoint.GetX(); // call member function
   cout << '\n';                        // newline
   cout << "Y is " << YourPoint.GetY(); // call member function
   cout << '\n';
   return 0;
}


