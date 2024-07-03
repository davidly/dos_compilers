{*************************************************************************}
{                                                                         }
{                         MicroCalc Spread Sheet                          }
{                            Version 2.0                                  }
{                                                                         }
{  This program is hereby donated to the public domain for non-commercial }
{  use only.                                                              }
{                                                                         }
{  The MicrCalc program has been included on our TURBO PASCAL disk for two}
{  reasons. One, as a sample program for you to study, modify, etc. and   }
{  also as a usefull program that will meet the spread sheet needs of the }
{  majority of TURBO PASCAL users.                                        }
{                                                                         }
{  Many users have expressed the neeed for more sample programs written in}
{  TURBO PASCAL for them to look at and study. While most of us will never}
{  take full advantage of the powers offered by the average spread sheet  }
{  on the market these days. Thus, MicroCalc serves two usefull perposes. }
{                                                                         }
{  INSTRUCTIONS :                                                         }
{    1. Compile this program using the TURBO.COM compiler.                }
{      A. Type 'TURBO' <CARRIAGE RETURN> at the operating system command  }
{         line.                                                           }
{      B. Type 'Y' to Include error messages                              }
{      C. Type 'W' for Workfile                                           }
{      D. Type 'CALC' for Workfile name                                   }
{      E. Type 'R' for run                                                }
{    2. If you receive a Compiler Overflow message - Error # 99 then      }
{      A. follow steps A through D above                                  }
{      B. Type 'O' for compiler Options                                   }
{      C. Type 'C' for .COM file                                          }
{      D. Type 'Q' to Quit compiler Options                               }
{      E. Type 'C' for Compile                                            }
{      F. Type 'Q' to Quit TURBO PASCAL                                   }
{      G. Type 'CALC' at the operating system command line.               }
{                                                                         }
{*************************************************************************}



{*************************************************************************}
{                                                                         }
{                         Main MicroCalc Module                           }
{                         Last Modified 7-22-85                           }
{                                                                         }
{  The MicroCalc program has been divided into several modules. Each      }
{  module contains related routines, thus enabling the programmer to      }
{  follow the code more easily. Following is a description of each of the }
{  modules :                                                              }
{                                                                         }
{  Module Name : Main MicroCalc Module                                    }
{  FileName    : CALC.PAS                                                 }
{  Contents    :                                                          }
{                1. Global Variable Declarations                          }
{                2. Procedure Commands (* called when user types "/" *)   }
{                3. Main program body                                     }
{                                                                         }
{  Module Name : MicroCalc Module 000                                     }
{  FileName    : CALC.INC                                                 }
{  Contents    :                                                          }
{                1. Miscellaneous routines                                }
{                                                                         }
{  Module Name : MicroCalc Module 001                                     }
{  FileName    : CALC.INC                                                 }
{  Contents    :                                                          }
{                1. Procedure Grid - Displays the spread sheet on the     }
{                   screen                                                }
{                2. Procedure Init - Initializes all cells in the spread  }
{                   sheet                                                 }
{                3. Procedure Clear - clears the current spread sheet     }
{                                                                         }
{  Module Name : MicroCalc Module 002                                     }
{  FileName    : CALC.INC                                                 }
{  Contents    :                                                          }
{                1. Procedure DisplayType - indicates the type and        }
{                   contents of a cell                                    }
{                2. Cursor movement procedures - called when user presses }
{                   the arrow keys                                        }
{                                                                         }
{  Module Name : MicroCalc Module 003                                     }
{  FileName    : CALC.INC                                                 }
{  Contents    :                                                          }
{                1. Procedures Load, Save and Print - Load a new spread   }
{                   sheet, Save the current spread sheet, and print the   }
{                   current spread sheet                                  }
{                2. Procedure Help - on line help system                  }
{    Special Note : If you are operating under MS/PC-DOS, you can take    }
{                   full advantage of DOS's filename ficilities by mod-   }
{                   -ifying line 56 (* remove comments *)                 }
{                                                                         }
{  Module Name : MicroCalc Module 004                                     }
{  FileName    : CALC.PAS                                                 }
{  Contents    :                                                          }
{                1. Procedure Evaluate - Evaluates a string passed to it  }
{                2. Procedure ReCalculate - Recalculates each cell in the }
{                   spread sheet                                          }
{                                                                         }
{  Module Name : MicroCalc Module 005                                     }
{  File Name   : CALC.PAS                                                 }
{  Contents    :                                                          }
{                1. Procedure GetCell - I/O routine that gets cell's      }
{                   contents from the user.                               }
{                2. Procedure Format - allows user to format a range of   }
{                   cells.                                                }
{                                                                         }
{*************************************************************************}


Program MicroCalc;

const
  FXMax : Char  = 'G';  { Maximum number of columns in spread sheet       }
  FYMax         = 21;   { Maximum number of lines in spread sheet         }
  EofLine       = ^M;
  Numbers : set of Char = ['0'..'9'];

type
  Anystring   = string[70];
  String3     = string[3];
  ColumnName  = 'A'..'G';
  Attributes  = (Constant,Formula,Txt,OverWritten,Locked,Calculated);
  SetOfAttri  = Set of Attributes;

{ The spreadsheet is made out of cells.  Each cell is defined as the      }
{ following record:                                                       }

  CellRec    = record
    CellStatus : set of Attributes; { Status of cell (see type def.)      }
    Contents   : String[70];        { Contains a formula or some text     }
    Value      : Real;              { Last calculated cell value          }
    DEC, FW    : 0..20;             { Decimals and Cell Width             }
  end;

  Cells      =  array['A'..'G',1..FYMax] of CellRec;

const
 {Initialize the array XPOS to hold the left most position of each column.}
  XPOS : array['A'..'G'] of Integer = (3,14,25,36,47,58,68);

var
  Sheet        : Cells;             { Definition of the spread sheet      }
  FX           : ColumnName;        { Culumn of current cell              }
  FY           : Integer;           { Line of current cell                }
  Ch           : Char;              { Last read Character                 }
  MCFile       : file of CellRec;   { File to store sheets in             }
  AutoCalc,
  Form         : boolean;           { Recalculate after each entry?       }
  FileName     : AnyString;
  Line         : string[100];

{$I CALC.INC}

{*************************************************************************}
{             THIS IS WHERE THE PROGRAM STARTS EXECUTING                  }
{*************************************************************************}

begin
  Init;                                                             { 001 }
  Welcome;                                                          { 001 }
  ClrScr;
  Grid;                                                             { 001 }
  GotoCell(FX,FY);                                                  { 002 }
  repeat
    Read(KBD,Ch);           { Read KeyBoard without echoing to screen     }
    if KeyPressed then      { Check for remaining characters in buffer,   }
    begin                   { if a character remains then a key with an   }
      Read(KBD,Ch);         { extended scan code was pressed. Thus, read  }
      IBMCh(Ch);            { the second character.                       }
    end;
    case Ch of {Based on the value of Ch execute the appropriate routine. }
      ^E         : MoveUp;                                          { 002 }
      ^X, ^J     : MoveDown;                                        { 002 }
      ^D, ^M, ^F : MoveRight;                                       { 002 }
      ^S, ^A     : MoveLeft;                                        { 002 }
      '/'        : Commands;
      ^[         : GetCell(FX,FY);                                  { 004 }
    else
      if Ch in [' '..'~'] then
        GetCell(FX,FY);                                             { 005 }
    end;
  until True = False;             { (program stops in procedure Commands) }
end.

