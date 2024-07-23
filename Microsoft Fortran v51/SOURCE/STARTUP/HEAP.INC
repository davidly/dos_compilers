;***
;heap.inc - definitions and structures for C library heap
;
;	Copyright (c) 1987-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	This file contains definitions and structures used by
;	the C library heap routines.
;
;*******************************************************************************

;
; --- Heap segment descriptor ---
;
; [***NOTE*** Some heap routines make assumptions about the layout of the
; heap descriptor.  If this descriptor changes, some routines may break.]
;

_heap_seg_desc	struc
	checksum	dw	?	; checksum area
	flags		dw	?	; flags word
	segsize 	dw	?	; size of segment
	start		dw	?	; offset of first heap entry
	rover		dw	?	; rover offset
	last		dw	?	; offset to end-of-heap marker
	nextseg 	dd	?	; far pointer to next _heap_seg_desc
	prevseg 	dd	?	; far pointer to previous _heap_seg_desc
_heap_seg_desc	ends

;
; _heap_seg_desc.flags bit offsets
;

_HEAP_MODIFY	equ	01h		; heap segment size can be modified
_HEAP_FREE	equ	02h		; heap segment may be freed up to OS
_HEAP_NEAR	equ	04h		; heap segment is part of the near heap
_HEAP_BASED	equ	08h		; heap segment is part of the based heap

;
; --- Heap Linked List Descriptor ---
;
; [***NOTE*** Some heap routines make assumptions about the layout of the
; heap list descriptor.  If this descriptor changes, some routines may break.]
;

_heap_list_desc struc
	startseg	dd	0	; pointer to first heap descriptor
	roverseg	dd	0	; rover pointer
	lastseg 	dd	0	; pointer to last heap descriptor
	segflags	dw	0	; flags word for init'ing new segs
_heap_list_desc ends

;
; --- General Use Heap Constants ---
;

_HEAP_END	equ	0FFFEh		; End-of-heap flag
_HEAP_COALESCE	equ	0FFFEh		; Coalesce segment value
_HEAP_GROWSEG	equ	2 shl 12	; Default (8K) heap seg growth increment
_HEAP_GROWSTART equ	2 shl 9 	; Startup heap seg growth size (1K)
_HEAP_MAXREQ	equ	0FFFCh - (size _heap_seg_desc)	; Max heap request size
_HEAP_MINSEG	equ	((size _heap_seg_desc) + 4) ; Min size heap segment

;
; --- Heap Check/Set/Walk Definitions ---
;

; Heap info structure used by heapwalk

_heapinfo	struc
	_pentry_off	dw	?	; far pointer to heap entry (offset)
	_pentry_seg	dw	?	; far pointer to heap entry (segment)
	_size		dw	?	; size of entry
	_useflag	dw	?	; in use flag
_heapinfo	ends

;
; Heap Check/Set/Walk Constants
; [NOTE: These definitions must match malloc.h]
;

_HEAPEMPTY	equ	-1
_HEAPOK 	equ	-2
_HEAPBADBEGIN	equ	-3
_HEAPBADNODE	equ	-4
_HEAPEND	equ	-5
_HEAPBADPTR	equ	-6

_HEAPSET_NOFILL equ	07FFFh

_FREEENTRY	equ	0
_USEDENTRY	equ	1

;
; Return value denoting failure for based heap functions of based pointer
; return type. The name and definition must correspond to the one given
; in MALLOC.H.
;

_NULLOFF	equ	-1


IFDEF	M_XENIX
;
; --- XENIX Heap Support ---
;

BR_ARGSEG	equ 1			; specified segment
BR_NEWSEG	equ 2			; new segment
BR_IMPSEG	equ 3			; last or new segment
BR_FREESEG	equ 4			; free segment

ENDIF
