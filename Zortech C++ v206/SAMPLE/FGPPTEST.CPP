#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <time.h>
#include "fg.hpp"

// Forward referenced functions
void demodots();
void demolines();
void demoboxes();
void demofilledboxes();
void demochars();
void demomatrix();
void demostring();
void democircles();
void demoarcs();
void demoellipses();
void demopolygons();
void demofilledpolygons();

main()
{
  if (fg_init())  // initialization
  {
    demostring();
    demomatrix();
    demochars();

    // Change colors
    if (FG_BLUE != -1)
    {   FgDisp::clear(FG_BLUE);
        Fg::setbackg(FG_BLUE);     // set background color
    }

    demodots();
    demolines();
    demoboxes();
    demofilledboxes();
    democircles();
    demoarcs();
    demoellipses();
    demopolygons();
    demofilledpolygons();

    fg_term();  // termination
  }
  else
    fputs ("Unable to initialize graphics device.", stdout);

  return 0;
}

/////////////////////////////
// Demo use of FgFilledPolygon

void demofilledpolygons()
{
    while (!kbhit())
    {
        // Draw a filled polygon travelling left-to-right across the screen
        int i = FgDisp::left();

        static fg_coord_t poly[5 * 2] = {0,0, 50,50, 100,0, 50,-50, 0,0};

        FgFilledPolygon filledpolygon(4, poly);
        filledpolygon.translate(i - 50, FgDisp::height()/2);

        filledpolygon.draw();
        while (!kbhit() && ++i <= FgDisp::right())
        {   filledpolygon.erase();
            filledpolygon.translate(1,0);
            filledpolygon.draw();
            msleep(10); // delay a bit
        }
        filledpolygon.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgPolygon

void demopolygons()
{
    while (!kbhit())
    {
        // Draw a polygon travelling left-to-right across the screen
        int i = FgDisp::left();

        static fg_coord_t poly[5 * 2] = {50,20, 50,50, 100,0, 25,-25, 50,20};

        FgPolygon polygon(4, poly);
        polygon.setvertex (0, 0, 0);    // Set first and last coord pair.
        polygon.setvertex (3, 50, -50); // Set fourth coord pair.

        polygon.translate(i - 50, FgDisp::height()/2);

        polygon.draw();
        while (!kbhit() && ++i <= FgDisp::right())
        {   polygon.erase();
            polygon.translate(1,0);
            polygon.draw();
            msleep(10); // delay a bit
        }
        polygon.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgArc

void demoarcs()
{
    while (!kbhit())
    {
        // Draw a arc travelling left-to-right across the screen
        int i = FgDisp::left();
        FgArc arc(i,FgDisp::height()/2,FgDisp::height()/4,0,1800);

        while (!kbhit() && ++i <= FgDisp::right())
        {
            arc.draw();
            msleep(10); // delay a bit
            arc.erase();

            arc.translate(1,0);

            fg_coord_t temp = arc.start() + 10;
            if (temp >= 3600)
              temp = 0;

            arc.setstart(temp);

            temp = arc.end() + 10;
            if (temp >= 3600)
              temp = 0;

            arc.setend(temp);
        }
    }
    getch();
}

/////////////////////////////
// Demo use of FgEllipse

void demoellipses()
{
    while (!kbhit())
    {
        // Draw a ellipse travelling left-to-right across the screen
        int i = FgDisp::left();
        FgEllipse ellipse(i,FgDisp::height()/2,FgDisp::height()/4,
                   FgDisp::height()/16,0,1800);

        while (!kbhit() && ++i <= FgDisp::right())
        {
            ellipse.draw();
            msleep(10); // delay a bit
            ellipse.erase();

            ellipse.translate(1,0);

            fg_coord_t temp = ellipse.start() - 10;
            if (temp <= 0)
              temp = 3600;

            ellipse.setstart(temp);

            temp = ellipse.end() - 10;
            if (temp <= 0)
              temp = 3600;

            ellipse.setend(temp);
        }
    }
    getch();
}

/////////////////////////////
// Demo use of FgCircle

void democircles()
{
    while (!kbhit())
    {
        // Draw a circle travelling left-to-right across the screen
        int i = FgDisp::left();
        FgCircle circle(i,FgDisp::height()/2,FgDisp::height()/4);

        circle.draw();
        while (!kbhit() && ++i <= FgDisp::right())
        {   circle.erase();
            circle.translate(1,0);
            circle.draw();
            msleep(10); // delay a bit
        }
        circle.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgDot

void demodots()
{
    while (!kbhit())
    {
        // Draw a dot travelling left-to-right across the screen
        int i = FgDisp::left();
        FgDot dot(i,FgDisp::height()/2);

        dot.draw();
        while (++i <= FgDisp::right())
        {   dot.erase();
            dot.translate(1,0);
            dot.draw();
            msleep(10); // delay a bit
            if (kbhit())    // if user struck a key
                break;
        }
        dot.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgLine

void demolines()
{
    while (!kbhit())
    {
        // Draw a line travelling left-to-right across the screen
        int i = FgDisp::left();
        fg_const_pbox_t p = FgDisp::box();
        FgLine line(p);

        line.draw();
        while (++i <= FgDisp::right())
        {   line.erase();
            line.setx1(i);
            line.draw();
            if (kbhit())    // if user struck a key
                break;
        }
        line.erase();
    }
    getch();
}

/////////////////////////////
//

void demofb(FgBox *fb)
{
    int i = fb->right();

    while (!kbhit())
    {
        // Draw a box travelling left-to-right across the screen

        fb->draw();
        while (++i <= FgDisp::right())
        {   fb->erase();
            fb->setright(i);
            fb->settop(fb->right() + 1);
            fb->draw();
            if (kbhit())    // if user struck a key
                break;
        }
        fb->erase();
        i = fb->left() + 1;
    }
    getch();
}

/////////////////////////////
// Demo use of FgBox

void demoboxes()
{
    FgBox fb(5,20,15,30);
    demofb(&fb);
}

/////////////////////////////
// Demo use of FgFillBox

void demofilledboxes()
{
    FgFillBox fb(15,25,20,35);
    demofb(&fb);
}

/////////////////////////////
// Demo use of FgChar

void demochars()
{
    while (!kbhit())
    {
        // Draw a char travelling left-to-right across the screen
        int i = FgDisp::left();
        FgChar ch(i,FgDisp::height()/2,'X');

        ch.draw();
        while (ch.x() <= FgDisp::right())
        {   ch.erase();
            ch.translate((rand() & 3) - 1,(rand() & 1) * 2 - 1);
            ch.draw();
            if (kbhit())    // if user struck a key
                break;
        }
        ch.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgMatrix

void demomatrix()
{
    char data[] =
    {   0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xA,0xB,0xC,0xD,0xE,0xF
    };
    fg_box_t databox = { 0,0,7,14 };

    while (!kbhit())
    {
        // Draw a char travelling left-to-right across the screen
        int i = FgDisp::left();
        FgMatrix m(i,FgDisp::height()/2,(fg_pbox_t)databox,data);

        m.draw();
        while (m.left() <= FgDisp::right())
        {   m.erase();
            m.translate(1,0);
            m.draw();
            msleep(10);
            if (kbhit())    // if user struck a key
                break;
        }
        m.erase();
    }
    getch();
}

/////////////////////////////
// Demo use of FgString

void demostring()
{
    while (!kbhit())
    {
        // Draw a string travelling left-to-right across the screen
        int i = FgDisp::left();
        FgString s(i,0,"Hello world");
        int velx=1,vely=1;

        s.draw();
        while (FgDisp::inside(s.x(),s.y()))
        {   s.erase();
            s.translate(velx,vely);
            s.draw();
            if (kbhit())    // if user struck a key
                break;

            if ((rand() & 15) == 0)
            {
                velx += ((unsigned) rand() % 5) - 2;
                vely += ((unsigned) rand() % 5) - 2;
            }
        }
        s.erase();
    }
    getch();
}

