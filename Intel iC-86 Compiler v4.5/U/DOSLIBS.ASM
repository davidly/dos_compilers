;***********************************************************************
; DOSLIBS - Small model interface from PLM-86 to MS-DOS
;***********************************************************************

	NAME	DOSLIBS

	CGROUP	GROUP	CODE
	DGROUP	GROUP	STACK

	ASSUME	CS:CGROUP, DS:DGROUP, SS:DGROUP


STACK	SEGMENT	STACK	'STACK'
	DW	1024 DUP(0)	; make room for stack
STACK	ENDS


CODE	SEGMENT	PUBLIC	'CODE'

	PUBLIC	dos_std_in, dos_std_out
	PUBLIC	dos_aux_in, dos_aux_out
	PUBLIC	dos_prn_out
	PUBLIC	dos_direct_in, dos_direct_out
	PUBLIC	dos_direct_in_noecho, dos_std_in_noecho
	PUBLIC	dos_std_string_out
	PUBLIC	dos_buffered_std_in
	PUBLIC	dos_check_std_in
	PUBLIC	dos_clear_and_std_in
	PUBLIC	dos_get_disk_transfer_address, dos_set_disk_transfer_address
	PUBLIC	dos_get_date, dos_set_date
	PUBLIC	dos_get_time, dos_set_time
	PUBLIC	dos_get_verify, dos_set_verify
	PUBLIC	dos_version
	PUBLIC	dos_get_ctrl_break, dos_set_ctrl_break
	PUBLIC	dos_get_vector, dos_set_vector
	PUBLIC	dos_get_disk_free_space
	PUBLIC	dos_create_dir, dos_delete_dir
	PUBLIC	dos_change_dir, dos_get_dir
	PUBLIC	dos_create, dos_delete
	PUBLIC	dos_open, dos_close
	PUBLIC	dos_read, dos_write
	PUBLIC	dos_seek
	PUBLIC	dos_get_attribute, dos_set_attribute
	PUBLIC	dos_allocate, dos_free
	PUBLIC	dos_set_block
	PUBLIC	dos_exec, dos_exit, dos_wait
	PUBLIC	dos_find_first, dos_find_next
	PUBLIC	dos_rename
	PUBLIC	dos_get_cs, dos_get_ds, dos_get_ss
	PUBLIC	dos_get_psp


;***********************************************************************
; dos_std_in() byte
;***********************************************************************

dos_std_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 01h		; Function: Keyboard Input
	int	21h		; DOS call
	pop	bp
	ret
dos_std_in	ENDP


;***********************************************************************
; dos_std_out(ch byte)
;***********************************************************************

dos_std_out	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]	; ch
	mov	ah, 02h		; Function: Display Output
	int	21h		; DOS call
	pop	bp
	ret	2
dos_std_out	ENDP


;***********************************************************************
; dos_aux_in() byte
;***********************************************************************

dos_aux_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 03h		; Function: Auxiliary Input
	int	21h		; DOS call
	pop	bp
	ret
dos_aux_in	ENDP


;***********************************************************************
; dos_aux_out(ch byte)
;***********************************************************************

dos_aux_out	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]	; ch
	mov	ah, 04h		; Function: Auxiliary Output
	int	21h		; DOS call
	pop	bp
	ret	2
dos_aux_out	ENDP


;***********************************************************************
; dos_prn_out(ch byte)
;***********************************************************************

dos_prn_out	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]	; ch
	mov	ah, 05h		; Function: Printer Output
	int	21h		; DOS call
	pop	bp
	ret	2
dos_prn_out	ENDP


;***********************************************************************
; dos_direct_in() byte /* 0FFh if input not ready, 0-0FEh otherwise */
;***********************************************************************

dos_direct_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 06h		; Function: Direct Console I/O
	mov	dl, 0FFh	; subfunction: Console input
	int	21h		; DOS call
	jnz	ddi0		; character received ?
	mov	al, 0FFh	; no char received. return 0FFh
ddi0:
	pop	bp
	ret
dos_direct_in	ENDP


;***********************************************************************
; dos_direct_out(ch byte)
;   /* ch <> 0FFh */
;***********************************************************************

dos_direct_out	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]	; ch
	cmp	dl, 0FFh	; invalid value?
	je	ddo1		; skip if value invalid
	mov	ah, 06h		; Function: Display Output
	int	21h		; DOS call
ddo1:
	pop	bp
	ret	2
dos_direct_out	ENDP


;***********************************************************************
; dos_direct_in_noecho() byte
;***********************************************************************

dos_direct_in_noecho	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 07h		; Function: Direct Console Input Without Echo
	int	21h		; DOS call
	pop	bp
	ret
dos_direct_in_noecho	ENDP


;***********************************************************************
; dos_std_in_noecho() byte
;***********************************************************************

dos_std_in_noecho	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 08h		; Function: Console Input Without Echo
	int	21h		; DOS call
	pop	bp
	ret
dos_std_in_noecho	ENDP


;***********************************************************************
; dos_std_string_out(str addr)
;   st$ based str (*) byte
;***********************************************************************

dos_std_string_out	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; str
	mov	ah, 09h		; Function: Print String
	int	21h		; DOS call
	pop	bp
	ret	2
dos_std_string_out	ENDP


;***********************************************************************
; dos_buffered_std_in(str addr)
;   stc based str structure(
;	len_in byte,	/* n+1 */
;	len_out byte,	/* 1..n */
;	str (n) byte,	/* string read */
;	cr byte)	/* CR */
;***********************************************************************

dos_buffered_std_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; str
	mov	ah, 0Ah		; Function: Read String
	int	21h		; DOS call
	pop	bp
	ret	2
dos_buffered_std_in	ENDP


;***********************************************************************
; dos_check_std_in() byte /* 0FFh if input ready, 0 otherwise */
;***********************************************************************

dos_check_std_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 0Bh		; Function: Check Standard Input Status
	int	21h		; DOS call
	pop	bp
	ret
dos_check_std_in	ENDP


;***********************************************************************
; dos_clear_and_std_in(type byte) byte
;   /* type = 1, 6, 7, 8, 0Ah */
;***********************************************************************

dos_clear_and_std_in	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 0Ch		; Function: Clear Buffer & Invoke Input
	mov	al, [bp+4]	; subfunction: Input function
	int	21h		; DOS call
	pop	bp
	ret	2
dos_clear_and_std_in	ENDP


;***********************************************************************
; dos_get_disk_transfer_address() dword
;***********************************************************************

dos_get_disk_transfer_address	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 2Fh		; Function: Get Disk Transfer Address
	int	21h		; DOS call
	mov	ax, bx		; dx:ax = es:bx
	mov	dx, es
	pop	bp
	ret
dos_get_disk_transfer_address	ENDP


;***********************************************************************
; dos_set_disk_transfer_address(dta addr)
;***********************************************************************

dos_set_disk_transfer_address	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; dta
	mov	ah, 1Ah		; Function: Set Disk Transfer Address
	int	21h		; DOS call
	pop	bp
	ret	2
dos_set_disk_transfer_address	ENDP


;***********************************************************************
; dos_get_date(date addr) byte /* day of week, 0=sun..6=sat */
;   dat based date structure(
;	day byte,	/* 1..31 */
;	month byte,	/* 1..12 */
;	year word)	/* 1980..2099 */
;***********************************************************************

dos_get_date	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 2Ah		; Function: Get Date
	int	21h		; DOS call
	mov	si, [bp+4]	; date
	mov	[si], dx	; month:day
	mov	[si+2], cx	; year
	pop	bp
	ret	2
dos_get_date	ENDP


;***********************************************************************
; dos_set_date(date addr) byte /* 0FFh if date invalid, 0 otherwise */
;   dat based date structure(
;	day byte,	/* 1..31 */
;	month byte,	/* 1..12 */
;	year word)	/* 1980..2099 */
;***********************************************************************

dos_set_date	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	si, [bp+4]	; date
	mov	dx, [si]	; month:day
	mov	cx, [si+2]	; year
	mov	ah, 2Bh		; Function: Set Date
	int	21h		; DOS call
	pop	bp
	ret	2
dos_set_date	ENDP


;***********************************************************************
; dos_get_time(time addr)
;   tim based time structure(
;	hundredeths byte,	/* 0..99 */
;	seconds byte,	/* 0..59 */
;	minutes byte,	/* 0..59 */
;	hours byte)	/* 0..23 */
;***********************************************************************

dos_get_time	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 2Ch		; Function: Get time
	int	21h		; DOS call
	mov	si, [bp+4]	; time
	mov	[si], dx	; seconds:hundredeths
	mov	[si+2], cx	; hours:minutes
	pop	bp
	ret	2
dos_get_time	ENDP


;***********************************************************************
; dos_set_time(time addr) byte /* 0FFh if time invalid, 0 otherwise */
;   tim based time structure(
;	hundredeths byte,	/* 0..99 */
;	seconds byte,	/* 0..59 */
;	minutes byte,	/* 0..59 */
;	hours byte)	/* 0..23 */
;***********************************************************************

dos_set_time	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	si, [bp+4]	; time
	mov	dx, [si]	; seconds:hundredeths
	mov	cx, [si+2]	; hours:minutes
	mov	ah, 2Dh		; Function: Set time
	int	21h		; DOS call
	pop	bp
	ret	2
dos_set_time	ENDP


;***********************************************************************
; dos_get_verify() byte /* 1 if verify is on, 0 otherwise */
;***********************************************************************

dos_get_verify	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 54h		; Function: Get Verify Setting
	int	21h		; DOS call
	pop	bp
	ret
dos_get_verify	ENDP


;***********************************************************************
; dos_set_verify(mode byte)
;   /* mode = 1 to turn on, 0 to turn off */
;***********************************************************************

dos_set_verify	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	al, [bp+4]	; mode
	mov	ah, 2Eh		; Function: Set Verify Setting
	int	21h		; DOS call
	pop	bp
	ret	2
dos_set_verify	ENDP


;***********************************************************************
; dos_version() word /* LOW = major version, HIGH = minor version */
;		     /* DOS 3.1 = 0103H */
;***********************************************************************

dos_version	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 30h		; Function: Get DOS Version Number
	int	21h		; DOS call
	pop	bp
	ret
dos_version	ENDP


;***********************************************************************
; dos_get_ctrl_break() byte /* 1 if ctrl-break check is on, 0 otherwise */
;***********************************************************************

dos_get_ctrl_break	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 33h		; Function: Ctrl-Break Check
	mov	al, 0		; subfunction: Request current state
	int	21h		; DOS call
	mov	al, dl		; return value in AL
	pop	bp
	ret
dos_get_ctrl_break	ENDP


;***********************************************************************
; dos_set_ctrl_break(mode byte)
;   /* mode = 1 to turn on, 0 to turn off */
;***********************************************************************

dos_set_ctrl_break	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+4]	; mode
	mov	ah, 33h		; Function: Ctrl-Break Check
	mov	al, 1		; subfunction: Set new state
	int	21h		; DOS call
	pop	bp
	ret	2
dos_set_ctrl_break	ENDP


;***********************************************************************
; dos_get_vector(vector byte) dword
;***********************************************************************

dos_get_vector	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	al, [bp+4]	; vector number
	mov	ah, 35h		; Function: Get Interrupt Vector
	int	21h		; DOS call
	mov	ax, bx		; dx:ax = es:bx
	mov	dx, es
	pop	bp
	ret	2
dos_get_vector	ENDP


;***********************************************************************
; dos_set_vector(vector byte, handler dword)
;***********************************************************************

dos_set_vector	PROC	NEAR
	push	bp
	mov	bp, sp
	push	ds		; save ds
	mov	dx, [bp+4]	; handler
	mov	ds, [bp+6]
	mov	al, [bp+8]	; vector number
	mov	ah, 25h		; Function: Set Interrupt Vector
	int	21h		; DOS call
	pop	ds		; restore ds
	pop	bp
	ret	6
dos_set_vector	ENDP


;***********************************************************************
; dos_get_disk_free_space(drive byte, info addr) word /* 0FFFFh if drive invalid, 0 otherwise */
;   inf based info structure(
;	avail_clusters word,
;	total_clusters word,
;	bytes_per_sector word,
;	sectors_per_cluster word)
;***********************************************************************

dos_get_disk_free_space	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dl, [bp+6]	; drive
	mov	ah, 36h		; Function: Get Disk Free Space
	int	21h		; DOS call
	cmp	ax, 0FFFFh
	je	dgf0		; skip if drive invalid
	mov	si, [bp+4]	; store return values
	mov	[si], bx	; available clusters
	mov	[si+2], dx	; total clusters
	mov	[si+4], cx	; bytes per sector
	mov	[si+6], ax	; sectors per cluster or error flag
	xor	ax, ax		; no error, return 0
dgf0:
	pop	bp
	ret	4
dos_get_disk_free_space	ENDP


;***********************************************************************
; dos_create_dir(name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_create_dir	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; name
	mov	ah, 39h		; Function: Create Subdirectory
	int	21h		; DOS call
	jc	dmd0		; skip if error
	xor	ax, ax		; no error, return 0
dmd0:
	pop	bp
	ret	2
dos_create_dir	ENDP


;***********************************************************************
; dos_delete_dir(name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_delete_dir	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; name
	mov	ah, 3Ah		; Function: Delete Subdirectory
	int	21h		; DOS call
	jc	ddd0		; skip if error
	xor	ax, ax		; no error, return 0
ddd0:
	pop	bp
	ret	2
dos_delete_dir	ENDP


;***********************************************************************
; dos_change_dir(name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_change_dir	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; name
	mov	ah, 3Bh		; Function: Change Current Directory
	int	21h		; DOS call
	jc	dcd0		; skip if error
	xor	ax, ax		; no error, return 0
dcd0:
	pop	bp
	ret	2
dos_change_dir	ENDP


;***********************************************************************
; dos_get_dir(drive byte, name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_get_dir	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	si, [bp+4]	; name
	mov	dl, [bp+6]	; drive
	mov	ah, 47h		; Function: Get Current Directory Name
	int	21h		; DOS call
	jc	dgd0		; skip if error
	xor	ax, ax		; no error, return 0
dgd0:
	pop	bp
	ret	4
dos_get_dir	ENDP


;***********************************************************************
; dos_create(file addr, name addr, attr word) word /* 0 if successful, error code otherwise */
;   fil based file word
;   nam based name (*) byte
;***********************************************************************

dos_create	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	cx, [bp+4]	; attribute
	mov	dx, [bp+6]	; name
	mov	ah, 3Ch		; Function: Create File
	int	21h		; DOS call
	jc	dcr0		; skip if error
	mov	si, [bp+8]	; file
	mov	[si], ax	; file handle or error code
	xor	ax, ax		; no error, return 0
dcr0:
	pop	bp
	ret	6
dos_create	ENDP


;***********************************************************************
; dos_open(file addr, name addr, mode word) word /* 0 if successful, error code otherwise */
;   fil based file word
;   nam based name (*) byte
;   /* mode = 0 for read, 1 for write, 2 for update */
;***********************************************************************

dos_open	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	al, [bp+4]	; mode
	mov	dx, [bp+6]	; name
	mov	ah, 3Dh		; Function: Open File
	int	21h		; DOS call
	jc	dop0		; skip if error
	mov	si, [bp+8]	; file
	mov	[si], ax	; file handle or error code
	xor	ax, ax		; no error, return 0
dop0:
	pop	bp
	ret	6
dos_open	ENDP


;***********************************************************************
; dos_close(file word) word /* 0 if successful, error code otherwise */
;***********************************************************************

dos_close	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	bx, [bp+4]	; file
	mov	ah, 3Eh		; Function: Close File
	int	21h		; DOS call
	jc	dcl0		; skip if error
	xor	ax, ax		; no error, return 0
dcl0:
	pop	bp
	ret	2
dos_close	ENDP


;***********************************************************************
; dos_read(file word, buff addr, count word, actual addr) word /* 0 if successful, error code otherwise */
;   buf based buff (*) byte
;   act based actual word
;***********************************************************************

dos_read	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	cx, [bp+6]	; count
	mov	dx, [bp+8]	; buff
	mov	bx, [bp+10]	; file
	mov	ah, 3Fh		; Function: Read From File or Device
	int	21h		; DOS call
	jc	drd0		; skip if error
	mov	si, [bp+4]	; actual
	mov	[si], ax	; actual bytes read or error code
	xor	ax, ax		; no error, return 0
drd0:
	pop	bp
	ret	8
dos_read	ENDP


;***********************************************************************
; dos_write(file word, buff addr, count word, actual addr) word /* 0 if successful, error code otherwise */
;   buf based buff (*) byte
;   act based actual word
;***********************************************************************

dos_write	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	cx, [bp+6]	; count
	mov	dx, [bp+8]	; buff
	mov	bx, [bp+10]	; file
	mov	ah, 40h		; Function: Write To File or Device
	int	21h		; DOS call
	jc	dwr0		; skip if error
	mov	si, [bp+4]	; actual
	mov	[si], ax	; actual bytes written or error code
	xor	ax, ax		; no error, return 0
dwr0:
	pop	bp
	ret	8
dos_write	ENDP


;***********************************************************************
; dos_delete(name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_delete	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; name
	mov	ah, 41h		; Function: Delete File
	int	21h		; DOS call
	jc	ddl0		; skip if error
	xor	ax, ax		; no error, return 0
ddl0:
	pop	bp
	ret	2
dos_delete	ENDP


;***********************************************************************
; dos_seek(file word, mode byte, offset dword, actual addr) word /* 0 if successful, error code otherwise */
;   act based actual dword
;   /* mode = 0 for beginning of file relative, 1 for current position */
;   /* relative, and 2 for end of file relative */
;***********************************************************************

dos_seek	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+6]	; low(off)
	mov	cx, [bp+8]	; high(off)
	mov	al, [bp+10]	; mode
	mov	bx, [bp+12]	; file
	mov	ah, 42h		; Function: Move File Read/Write Pointer
	int	21h		; DOS call
	jc	dsk0		; skip if error
	mov	si, [bp+4]	; actual
	mov	[si], ax	; return current offset
	mov	[si+2], dx
	xor	ax, ax		; no error, return 0
dsk0:
	pop	bp
	ret	10
dos_seek	ENDP


;***********************************************************************
; dos_get_attribute(name addr, attr addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;   att based attr word
;***********************************************************************

dos_get_attribute	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+6]	; name
	mov	ah, 43h		; Function: Change File Attributes
	mov	al, 0		; subfunction: Get attributes
	int	21h		; DOS call
	jc	dga0		; skip if error
	mov	si, [bp+4]	; attr
	mov	[si], cx	; attribute
	xor	ax, ax		; no error, return 0
dga0:
	pop	bp
	ret	4
dos_get_attribute	ENDP


;***********************************************************************
; dos_set_attribute(name addr, attr word) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_set_attribute	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	cx, [bp+4]	; attribute
	mov	dx, [bp+6]	; name
	mov	ah, 43h		; Function: Change File Attributes
	mov	al, 1		; subfunction: Set attributes
	int	21h		; DOS call
	jc	dsa0		; skip if error
	xor	ax, ax		; no error, return 0
dsa0:
	pop	bp
	ret	4
dos_set_attribute	ENDP


;***********************************************************************
; dos_allocate(segment addr, paragraphs word, max_block addr) word /* 0 if successful, error code otherwise */
;   seg based segment selector
;   max based max_block word
;***********************************************************************

dos_allocate	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	bx, [bp+6]	; paragraphs
	mov	ah, 48h		; Function: Allocate Memory
	int	21h		; DOS call
	mov	si, [bp+4]	; max_block
	mov	[si], bx	; max block size available
	mov	si, [bp+8]	; segment
	mov	[si], ax	; selector of area allocated or error code
	jc	dam0		; skip if error
	xor	ax, ax		; no error, return 0
dam0:
	pop	bp
	ret	6
dos_allocate	ENDP


;***********************************************************************
; dos_free(segment selector) word /* 0 if successful, error code otherwise */
;***********************************************************************

dos_free	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	es, [bp+4]	; segment
	mov	ah, 49h		; Function: Free Allocated Memory
	int	21h		; DOS call
	jc	dfr0		; skip if error
	xor	ax, ax		; no error, return 0
dfr0:
	pop	bp
	ret	2
dos_free	ENDP


;***********************************************************************
; dos_set_block(segment selector, paragraphs word, max_block addr) word /* 0 if successful, error code otherwise */
;   max based max_block word
;***********************************************************************

dos_set_block	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	bx, [bp+6]	; paragraphs
	mov	es, [bp+8]	; segment
	mov	ah, 4Ah		; Function: Modify Allocated Memory Block
	int	21h		; DOS call
	mov	si, [bp+4]	; max_block
	mov	[si], bx	; max block size available
	jc	dsb0		; skip if error
	xor	ax, ax		; no error, return 0
dsb0:
	pop	bp
	ret	6
dos_set_block	ENDP


;***********************************************************************
; dos_exec(mode byte, name addr, parm addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;   par based parm structure /* depends on mode */
;   /* mode = 0 to load and execute program, 3 to load overlay */
;***********************************************************************

dos_exec	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	bx, [bp+4]	; parm
	mov	ax, ds
	mov	es, ax
	mov	dx, [bp+6]	; name
	mov	al, [bp+8]	; mode
	mov	ah, 4Bh		; Function: Load or Execute
	int	21h		; DOS call
	jc	dex0		; skip if error
	xor	ax, ax		; no error, return 0
dex0:
	pop	bp
	ret	6
dos_exec	ENDP


;***********************************************************************
; dos_exit(code word)
;***********************************************************************

dos_exit	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ax, [bp+4]	; code
	mov	ah, 4Ch		; Function: Terminate Process
	int	21h		; DOS call
	pop	bp
	ret	2
dos_exit	ENDP


;***********************************************************************
; dos_wait() word /* exit code of sub-process */
;***********************************************************************

dos_wait	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 4Dh		; Function: Get Exit Code of Sub-Process
	int	21h		; DOS call
	pop	bp
	ret
dos_wait	ENDP


;***********************************************************************
; dos_find_first(name addr, attr word) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_find_first	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	cx, [bp+4]	; search attribute
	mov	dx, [bp+6]	; name
	mov	ah, 4Eh		; Function: Find First Matching File Name
	int	21h		; DOS call
	jc	dff0		; skip if error
	xor	ax, ax		; no error, return 0
dff0:
	pop	bp
	ret	4
dos_find_first	ENDP


;***********************************************************************
; dos_find_next(name addr) word /* 0 if successful, error code otherwise */
;   nam based name (*) byte
;***********************************************************************

dos_find_next	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	dx, [bp+4]	; name
	mov	ah, 4Fh		; Function: Find Next Matching File Name
	int	21h		; DOS call
	jc	dfn0		; skip if error
	xor	ax, ax		; no error, return 0
dfn0:
	pop	bp
	ret	2
dos_find_next	ENDP


;***********************************************************************
; dos_rename(old_name addr, new_name addr) word /* 0 if successful, error code otherwise */
;   old based old_name (*) byte
;   new based new_name (*) byte
;***********************************************************************

dos_rename	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	di, [bp+4]	; new_name
	mov	ax, ds
	mov	es, ax
	mov	dx, [bp+6]	; old_name
	mov	ah, 56h		; Function: Rename File
	int	21h		; DOS call
	jc	drn0		; skip if error
	xor	ax, ax		; no error, return 0
drn0:
	pop	bp
	ret	4
dos_rename	ENDP


;***********************************************************************
; dos_get_cs() selector /* current cs register value */
;***********************************************************************

dos_get_cs	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ax, cs
	pop	bp
	ret
dos_get_cs	ENDP


;***********************************************************************
; dos_get_ds() selector /* current ds register value */
;***********************************************************************

dos_get_ds	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ax, ds
	pop	bp
	ret
dos_get_ds	ENDP


;***********************************************************************
; dos_get_ss() selector /* current ss register value */
;***********************************************************************

dos_get_ss	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ax, ss
	pop	bp
	ret
dos_get_ss	ENDP


;***********************************************************************
; dos_get_psp() selector /* program prefix segment selector */
;***********************************************************************

dos_get_psp	PROC	NEAR
	push	bp
	mov	bp, sp
	mov	ah, 62h		; DOS call to Program Segment Prefix Address
	int	21h		; *** works only in DOS 3.0 or later
	mov	ax, bx

; -----	General technique for PLM small model (or when in initial code segment)

;	mov	ax, cs		; psp selector in PLM small is CS - 10h
;	sub	ax, 10h

	pop	bp
	ret
dos_get_psp	ENDP


CODE	ENDS


	END
