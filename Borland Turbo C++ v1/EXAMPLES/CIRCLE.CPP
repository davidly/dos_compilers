/* CIRCLE.CPP--Example from Chapter 5 of User's Guide */

// CIRCLE.CPP   A Circle class derived from Point

#include <graphics.h>    // graphics library declarations
#include "point.h"       // Location and Point class declarations
#include <conio.h>       // for getch() function

// link with point2.obj and graphics.lib

class Circle : Point {   // derived privately from class Point
			 // and ultimately from class Location
   int Radius;           // private by default

public:
   Circle(int InitX, int InitY, int InitRadius);
   void Show(void);
   void Hide(void);
   void Expand(int ExpandBy);
   void MoveTo(int NewX, int NewY);
   void Contract(int ContractBy);
};

Circle::Circle(int InitX, int InitY, int InitRadius) : Point(InitX,InitY)
{
   Radius = InitRadius;
};

void Circle::Show(void)
{
   Visible = true;
   circle(X, Y, Radius);      // draw the circle
}

void Circle::Hide(void)
{
   unsigned int TempColor;    // to save current color
   TempColor = getcolor();    // set to current color
   setcolor(getbkcolor());    // set drawing color to background
   Visible = false;
   circle(X, Y, Radius);      // draw in background color to erase
   setcolor(TempColor);       // set color back to current color
};

void Circle::Expand(int ExpandBy)
{
   Hide();                       // erase old circle
   Radius += ExpandBy;           // expand radius
   if (Radius < 0)               // avoid negative radius
      Radius = 0;
   Show();                       // draw new circle
};

void Circle::Contract(int ContractBy)
{
   Expand(-ContractBy);       // redraws with (Radius - ContractBy)
};

void Circle::MoveTo(int NewX, int NewY)
{
   Hide();                    // erase old circle
   X = NewX;                  // set new location
   Y = NewY;
   Show();                    // draw in new location
};

main()                        // test the functions
{
   // initialize the graphics system
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "..\\bgi");

   Circle MyCircle(100, 200, 50);   // declare a circle object
   MyCircle.Show();                 // show it
   getch();                         // wait for keypress
   MyCircle.MoveTo(200, 250);       // move the circle (tests hide
                                    // and show also)
   getch();
   MyCircle.Expand(50);             // make it bigger
   getch();
   MyCircle.Contract(75);           // make it smaller
   getch();
   closegraph();
   return 0;
}
