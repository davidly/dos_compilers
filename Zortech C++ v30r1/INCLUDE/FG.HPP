//_ fg.hpp   Thu Sep 21 1989   Modified by: Walter Bright */
// Copyright (C) 1989 by Zortech, All Rights Reserved
// Written by Walter Bright
// Modified by Joe Huffman October 8, 1989
// Modified by Samuel Druker/Steve Teale October 14 1989

#ifndef __FG_HPP
#define __FG_HPP

#ifndef __FG_H
#include    <fg.h>
#endif

//////////////////////////////////////////
// Class representing the display itself.

class FgDisp
{
public:
    // Get pointer to a box describing the edges of the display
    static fg_const_pbox_t box()  { return fg.displaybox; }

    // Inquire about the coordinates of the edges of the display
    static fg_coord_t left()    { return fg.displaybox[FG_X1]; }
    static fg_coord_t right()   { return fg.displaybox[FG_X2]; }
    static fg_coord_t bottom()  { return fg.displaybox[FG_Y1]; }
    static fg_coord_t top()     { return fg.displaybox[FG_Y2]; }

    // Inquire about the height and width of the display
    static int height()     { return fg.displaybox[FG_Y2] + 1; }
    static int width()      { return fg.displaybox[FG_X2] + 1; }

    // Determine if point x,y is inside the display
    static int inside(fg_coord_t x, fg_coord_t y);

    // Inquire about the display type (FG_EGAECD, etc.)
    static int type()       { return fg.display; }

    // Clear the display (set it to color)
    static void clear(fg_color_t color = FG_BLACK);
};

//////////////////////////////////////////
// Root of all drawing objects

class Fg
{
public:

    // Drawing modes
    enum MODE { SET = FG_MODE_SET, XOR = FG_MODE_XOR };

    ///////////////////////////////////
    // Access functions.

    static int mode() { return _mode; }
    static int setmode(enum MODE newmode) { return _mode = newmode; }

    static int mask() { return _mask; }
    static int setmask(int newmask) { return _mask = newmask; }

    fg_color_t foreg() const { return curfg; }
    fg_color_t setdefforeg(fg_color_t dfg)
        { curfg = dfg; return _setdefforeg(dfg); }
    fg_color_t setforeg(fg_color_t fg) { return curfg = fg; }

    static fg_color_t backg() { return attrbg; }
    static fg_color_t setbackg(fg_color_t bg) { return attrbg = bg; }

    ///////////////////////////////////
    // Draw the object.
    // The drawing is not guaranteed to be complete until
    // fg_flush() is called.
    // Input:
    //  clip    Box against which to clip all output

    virtual void drawc(fg_const_pbox_t clip) = 0;
    virtual void draw();        // clip against edge of screen

    ///////////////////////////////////
    // Erase the object.

    virtual void erasec(fg_const_pbox_t clip) = 0;
    virtual void erase();       // clip against edge of screen

    ///////////////////////////////////
    // Translate the object, that is, move it by xoffset, yoffset.

    virtual void translate(fg_coord_t xoffset, fg_coord_t yoffset) = 0;

    // Constructors and destructors
    Fg();
    virtual ~Fg();

private:

    static int display;
    static MODE _mode; // drawing mode
    static int _mask;       // drawing mask
    fg_color_t curfg;       // color for this instance
    static fg_color_t deffg;    // default color
    static fg_color_t attrbg;   // background color
    static fg_color_t _setdefforeg(fg_color_t dfg)
        { return deffg = dfg; }
};

//////////////////// Dot //////////////////

class FgDot : public Fg
{
public:
    fg_coord_t setx(fg_coord_t x) { return _x = x; }
    fg_coord_t sety(fg_coord_t y) { return _y = y; }
    fg_coord_t x() const { return _x; }
    fg_coord_t y() const { return _y; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);
    virtual void translate(fg_coord_t xoffset, fg_coord_t yoffset);

    FgDot(fg_coord_t x, fg_coord_t y);

private:
    fg_coord_t _x,_y;
};

//////////////////// Line //////////////////

class FgLine : public Fg
{
public:
    fg_const_pline_t line() const { return _line; }

    fg_coord_t setx1(fg_coord_t x) { return _line[FG_X1] = x; }
    fg_coord_t sety1(fg_coord_t y) { return _line[FG_Y1] = y; }
    fg_coord_t setx2(fg_coord_t x) { return _line[FG_X2] = x; }
    fg_coord_t sety2(fg_coord_t y) { return _line[FG_Y2] = y; }
    fg_coord_t x1() { return _line[FG_X1]; }
    fg_coord_t y1() { return _line[FG_Y1]; }
    fg_coord_t x2() { return _line[FG_X2]; }
    fg_coord_t y2() { return _line[FG_Y2]; }

    static int type()		    { return _type; }
    static int settype(int type)    { return _type = type; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);
    virtual void translate(fg_coord_t xoffset, fg_coord_t yoffset);

    FgLine(fg_coord_t x1, fg_coord_t y1, fg_coord_t x2, fg_coord_t y2);
    FgLine(fg_const_pline_t pline);

protected:
    fg_line_t _line;
    static int _type;       // line style (FG_LINE_XXXX)
};

class FgThickLine : public FgLine {
public:
    int thickness() const { return _thickness; }
    int setthickness(int t) { return _thickness = t; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);
    virtual void translate(fg_coord_t xoffset, fg_coord_t yoffset);
    FgThickLine(fg_coord_t x1, fg_coord_t y1,
                    fg_coord_t x2, fg_coord_t y2, int t);
    FgThickLine(fg_const_pline_t pline, int t);
private:
    int _thickness;
};

//////////////////// Box //////////////////

class FgBox : public FgLine
{
    // This is nearly identical to the FgLine class, mostly we
    // just need to redefine the drawing functions.
public:
    fg_const_pbox_t box() const { return FgLine::line(); }

    fg_coord_t setleft(fg_coord_t x)    { return setx1(x); }
    fg_coord_t setbottom(fg_coord_t y)  { return sety1(y); }
    fg_coord_t setright(fg_coord_t x)   { return setx2(x); }
    fg_coord_t settop(fg_coord_t y) { return sety2(y); }
    fg_coord_t left()   { return x1(); }
    fg_coord_t bottom() { return y1(); }
    fg_coord_t right()  { return x2(); }
    fg_coord_t top()    { return y2(); }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgBox(fg_coord_t left, fg_coord_t bottom, fg_coord_t right, fg_coord_t top);
    FgBox(fg_const_pbox_t pbox);
};

//////////////////// FillBox //////////////////

class FgFillBox : public FgBox
{
    // This is nearly identical to the FgBox class, mostly we
    // just need to redefine the drawing functions.
public:
    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgFillBox(fg_coord_t left, fg_coord_t bottom, fg_coord_t right, fg_coord_t top);
    FgFillBox(fg_const_pbox_t pbox);

private:
    void drawfb(fg_const_pbox_t clip, fg_color_t color);
};

//////////////////// Char //////////////////

class FgChar : public FgDot // FgDot is the position of the lower left corner
{
public:
    char ch() const     { return _ch; }
    char setch(char ch) { return _ch = ch; }
    char rot() const    { return _rot; }
    char setrot(int rot){ return _rot = rot; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgChar(fg_coord_t x, fg_coord_t y, char ch, int rot = FG_ROT0);

private:
    int _rot;       // rotation (FG_ROT_XXX)
    char _ch;       // the char itself
};

//////////////////// Matrix //////////////////

class FgMatrix : public FgBox   // FgBox encloses the matrix
{
public:
    const char *matrix() const  { return _matrix; }
    const char *setmatrix(const char *matrix);
    char rot() const        { return _rot; }
    char setrot(int rot)    { return _rot = rot; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgMatrix(fg_coord_t x, fg_coord_t y, fg_const_pbox_t box, char *matrix, 
             int rot = FG_ROT0);
    FgMatrix(const FgMatrix&);
    FgMatrix& operator=(const FgMatrix&);
    ~FgMatrix();

private:
    int _rot;       // rotation (FG_ROT_XXX)
    char *_matrix;  // the matrix data
};

//////////////////// String //////////////////

class FgString : public FgDot // FgDot is the position of the lower left corner
{
public:
    char *string() const  { return _string; }
    char *setstring(char *string);
    char rot() const      { return _rot; }
    char setrot(int rot)  { return _rot = rot; }

    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgString(fg_coord_t x, fg_coord_t y, char *string, int rot = FG_ROT0);
    FgString(const FgString&);
    FgString& operator=(const FgString&);
    ~FgString();

private:
    int _rot;       // rotation (FG_ROT_XXX)
    char *_string;  // the string data
};


//////////////////// Circle //////////////////

class FgCircle : public FgDot
{
public:
    fg_coord_t setradius(fg_coord_t radius) {return _radius = radius;}
    fg_coord_t radius() const {return _radius;}
    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgCircle(fg_coord_t x, fg_coord_t y, fg_coord_t radius):FgDot(x,y)
    {
      setradius(radius);
    }

private:
    fg_coord_t _radius;
};


//////////////////// Arc //////////////////

class FgArc : public FgCircle
{
public:
    fg_coord_t setstart(fg_coord_t start) {return start_angle = start;}
    fg_coord_t setend(fg_coord_t end) {return end_angle = end;}
    fg_coord_t start() const {return start_angle;}
    fg_coord_t end() const {return end_angle;}
    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgArc(fg_coord_t x, fg_coord_t y, fg_coord_t radius, 
              fg_coord_t start, fg_coord_t end):FgCircle(x,y,radius)
    {
      setstart(start);
      setend(end);
    }

private:
    fg_coord_t start_angle, end_angle;
};


//////////////////// Ellipse //////////////////

class FgEllipse : public FgArc
{
public:
    fg_coord_t setxradius(fg_coord_t xrad) {return setradius(xrad);}
    fg_coord_t setyradius(fg_coord_t yrad) {return y_radius = yrad;}
    fg_coord_t xradius() const {return radius();}
    fg_coord_t yradius() const {return y_radius;}
    virtual void drawc(fg_const_pbox_t clip);
    virtual void erasec(fg_const_pbox_t clip);

    FgEllipse(fg_coord_t x, fg_coord_t y, fg_coord_t xradius, 
              fg_coord_t yradius, fg_coord_t start, fg_coord_t end)
              :FgArc(x,y,xradius,start,end)
    {
      setyradius(yradius);
    }

private:
    fg_coord_t y_radius;
};

//////////////////// Polygon //////////////////

class FgPolygon : public Fg
{
public:
  unsigned int vertices() const {return _vertices;}
  const fg_coord_t *polygon() const {return _poly;}
  const fg_coord_t *setpolygon(unsigned int vertices,const fg_coord_t *poly);
  void setvertex (unsigned int vertex,fg_coord_t x,fg_coord_t y);
  int type() const {return _type;}    // Line type to draw with.
  int settype(int type) {return _type = type;}
  virtual void drawc(fg_const_pbox_t clip);
  virtual void erasec(fg_const_pbox_t clip);
  virtual void translate(fg_coord_t xoffset, fg_coord_t yoffset);

  FgPolygon(unsigned int vertices, const fg_coord_t *poly = 0,
            int type = FG_LINE_SOLID);
  FgPolygon(const FgPolygon&);
  virtual FgPolygon& operator=(const FgPolygon&);
  ~FgPolygon();

private:
  fg_coord_t *_poly;
  unsigned int _vertices;
  static int _type;
};


//////////////////// Filled Polygon //////////////////

class FgFilledPolygon : public FgPolygon
{
public:

  virtual void drawc (fg_const_pbox_t clip);
  virtual void erasec(fg_const_pbox_t clip);
  FgFilledPolygon (unsigned int vertices, const fg_coord_t *poly)
    : FgPolygon (vertices, poly) {}
  FgFilledPolygon(const FgFilledPolygon &a)
    : FgPolygon(a) {}
};

#endif /* __FG_HPP */

