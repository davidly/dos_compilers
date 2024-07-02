
{*******************************************************}
{                                                       }
{       Turbo Pascal Runtime Library                    }
{       String Handling Unit                            }
{                                                       }
{       Copyright (C) 1990,92 Borland International     }
{                                                       }
{*******************************************************}

unit Strings;

{$S-}

interface

{ StrLen returns the number of characters in Str, not counting  }
{ the null terminator.                                          }

function StrLen(Str: PChar): Word;

{ StrEnd returns a pointer to the null character that           }
{ terminates Str.                                               }

function StrEnd(Str: PChar): PChar;

{ StrMove copies exactly Count characters from Source to Dest   }
{ and returns Dest. Source and Dest may overlap.                }

function StrMove(Dest, Source: PChar; Count: Word): PChar;

{ StrCopy copies Source to Dest and returns Dest.               }

function StrCopy(Dest, Source: PChar): PChar;

{ StrECopy copies Source to Dest and returns StrEnd(Dest).      }

function StrECopy(Dest, Source: PChar): PChar;

{ StrLCopy copies at most MaxLen characters from Source to Dest }
{ and returns Dest.                                             }

function StrLCopy(Dest, Source: PChar; MaxLen: Word): PChar;

{ StrPCopy copies the Pascal style string Source into Dest and  }
{ returns Dest.                                                 }

function StrPCopy(Dest: PChar; Source: String): PChar;

{ StrCat appends a copy of Source to the end of Dest and        }
{ returns Dest.                                                 }

function StrCat(Dest, Source: PChar): PChar;

{ StrLCat appends at most MaxLen - StrLen(Dest) characters from }
{ Source to the end of Dest, and returns Dest.                  }

function StrLCat(Dest, Source: PChar; MaxLen: Word): PChar;

{ StrComp compares Str1 to Str2. The return value is less than  }
{ 0 if Str1 < Str2, 0 if Str1 = Str2, or greater than 0 if      }
{ Str1 > Str2.                                                  }

function StrComp(Str1, Str2: PChar): Integer;

{ StrIComp compares Str1 to Str2, without case sensitivity. The }
{ return value is the same as StrComp.                          }

function StrIComp(Str1, Str2: PChar): Integer;

{ StrLComp compares Str1 to Str2, for a maximum length of       }
{ MaxLen characters. The return value is the same as StrComp.   }

function StrLComp(Str1, Str2: PChar; MaxLen: Word): Integer;

{ StrLIComp compares Str1 to Str2, for a maximum length of      }
{ MaxLen characters, without case sensitivity. The return value }
{ is the same as StrComp.                                       }

function StrLIComp(Str1, Str2: PChar; MaxLen: Word): Integer;

{ StrScan returns a pointer to the first occurrence of Chr in   }
{ Str. If Chr does not occur in Str, StrScan returns NIL. The   }
{ null terminator is considered to be part of the string.       }

function StrScan(Str: PChar; Chr: Char): PChar;

{ StrRScan returns a pointer to the last occurrence of Chr in   }
{ Str. If Chr does not occur in Str, StrRScan returns NIL. The  }
{ null terminator is considered to be part of the string.       }

function StrRScan(Str: PChar; Chr: Char): PChar;

{ StrPos returns a pointer to the first occurrence of Str2 in   }
{ Str1. If Str2 does not occur in Str1, StrPos returns NIL.     }

function StrPos(Str1, Str2: PChar): PChar;

{ StrUpper converts Str to upper case and returns Str.          }

function StrUpper(Str: PChar): PChar;

{ StrLower converts Str to lower case and returns Str.          }

function StrLower(Str: PChar): PChar;

{ StrPas converts Str to a Pascal style string.                 }

function StrPas(Str: PChar): String;

{ StrNew allocates a copy of Str on the heap. If Str is NIL or  }
{ points to an empty string, StrNew returns NIL and doesn't     }
{ allocate any heap space. Otherwise, StrNew makes a duplicate  }
{ of Str, obtaining space with a call to the GetMem standard    }
{ procedure, and returns a pointer to the duplicated string.    }
{ The allocated space is StrLen(Str) + 1 bytes long.            }

function StrNew(Str: PChar): PChar;

{ StrDispose disposes a string that was previously allocated    }
{ with StrNew. If Str is NIL, StrDispose does nothing.          }

procedure StrDispose(Str: PChar);

implementation

{$W-}

function StrLen(Str: PChar): Word; assembler;
asm
	CLD
	LES	DI,Str
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	MOV	AX,0FFFEH
	SUB	AX,CX
end;

function StrEnd(Str: PChar): PChar; assembler;
asm
	CLD
	LES	DI,Str
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	MOV	AX,DI
	MOV	DX,ES
	DEC	AX
end;

function StrMove(Dest, Source: PChar; Count: Word): PChar; assembler;
asm
	PUSH	DS
	CLD
	LDS	SI,Source
	LES	DI,Dest
	MOV	AX,DI
	MOV	DX,ES
	MOV	CX,Count
	CMP	SI,DI
	JAE	@@1
	STD
	ADD	SI,CX
	ADD	DI,CX
	DEC	SI
	DEC	DI
@@1:	REP	MOVSB
	CLD
	POP	DS
end;

function StrCopy(Dest, Source: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Source
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	LDS	SI,Source
	LES	DI,Dest
	MOV	AX,DI
	MOV	DX,ES
	REP	MOVSB
	POP	DS
end;

function StrECopy(Dest, Source: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Source
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	LDS	SI,Source
	LES	DI,Dest
	REP	MOVSB
	MOV	AX,DI
	MOV	DX,ES
	DEC	AX
	POP	DS
end;

function StrLCopy(Dest, Source: PChar; MaxLen: Word): PChar; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Source
	MOV	CX,MaxLen
	MOV	BX,CX
	XOR	AL,AL
	REPNE	SCASB
	SUB	BX,CX
	MOV	CX,BX
	LDS	SI,Source
	LES	DI,Dest
	MOV	BX,DI
	MOV	DX,ES
	REP	MOVSB
	STOSB
	XCHG	AX,BX
	POP	DS
end;

function StrPCopy(Dest: PChar; Source: String): PChar; assembler;
asm
	PUSH	DS
	CLD
	LDS	SI,Source
	LES	DI,Dest
	MOV	BX,DI
	MOV	DX,ES
	LODSB
	XOR	AH,AH
	XCHG	AX,CX
	REP	MOVSB
	XOR	AL,AL
	STOSB
	XCHG	AX,BX
	POP	DS
end;

function StrCat(Dest, Source: PChar): PChar; assembler;
asm
	PUSH	Dest.Word[2]
	PUSH	Dest.Word[0]
	PUSH	CS
	CALL	NEAR PTR StrEnd
	PUSH	DX
	PUSH	AX
	PUSH	Source.Word[2]
	PUSH	Source.Word[0]
	PUSH	CS
	CALL	NEAR PTR StrCopy
	MOV	AX,Dest.Word[0]
	MOV	DX,Dest.Word[2]
end;

function StrLCat(Dest, Source: PChar; MaxLen: Word): PChar; assembler;
asm
	PUSH	Dest.Word[2]
	PUSH	Dest.Word[0]
	PUSH	CS
	CALL	NEAR PTR StrEnd
	MOV	CX,Dest.Word[0]
	ADD	CX,MaxLen
	SUB	CX,AX
	JBE	@@1
	PUSH	DX
	PUSH	AX
	PUSH	Source.Word[2]
	PUSH	Source.Word[0]
	PUSH	CX
	PUSH	CS
	CALL	NEAR PTR StrLCopy
@@1:	MOV	AX,Dest.Word[0]
	MOV	DX,Dest.Word[2]
end;

function StrComp(Str1, Str2: PChar): Integer; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str2
	MOV	SI,DI
	MOV	CX,0FFFFH
	XOR	AX,AX
	CWD
	REPNE	SCASB
	NOT	CX
	MOV	DI,SI
	LDS	SI,Str1
	REPE	CMPSB
	MOV	AL,DS:[SI-1]
	MOV	DL,ES:[DI-1]
	SUB	AX,DX
	POP	DS
end;

function StrIComp(Str1, Str2: PChar): Integer; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str2
	MOV	SI,DI
	MOV	CX,0FFFFH
	XOR	AX,AX
	CWD
	REPNE	SCASB
	NOT	CX
	MOV	DI,SI
	LDS	SI,Str1
@@1:	REPE	CMPSB
	JE	@@4
	MOV	AL,DS:[SI-1]
	CMP	AL,'a'
	JB	@@2
	CMP	AL,'z'
	JA	@@2
	SUB	AL,20H
@@2:	MOV	DL,ES:[DI-1]
	CMP	DL,'a'
	JB	@@3
	CMP	DL,'z'
	JA	@@3
	SUB	DL,20H
@@3:	SUB	AX,DX
	JE	@@1
@@4:	POP	DS
end;

function StrLComp(Str1, Str2: PChar; MaxLen: Word): Integer; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str2
	MOV	SI,DI
	MOV	AX,MaxLen
	MOV	CX,AX
	JCXZ	@@1
	XCHG	AX,BX
	XOR	AX,AX
	CWD
	REPNE	SCASB
	SUB	BX,CX
	MOV	CX,BX
	MOV	DI,SI
	LDS	SI,Str1
	REPE	CMPSB
	MOV	AL,DS:[SI-1]
	MOV	DL,ES:[DI-1]
	SUB	AX,DX
@@1:	POP	DS
end;

function StrLIComp(Str1, Str2: PChar; MaxLen: Word): Integer; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str2
	MOV	SI,DI
	MOV	AX,MaxLen
	MOV	CX,AX
	JCXZ	@@4
	XCHG	AX,BX
	XOR	AX,AX
	CWD
	REPNE	SCASB
	SUB	BX,CX
	MOV	CX,BX
	MOV	DI,SI
	LDS	SI,Str1
@@1:	REPE	CMPSB
	JE	@@4
	MOV	AL,DS:[SI-1]
	CMP	AL,'a'
	JB	@@2
	CMP	AL,'z'
	JA	@@2
	SUB	AL,20H
@@2:	MOV	DL,ES:[DI-1]
	CMP	DL,'a'
	JB	@@3
	CMP	DL,'z'
	JA	@@3
	SUB	DL,20H
@@3:	SUB	AX,DX
	JE	@@1
@@4:	POP	DS
end;

function StrScan(Str: PChar; Chr: Char): PChar; assembler;
asm
	CLD
	LES	DI,Str
	MOV	SI,DI
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	MOV	DI,SI
	MOV	AL,Chr
	REPNE	SCASB
	MOV	AX,0
	CWD
	JNE	@@1
	MOV	AX,DI
	MOV	DX,ES
	DEC	AX
@@1:
end;

function StrRScan(Str: PChar; Chr: Char): PChar; assembler;
asm
	CLD
	LES	DI,Str
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	STD
	DEC	DI
	MOV	AL,Chr
	REPNE	SCASB
	MOV	AX,0
	CWD
	JNE	@@1
	MOV	AX,DI
	MOV	DX,ES
	INC	AX
@@1:	CLD
end;

function StrPos(Str1, Str2: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	XOR	AL,AL
	LES	DI,Str2
	MOV	CX,0FFFFH
	REPNE	SCASB
	NOT	CX
	DEC	CX
	JE	@@2
	MOV	DX,CX
	MOV	BX,ES
	MOV	DS,BX
	LES	DI,Str1
	MOV	BX,DI
	MOV	CX,0FFFFH
	REPNE	SCASB
	NOT	CX
	SUB	CX,DX
	JBE	@@2
	MOV	DI,BX
@@1:	MOV	SI,Str2.Word[0]
	LODSB
	REPNE	SCASB
	JNE	@@2
	MOV	AX,CX
	MOV	BX,DI
	MOV	CX,DX
	DEC	CX
	REPE	CMPSB
	MOV	CX,AX
	MOV	DI,BX
	JNE	@@1
	MOV	AX,DI
	MOV	DX,ES
	DEC	AX
	JMP	@@3
@@2:	XOR	AX,AX
	MOV	DX,AX
@@3:	POP	DS
end;

function StrUpper(Str: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	LDS	SI,Str
	MOV	BX,SI
	MOV	DX,DS
@@1:	LODSB
	OR	AL,AL
	JE	@@2
	CMP	AL,'a'
	JB	@@1
	CMP	AL,'z'
	JA	@@1
	SUB	AL,20H
	MOV	[SI-1],AL
	JMP	@@1
@@2:	XCHG	AX,BX
	POP	DS
end;

function StrLower(Str: PChar): PChar; assembler;
asm
	PUSH	DS
	CLD
	LDS	SI,Str
	MOV	BX,SI
	MOV	DX,DS
@@1:	LODSB
	OR	AL,AL
	JE	@@2
	CMP	AL,'A'
	JB	@@1
	CMP	AL,'Z'
	JA	@@1
	ADD	AL,20H
	MOV	[SI-1],AL
	JMP	@@1
@@2:	XCHG	AX,BX
	POP	DS
end;

function StrPas(Str: PChar): String; assembler;
asm
	PUSH	DS
	CLD
	LES	DI,Str
	MOV	CX,0FFFFH
	XOR	AL,AL
	REPNE	SCASB
	NOT	CX
	DEC	CX
	LDS	SI,Str
	LES	DI,@Result
	MOV	AL,CL
	STOSB
	REP	MOVSB
	POP	DS
end;

{$W+}

function StrNew(Str: PChar): PChar;
var
  L: Word;
  P: PChar;
begin
  StrNew := nil;
  if (Str <> nil) and (Str^ <> #0) then
  begin
    L := StrLen(Str) + 1;
    GetMem(P, L);
    if P <> nil then StrNew := StrMove(P, Str, L);
  end;
end;

procedure StrDispose(Str: PChar);
begin
  if Str <> nil then FreeMem(Str, StrLen(Str) + 1);
end;

end.
