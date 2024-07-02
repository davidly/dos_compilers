/* PIXEL.CPP--Example from Chapter 5 of User's Guide */

// PIXEL.CPP demonstrates the Point and Location classes
// compile with POINT2.CPP and link with GRAPHICS.LIB

#include <graphics.h>   // declarations for graphics library
#include <conio.h>      // for getch() function
#include "point.h"      // declarations for Point and Location classes

int main()
{
   // initialize the graphics system
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "..\\bgi");

   // move a point across the screen
   Point APoint(100, 50);   // Initial X, Y at 100, 50
   APoint.Show();           // APoint turns itself on
   getch();                 // Wait for keypress
   APoint.MoveTo(300, 150); // APoint moves to 300,150
   getch();                 // Wait for keypress
   APoint.Hide();           // APoint turns itself off
   getch();                 // Wait for keypress
   closegraph();            // Restore original screen
   return 0;
}
