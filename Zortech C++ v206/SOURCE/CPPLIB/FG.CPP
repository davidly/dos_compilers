//_ fg.cpp   Thu Sep 21 1989   Modified by: Walter Bright */
// Copyright (C) 1989 by Zortech, All Rights Reserved
// Written by Walter Bright
// Modified by Joe Huffman October 8, 1989
// Modified by Sam Drucker/Steve Teale October 14 1989


#include    <string.h>
#include    <stdlib.h>
#include    <fg.hpp>

////////////// Implementation of FgDisp //////////////////

int FgDisp::inside(fg_coord_t x, fg_coord_t y)
{
    return
    FgDisp::left() <= x && x <= FgDisp::right() &&
    FgDisp::bottom() <= y && y <= FgDisp::top();
}

void FgDisp::clear(fg_color_t color)
{
    fg_fillbox(color,FG_MODE_SET,~0,box());
}

////////////// Implementation of Fg //////////////////

int Fg::display = FG_NULL;
enum MODE Fg::_mode = Fg::SET;
int Fg::_mask = ~0;     // write across all bit planes

// The colors cannot really be initialized until fg_init is called.
// But we'll fake it here with values that have a good chance of
// working on a monochrome screen.
fg_color_t Fg::attrfg = 1;      // white
fg_color_t Fg::attrbg = 0;      // black

void Fg::draw()
{
    drawc(FgDisp::box());
}

void Fg::erase()
{
    erasec(FgDisp::box());
}

///////////////////////////////////
// The explicit constructor is needed so the compiler won't implicitly generate
// one, and spray vtbls all over the place.
// We also use it to set some default colors.

Fg::Fg()
{
    if (display != FgDisp::type())       // if display has changed
    {
    // User can change these values later
      Fg::setbackg(FG_BLACK);
      Fg::_setdefforeg(FG_LIGHT_WHITE);
      display = FgDisp::type();
    }
    setforeg(deffg);
}

Fg::~Fg()
{
}

////////////// Implementation of FgDot //////////////////

void FgDot::drawc(fg_const_pbox_t clip)
{
    if (clip[FG_X1] <= x() && x() <= clip[FG_X2] &&
    clip[FG_Y1] <= y() && y() <= clip[FG_Y2])
    fg_drawdot(foreg(),mode(),mask(),x(),y());
}

void FgDot::erasec(fg_const_pbox_t clip)
{
    if (clip[FG_X1] <= x() && x() <= clip[FG_X2] &&
    clip[FG_Y1] <= y() && y() <= clip[FG_Y2])
    fg_drawdot(backg(),mode(),mask(),x(),y());
}

void FgDot::translate(fg_coord_t xoffset, fg_coord_t yoffset)
{
    setx(x() + xoffset);
    sety(y() + yoffset);
}

FgDot::FgDot(fg_coord_t x, fg_coord_t y)
{
    _x = x;
    _y = y;
}

////////////// Implementation of FgLine //////////////////

int FgLine::_type = FG_LINE_SOLID;

void FgLine::drawc(fg_const_pbox_t clip)
{
    fg_drawlineclip(foreg(),mode(),mask(),type(),line(),clip);
}

void FgLine::erasec(fg_const_pbox_t clip)
{
    fg_drawlineclip(backg(),mode(),mask(),type(),line(),clip);
}

void FgLine::translate(fg_coord_t xoffset, fg_coord_t yoffset)
{
    setx1(x1() + xoffset);
    sety1(y1() + yoffset);
    setx2(x2() + xoffset);
    sety2(y2() + yoffset);
}

FgLine::FgLine(fg_coord_t x1, fg_coord_t y1, fg_coord_t x2, fg_coord_t y2)
{
    setx1(x1);
    sety1(y1);
    setx2(x2);
    sety2(y2);
}

FgLine::FgLine(fg_const_pline_t pline)
{
    fg_line_cpy(_line,pline);
}

void FgThickLine::drawc(fg_const_pbox_t clip)
{
    fg_drawthickline(foreg(),mode(),mask(),
            type(),line(),clip,_thickness);
}

void FgThickLine::erasec(fg_const_pbox_t clip)
{
    fg_drawthickline(backg(),mode(),mask(),
            type(),line(),clip,_thickness);
}

void FgThickLine::translate(fg_coord_t xoffset, fg_coord_t yoffset)
{
    setx1(x1() + xoffset);
    sety1(y1() + yoffset);
    setx2(x2() + xoffset);
    sety2(y2() + yoffset);
}

FgThickLine::FgThickLine(fg_coord_t x1, fg_coord_t y1,
                             fg_coord_t x2, fg_coord_t y2, int t)
    : (x1, y1, x2, y2)
{
    _thickness = t;
}

FgThickLine::FgThickLine(fg_const_pline_t pline, int t)
    : (pline)
{
    _thickness = t;
}

////////////// Implementation of FgBox //////////////////

void FgBox::drawc(fg_const_pbox_t clip)
{
    fg_drawbox(foreg(),mode(),mask(),type(),box(),clip);
}

void FgBox::erasec(fg_const_pbox_t clip)
{
    fg_drawbox(backg(),mode(),mask(),type(),box(),clip);
}

FgBox::FgBox(fg_coord_t left, fg_coord_t bottom, fg_coord_t right, fg_coord_t top)
    : FgLine(left,bottom,right,top)
{
}

FgBox::FgBox(fg_const_pbox_t pbox) : FgLine(pbox)
{
}

////////////// Implementation of FgFillBox //////////////////

////////////////////////////////////
// Utility routine to handle clipping of a filled box.

static void FgFillBox::drawfb(fg_const_pbox_t clip, fg_color_t color)
{   fg_box_t b;

    b[FG_X1] = left() < clip[FG_X1] ? clip[FG_X1] : left();
    b[FG_Y1] = bottom() < clip[FG_Y1] ? clip[FG_Y1] : bottom();
    b[FG_X2] = right() < clip[FG_X2] ? right() : clip[FG_X2];
    b[FG_Y2] = top() < clip[FG_Y2] ? top() : clip[FG_Y2];
    if (b[FG_X1] <= b[FG_X2] &&
    b[FG_Y1] <= b[FG_Y2])
    fg_fillbox(color,mode(),mask(),b);
}

void FgFillBox::drawc(fg_const_pbox_t clip)
{
    drawfb(clip,foreg());
}

void FgFillBox::erasec(fg_const_pbox_t clip)
{
    drawfb(clip,backg());
}

FgFillBox::FgFillBox(fg_coord_t left, fg_coord_t bottom, fg_coord_t right, fg_coord_t top)
    : FgBox(left,bottom,right,top)
{
}

FgFillBox::FgFillBox(fg_const_pbox_t pbox) : FgBox(pbox)
{
}

////////////// Implementation of FgChar //////////////////

void FgChar::drawc(fg_const_pbox_t clip)
{
    fg_putc(foreg(),mode(),mask(),rot(),x(),y(),ch(),clip);
}

void FgChar::erasec(fg_const_pbox_t clip)
{
    fg_putc(backg(),mode(),mask(),rot(),x(),y(),ch(),clip);
}

FgChar::FgChar(fg_coord_t x, fg_coord_t y, char ch, int rot) : FgDot(x,y)
{
    setch(ch);
    setrot(rot);
}


////////////// Implementation of FgMatrix //////////////////

void FgMatrix::drawc(fg_const_pbox_t clip)
{   fg_box_t b;

    b[FG_X1] = 0;
    b[FG_Y1] = 0;
    b[FG_X2] = right() - left();
    b[FG_Y2] = top() - bottom();
    fg_drawmatrix(foreg(),mode(),mask(),rot(),left(),bottom(),
                  (char far *) matrix(), b, clip);
}

void FgMatrix::erasec(fg_const_pbox_t clip)
{   fg_box_t b;

    b[FG_X1] = 0;
    b[FG_Y1] = 0;
    b[FG_X2] = right() - left();
    b[FG_Y2] = top() - bottom();
    fg_drawmatrix(backg(),mode(),mask(),rot(),left(),bottom(),
                  (char far *) matrix(), b, clip);
}

FgMatrix::FgMatrix(fg_coord_t x, fg_coord_t y, fg_const_pbox_t box, 
                   char *matrix, int rot)
    : FgBox(box)
{
    _matrix = 0;
    translate(x,y);
    setmatrix(matrix);
    setrot(rot);
}

FgMatrix::FgMatrix(const FgMatrix& a)
    : FgBox(a.box())
{
    _rot = a._rot;
    _matrix = new char[fg_matrix_size(box())];
    if (_matrix)
        memcpy (_matrix, a._matrix, fg_matrix_size(box()));
}

FgMatrix& FgMatrix::operator=(const FgMatrix &a)
{
    if (this == (FgMatrix *) &a)
        return *this;
    *((FgBox *) this) = a;
    delete _matrix;
    _matrix = new char[fg_matrix_size(box())];
    if (_matrix)
        memcpy (_matrix, a._matrix, fg_matrix_size(box()));
    return *this;
}
    

const char *FgMatrix::setmatrix(const char *matrix)
{
  delete _matrix;
  _matrix = new char[fg_matrix_size (box())];

  if (_matrix)
    memcpy (_matrix, matrix, fg_matrix_size(box()));

  return _matrix;
}

FgMatrix::~FgMatrix()
{
    delete _matrix;
}


////////////// Implementation of FgString //////////////////

char *FgString::setstring(char *string)
{
    delete _string;      // dump any previous string
    _string = new char[strlen(string)+1];
    if (_string)
        strcpy(_string,string);
}

void FgString::drawc(fg_const_pbox_t clip)
{
    fg_puts(foreg(),mode(),mask(),rot(),x(),y(),string(),clip);
}

void FgString::erasec(fg_const_pbox_t clip)
{
    fg_puts(backg(),mode(),mask(),rot(),x(),y(),string(),clip);
}

FgString::FgString(fg_coord_t x, fg_coord_t y, char *string, int rot)
    : FgDot(x,y)
{
    _string = NULL;     // eliminate garbage value
    setstring(string);
    setrot(rot);
}

FgString::FgString(const FgString &a)
    : FgDot(a.x(), a.y())
{
    _rot = a._rot;
    _string = NULL;
    setstring(a._string);
}

FgString& FgString::operator=(const FgString& a)
{
    if (this == (FgString *) &a)
        return *this;
    *((FgDot *) this) = a;
    _rot = a._rot;
    setstring(a._string);
}
    
FgString::~FgString()
{
    delete _string;
}

////////////// Implementation of FgCircle //////////////////

void FgCircle::drawc (fg_const_pbox_t clip)
{
  fg_drawarc (foreg(),mode(),mask(),x(),y(),radius(),0,3600,clip);
}

void FgCircle::erasec (fg_const_pbox_t clip)
{
  fg_drawarc (backg(),mode(),mask(),x(),y(),radius(),0,3600,clip);
}

////////////// Implementation of FgArc //////////////////

void FgArc::drawc (fg_const_pbox_t clip)
{
  fg_drawarc (foreg(),mode(),mask(),x(),y(),radius(),start(),end(),clip);
}

void FgArc::erasec (fg_const_pbox_t clip)
{
  fg_drawarc (backg(),mode(),mask(),x(),y(),radius(),start(),end(),clip);
}

////////////// Implementation of FgEllipse //////////////////

void FgEllipse::drawc (fg_const_pbox_t clip)
{
  fg_drawellipse (foreg(),mode(),mask(),x(),y(),xradius(),yradius(),
                  start(),end(),clip);
}

void FgEllipse::erasec (fg_const_pbox_t clip)
{
  fg_drawellipse (backg(),mode(),mask(),x(),y(),xradius(),yradius(),
                  start(),end(),clip);
}

////////////// Implementation of FgPolygon //////////////////

FgPolygon::FgPolygon(unsigned int vertices, const fg_coord_t *poly, int t)
{
  settype (t);
  _poly = 0;
  setpolygon (vertices, poly);
}

FgPolygon::FgPolygon(const FgPolygon &a)
{
    _type = a._type;
    _poly = 0;
    setpolygon(a._vertices,a._poly);
}

FgPolygon& FgPolygon::operator=(const FgPolygon &a)
{
    if (this == (FgPolygon *) &a)
        return *this;
    _type = a._type;
    setpolygon(a._vertices,a._poly);
}

FgPolygon::~FgPolygon()
{
    delete _poly;
}

const fg_coord_t *FgPolygon::
      setpolygon(unsigned int vertices, const fg_coord_t *poly)
{
  delete _poly;

  _vertices = vertices;
  size_t temp = 2 * (vertices + 1);

  _poly = new fg_coord_t[temp];
  if (_poly && poly)
    memcpy (_poly, poly, temp * sizeof(fg_coord_t));

  return _poly;
}

void FgPolygon::translate(fg_coord_t x, fg_coord_t y)
{
  unsigned int i = 2 * vertices() + 1;

  do
  {
    _poly [i--] += y;
    _poly [i] += x;
  } while (i-- != 0);
}

void FgPolygon::setvertex (unsigned int vertex, fg_coord_t x, fg_coord_t y)
{
  if (_poly && vertex <= _vertices)
  {
    _poly [2 * vertex] = x;
    _poly [2 * vertex + 1] = y;

    if (vertex == 0)
    {
      _poly [2 * _vertices] = x;
      _poly [2 * _vertices + 1] = y;
    }
  }
}

void FgPolygon::drawc (fg_const_pbox_t clip)
{
  fg_drawpolygon (foreg(),mode(),mask(),type(),vertices(),polygon(),clip);
}

void FgPolygon::erasec (fg_const_pbox_t clip)
{
  fg_drawpolygon (backg(),mode(),mask(),type(),vertices(),polygon(),clip);
}

////////////// Implementation of FgFilledPolygon //////////////////

void FgFilledPolygon::drawc (fg_const_pbox_t clip)
{
  fg_fillpolygon (foreg(),mode(),mask(),vertices(),polygon(),clip);
}

void FgFilledPolygon::erasec (fg_const_pbox_t clip)
{
  fg_fillpolygon (backg(),mode(),mask(),vertices(),polygon(),clip);
}

