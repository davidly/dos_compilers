
{*******************************************************}
{                                                       }
{       Turbo Pascal Runtime Library                    }
{       Windows DOS Interface Unit                      }
{                                                       }
{       Copyright (c) 1991,92 Borland International     }
{                                                       }
{*******************************************************}

unit WinDos;

{$O+,S-,W-}

interface

{ Flags bit masks }

const
  fCarry     = $0001;
  fParity    = $0004;
  fAuxiliary = $0010;
  fZero      = $0040;
  fSign      = $0080;
  fOverflow  = $0800;

{ File mode magic numbers }

const
  fmClosed = $D7B0;
  fmInput  = $D7B1;
  fmOutput = $D7B2;
  fmInOut  = $D7B3;

{ File attribute constants }

const
  faReadOnly  = $01;
  faHidden    = $02;
  faSysFile   = $04;
  faVolumeID  = $08;
  faDirectory = $10;
  faArchive   = $20;
  faAnyFile   = $3F;

{ Maximum file name component string lengths }

const
  fsPathName  = 79;
  fsDirectory = 67;
  fsFileName  = 8;
  fsExtension = 4;

{ FileSplit return flags }

const
  fcExtension = $0001;
  fcFileName  = $0002;
  fcDirectory = $0004;
  fcWildcards = $0008;

{ Registers record used by Intr and MsDos }

type
  TRegisters = record
    case Integer of
      0: (AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: Word);
      1: (AL, AH, BL, BH, CL, CH, DL, DH: Byte);
  end;

{ Typed-file and untyped-file record }

type
  TFileRec = record
    Handle: Word;
    Mode: Word;
    RecSize: Word;
    Private: array[1..26] of Byte;
    UserData: array[1..16] of Byte;
    Name: array[0..79] of Char;
  end;

{ Textfile record }

type
  PTextBuf = ^TTextBuf;
  TTextBuf = array[0..127] of Char;
  TTextRec = record
    Handle: Word;
    Mode: Word;
    BufSize: Word;
    Private: Word;
    BufPos: Word;
    BufEnd: Word;
    BufPtr: PTextBuf;
    OpenFunc: Pointer;
    InOutFunc: Pointer;
    FlushFunc: Pointer;
    CloseFunc: Pointer;
    UserData: array[1..16] of Byte;
    Name: array[0..79] of Char;
    Buffer: TTextBuf;
  end;

{ Search record used by FindFirst and FindNext }

type
  TSearchRec = record
    Fill: array[1..21] of Byte;
    Attr: Byte;
    Time: Longint;
    Size: Longint;
    Name: array[0..12] of Char;
  end;

{ Date and time record used by PackTime and UnpackTime }

type
  TDateTime = record
    Year, Month, Day, Hour, Min, Sec: Word;
  end;

{ Error status variable }

var
  DosError: Integer;

{ DosVersion returns the DOS version number. The low byte of    }
{ the result is the major version number, and the high byte is  }
{ the minor version number. For example, DOS 3.20 returns 3 in  }
{ the low byte, and 20 in the high byte.                        }

function DosVersion: Word;

{ Intr executes a specified software interrupt with a specified }
{ TRegisters package. NOTE: To avoid general protection faults  }
{ when running in protected mode, always make sure to           }
{ initialize the DS and ES fields of the TRegisters record with }
{ valid selector values, or set the fields to zero.             }

procedure Intr(IntNo: Byte; var Regs: TRegisters);

{ MsDos invokes the DOS function call handler with a specified  }
{ TRegisters package.                                           }

procedure MsDos(var Regs: TRegisters);

{ GetDate returns the current date set in the operating system. }
{ Ranges of the values returned are: Year 1980-2099, Month      }
{ 1-12, Day 1-31 and DayOfWeek 0-6 (0 corresponds to Sunday).   }

procedure GetDate(var Year, Month, Day, DayOfWeek: Word);

{ SetDate sets the current date in the operating system. Valid  }
{ parameter ranges are: Year 1980-2099, Month 1-12 and Day      }
{ 1-31. If the date is not valid, the function call is ignored. }

procedure SetDate(Year, Month, Day: Word);

{ GetTime returns the current time set in the operating system. }
{ Ranges of the values returned are: Hour 0-23, Minute 0-59,    }
{ Second 0-59 and Sec100 (hundredths of seconds) 0-99.          }

procedure GetTime(var Hour, Minute, Second, Sec100: Word);

{ SetTime sets the time in the operating system. Valid          }
{ parameter ranges are: Hour 0-23, Minute 0-59, Second 0-59 and }
{ Sec100 (hundredths of seconds) 0-99. If the time is not       }
{ valid, the function call is ignored.                          }

procedure SetTime(Hour, Minute, Second, Sec100: Word);

{ GetCBreak returns the state of Ctrl-Break checking in DOS.    }
{ When off (False), DOS only checks for Ctrl-Break during I/O   }
{ to console, printer, or communication devices. When on        }
{ (True), checks are made at every system call.                 }

procedure GetCBreak(var Break: Boolean);

{ SetCBreak sets the state of Ctrl-Break checking in DOS.       }

procedure SetCBreak(Break: Boolean);

{ GetVerify returns the state of the verify flag in DOS. When   }
{ off (False), disk writes are not verified. When on (True),    }
{ all disk writes are verified to insure proper writing.        }

procedure GetVerify(var Verify: Boolean);

{ SetVerify sets the state of the verify flag in DOS.           }

procedure SetVerify(Verify: Boolean);

{ DiskFree returns the number of free bytes on the specified    }
{ drive number (0=Default,1=A,2=B,..). DiskFree returns -1 if   }
{ the drive number is invalid.                                  }

function DiskFree(Drive: Byte): Longint;

{ DiskSize returns the size in bytes of the specified drive     }
{ number (0=Default,1=A,2=B,..). DiskSize returns -1 if the     }
{ drive number is invalid.                                      }

function DiskSize(Drive: Byte): Longint;

{ GetFAttr returns the attributes of a file. F must be a file   }
{ variable (typed, untyped or textfile) which has been assigned }
{ a name. The attributes are examined by ANDing with the        }
{ attribute masks defined as constants above. Errors are        }
{ reported in DosError.                                         }

procedure GetFAttr(var F; var Attr: Word);

{ SetFAttr sets the attributes of a file. F must be a file      }
{ variable (typed, untyped or textfile) which has been assigned }
{ a name. The attribute value is formed by adding (or ORing)    }
{ the appropriate attribute masks defined as constants above.   }
{ Errors are reported in DosError.                              }

procedure SetFAttr(var F; Attr: Word);

{ GetFTime returns the date and time a file was last written.   }
{ F must be a file variable (typed, untyped or textfile) which  }
{ has been assigned and opened. The Time parameter may be       }
{ unpacked throgh a call to UnpackTime. Errors are reported in  }
{ DosError.                                                     }

procedure GetFTime(var F; var Time: Longint);

{ SetFTime sets the date and time a file was last written.      }
{ F must be a file variable (typed, untyped or textfile) which  }
{ has been assigned and opened. The Time parameter may be       }
{ created through a call to PackTime. Errors are reported in    }
{ DosError.                                                     }

procedure SetFTime(var F; Time: Longint);

{ FindFirst searches the specified (or current) directory for   }
{ the first entry that matches the specified filename and       }
{ attributes. The result is returned in the specified search    }
{ record. Errors (and no files found) are reported in DosError. }

procedure FindFirst(Path: PChar; Attr: Word; var F: TSearchRec);

{ FindNext returs the next entry that matches the name and      }
{ attributes specified in a previous call to FindFirst. The     }
{ search record must be one passed to FindFirst. Errors (and no }
{ more files) are reported in DosError.                         }

procedure FindNext(var F: TSearchRec);

{ UnpackTime converts a 4-byte packed date/time returned by     }
{ FindFirst, FindNext or GetFTime into a TDateTime record.      }

procedure UnpackTime(P: Longint; var T: TDateTime);

{ PackTime converts a TDateTime record into a 4-byte packed     }
{ date/time used by SetFTime.                                   }

procedure PackTime(var T: TDateTime; var P: Longint);

{ GetIntVec returns the address stored in the specified         }
{ interrupt vector.                                             }

procedure GetIntVec(IntNo: Byte; var Vector: Pointer);

{ SetIntVec sets the address in the interrupt vector table for  }
{ the specified interrupt.                                      }

procedure SetIntVec(IntNo: Byte; Vector: Pointer);

{ FileSearch searches for the file given by Name in the list of }
{ directories given by List. The directory paths in List must   }
{ be separated by semicolons. The search always starts with the }
{ current directory of the current drive. If the file is found, }
{ FileSearch stores a concatenation of the directory path and   }
{ the file name in Dest. Otherwise FileSearch stores an empty   }
{ string in Dest. The maximum length of the result is defined   }
{ by the fsPathName constant. The returned value is Dest.       }

function FileSearch(Dest, Name, List: PChar): PChar;

{ FileExpand fully expands the file name in Name, and stores    }
{ the result in Dest. The maximum length of the result is       }
{ defined by the fsPathName constant. The result is an all	}
{ upper case string consisting of a drive letter, a colon, a	}
{ root relative directory path, and a file name. Embedded '.'	}
{ and '..' directory references are removed, and all name and	}
{ extension components are truncated to 8 and 3 characters. The }
{ returned value is Dest.            				}

function FileExpand(Dest, Name: PChar): PChar;

{ FileSplit splits the file name specified by Path into its     }
{ three components. Dir is set to the drive and directory path  }
{ with any leading and trailing backslashes, Name is set to the }
{ file name, and Ext is set to the extension with a preceding   }
{ period. If a component string parameter is NIL, the           }
{ corresponding part of the path is not stored. If the path     }
{ does not contain a given component, the returned component    }
{ string is empty. The maximum lengths of the strings returned  }
{ in Dir, Name, and Ext are defined by the fsDirectory,         }
{ fsFileName, and fsExtension constants. The returned value is  }
{ a combination of the fcDirectory, fcFileName, and fcExtension }
{ bit masks, indicating which components were present in the    }
{ path. If the name or extension contains any wildcard          }
{ characters (* or ?), the fcWildcards flag is set in the       }
{ returned value.                                               }

function FileSplit(Path, Dir, Name, Ext: PChar): Word;

{ GetCurDir returns the current directory of a specified drive. }
{ Drive = 0 indicates the current drive, 1 indicates drive A, 2 }
{ indicates drive B, and so on. The string returned in Dir      }
{ always starts with a drive letter, a colon, and a backslash.  }
{ The maximum length of the resulting string is defined by the  }
{ fsDirectory constant. The returned value is Dir. Errors are   }
{ reported in DosError.                                         }

function GetCurDir(Dir: PChar; Drive: Byte): PChar;

{ SetCurDir changes the current directory to the path specified }
{ by Dir. If Dir specifies a drive letter, the current drive is }
{ also changed. Errors are reported in DosError.                }

procedure SetCurDir(Dir: PChar);

{ CreateDir creates a new subdirectory with the path specified  }
{ by Dir. Errors are reported in DosError.                      }

procedure CreateDir(Dir: PChar);

{ RemoveDir removes the subdirectory with the path specified by }
{ Dir. Errors are reported in DosError.                         }

procedure RemoveDir(Dir: PChar);

{ GetArgCount returns the number of parameters passed to the    }
{ program on the command line.                                  }

function GetArgCount: Integer;

{ GetArgStr returns the Index'th parameter from the command     }
{ line, or an empty string if Index is less than zero or        }
{ greater than GetArgCount. If Index is zero, GetArgStr returns }
{ the filename of the current module. The maximum length of the }
{ string returned in Dest is given by the MaxLen parameter. The }
{ returned value is Dest.                                       }

function GetArgStr(Dest: PChar; Index: Integer; MaxLen: Word): PChar;

{ GetEnvVar returns a pointer to the value of a specified       }
{ environment variable, i.e. a pointer to the first character   }
{ after the equals sign (=) in the environment entry given by   }
{ VarName. VarName is case insensitive. GetEnvVar returns NIL   }
{ if the specified environment variable does not exist.         }

function GetEnvVar(VarName: PChar): PChar;

implementation

{$IFDEF Windows}
{$DEFINE ProtectedMode}
{$ENDIF}

{$IFDEF DPMI}
{$DEFINE ProtectedMode}
{$ENDIF}

{$IFDEF Windows}

uses WinTypes, WinProcs, Strings;

{$ELSE}

uses Strings;

{$ENDIF}

{$IFDEF Windows}

procedure AnsiDosFunc; assembler;
var
  TempName: array[0..fsPathName] of Char;
asm
	PUSH	DS
	PUSH	CX
	PUSH	AX
	MOV	SI,DI
	PUSH	ES
	POP	DS
	LEA	DI,TempName
	PUSH	SS
	POP	ES
	MOV	CX,fsPathName
	CLD
@@1:	LODSB
	OR	AL,AL
	JE	@@2
	STOSB
	LOOP	@@1
@@2:	XOR	AL,AL
	STOSB
	LEA	DI,TempName
	PUSH	SS
	PUSH	DI
	PUSH	SS
	PUSH	DI
	CALL	AnsiToOem
	POP	AX
	POP	CX
	LEA	DX,TempName
	PUSH	SS
	POP	DS
	INT	21H
	POP	DS
end;

{$ELSE}

procedure AnsiDosFunc; assembler;
asm
	PUSH	DS
	MOV	DX,DI
	PUSH	ES
	POP	DS
	INT	21H
	POP	DS
end;

{$ENDIF}

function DosVersion: Word; assembler;
asm
	MOV	AH,30H
	INT	21H
end;

procedure Intr(IntNo: Byte; var Regs: TRegisters); assembler;
asm
	PUSH	DS
{$IFDEF ProtectedMode}
{$IFDEF Windows}
	PUSH	CS
	CALL	AllocCSToDSAlias
{$ELSE}
	MOV	AX,CS
	ADD	AX,SelectorInc
{$ENDIF}
	MOV	DS,AX
	CLI
	PUSH	WORD PTR DS:@@Int
	PUSH	DS
	MOV	AL,IntNo
	MOV	BYTE PTR DS:@@Int+1,AL
{$ELSE}
	PUSH	WORD PTR CS:@@Int
	MOV	AL,IntNo
	MOV	BYTE PTR CS:@@Int+1,AL
{$ENDIF}
	LDS	SI,Regs
	CLD
	LODSW
	PUSH	AX
	LODSW
	XCHG	AX,BX
	LODSW
	XCHG	AX,CX
	LODSW
	XCHG	AX,DX
	LODSW
	XCHG	AX,BP
	LODSW
	PUSH	AX
	LODSW
	XCHG	AX,DI
	LODSW
	PUSH	AX
	LODSW
{$IFDEF DPMI}
        VERR    AX
	JNZ	@@1
	MOV	ES,AX
@@1:	POP	AX
	VERR	AX
	JNZ	@@2
	MOV	DS,AX
@@2:
{$ELSE}
	MOV	ES,AX
	POP	DS
{$ENDIF}
	POP	SI
	POP	AX
@@Int:	INT	0
	STI
	PUSHF
	PUSH	ES
	PUSH	DI
	PUSH	BP
	MOV	BP,SP
{$IFDEF ProtectedMode}
	ADD	BP,14
{$ELSE}
	ADD	BP,12
{$ENDIF}
	LES	DI,Regs
	CLD
	STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,CX
	STOSW
	XCHG	AX,DX
	STOSW
	POP	AX
	STOSW
	XCHG	AX,SI
	STOSW
	POP	AX
	STOSW
	MOV	AX,DS
	STOSW
	POP	AX
	STOSW
	POP	AX
	STOSW
{$IFDEF ProtectedMode}
	POP	DS
	POP	WORD PTR DS:@@Int
{$ELSE}
	POP	WORD PTR CS:@@Int
{$ENDIF}
{$IFDEF Windows}
	MOV	AX,DS
	POP	DS
	PUSH	AX
	CALL	FreeSelector
{$ELSE}
	POP	DS
{$ENDIF}
end;

procedure MsDos(var Regs: TRegisters);
begin
  Intr($21, Regs);
end;

procedure GetDate(var Year, Month, Day, DayOfWeek: Word); assembler;
asm
	MOV	AH,2AH
	INT	21H
	XOR	AH,AH
	LES	DI,DayOfWeek
	STOSW
	MOV	AL,DL
	LES	DI,Day
	STOSW
	MOV	AL,DH
	LES	DI,Month
	STOSW
	XCHG	AX,CX
	LES	DI,Year
	STOSW
end;

procedure SetDate(Year, Month, Day: Word); assembler;
asm
	MOV	CX,Year
	MOV	DH,BYTE PTR Month
	MOV	DL,BYTE PTR Day
	MOV	AH,2BH
	INT	21H
end;

procedure GetTime(var Hour, Minute, Second, Sec100: Word); assembler;
asm
	MOV	AH,2CH
	INT	21H
	XOR	AH,AH
	MOV	AL,DL
	LES	DI,Sec100
	STOSW
	MOV	AL,DH
	LES	DI,Second
	STOSW
	MOV	AL,CL
	LES	DI,Minute
	STOSW
	MOV	AL,CH
	LES	DI,Hour
	STOSW
end;

procedure SetTime(Hour, Minute, Second, Sec100: Word); assembler;
asm
	MOV	CH,BYTE PTR Hour
	MOV	CL,BYTE PTR Minute
	MOV	DH,BYTE PTR Second
	MOV	DL,BYTE PTR Sec100
	MOV	AH,2DH
	INT	21H
end;

procedure GetCBreak(var Break: Boolean); assembler;
asm
	MOV	AX,3300H
	INT	21H
	LES	DI,Break
	MOV	ES:[DI],DL
end;

procedure SetCBreak(Break: Boolean); assembler;
asm
	MOV	DL,Break
	MOV	AX,3301H
	INT	21H
end;

procedure GetVerify(var Verify: Boolean); assembler;
asm
	MOV	AH,54H
	INT	21H
	LES	DI,Verify
	STOSB
end;

procedure SetVerify(Verify: Boolean); assembler;
asm
	MOV	AL,Verify
	MOV	AH,2EH
	INT	21H
end;

function DiskFree(Drive: Byte): Longint; assembler;
asm
	MOV	DL,Drive
	MOV	AH,36H
	INT	21H
	MOV	DX,AX
	CMP	AX,0FFFFH
	JE	@@1
	MUL	CX
	MUL	BX
@@1:
end;

function DiskSize(Drive: Byte): Longint; assembler;
asm
	MOV	DL,Drive
	MOV	AH,36H
	INT	21H
	MOV	BX,DX
	MOV	DX,AX
	CMP	AX,0FFFFH
	JE	@@1
	MUL	CX
	MUL	BX
@@1:
end;

procedure GetFAttr(var F; var Attr: Word); assembler;
asm
	PUSH	DS
	LDS	DX,F
	ADD	DX,OFFSET TFileRec.Name
	MOV	AX,4300H
	INT	21H
	POP	DS
	JNC	@@1
	XOR	CX,CX
	JMP	@@2
@@1:	XOR	AX,AX
@@2:	MOV	DosError,AX
	LES	DI,Attr
	XCHG	AX,CX
	STOSW
end;

procedure SetFAttr(var F; Attr: Word); assembler;
asm
	PUSH	DS
	LDS	DX,F
	ADD	DX,OFFSET TFileRec.Name
	MOV	CX,Attr
	MOV	AX,4301H
	INT	21H
	POP	DS
	JC	@@1
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

procedure GetFTime(var F; var Time: Longint); assembler;
asm
	LES	DI,F
	MOV	BX,ES:[DI].TFileRec.Handle
	MOV	AX,5700H
	INT	21H
	JNC	@@1
	XOR	CX,CX
	XOR	DX,DX
	JMP	@@2
@@1:	XOR	AX,AX
@@2:	MOV	DosError,AX
	LES	DI,Time
	CLD
	XCHG	AX,CX
	STOSW
	XCHG	AX,DX
	STOSW
end;

procedure SetFTime(var F; Time: Longint); assembler;
asm
	LES	DI,F
	MOV	BX,ES:[DI].TFileRec.Handle
	MOV	CX,WORD PTR Time[0]
	MOV	DX,WORD PTR Time[2]
	MOV	AX,5701H
	INT	21H
	JC	@@1
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

procedure FindFirst(Path: PChar; Attr: Word; var F: TSearchRec); assembler;
asm
	PUSH	DS
	LDS	DX,F
	MOV	AH,1AH
	INT	21H
	POP	DS
	LES	DI,Path
	MOV	CX,Attr
	MOV	AH,4EH
	CALL	AnsiDosFunc
	JC	@@1
{$IFDEF Windows}
	LES	DI,F
	ADD	DI,OFFSET TSearchRec.Name
	PUSH	ES
	PUSH	DI
	PUSH	ES
	PUSH	DI
	CALL	OemToAnsi
{$ENDIF}
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

procedure FindNext(var F: TSearchRec); assembler;
asm
	PUSH	DS
	LDS	DX,F
	MOV	AH,1AH
	INT	21H
	POP	DS
	MOV	AH,4FH
	INT	21H
	JC	@@1
{$IFDEF Windows}
	LES	DI,F
	ADD	DI,OFFSET TSearchRec.Name
	PUSH	ES
	PUSH	DI
	PUSH	ES
	PUSH	DI
	CALL	OemToAnsi
{$ENDIF}
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

procedure UnpackTime(P: Longint; var T: TDateTime); assembler;
asm
	LES	DI,T
	CLD
	MOV	AX,P.Word[2]
	MOV	CL,9
	SHR	AX,CL
	ADD	AX,1980
	STOSW
	MOV	AX,P.Word[2]
	MOV	CL,5
	SHR	AX,CL
	AND	AX,15
	STOSW
	MOV	AX,P.Word[2]
	AND	AX,31
	STOSW
	MOV	AX,P.Word[0]
	MOV	CL,11
	SHR	AX,CL
	STOSW
	MOV	AX,P.Word[0]
	MOV	CL,5
	SHR	AX,CL
	AND	AX,63
	STOSW
	MOV	AX,P.Word[0]
	AND	AX,31
	SHL	AX,1
	STOSW
end;

procedure PackTime(var T: TDateTime; var P: Longint); assembler;
asm
	PUSH	DS
	LDS	SI,T
	CLD
	LODSW
	SUB	AX,1980
	MOV	CL,9
	SHL	AX,CL
	XCHG	AX,DX
	LODSW
	MOV	CL,5
	SHL	AX,CL
	ADD	DX,AX
	LODSW
	ADD	DX,AX
	LODSW
	MOV	CL,11
	SHL	AX,CL
	XCHG	AX,BX
	LODSW
	MOV	CL,5
	SHL	AX,CL
	ADD	BX,AX
	LODSW
	SHR	AX,1
	ADD	AX,BX
	POP	DS
	LES	DI,P
	STOSW
	XCHG	AX,DX
	STOSW
end;

procedure GetIntVec(IntNo: Byte; var Vector: Pointer); assembler;
asm
	MOV	AL,IntNo
	MOV	AH,35H
	INT	21H
	MOV	AX,ES
	LES	DI,Vector
	CLD
	XCHG	AX,BX
	STOSW
	XCHG	AX,BX
	STOSW
end;

procedure SetIntVec(IntNo: Byte; Vector: Pointer); assembler;
asm
	PUSH	DS
	LDS	DX,Vector
	MOV	AL,IntNo
	MOV	AH,25H
	INT	21H
	POP	DS
end;

function FileSearch(Dest, Name, List: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	LDS	SI,List
	LES	DI,Dest
	MOV	CX,fsPathName
@@1:	PUSH	DS
	PUSH	SI
	JCXZ	@@3
	LDS	SI,Name
@@2:	LODSB
	OR	AL,AL
	JE	@@3
	STOSB
	LOOP	@@2
@@3:	XOR	AL,AL
	STOSB
	LES	DI,Dest
	MOV	AX,4300H
	CALL	AnsiDosFunc
	POP	SI
	POP	DS
	JC	@@4
	TEST	CX,18H
	JE	@@9
@@4:	LES	DI,Dest
	MOV	CX,fsPathName
	XOR	AH,AH
	LODSB
	OR	AL,AL
	JE	@@8
@@5:	CMP	AL,';'
	JE	@@7
	JCXZ	@@6
	MOV	AH,AL
	STOSB
	DEC	CX
@@6:	LODSB
	OR	AL,AL
	JNE	@@5
	DEC	SI
@@7:	JCXZ	@@1
	CMP	AH,':'
	JE	@@1
	MOV	AL,'\'
	CMP	AL,AH
        JE	@@1
	STOSB
	DEC	CX
	JMP	@@1
@@8:	STOSB
@@9:	MOV	AX,Dest.Word[0]
	MOV	DX,Dest.Word[2]
	POP	DS
end;

function FileExpand(Dest, Name: PChar): PChar; assembler;
var
  TempName: array[0..159] of Char;
asm
	PUSH	DS
	CLD
	LDS	SI,Name
	LEA	DI,TempName
	PUSH	SS
	POP	ES
	LODSW
	OR	AL,AL
	JE	@@1
	CMP	AH,':'
	JNE	@@1
	CMP	AL,'a'
	JB	@@2
	CMP	AL,'z'
	JA	@@2
	SUB	AL,20H
	JMP	@@2
@@1:	DEC	SI
	DEC	SI
	MOV	AH,19H
	INT	21H
	ADD	AL,'A'
	MOV	AH,':'
@@2:	STOSW
	CMP	[SI].Byte,'\'
	JE	@@3
	SUB	AL,'A'-1
	MOV	DL,AL
	MOV	AL,'\'
	STOSB
	PUSH	DS
	PUSH	SI
	MOV	AH,47H
	MOV	SI,DI
	PUSH	ES
	POP	DS
	INT	21H
	POP	SI
	POP	DS
	JC	@@3
	XOR	AL,AL
	CMP	AL,ES:[DI]
	JE	@@3
{$IFDEF Windows}
	PUSH	ES
	PUSH	ES
	PUSH	DI
	PUSH	ES
	PUSH	DI
	CALL	OemToAnsi
	POP	ES
{$ENDIF}
	MOV	CX,0FFFFH
	XOR	AL,AL
	CLD
	REPNE	SCASB
	DEC	DI
	MOV	AL,'\'
	STOSB
@@3:	MOV	CX,8
@@4:	LODSB
	OR	AL,AL
	JE	@@7
	CMP	AL,'\'
	JE	@@7
	CMP	AL,'.'
	JE	@@6
	JCXZ	@@4
	DEC	CX
{$IFNDEF Windows}
	CMP	AL,'a'
	JB	@@5
	CMP	AL,'z'
	JA	@@5
	SUB	AL,20H
{$ENDIF}
@@5:	STOSB
	JMP	@@4
@@6:	MOV	CL,3
	JMP	@@5
@@7:	CMP	ES:[DI-2].Word,'.\'
	JNE	@@8
	DEC	DI
	DEC	DI
	JMP	@@10
@@8:	CMP	ES:[DI-2].Word,'..'
	JNE	@@10
	CMP	ES:[DI-3].Byte,'\'
	JNE	@@10
	SUB	DI,3
	CMP	ES:[DI-1].Byte,':'
	JE	@@10
@@9:	DEC	DI
	CMP	ES:[DI].Byte,'\'
	JNE	@@9
@@10:	MOV	CL,8
	OR	AL,AL
	JNE	@@5
	CMP	ES:[DI-1].Byte,':'
	JNE	@@11
	MOV	AL,'\'
	STOSB
@@11:	LEA	SI,TempName
	PUSH	SS
	POP	DS
	MOV	CX,DI
	SUB	CX,SI
	CMP	CX,79
	JBE	@@12
	MOV	CX,79
@@12:	LES	DI,Dest
	PUSH	ES
	PUSH	DI
{$IFDEF Windows}
	PUSH	ES
	PUSH	DI
{$ENDIF}
	REP	MOVSB
	XOR	AL,AL
	STOSB
{$IFDEF Windows}
	CALL	AnsiUpper
{$ENDIF}
	POP	AX
	POP	DX
	POP	DS
end;

{$W+}

function FileSplit(Path, Dir, Name, Ext: PChar): Word;
var
  DirLen, NameLen, Flags: Word;
  NamePtr, ExtPtr: PChar;
begin
  NamePtr := StrRScan(Path, '\');
  if NamePtr = nil then NamePtr := StrRScan(Path, ':');
  if NamePtr = nil then NamePtr := Path else Inc(NamePtr);
  ExtPtr := StrScan(NamePtr, '.');
  if ExtPtr = nil then ExtPtr := StrEnd(NamePtr);
  DirLen := NamePtr - Path;
  if DirLen > fsDirectory then DirLen := fsDirectory;
  NameLen := ExtPtr - NamePtr;
  if NameLen > fsFilename then NameLen := fsFilename;
  Flags := 0;
  if (StrScan(NamePtr, '?') <> nil) or (StrScan(NamePtr, '*') <> nil) then
    Flags := fcWildcards;
  if DirLen <> 0 then Flags := Flags or fcDirectory;
  if NameLen <> 0 then Flags := Flags or fcFilename;
  if ExtPtr[0] <> #0 then Flags := Flags or fcExtension;
  if Dir <> nil then StrLCopy(Dir, Path, DirLen);
  if Name <> nil then StrLCopy(Name, NamePtr, NameLen);
  if Ext <> nil then StrLCopy(Ext, ExtPtr, fsExtension);
  FileSplit := Flags;
end;

{$W-}

function GetCurDir(Dir: PChar; Drive: Byte): PChar; assembler;
asm
	MOV	AL,Drive
	OR	AL,AL
	JNE	@@1
	MOV	AH,19H
	INT	21H
	INC	AX
@@1:	MOV	DL,AL
	LES	DI,Dir
	PUSH	ES
	PUSH	DI
	CLD
	ADD	AL,'A'-1
	MOV	AH,':'
	STOSW
	MOV	AX,'\'
	STOSW
	PUSH	DS
	LEA	SI,[DI-1]
	PUSH	ES
	POP	DS
	MOV	AH,47H
	INT	21H
	JC	@@2
{$IFDEF Windows}
	PUSH	DS
	PUSH	SI
	PUSH	DS
	PUSH	SI
	CALL	OemToAnsi
{$ENDIF}
	XOR	AX,AX
@@2:	POP	DS
	MOV	DosError,AX
	POP	AX
	POP	DX
end;

procedure SetCurDir(Dir: PChar); assembler;
asm
	LES	DI,Dir
	MOV	AX,ES:[DI]
	OR	AL,AL
	JE	@@2
	CMP	AH,':'
	JNE	@@1
	AND	AL,0DFH
	SUB	AL,'A'
	MOV	DL,AL
	MOV	AH,0EH
	INT	21H
	MOV	AH,19H
	INT	21H
	CMP	AL,DL
	MOV	AX,15
	JNE	@@3
	CMP	AH,ES:[DI+2]
	JE	@@2
@@1:	MOV	AH,3BH
	CALL	AnsiDosFunc
	JC	@@3
@@2:	XOR	AX,AX
@@3:	MOV	DosError,AX
end;

procedure CreateDir(Dir: PChar); assembler;
asm
	LES	DI,Dir
	MOV	AH,39H
	CALL	AnsiDosFunc
	JC	@@1
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

procedure RemoveDir(Dir: PChar); assembler;
asm
	LES	DI,Dir
	MOV	AH,3AH
	CALL	AnsiDosFunc
	JC	@@1
	XOR	AX,AX
@@1:	MOV	DosError,AX
end;

{$IFDEF Windows}

procedure ArgStrCount; assembler;
asm
	LDS	SI,CmdLine
	CLD
@@1:	LODSB
	OR	AL,AL
	JE	@@2
	CMP	AL,' '
	JBE	@@1
@@2:	DEC	SI
	MOV	BX,SI
@@3:	LODSB
	CMP	AL,' '
	JA	@@3
	DEC	SI
	MOV	AX,SI
	SUB	AX,BX
	JE	@@4
	LOOP	@@1
@@4:
end;

function GetArgCount: Integer; assembler;
asm
	PUSH	DS
	XOR	CX,CX
	CALL	ArgStrCount
	XCHG	AX,CX
	NEG	AX
	POP	DS
end;

function GetArgStr(Dest: PChar; Index: Integer;
  MaxLen: Word): PChar; assembler;
asm
	MOV	CX,Index
	JCXZ	@@2
	PUSH	DS
	CALL	ArgStrCount
	MOV	SI,BX
	LES	DI,Dest
	MOV	CX,MaxLen
	CMP	CX,AX
	JB	@@1
	XCHG	AX,CX
@@1:	REP	MOVSB
	XCHG	AX,CX
	STOSB
	POP	DS
	JMP	@@3
@@2:	PUSH	HInstance
	PUSH	Dest.Word[2]
	PUSH	Dest.Word[0]
	MOV	AX,MaxLen
	INC	AX
	PUSH	AX
	CALL	GetModuleFileName
@@3:	MOV	AX,Dest.Word[0]
	MOV	DX,Dest.Word[2]
end;

{$ELSE}

procedure ArgStrCount; assembler;
asm
	MOV	DS,PrefixSeg
	MOV	SI,80H
	CLD
	LODSB
	MOV	DL,AL
	XOR	DH,DH
	ADD	DX,SI
@@1:	CMP	SI,DX
	JE	@@2
	LODSB
	CMP	AL,' '
	JBE	@@1
	DEC	SI
@@2:	MOV	BX,SI
@@3:	CMP	SI,DX
	JE	@@4
	LODSB
	CMP	AL,' '
	JA	@@3
	DEC	SI
@@4:	MOV	AX,SI
	SUB	AX,BX
	JE	@@5
	LOOP	@@1
@@5:
end;

function GetArgCount: Integer; assembler;
asm
	PUSH	DS
	XOR	CX,CX
	CALL	ArgStrCount
	XCHG	AX,CX
	NEG	AX
	POP	DS
end;

function GetArgStr(Dest: PChar; Index: Integer;
  MaxLen: Word): PChar; assembler;
asm
	PUSH	DS
	MOV	CX,Index
	JCXZ	@@1
	CALL	ArgStrCount
	MOV	SI,BX
	JMP	@@4
@@1:	MOV	AH,30H
	INT	21H
	CMP	AL,3
	MOV	AX,0
	JB	@@4
	MOV	DS,PrefixSeg
	MOV	ES,DS:WORD PTR 2CH
	XOR	DI,DI
	CLD
@@2:	CMP	AL,ES:[DI]
	JE	@@3
	MOV	CX,-1
	REPNE	SCASB
	JMP	@@2
@@3:	ADD	DI,3
	MOV	SI,DI
	PUSH	ES
	POP	DS
	MOV	CX,256
	REPNE	SCASB
	XCHG	AX,CX
	NOT	AL
@@4:	LES	DI,Dest
	MOV	CX,MaxLen
	CMP	CX,AX
	JB	@@5
	XCHG	AX,CX
@@5:	REP	MOVSB
	XCHG	AX,CX
	STOSB
	MOV	AX,Dest.Word[0]
	MOV	DX,Dest.Word[2]
	POP	DS
end;

{$ENDIF}

{$W+}

function GetEnvVar(VarName: PChar): PChar;
var
  L: Word;
  P: PChar;
begin
  L := StrLen(VarName);
{$IFDEF Windows}
  P := GetDosEnvironment;
{$ELSE}
  P := Ptr(Word(Ptr(PrefixSeg, $2C)^), 0);
{$ENDIF}
  while P^ <> #0 do
  begin
    if (StrLIComp(P, VarName, L) = 0) and (P[L] = '=') then
    begin
      GetEnvVar := P + L + 1;
      Exit;
    end;
    Inc(P, StrLen(P) + 1);
  end;
  GetEnvVar := nil;
end;

{$W-}

end.
