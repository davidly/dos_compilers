// FIGURES.CPP: This file contains the definitions for the Point
// class (declared in figures.h). Member functions for the
// Location class appear as inline functions in figures.h.

#include "figures.h"
#include <graphics.h>
#include <conio.h>

// member functions for the Point class

//constructor
Point::Point(int InitX, int InitY) : Location (InitX, InitY)
{
   Visible = false;    // make invisible by default
}

void Point::Show()
{
   Visible = true;
   putpixel(X, Y, getcolor()); // uses default color
}

void Point::Hide()
{
   Visible = false;
   putpixel(X, Y, getbkcolor()); // uses background color to erase
}

void Point::MoveTo(int NewX, int NewY)
{
   Hide();          // make current point invisible
   X = NewX;        // change X and Y coordinates to new location
   Y = NewY;
   Show();          // show point at new location
}

// a general-purpose function for getting keyboard
// cursor movement keys (not a member function)

Boolean GetDelta(int& DeltaX, int& DeltaY)
{
   char KeyChar;
   Boolean Quit;
   DeltaX = 0;
   DeltaY = 0;

   do
{
      KeyChar = getch();     // read the keystroke
      if (KeyChar == 13)     // carriage return
         return(false);
      if (KeyChar == 0)      // an extended keycode
         {
          Quit = true;       // assume it is usable
          KeyChar = getch(); // get rest of keycode
              switch (KeyChar) {
                 case 72: DeltaY = -1; break; // down arrow
                 case 80: DeltaY =  1; break; // up arrow
                 case 75: DeltaX = -1; break; // left arrow
                 case 77: DeltaX =  1; break; // right arrow
                 default: Quit = false; // bad key
                 };
         };
   } while (!Quit);
   return(true);
}

void Point::Drag(int DragBy)
{
   int DeltaX, DeltaY;
   int FigureX, FigureY;

   Show(); // display figure to be dragged
     FigureX = GetX(); // get initial position of figure
   FigureY = GetY();

   // This is the drag loop
   while (GetDelta(DeltaX, DeltaY))
{
      // Apply delta to figure at X, Y
      FigureX += (DeltaX * DragBy);
      FigureY += (DeltaY * DragBy);
      MoveTo(FigureX, FigureY); // tell figure to move
      };
}
// Member functions for the Circle class

//constructor
Circle::Circle(int InitX, int InitY, int InitRadius) : Point (InitX, InitY)
{
   Radius = InitRadius;
}

void Circle::Show()
{
   Visible = true;
   circle(X, Y, Radius);     // draw the circle
}

void Circle::Hide()
{
   unsigned int TempColor;   // to save current color
   TempColor = getcolor();   // set to current color
   setcolor(getbkcolor());   // set drawing color to background
   Visible = false;
   circle(X, Y, Radius);     // draw in background color to
   setcolor(TempColor);      // set color back to current color
}

void Circle::Expand(int ExpandBy)
{
   Hide();                       // erase old circle
   Radius += ExpandBy;           // expand radius
   if (Radius < 0)               // avoid negative radius
      Radius = 0;
   Show();                       // draw new circle
}

void Circle::Contract(int ContractBy)
{
   Expand(-ContractBy);      // redraws with (Radius-ContractBy)
}
