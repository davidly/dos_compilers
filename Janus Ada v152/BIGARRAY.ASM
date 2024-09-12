With Jlib86;
Use Jlib86;
Package Assembly BigArray Is

    --
    -- Package to allow BigArrays outside of the main Data segment.
    -- The user of this package should change the element_type and
    -- num_of_elements to match his or her needs.
    --
    -- Limits:	The total array size can be no larger than 128K.
    --		The element size must be less than 4000 Bytes.
    --		Only one copy of this package may be used under MS-DOS 1.xx;
    --		Multiple copies are OK under MS-DOS 2.xx and later.
    --		The lower bound of the array is always 0.
    --
    -- Written  3/85
    -- Last Modified  3/18/85
    --
    -- Copyright 1985  RR Software, Inc, P.O. Box 1512, Madison WI  53704
    --

    Pragma Include("MEMMOD.INC"); -- Include the memory model definition
	-- Memory_Model Equ 0 -- Memory model number.
	-- Pragma Memory_Model(0);

    -- Pick the DOS used...
    MS_DOS1 Equ False
    MS_DOS2 Equ True

    NUM_ELEMENT_IN_SEGMENT_1 Equ
	((4095 * 8) / (Size Element_Type)) * 2;
    NUM_ELEMENT_IN_SEGMENT_2 Equ
	NUM_OF_ELEMENTS - NUM_ELEMENT_IN_SEGMENT_1;
	-- Maximum item number in RAM .. use funny expressions to avoid
	-- overflow
    If NUM_ELEMENT_IN_SEGMENT_2 > 0 Then
	-- Include segment 2 in calculations
	ARRAY_RAM_SIZE Equ 1000h + 
	    ((NUM_ELEMENT_IN_SEGMENT_2 + 15)/16 * Size Element_Type)
	SEGMENT2_USED Equ True
    Else
	ARRAY_RAM_SIZE Equ
	    ((NUM_OF_ELEMENTS + 15)/16 * Size Element_Type)
	SEGMENT2_USED Equ False
    End If;


	-- Initialization code
	Mov	AX,ARRAY_RAM_SIZE-- Check that we can even have enough RAM
	Cmp	AX,8191		-- Check that we're using two segments or less.
	Ja	Error
	If MS_DOS2 Then -- MS-DOS 2.0 and later version.
	  Mov	AH,48h	-- Allocate Memory Call.
	  Mov	BX,ARRAY_RAM_SIZE -- Get ARRAY_RAM_SIZE paragraphs.
	  Int	33
	  Jc	Error
	  Mov	[ISegment],AX -- Save first segment address
	  If Segment2_Used Then
	    Add	AX,1000h
	    Mov	[ISegment2],AX -- Save second segment address
--	    -- For debugging
--	    Sub	AX,1000h
--	    Add	AX,ARRAY_RAM_SIZE -- Calc. value to print-out below.
	  End If;
	Else  -- MS-DOS 1.xx version
	  Mov	AX,SS		-- Get stack segment pointer
	  Add	AX,1000h	-- Assume a 64K stack segment (else not enough
				--  room anyway)
	  Mov	[ISegment],AX	-- Save the first segment address
	  If Segment2_Used Then
	    Add	AX,1000h	-- Get second segment address
	    Mov	[ISegment2],AX	-- Save the second segement address
	  End If;

	  Mov	AX,[ISegment]
	  Add	AX,ARRAY_RAM_SIZE-- Check that we have enough RAM
	  If Memory_Model = 0 Then
	    Cmp	AX,CS:[2]	-- Check that we are below the top of RAM address
	  Else
	    Push ES
	    Mov	DX,[Jlib86.Base_Page]
	    Mov	ES,DX
	    Cmp	AX,ES:[2]	-- Check that we are below the top of RAM address
	    Pop	ES
	  End If;
	  Ja	Error
	End If;

--	-- Print top of RAM used for reference (for debugging)
--	Push	AX
--	Mov	BX,[Output_File]
--	Push	BX
--	Call	EPutInt
--	Mov	AX,[Output_File]
--	Mov	BX,IMess
--	Call	Put_CStr

	Jmp	Pend

	CONSTSEG
IMess   DB	18," - Top of Memory",13,10
	CSEG

Error:	Push	DS
	Push	CS
	Pop	DS
	Mov	DX,Msg
	Mov	AH,9
	Int	33
	Pop	DS
	Mov	AH,4Ch
	Mov	AL,0
	Int	33	-- Halt!!
Msg:	DB	"** BIG ARRAY ERROR ** Not enough RAM$"

Procedure Get_from_Array(index : index_subtype; rec : Out Element_Type) Is
	-- Get Array(index)
	If Memory_Model = 0 Then
	  Pop	SI
	  Pop	DI	-- Rec address
	  Pop	AX	-- index
	  Push	AX	-- Restore params
	  Push	DI
	  Push	SI
	Else
	  Pop	DX
	  Pop	SI
	  Pop	DI	-- Rec address
	  Pop	AX	-- index
	  Push	AX	-- Restore params
	  Push	DI
	  Push	SI
	  Push	DX
	End If;
	If Segment2_Used Then
	  Cmp	AX,NUM_ELEMENT_IN_SEGMENT_1
	  Jae	RSecond_Seg
	End If;
	Mov	BX,Size Element_Type	-- Multiply by size to get address
	Imul	BX
	Mov	SI,AX
	Push	DS	-- Save register
	Mov	DS,[ISegment]
	Mov	CX,Size Element_Type
	Rep
	Movsb		-- Block move
	Pop	DS	-- Restore register
	If Memory_Model = 0 Then
	  Ret
	Else
	  Ret	Far
	End If;
	If Segment2_Used Then
RSecond_Seg:
	  Sub	AX,NUM_ELEMENT_IN_SEGMENT_1
	  Mov	BX,Size Element_Type	-- Multiply by size to get address
	  Imul	BX
	  Mov	SI,AX
	  Push	DS	-- Save register
	  Mov	DS,[ISegment2]
	  Mov	CX,Size Element_Type
	  Rep
	  Movsb		-- Block move
	  Pop	DS	-- Restore register
	  If Memory_Model = 0 Then
	    Ret
	  Else
	    Ret	Far
	  End If;
	End If;
End Get_from_Array

Procedure Put_to_Array(index : index_subtype; rec : In Element_Type) Is
	-- Set Array(index)
	If Memory_Model = 0 Then
	  Pop	DI
	  Pop	SI	-- Rec address (or value)
	  Pop	AX	-- index
	  Push	DI	-- Restore only return address
	Else
	  Pop	DX
	  Pop	DI
	  Pop	SI	-- Rec address (or value)
	  Pop	AX	-- index
	  Push	DI	-- Restore only return address
	  Push	DX
	End If;
	If Segment2_Used Then
	  Cmp	AX,NUM_ELEMENT_IN_SEGMENT_1
	  Jae	WSecond_Seg
	End If;
	Mov	BX,Size Element_Type	-- Multiply by size to get address
	IMul    BX
	Mov	DI,AX
	Push	ES	-- Save register
	Mov	ES,[ISegment]
	If Size Element_Type = 2 Then
	  Mov	ES:[DI],SI
	Elsif Size Element_Type = 1 Then
	  Mov	AX,SI
	  Mov	ES:[DI],AL
	Else
	  Mov	CX,Size Element_Type
	  Rep
	  Movsb		-- Block move
	End If;
	Pop	ES	-- Restore register
	If Memory_Model = 0 Then
	  Ret
	Else
	  Ret	Far
	End If;
	If Segment2_Used Then
WSecond_Seg:
	  Sub	AX,NUM_ELEMENT_IN_SEGMENT_1
	  Mov	BX,Size Element_Type	-- Multiply by size to get address
	  IMul    BX
	  Mov	DI,AX
	  Push	ES	-- Save register
	  Mov	ES,[ISegment2]
	  If Size Element_Type = 2 Then
	    Mov	ES:[DI],SI
	  Elsif Size Element_Type = 1 Then
	    Mov	AX,SI
	    Mov	ES:[DI],AL
	  Else
	    Mov	CX,Size Element_Type
	    Rep
	    Movsb	-- Block move
	  End If;
	  Pop	ES	-- Restore register
	  If Memory_Model = 0 Then
	    Ret
	  Else
	    Ret	Far
	  End If;
	End If;
End Put_to_Array

DSEG
ISegment	DW	?	-- Segment pointer for array segment
ISegment2	DW	?	-- Segment pointer for second array segment
CSEG

Pend:		-- End of Package

End BigArray
