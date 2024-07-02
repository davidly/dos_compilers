/*  PBAR.PRO -- sample Turbo Prolog program to be used with BAR.C

    Copyright (c) 1987,88 Borland International.  All rights reserved.
*/

database
    barchart(integer)
    chartbar(integer,integer,integer,integer,integer,integer)

global predicates
 cbar(integer,integer,integer,integer,integer)-(i,i,i,i,i) language c
predicates
    process(char)
    repeat
    myretractall
    drawbar(integer,integer,integer,integer)

goal
    graphics(1,0,0),
    asserta(barchart(0)),
    makewindow(1,1,1,"Bar",0,0,20,40),
    makewindow(2,1,1,"",20,0,4,40),
    repeat,
    write("Press any key to continue"), readchar(_),
    clearwindow,
    makewindow(1,1,1,"Bar",0,0,20,40),
    write("m. Make a bar Chart.\n"),
    write("s. Save your bar Chart.\n"),
    write("l. Load your bar Chart.\n"),
    write("d. Draw your bar Chart.\n"),
    write("e. End\nEnter Choice: "),
    readchar(Choice),
    clearwindow,
    shiftwindow(2),
    process(Choice),
    bios(16,reg(3,0,0,0,0,0,0,0),_).

clauses
     process('m'):-
            barchart(Nu),
            retract(barchart(Nu)),
            NewNu = Nu+1,
            asserta(barchart(NewNu)),
            write("Enter the number of bars: "),
            readint(NuOfBars),clearwindow,
            write("Enter max value on Y scale: "),
            readint(Max),clearwindow,
            YScale = 140/Max,
            Width = 265/NuOfBars,
            Start = 305-Width,
            clearwindow,
            drawbar(NuOfBars, Width, Start, Yscale),
            fail.
     process('s'):-
            write("Enter file name of chart: "),readln(Name),
            concat(Name,".CHT",FName),save(Fname),fail.
     process('l'):-
            myretractall,
            write("Enter file name of chart: "),readln(Name),
            concat(Name,".CHT",FName),consult(FName),fail.
     process('d'):-
             barchart(Chart),
             chartbar(Chart,XPosition,Ypos,Width,YBarSize,1),
             cbar(XPosition,Ypos,Width,YBarSize,1),fail.
     process('e').

     drawbar(0,_,_,_):-!.
     drawbar(Nu,Width,XPosition,Yscale):-
            XNuNew=Nu-1,clearwindow,
            write("Enter the value associated bar ",Nu ,": "),
            readint(Y),
            YBarSize=Y*YScale,
            Ypos=140 - YBarSize,
            cbar(XPosition,Ypos,Width,YBarSize,1),
            barchart(Chart),
            asserta(chartbar(Chart,XPosition,Ypos,Width,YBarSize,1)),
            XNewPos= XPosition-Width-5,
            drawbar(XNuNew,Width,XNewPos,Yscale).

repeat.
repeat:- repeat.
myretractall:- retract(_),fail.
myretractall.

