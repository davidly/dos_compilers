;
;	simple function to be called from 'C' to move the cursor
;
include MACROS.ASM
begdata
	c_public	curr_x
_curr_x	dw		?
	c_public	curr_y
_curr_y	dw		?

enddata
begcode gotoxy

;
;	usage:
;		void	gotoxy(int y,int x);
;
	c_public gotoxy
func	gotoxy
	push	bp
	mov		bp,sp
	mov		ax,word ptr P[bp]
	mov		curr_y,ax
	mov		dh,al
	mov		ax,word ptr P+2[bp]
	mov		curr_x,ax
	mov		dl,al
	mov		ah,2
	xor		bx,bx
	int		10H
	pop		bp
	ret
c_endp gotoxy
endcode gotoxy
end

