// figures.h contains three classes.
//
//  Class Location describes screen locations in X and Y
//  coordinates.
//
//  Class Point describes whether a point is hidden or visible.
//
//  Class Circle describes the radius of a circle around a point.
//
// To use this module, put #include <figures.h> in your main
// source file and compile the source file FIGURES.CPP together
// with your main source file.

enum Boolean {false, true};

class Location {
protected:
   int X;
   int Y;
public:
   Location(int InitX, int InitY) {X = InitX; Y = InitY;}
   int GetX() {return X;}
   int GetY() {return Y;}
};

class Point : public Location {
protected:
   Boolean Visible;
public:
   Point(int InitX, int InitY);
   virtual void Show();       // Show and Hide are virtual
   virtual void Hide();
   virtual void Drag(int DragBy); // new virtual drag function
   Boolean IsVisible() {return Visible;}
   void MoveTo(int NewX, int NewY);
};

class Circle : public Point {  // Derived from class Point and
                               // ultimately from class Location
protected:
   int Radius;
public:
   Circle(int InitX, int InitY, int InitRadius);
   void Show();
   void Hide();
   void Expand(int ExpandBy);
   void Contract(int ContractBy);
};

// prototype of general-purpose, non-member function
// defined in FIGURES.CPP

Boolean GetDelta(int& DeltaX, int& DeltaY);