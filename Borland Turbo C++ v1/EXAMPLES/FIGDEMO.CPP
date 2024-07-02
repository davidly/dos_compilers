// FIGDEMO.CPP -- Exercise for Chapter 5

// demonstrates the Figures toolbox by extending it with
// a new type Arc.

// Link with FIGURES.OBJ and GRAPHICS.LIB

#include "figures.h"
#include <graphics.h>
#include <conio.h>

class Arc : public Circle {
   int StartAngle;
   int EndAngle;
public:
// constructor
   Arc(int InitX, int InitY, int InitRadius, int InitStartAngle, int
       InitEndAngle) : Circle (InitX, InitY, InitRadius) {
       StartAngle = InitStartAngle; EndAngle = InitEndAngle;}
   void Show();  // these functions are virtual in Point
   void Hide();
};

// Member functions for Arc

void Arc::Show() 
{
   Visible = true;
   arc(X, Y, StartAngle, EndAngle, Radius);
}

void Arc::Hide()
{
   int TempColor;
   TempColor = getcolor();
   setcolor (getbkcolor());
   Visible = false;
   // draw arc in background color to hide it
   arc(X, Y, StartAngle, EndAngle, Radius);
   setcolor(TempColor);
}

int main()   // test the new Arc class
{
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "..\\bgi");
   Circle ACircle(151, 82, 50);
   Arc AnArc(151, 82, 25, 0, 190);

   // you first drag an arc using arrow keys (5 pixels per key)
   // press Enter when tired of this!
   // Now drag a circle (10 pixels per arrow key)
   // Press Enter to end FIGDEMO.

   AnArc.Drag(5);   // drag increment is 5 pixels
   AnArc.Hide();
   ACircle.Drag(10); // now each drag is 10 pixels
   closegraph();
   return 0;
}
