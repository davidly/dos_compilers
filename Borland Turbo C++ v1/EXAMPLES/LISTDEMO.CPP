/* LISTDEMO.CPP--Example from Chapter 5 of User's Guide */

// LISTDEMO.CPP           Demonstrates dynamic objects

// Link with FIGURES.OBJ and GRAPHICS.LIB

#include <conio.h>          // for getch()
#include <alloc.h>          // for coreleft()
#include <stdlib.h>         // for itoa()
#include <string.h>         // for strcpy()
#include <graphics.h>
#include "figures.h"

class Arc : public Circle {
   int StartAngle, EndAngle;
public:
   // constructor
   Arc(int InitX, int InitY, int InitRadius, int InitStartAngle,
       int InitEndAngle);
   // virtual functions
   void Show();
   void Hide();
};

struct Node {     // the list item
   Point *Item;   // can be Point or any class derived from Point
   Node  *Next;   // point to next Node object
};

class List {      // the list of objects pointed to by nodes
   Node *Nodes;   // points to a node
public:
   // constructor
   List();
   // destructor
   ~List();
   // add an item to list
   void Add(Point *NewItem);
   // list the items
   void Report();
};

// definitions for standalone functions

void OutTextLn(char *TheText)
{
   outtext(TheText);
   moveto(0, gety() + 12);   // move to equivalent of next line
}

void MemStatus(char *StatusMessage)
{
   unsigned long MemLeft;  // to match type returned by
			   // coreleft()
   char CharString[12];    // temp string to send to outtext()
   outtext(StatusMessage);
   MemLeft = long (coreleft());

   // convert result to string with ltoa then copy into
   // temporary string
   ltoa(MemLeft, CharString, 10);
   OutTextLn(CharString);
}

// member functions for Arc class

Arc::Arc(int InitX, int InitY, int InitRadius, int InitStartAngle,
         int InitEndAngle) : Circle (InitX, InitY,InitRadius)
                              // calls Circle
                              // constructor
{
   StartAngle = InitStartAngle;
   EndAngle = InitEndAngle;
}

void Arc::Show()
{
   Visible = true;
   arc(X, Y, StartAngle, EndAngle, Radius);
}

void Arc::Hide()
{
   unsigned TempColor;
   TempColor = getcolor();
   setcolor(getbkcolor());
   Visible = false;
   arc(X, Y, StartAngle, EndAngle, Radius);
   setcolor(TempColor);
}

// member functions for List class

List::List () {
   Node *N;
   N = new Node;
   N->Item = NULL;
   N->Next = NULL;
   Nodes = NULL;             // sets node pointer to "empty"
                             // because nothing in list yet
}

List::~List()                // destructor
{
   while (Nodes != NULL) {   // until end of list
      Node *N = Nodes;       // get node pointed to
      delete(N->Item);       // delete item's memory
      Nodes = N->Next;       // point to next node
        delete N;            // delete pointer's memory
   };
}

void List::Add(Point *NewItem)
{
   Node *N;              // N is pointer to a node
   N = new Node;         // create a new node
   N->Item = NewItem;    // store pointer to object in node
   N->Next = Nodes;      // next item points to curent list pos
   Nodes = N;            // last item in list now points
                         // to this node
}

void List::Report()
{
   char TempString[12];
   Node *Current = Nodes;
   while (Current != NULL)
   {
      // get X value of item in current node and convert to string
      itoa(Current->Item->GetX(), TempString, 10);
      outtext("X = ");
      OutTextLn(TempString);
      // do the same thing for the Y value
      itoa(Current->Item->GetY(), TempString, 10);
      outtext("Y = ");
      OutTextLn(TempString);
      // point to the next node
      Current = Current->Next;
   };
}

void setlist(void);

// Main program
main()
{
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "..\\bgi");

   MemStatus("Free memory before list is allocated: ");
   setlist();
   MemStatus("Free memory after List destructor: ");
   getch();
   closegraph();
}

void setlist() {

   // declare a list (calls List constructor)
   List AList;

   // create and add several figures to the list
   Arc *Arc1 = new Arc(151, 82, 25, 200, 330);
   AList.Add(Arc1);
   MemStatus("Free memory after adding arc1: ");
   Circle *Circle1 = new Circle(200, 80, 40);
   AList.Add(Circle1);
   MemStatus("Free memory after adding circle1: ");
   Circle *Circle2 = new Circle(305, 136, 35);
   AList.Add(Circle2);
   MemStatus("Free memory after adding circle2: ");
   // traverse list and display X, Y of the list's figures
   AList.Report();
   // The 3 Alist nodes and the Arc and Circle objects will be
   // deallocated automatically by their destructors when they
   // go out of scope in main(). Arc and Circle use implicit
   // destructors in contrast to the explicit ~List destructor.
   // However, you could delete explicitly here if you wish:
   // delete Arc1; delete Circle1; delete Circle2;
   getch();   // wait for a keypress
   return;
}
