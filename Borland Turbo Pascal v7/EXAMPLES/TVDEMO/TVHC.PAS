{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{===== TVHC version 1.1 ================================================}
{  Turbo Vision help file compiler documentation.                       }
{=======================================================================}
{                                                                       }
{    Refer to DEMOHELP.TXT for an example of a help source file.        }
{                                                                       }
{    This program takes a help script and produces a help file (.HLP)   }
{    and a help context file (.PAS).  The format for the help file is   }
{    very simple.  Each context is given a symbolic name (i.e FileOpen) }
{    which is then put in the context file (i.e. hcFileOpen).  The text }
{    following the topic line is put into the help file.  Since the     }
{    help file can be resized, some of the text will need to be wrapped }
{    to fit into the window.  If a line of text is flush left with      }
{    no preceeding white space, the line will be wrapped.  All adjacent }
{    wrappable lines are wrapped as a paragraph.  If a line begins with }
{    a space it will not be wrapped. For example, the following is a    }
{    help topic for a File|Open menu item.                              }
{                                                                       }
{       |.topic FileOpen                                                }
{       |  File|Open                                                    }
{       |  ---------                                                    }
{       |This menu item will bring up a dialog...                       }
{                                                                       }
{    The "File|Open" will not be wrapped with the "----" line since     }
{    they both begin with a space, but the "This menu..." line will     }
{    be wrapped.                                                        }
{      The syntax for a ".topic" line is:                               }
{                                                                       }
{        .topic symbol[=number][, symbol[=number][...]]                 }
{                                                                       }
{    Note a topic can have multiple symbols that define it so that one  }
{    topic can be used by multiple contexts.  The number is optional    }
{    and will be the value of the hcXXX context in the context file     }
{    Once a number is assigned all following topic symbols will be      }
{    assigned numbers in sequence.  For example,                        }
{                                                                       }
{       .topic FileOpen=3, OpenFile, FFileOpen                          }
{                                                                       }
{    will produce the follwing help context number definitions,         }
{                                                                       }
{        hcFileOpen  = 3;                                               }
{        hcOpenFile  = 4;                                               }
{        hcFFileOpen = 5;                                               }
{                                                                       }
{    Cross references can be imbedded in the text of a help topic which }
{    allows the user to quickly access related topics.  The format for  }
{    a cross reference is as follows,                                   }
{                                                                       }
(*        {text[:alias]}                                               *)
{                                                                       }
{    The text in the brackets is highlighted by the help viewer.  This  }
{    text can be selected by the user and will take the user to the     }
{    topic by the name of the text.  Sometimes the text will not be     }
{    the same as a topic symbol.  In this case you can use the optional }
{    alias syntax.  The symbol you wish to use is placed after the text }
{    after a ':'. The following is a paragraph of text using cross      }
{    references,                                                        }
{                                                                       }
(*      |The {file open dialog:FileOpen} allows you specify which      *)
{       |file you wish to view.  If it also allow you to navigate       }
{       |directories.  To change to a given directory use the           }
(*      |{change directory dialog:ChDir}.                              *)
{                                                                       }
{    The user can tab or use the mouse to select more information about }
{    the "file open dialog" or the "change directory dialog". The help  }
{    compiler handles forward references so a topic need not be defined }
{    before it is referenced.  If a topic is referenced but not         }
{    defined, the compiler will give a warning but will still create a  }
{    useable help file.  If the undefined reference is used, a message  }
{    ("No help available...") will appear in the help window.           }
{=======================================================================}

program TVHC;

{$S-}

{$M 8192,8192,655360}

uses Drivers, Objects, Dos, Strings, HelpFile;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\DOS\TVDEMO directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

{======================= File Management ===============================}

procedure Error(Text: String); forward;

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    FileName: FNameStr;
    Mode: Word;
    constructor Init(AFileName: FNameStr; AMode, Size: Word);
    destructor Done; virtual;
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  TextStrm,
  SymbStrm: TProtectedStream;

const
  HelpStrm: PProtectedStream = nil;

constructor TProtectedStream.Init(AFileName: FNameStr; AMode, Size: Word);
begin
  inherited Init(AFileName, AMode, Size);
  FileName := AFileName;
  Mode := AMode;
end;

destructor TProtectedStream.Done;
var
  F: File;
begin
  inherited Done;
  if (Mode = stCreate) and ((Status <> stOk) or (ExitCode <> 0)) then
  begin
    Assign(F, FileName);
    Erase(F);
  end;
end;

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  case Code of
    stError:
      TVHC.Error('Error encountered in file ' + FileName);
    stInitError:
      if Mode = stCreate then
        TVHC.Error('Could not create ' + FileName)
      else
        TVHC.Error('Could not find ' + FileName);
    stReadError: Status := Code; {EOF is "ok"}
    stWriteError:
      TVHC.Error('Disk full encountered writting file '+ FileName);
  else
      TVHC.Error('Internal error.');
  end;
end;

{----- UpStr(Str) ------------------------------------------------------}
{  Returns a string with Str uppercased.				}
{-----------------------------------------------------------------------}

function UpStr(Str: String): String;
var
  I: Integer;
begin
  for I := 1 to Length(Str) do
    Str[I] := UpCase(Str[I]);
  UpStr := Str;
end;

{----- ReplaceExt(FileName, NExt, Force) -------------------------------}
{  Replace the extension of the given file with the given extension.    }
{  If the an extension already exists Force indicates if it should be   }
{  replaced anyway.                                                     }
{-----------------------------------------------------------------------}

function ReplaceExt(FileName: PathStr; NExt: ExtStr; Force: Boolean):
  PathStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FileName := UpStr(FileName);
  FSplit(FileName, Dir, Name, Ext);
  if Force or (Ext = '') then
    ReplaceExt := Dir + Name + NExt else
    ReplaceExt := FileName;
end;

{----- FExist(FileName) ------------------------------------------------}
{  Returns true if the file exists false otherwise.                     }
{-----------------------------------------------------------------------}

function FExists(FileName: PathStr): Boolean;
var
  F: file;
  Attr: Word;
begin
  Assign(F, FileName);
  GetFAttr(F, Attr);
  FExists := DosError = 0;
end;


{======================== Line Management ==============================}

{----- GetLine(S) ------------------------------------------------------}
{  Return the next line out of the stream.                              }
{-----------------------------------------------------------------------}

const
  Line: String = '';
  LineInBuffer: Boolean = False;
  Count: Integer = 0;

function GetLine(var S: TStream): String;
var
  C, I: Byte;
begin
  if S.Status <> stOk then
  begin
    GetLine := #26;
    Exit;
  end;
  if not LineInBuffer then
  begin
    Line := '';
    C := 0;
    I := 0;
    while (Line[I] <> #13) and (I < 254) and (S.Status = stOk) do
    begin
      Inc(I);
      S.Read(Line[I], 1);
    end;
    Dec(I);
    S.Read(C, 1); { Skip #10 }
    Line[0] := Char(I);
  end;
  Inc(Count);

  { Return a blank line if the line is a comment }
  if Line[1] = ';' then Line[0] := #0;

  GetLine := Line;
  LineInBuffer := False;
end;

{----- UnGetLine(S) ----------------------------------------------------}
{  Return given line into the stream.                                   }
{-----------------------------------------------------------------------}

procedure UnGetLine(S: String);
begin
  Line := S;
  LineInBuffer := True;
  Dec(Count);
end;

{========================= Error routines ==============================}

{----- PrntMsg(Text) ---------------------------------------------------}
{  Used by Error and Warning to print the message.                      }
{-----------------------------------------------------------------------}

procedure PrntMsg(Pref: String; var Text: String);
const
  Blank: String[1] = '';
var
  S: String;
  L: array[0..3] of LongInt;
begin
  L[0] := LongInt(@Pref);
  if HelpStrm <> nil then
    L[1] := LongInt(@HelpStrm^.FileName)
  else
    L[1] := LongInt(@Blank);
  L[2] := Count;
  L[3] := LongInt(@Text);
  if Count > 0 then FormatStr(S, '%s: %s(%d): %s'#13#10, L)
  else FormatStr(S, '%s: %s %3#%s', L);
  PrintStr(S);
end;

{----- Error(Text) -----------------------------------------------------}
{  Used to indicate an error.  Terminates the program                   }
{-----------------------------------------------------------------------}

procedure Error(Text: String);
begin
  PrntMsg('Error', Text);
  Halt(1);
end;

{----- Warning(Text) ---------------------------------------------------}
{  Used to indicate an warning.                                         }
{-----------------------------------------------------------------------}

procedure Warning(Text: String);
begin
  PrntMsg('Warning', Text);
end;

{================ Built-in help context number managment ===============}

type
  TBuiltInContext = record
    Text: PChar;
    Number: Word;
  end;

{ A list of all the help contexts defined in APP }
const
  BuiltInContextTable: array[0..21] of TBuiltInContext = (
    (Text: 'Cascade';   Number: $FF21),
    (Text: 'ChangeDir'; Number: $FF06),
    (Text: 'Clear';     Number: $FF14),
    (Text: 'Close';     Number: $FF27),
    (Text: 'CloseAll';  Number: $FF22),
    (Text: 'Copy';      Number: $FF12),
    (Text: 'Cut';       Number: $FF11),
    (Text: 'DosShell';  Number: $FF07),
    (Text: 'Dragging';  Number: 1),
    (Text: 'Exit';      Number: $FF08),
    (Text: 'New';       Number: $FF01),
    (Text: 'Next';      Number: $FF25),
    (Text: 'Open';      Number: $FF02),
    (Text: 'Paste';     Number: $FF13),
    (Text: 'Prev';      Number: $FF26),
    (Text: 'Resize';    Number: $FF23),
    (Text: 'Save';      Number: $FF03),
    (Text: 'SaveAll';   Number: $FF05),
    (Text: 'SaveAs';    Number: $FF04),
    (Text: 'Tile';      Number: $FF20),
    (Text: 'Undo';      Number: $FF10),
    (Text: 'Zoom';      Number: $FF24)
    );

function IsBuiltInContext(Text: String; var Number: Word): Boolean;
var
  Hi, Lo, Mid, Cmp: Integer;
begin
  { Convert Text into a #0 terminted PChar }
  Inc(Text[0]);
  Text[Length(Text)] := #0;

  Hi := High(BuiltInContextTable);
  Lo := Low(BuiltInContextTable);
  while Lo <= Hi do
  begin
    Mid := (Hi + Lo) div 2;
    Cmp := StrComp(@Text[1], BuiltInContextTable[Mid].Text);
    if Cmp > 0 then
      Lo := Mid + 1
    else if Cmp < 0 then
      Hi := Mid - 1
    else
    begin
      Number := BuiltInContextTable[Mid].Number;
      IsBuiltInContext := True;
      Exit;
    end;
  end;
  IsBuiltInContext := False;
end;

{====================== Topic Reference Management =====================}

type
  PFixUp = ^TFixUp;
  TFixUp = record
    Pos: LongInt;
    Next: PFixUp;
  end;

  PReference = ^TReference;
  TReference = record
    Topic: PString;
    case Resolved: Boolean of
      True:  (Value: Word);
      False: (FixUpList: PFixUp);
  end;

  PRefTable = ^TRefTable;
  TRefTable = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetReference(var Topic: String): PReference;
    function KeyOf(Item: Pointer): Pointer; virtual;
  end;

const
  RefTable: PRefTable = nil;

procedure DisposeFixUps(P: PFixUp);
var
  Q: PFixUp;
begin
  while P <> nil do
  begin
    Q := P^.Next;
    Dispose(P);
    P := Q;
  end;
end;

{----- TRefTable -------------------------------------------------------}
{  TRefTable is a collection of PReference's used as a symbol table.    }
{  If the topic has not been seen, a forward reference is inserted and  }
{  a fix-up list is started.  When the topic is seen all forward        }
{  references are resolved.  If the topic has been seen already the     }
{  value it has is used.                                                }
{-----------------------------------------------------------------------}

function TRefTable.Compare(Key1, Key2: Pointer): Integer;
var
  K1,K2: String;
begin
  K1 := UpStr(PString(Key1)^);
  K2 := UpStr(PString(Key2)^);
  if K1 > K2 then Compare := 1
  else if K1 < K2 then Compare := -1
  else Compare := 0;
end;

procedure TRefTable.FreeItem(Item: Pointer);
var
  Ref: PReference absolute Item;
  P, Q: PFixUp;
begin
  if not Ref^.Resolved then DisposeFixUps(Ref^.FixUpList);
  DisposeStr(Ref^.Topic);
  Dispose(Ref);
end;

function TRefTable.GetReference(var Topic: String): PReference;
var
  Ref: PReference;
  I: Integer;
begin
  if Search(@Topic, I) then
    Ref := At(I)
  else
  begin
    New(Ref);
    Ref^.Topic := NewStr(Topic);
    Ref^.Resolved := False;
    Ref^.FixUpList := nil;
    Insert(Ref);
  end;
  GetReference := Ref;
end;

function TRefTable.KeyOf(Item: Pointer): Pointer;
begin
  KeyOf := PReference(Item)^.Topic;
end;

{----- InitRefTable ----------------------------------------------------}
{  Make sure the reference table is initialized.                        }
{-----------------------------------------------------------------------}

procedure InitRefTable;
begin
  if RefTable = nil then
    RefTable := New(PRefTable, Init(5,5));
end;

{----- RecordReference -------------------------------------------------}
{  Record a reference to a topic to the given stream.  This routine     }
{  handles forward references.                                          }
{-----------------------------------------------------------------------}

procedure RecordReference(var Topic: String; var S: TStream);
var
  I: Integer;
  Ref: PReference;
  FixUp: PFixUp;
begin
  InitRefTable;
  Ref := RefTable^.GetReference(Topic);
  if Ref^.Resolved then
    S.Write(Ref^.Value, SizeOf(Ref^.Value))
  else
  begin
    New(FixUp);
    FixUp^.Pos := S.GetPos;
    I := -1;
    S.Write(I, SizeOf(I));
    FixUp^.Next := Ref^.FixUpList;
    Ref^.FixUpList := FixUp;
  end;
end;

{----- ResolveReference ------------------------------------------------}
{  Resolve a reference to a topic to the given stream.  This routine    }
{  handles forward references.                                          }
{-----------------------------------------------------------------------}

procedure ResolveReference(var Topic: String; Value: Word; var S: TStream);
var
  I: Integer;
  Ref: PReference;

procedure DoFixUps(P: PFixUp);
var
  Pos: LongInt;
begin
  Pos := S.GetPos;
  while P <> nil do
  begin
    S.Seek(P^.Pos);
    S.Write(Value, SizeOf(Value));
    P := P^.Next;
  end;
  S.Seek(Pos);
end;

begin
  InitRefTable;
  Ref := RefTable^.GetReference(Topic);
  if Ref^.Resolved then
    Error('Redefinition of ' + Ref^.Topic^)
  else
  begin
    DoFixUps(Ref^.FixUpList);
    DisposeFixUps(Ref^.FixUpList);
    Ref^.Resolved := True;
    Ref^.Value := Value;
  end;
end;

{======================== Help file parser =============================}

{----- GetWord ---------------------------------------------------------}
{   Extract the next word from the given line at offset I.              }
{-----------------------------------------------------------------------}

function GetWord(var Line: String; var I: Integer): String;
var
  J: Integer;
const
  WordChars = ['A'..'Z','a'..'z','0'..'9','_'];

procedure SkipWhite;
begin
  while (I <= Length(Line)) and (Line[I] = ' ') or (Line[I] = #8) do
    Inc(I);
end;

procedure SkipToNonWord;
begin
  while (I <= Length(Line)) and (Line[I] in WordChars) do Inc(I);
end;

begin
  SkipWhite;
  J := I;
  if J > Length(Line) then GetWord := ''
  else
  begin
    Inc(I);
    if Line[J] in WordChars then SkipToNonWord;
    GetWord := Copy(Line, J, I - J);
  end;
end;

{----- TopicDefinition -------------------------------------------------}
{  Extracts the next topic definition from the given line at I.         }
{-----------------------------------------------------------------------}

type
  PTopicDefinition = ^TTopicDefinition;
  TTopicDefinition = object(TObject)
    Topic: PString;
    Value: Word;
    Next: PTopicDefinition;
    constructor Init(var ATopic: String; AValue: Word);
    destructor Done; virtual;
  end;

constructor TTopicDefinition.Init(var ATopic: String; AValue: Word);
begin
  Topic := NewStr(ATopic);
  Value := AValue;
  Next := nil;
end;

destructor TTopicDefinition.Done;
begin
  DisposeStr(Topic);
  if Next <> nil then Dispose(Next, Done);
end;

function TopicDefinition(var Line: String; var I: Integer): PTopicDefinition;
var
  J,K: Integer;
  TopicDef: PTopicDefinition;
  Value: Word;
  Topic, W: String;
  HelpNumber: Word;
const
  HelpCounter: Word = 2; {1 is hcDragging}
begin
  Topic := GetWord(Line, I);
  if Topic = '' then
  begin
    Error('Expected topic definition');
    TopicDefinition := nil;
  end
  else
  begin
    J := I;
    W := GetWord(Line, J);
    if W = '=' then
    begin
      I := J;
      W := GetWord(Line, I);
      Val(W, J, K);
      if K <> 0 then Error('Expected numeric')
      else
      begin
        HelpCounter := J;
        HelpNumber := J;
      end
    end
    else
      if not IsBuiltInContext(Topic, HelpNumber) then
      begin
        Inc(HelpCounter);
        HelpNumber := HelpCounter;
      end;
    TopicDefinition := New(PTopicDefinition, Init(Topic, HelpNumber));
  end;
end;

{----- TopicDefinitionList----------------------------------------------}
{  Extracts a list of topic definitions from the given line at I.       }
{-----------------------------------------------------------------------}

function TopicDefinitionList(var Line: String; var I: Integer):
  PTopicDefinition;
var
  J: Integer;
  W: String;
  TopicList, P: PTopicDefinition;
begin
  J := I;
  TopicList := nil;
  repeat
    I := J;
    P := TopicDefinition(Line, I);
    if P = nil then
    begin
      if TopicList <> nil then Dispose(TopicList, Done);
      TopicDefinitionList := nil;
      Exit;
    end;
    P^.Next := TopicList;
    TopicList := P;
    J := I;
    W := GetWord(Line, J);
  until W <> ',';
  TopicDefinitionList := TopicList;
end;

{----- TopicHeader -----------------------------------------------------}
{  Parse a the Topic header                                             }
{-----------------------------------------------------------------------}

const
  CommandChar = '.';

function TopicHeader(var Line: String): PTopicDefinition;
var
  I,J: Integer;
  W: String;
  TopicDef: PTopicDefinition;

begin
  I := 1;
  W := GetWord(Line, I);
  if W <> CommandChar then
  begin
    TopicHeader := nil;
    Exit;
  end;
  W := UpStr(GetWord(Line, I));
  if W = 'TOPIC' then
    TopicHeader := TopicDefinitionList(Line, I)
  else
  begin
    Error('TOPIC expected');
    TopicHeader := nil;
  end;
end;

{----- ReadParagraph ---------------------------------------------------}
{ Read a paragraph of the screen.  Returns the paragraph or nil if the  }
{ paragraph was not found in the given stream.  Searches for cross      }
{ references and updates the XRefs variable.                            }
{-----------------------------------------------------------------------}
type
  PCrossRefNode = ^TCrossRefNode;
  TCrossRefNode = record
    Topic: PString;
    Offset: Integer;
    Length: Byte;
    Next: PCrossRefNode;
  end;
const
  BufferSize = 4096;
var
  Buffer: array[0..BufferSize-1] of Byte;
  Ofs: Integer;

function ReadParagraph(var TextFile: TStream; var XRefs: PCrossRefNode;
 var Offset: Integer): PParagraph;
var
  Line: String;
  State: (Undefined, Wrapping, NotWrapping);
  P: PParagraph;

procedure CopyToBuffer(var Line: String; Wrapping: Boolean); assembler;
asm
        PUSH    DS
        CLD
        PUSH    DS
        POP     ES
        MOV     DI,OFFSET Buffer
        ADD     DI,Ofs
        LDS     SI,Line
        LODSB
        XOR     AH,AH
        ADD     ES:Ofs,AX
        XCHG    AX,CX
        REP     MOVSB
        XOR     AL,AL
        TEST    Wrapping,1      { Only add a #13, line terminator, if not }
        JE      @@1             { currently wrapping the text. Otherwise  }
        MOV     AL,' '-13       { add a ' '.                              }
@@1:    ADD     AL,13
@@2:    STOSB
        POP     DS
        INC     Ofs
end;

procedure AddToBuffer(var Line: String; Wrapping: Boolean);
begin
  if Length(Line) + Ofs > BufferSize - 1 then
    Error('Topic too large.')
  else
    CopyToBuffer(Line, Wrapping);
end;

procedure ScanForCrossRefs(var Line: String);
var
  I, BegPos, EndPos, Alias: Integer;
const
  BegXRef = '{';
  EndXRef = '}';
  AliasCh = ':';

procedure AddXRef(XRef: String; Offset: Integer; Length: Byte);
var
  P: PCrossRefNode;
  PP: ^PCrossRefNode;
begin
  New(P);
  P^.Topic := NewStr(XRef);
  P^.Offset := Offset;
  P^.Length := Length;
  P^.Next := nil;
  PP := @XRefs;
  while PP^ <> nil do
    PP := @PP^^.Next;
  PP^ := P;
end;

procedure ReplaceSpacesWithFF(var Line: String; Start: Integer;
  Length: Byte);
var
  I: Integer;
begin
  for I := Start to Start + Length do
    if Line[I] = ' ' then Line[I] := #$FF;
end;

begin
  I := 1;
  repeat
    BegPos := Pos(BegXRef, Copy(Line, I, 255));
    if BegPos = 0 then I := 0
    else
    begin
      Inc(I, BegPos);
      if Line[I] = BegXRef then
      begin
        Delete(Line, I, 1);
        Inc(I);
      end
      else
      begin
        EndPos := Pos(EndXRef, Copy(Line, I, 255));
        if EndPos = 0 then
        begin
          Error('Unterminated topic reference.');
          Inc(I);
        end
        else
        begin
          Alias := Pos(AliasCh, Copy(Line, I, 255));
          if (Alias = 0) or (Alias > EndPos) then
            AddXRef(Copy(Line, I, EndPos - 1), Offset + Ofs + I - 1, EndPos - 1)
          else
          begin
            AddXRef(Copy(Line, I + Alias, EndPos - Alias - 1),
              Offset + Ofs + I - 1, Alias - 1);
            Delete(Line, I + Alias - 1, EndPos - Alias);
            EndPos := Alias;
          end;
          ReplaceSpacesWithFF(Line, I, EndPos-1);
          Delete(Line, I + EndPos - 1, 1);
          Delete(Line, I - 1, 1);
          Inc(I, EndPos - 2);
        end;
      end;
    end;
  until I = 0;
end;

function IsEndParagraph: Boolean;
begin
  IsEndParagraph :=
     (Line = '') or
     (Line[1] = CommandChar) or
     (Line = #26) or
     ((Line[1] =  ' ') and (State = Wrapping)) or
     ((Line[1] <> ' ') and (State = NotWrapping));
end;

begin
  Ofs := 0;
  ReadParagraph := nil;
  State := Undefined;
  Line := GetLine(TextFile);
  while Line = '' do
  begin
    AddToBuffer(Line, State = Wrapping);
    Line := GetLine(TextFile);
  end;

  if IsEndParagraph then
  begin
    ReadParagraph := nil;
    UnGetLine(Line);
    Exit;
  end;
  while not IsEndParagraph do
  begin
    if State = Undefined then
      if Line[1] = ' ' then State := NotWrapping
      else State := Wrapping;
    ScanForCrossRefs(Line);
    AddToBuffer(Line, State = Wrapping);
    Line := GetLine(TextFile);
  end;
  UnGetLine(Line);
  GetMem(P, SizeOf(P^) + Ofs);
  P^.Size := Ofs;
  P^.Wrap := State = Wrapping;
  Move(Buffer, P^.Text, Ofs);
  Inc(Offset, Ofs);
  ReadParagraph := P;
end;

{----- ReadTopic -------------------------------------------------------}
{ Read a topic from the source file and write it to the help file       }
{-----------------------------------------------------------------------}
var
  XRefs: PCrossRefNode;

procedure HandleCrossRefs(var S: TStream; XRefValue: Integer); far;
var
  P: PCrossRefNode;
begin
  P := XRefs;
  while XRefValue > 1 do
  begin
    if P <> nil then P := P^.Next;
    Dec(XRefValue);
  end;
  if P <> nil then RecordReference(P^.Topic^, S);
end;

procedure ReadTopic(var TextFile: TStream; var HelpFile: THelpFile);
var
  Line: String;
  P: PParagraph;
  Topic: PHelpTopic;
  TopicDef: PTopicDefinition;
  I, J, Offset: Integer;
  Ref: TCrossRef;
  RefNode: PCrossRefNode;

procedure SkipBlankLines(var S: TStream);
var
  Line: String;
begin
  Line := '';
  while Line = '' do
    Line := GetLine(S);
  UnGetLine(Line);
end;

function XRefCount: Integer;
var
  I: Integer;
  P: PCrossRefNode;
begin
  I := 0;
  P := XRefs;
  while P <> nil do
  begin
    Inc(I);
    P := P^.Next;
  end;
  XRefCount := I;
end;

procedure DisposeXRefs(P: PCrossRefNode);
var
  Q: PCrossRefNode;
begin
  while P <> nil do
  begin
    Q := P;
    P := P^.Next;
    if Q^.Topic <> nil then DisposeStr(Q^.Topic);
    Dispose(Q);
  end;
end;

procedure RecordTopicDefinitions(P: PTopicDefinition);
begin
  while P <> nil do
  begin
    ResolveReference(P^.Topic^, P^.Value, HelpFile.Stream^);
    HelpFile.RecordPositionInIndex(P^.Value);
    P := P^.Next;
  end;
end;

begin
  { Get Screen command }
  SkipBlankLines(TextFile);
  Line := GetLine(TextFile);

  TopicDef := TopicHeader(Line);

  Topic := New(PHelpTopic, Init);

  { Read paragraphs }
  XRefs := nil;
  Offset := 0;
  P := ReadParagraph(TextFile, XRefs, Offset);
  while P <> nil do
  begin
    Topic^.AddParagraph(P);
    P := ReadParagraph(TextFile, XRefs, Offset);
  end;

  I := XRefCount;
  Topic^.SetNumCrossRefs(I);
  RefNode := XRefs;
  for J := 1 to I do
  begin
    Ref.Offset := RefNode^.Offset;
    Ref.Length := RefNode^.Length;
    Ref.Ref := J;
    Topic^.SetCrossRef(J, Ref);
    RefNode := RefNode^.Next;
  end;

  RecordTopicDefinitions(TopicDef);

  CrossRefHandler := HandleCrossRefs;
  HelpFile.PutTopic(Topic);

  if Topic <> nil then Dispose(Topic, Done);
  if TopicDef <> nil then Dispose(TopicDef, Done);
  DisposeXRefs(XRefs);

  SkipBlankLines(TextFile);
end;

{----- WriteSymbFile ---------------------------------------------------}
{ Write the .PAS file containing all screen titles as constants.        }
{-----------------------------------------------------------------------}

procedure WriteSymbFile(var SymbFile: TProtectedStream);
const
  HeaderText1 =
    'unit ';
  HeaderText2 =
    ';'#13#10 +
    #13#10 +
    'interface'#13#10 +
    #13#10 +
    'const'#13#10 +
    #13#10;
  FooterText =
    #13#10 +
    'implementation'#13#10 +
    #13#10 +
    'end.'#13#10;
  Header1: array[1..Length(HeaderText1)] of Char = HeaderText1;
  Header2: array[1..Length(HeaderText2)] of Char = HeaderText2;
  Footer: array[1..Length(FooterText)] of Char = FooterText;
var
  I, Count: Integer;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;

procedure DoWriteSymbol(P: PReference); far;
var
  L: array[0..1] of LongInt;
  Line: String;
  I: Word;
begin
  if (P^.Resolved) then
  begin
    if not IsBuiltInContext(P^.Topic^, I) then
    begin
      L[0] := LongInt(P^.Topic);
      L[1] := P^.Value;
      FormatStr(Line, '  hc%-20s = %d;'#13#10, L);
      SymbFile.Write(Line[1], Length(Line));
    end
  end
  else Warning('Unresolved forward reference "' + P^.Topic^ + '"');
end;

begin
  SymbFile.Write(Header1, SizeOf(Header1));
  FSplit(SymbFile.FileName, Dir, Name, Ext);
  SymbFile.Write(Name[1], Length(Name));
  SymbFile.Write(Header2, SizeOf(Header2));

  RefTable^.ForEach(@DoWriteSymbol);

  SymbFile.Write(Footer, SizeOf(Footer));
end;

{----- ProcessText -----------------------------------------------------}
{ Compile the given stream, and output a help file.                     }
{-----------------------------------------------------------------------}

procedure ProcessText(var TextFile, HelpFile, SymbFile: TProtectedStream);
var
  HelpRez: THelpFile;
begin
  HelpRez.Init(@HelpFile);
  while TextFile.Status = stOk do
    ReadTopic(TextFile, HelpRez);
  WriteSymbFile(SymbFile);
  HelpRez.Done;
end;

{========================== Program Block ==========================}

var
  TextName,
  HelpName,
  SymbName: PathStr;

procedure ExitClean; far;
begin
  { Print a message if an out of memory error encountered }
  if ExitCode = 201 then
  begin
    Writeln('Error: Out of memory.');
    ErrorAddr := nil;
    ExitCode := 1;
  end;

  { Clean up files }
  TextStrm.Done;
  SymbStrm.Done;
end;

begin
  { Banner messages }
  PrintStr('Help Compiler  Version 1.1  Copyright (c) 1992 Borland International.'#13#10);
  if ParamCount < 1 then
  begin
    PrintStr(
      #13#10 +
      '  Syntax:  TVHC <Help text>[.TXT] [<Help file>[.HLP] [<Symbol file>[.PAS]]'#13#10 +
      #13#10+
      '     Help text   = Help file source'#13#10 +
      '     Help file   = Compiled help file'#13#10 +
      '     Symbol file = A Pascal file containing all the screen names as CONST''s'#13#10);
    Halt(0);
  end;

  { Calculate file names }
  TextName := ReplaceExt(ParamStr(1), '.TXT', False);
  if not FExists(TextName) then
    Error('File "' + TextName + '" not found.');
  if ParamCount >= 2 then
    HelpName := ReplaceExt(ParamStr(2), '.HLP', False) else
    HelpName := ReplaceExt(TextName, '.HLP',  True);
  if ParamCount >= 3 then
    SymbName := ReplaceExt(ParamStr(3), '.PAS', False) else
    SymbName := ReplaceExt(HelpName, '.PAS', True);

  ExitProc := @ExitClean;

  RegisterHelpFile;

  TextStrm.Init(TextName, stOpenRead, 1024);
  SymbStrm.Init(SymbName, stCreate,   1024);
  HelpStrm := New(PProtectedStream, Init(HelpName, stCreate, 1024));
  ProcessText(TextStrm, HelpStrm^, SymbStrm);
end.
