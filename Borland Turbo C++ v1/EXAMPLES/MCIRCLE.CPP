/* MCIRCLE.CPP--Example for Chapter 5 of User's Guide */

// MCIRCLE.CPP        Illustrates multiple inheritance

#include <graphics.h> // Graphics library declarations
#include "point.h"    // Location and Point class declarations
#include <string.h>   // for string functions
#include <conio.h>    // for console I/O

// link with point2.obj and graphics.lib

// The class hierarchy:
// Location->Point->Circle
// (Circle and CMessage)->MCircle

class Circle : public Point {  // Derived from class Point and ultimately
			       // from class Location
protected:
   int Radius;
public:
   Circle(int InitX, int InitY, int InitRadius);
   void Show(void);
};


class GMessage : public Location {
// display a message on graphics screen
   char *msg;               // message to be displayed
   int Font;                // BGI font to use
   int Field;               // size of field for text scaling

public:
   // Initialize message
   GMessage(int msgX, int msgY, int MsgFont, int FieldSize,
            char *text);
   void Show(void);         // show message
};


class MCircle : Circle, GMessage {  // inherits from both classes
public:
   MCircle(int mcircX, int mcircY, int mcircRadius, int Font,
           char *msg);
   void Show(void);                 // show circle with message
};


// Member functions for Circle class

//Circle constructor
Circle::Circle(int InitX, int InitY, int InitRadius) :
	Point (InitX, InitY)        // initialize inherited members
//also invokes Location constructor
{
   Radius = InitRadius;
};

void Circle::Show(void)
{
   Visible = true;
   circle(X, Y, Radius); // draw the circle
}

// Member functions for GMessage class

//GMessage constructor
GMessage::GMessage(int msgX, int msgY, int MsgFont,
		   int FieldSize, char *text) :
		   Location(msgX, msgY)
//X and Y coordinates for centering message
{
   Font = MsgFont;    // standard fonts defined in graph.h
   Field = FieldSize; // width of area in which to fit text
   msg = text;        // point at message
};

void GMessage::Show(void)
{
   int size = Field / (8 * strlen(msg));     // 8 pixels per char.
   settextjustify(CENTER_TEXT, CENTER_TEXT); // centers in circle
   settextstyle(Font, HORIZ_DIR, size);      // if size > 1, magnifies
   outtextxy(X, Y, msg);                     // display the text
}

//Member functions for MCircle class

//MCircle constructor
MCircle::MCircle(int mcircX, int mcircY, int mcircRadius, int Font,
		 char *msg) : Circle (mcircX, mcircY, mcircRadius),
		 GMessage(mcircX,mcircY,Font,2*mcircRadius,msg)
{
}

void MCircle::Show(void)
{
   Circle::Show();
   GMessage::Show();
}

main()      //draws some circles with text
{
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "..\\bgi");
   MCircle Small(250, 100, 25, SANS_SERIF_FONT, "You");
   Small.Show();
   MCircle Medium(250, 150, 100, TRIPLEX_FONT, "World");
   Medium.Show();
   MCircle Large(250, 250, 225, GOTHIC_FONT, "Universe");
   Large.Show();
   getch();
   closegraph();
   return 0;
}
