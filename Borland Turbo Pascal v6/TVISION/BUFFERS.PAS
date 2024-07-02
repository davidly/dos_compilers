
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1990 Borland International        }
{                                                       }
{*******************************************************}

unit Buffers;

{$F+,O+,S-,X+,D-}

interface

procedure InitBuffers;
procedure DoneBuffers;
procedure NewBuffer(var P: Pointer);
procedure DisposeBuffer(P: Pointer);
function GetBufferSize(P: Pointer): Word;
function SetBufferSize(P: Pointer; Size: Word): Boolean;

const
  BufHeapSize: Word = 0;
  BufHeapPtr: Word = 0;
  BufHeapEnd: Word = 0;

implementation

uses Objects;

type
  PBuffer = ^TBuffer;
  TBuffer = record
    Master: ^Word;
    Size: Word;
  end;

procedure MoveSeg(Source, Dest, Size: Word); assembler;
asm
	PUSH	DS
	MOV	AX,Source
	MOV	DX,Dest
	MOV	BX,Size
	CMP	AX,DX
	JB	@@3
	CLD
@@1:	MOV	CX,0FFFH
	CMP	CX,BX
	JB	@@2
	MOV	CX,BX
@@2:	MOV	DS,AX
	MOV	ES,DX
	ADD	AX,CX
	ADD	DX,CX
	SUB	BX,CX
	SHL	CX,1
	SHL	CX,1
	SHL	CX,1
	XOR	SI,SI
	XOR	DI,DI
	REP	MOVSW
	OR	BX,BX
	JNE	@@1
	JMP	@@6
@@3:	ADD	AX,BX
	ADD	DX,BX
	STD
@@4:	MOV	CX,0FFFH
	CMP	CX,BX
	JB	@@5
	MOV	CX,BX
@@5:    SUB	AX,CX
	SUB	DX,CX
	SUB	BX,CX
	MOV	DS,AX
	MOV	ES,DX
	SHL	CX,1
	SHL	CX,1
	SHL	CX,1
	MOV	SI,CX
	DEC	SI
	SHL	SI,1
	MOV	DI,SI
	REP	MOVSW
	OR	BX,BX
	JNE	@@4
@@6:	POP	DS
end;

function GetBufSize(P: PBuffer): Word;
begin
  GetBufSize := (P^.Size + 15) shr 4 + 1;
end;

procedure SetBufSize(P: PBuffer; NewSize: Word);
var
  CurSize: Word;
begin
  CurSize := GetBufSize(P);
  MoveSeg(PtrRec(P).Seg + CurSize, PtrRec(P).Seg + NewSize,
    BufHeapPtr - PtrRec(P).Seg - CurSize);
  Inc(BufHeapPtr, NewSize - CurSize);
  Inc(PtrRec(P).Seg, NewSize);
  while PtrRec(P).Seg < BufHeapPtr do
  begin
    Inc(P^.Master^, NewSize - CurSize);
    Inc(PtrRec(P).Seg, (P^.Size + 15) shr 4 + 1);
  end;
end;

procedure InitBuffers;
var
  HeapSize: Word;
begin
  HeapSize := PtrRec(HeapEnd).Seg - PtrRec(HeapOrg).Seg;
  BufHeapPtr := PtrRec(HeapEnd).Seg - BufHeapSize;
  BufHeapEnd := PtrRec(HeapEnd).Seg;
  PtrRec(HeapEnd).Seg := BufHeapPtr;
end;

procedure DoneBuffers;
begin
  PtrRec(HeapEnd).Seg := BufHeapEnd;
end;
   
procedure NewBuffer(var P: Pointer);
begin
  if BufHeapPtr = BufHeapEnd then P := nil else
  begin
    with PBuffer(Ptr(BufHeapPtr, 0))^ do
    begin
      Master := @PtrRec(P).Seg;
      Size := 0;
    end;
    Inc(BufHeapPtr);
    P := Ptr(BufHeapPtr, 0);
  end;
end;

procedure DisposeBuffer(P: Pointer);
begin
  Dec(PtrRec(P).Seg);
  SetBufSize(P, 0);
end;

function GetBufferSize(P: Pointer): Word;
begin
  Dec(PtrRec(P).Seg);
  GetBufferSize := PBuffer(P)^.Size;
end;

function SetBufferSize(P: Pointer; Size: Word): Boolean;
var
  NewSize: Word;
begin
  Dec(PtrRec(P).Seg);
  NewSize := (Size + 15) shr 4 + 1;
  SetBufferSize := False;
  if BufHeapPtr + NewSize - GetBufSize(P) <= BufHeapEnd then
  begin
    SetBufSize(P, NewSize);
    PBuffer(P)^.Size := Size;
    SetBufferSize := True;
  end;
end;

end.
