.code16
.intel_syntax noprefix
.arch i8086
.section .text,"ax"
.global start, select_compile

# Normalize a single DOS basename and leave NAME.BAS in the PSP tail.
start:
    cld
    xor cx, cx
    mov cl, byte ptr [0x80]
    mov si, 0x81
skip_space:
    or cx, cx
    jz usage
    lodsb
    dec cx
    cmp al, ' '
    je skip_space
    push cs
    pop es
    mov di, offset filename
    xor bx, bx
stem:
    cmp al, '.'
    je extension
    cmp al, ' '
    je trailing
    call upper
    cmp al, 'A'
    jb digit
    cmp al, 'Z'
    jbe store
digit:
    cmp al, '0'
    jb punctuation
    cmp al, '9'
    jbe store
punctuation:
    cmp al, '_'
    je store
    cmp al, '-'
    jne usage
store:
    stosb
    inc bx
    cmp bx, 8
    ja usage
    jcxz finish
    lodsb
    dec cx
    jmp stem
extension:
    cmp cx, 3
    jb usage
    lodsb
    call upper
    cmp al, 'B'
    jne usage
    lodsb
    call upper
    cmp al, 'A'
    jne usage
    lodsb
    call upper
    cmp al, 'S'
    jne usage
    sub cx, 3
trailing:
    jcxz finish
    lodsb
    dec cx
    cmp al, ' '
    je trailing
usage:
    mov dx, offset usage_message
    jmp diagnostic
finish:
    or bx, bx
    jz usage
    mov ax, 0x422e
    stosw
    mov ax, 0x5341
    stosw
    xor al, al
    stosb
    push ds
    push cs
    pop ds
    mov dx, offset filename
    mov ax, 0x3d00
    int 0x21
    mov dx, offset missing_message
    jc diagnostic
    mov bx, ax
    mov ah, 0x3e
    int 0x21
    pop es
    mov si, offset filename
    mov di, 0x82
    mov byte ptr es:[0x81], ' '
copy_tail:
    lodsb
    stosb
    or al, al
    jnz copy_tail
    dec di
    mov byte ptr es:[di], 13
    sub di, 0x81
    mov ax, di
    mov byte ptr es:[0x80], al
    push es
    pop ds
    mov ax, cs
    sub ax, IMAGE_SEGMENT - OLD_CS
    mov word ptr cs:[entry+2], ax
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    jmp far ptr cs:[entry]
upper:
    cmp al, 'a'
    jb upper_done
    cmp al, 'z'
    ja upper_done
    and al, 0xdf
upper_done:
    ret

diagnostic:
    push cs
    pop ds
    mov ah, 9
    int 0x21
    jmp failed


# Select the native compile action and stop if the IDE returns to its input loop.
select_compile:
.if POWERBASIC
    # The PowerBASIC dispatcher checks the selection twice before compiling.
    cmp byte ptr cs:[phase], 2
    jae failed
.else
    cmp byte ptr cs:[phase], 0
    jne failed
.endif
    inc byte ptr cs:[phase]
.if POWERBASIC
    # Main file is a zero-terminated string in the IDE configuration area.
    push si
    push es
    push ds
    push di
    push cx
    push ds
    pop es
    push cs
    pop ds
    cld
    mov si, offset filename
    mov di, 0x3e70
    mov cx, 13
    rep movsb
    pop cx
    pop di
    pop ds
    pop es
    mov ax, 0x7000
    pop si
.else
    mov ax, 0x2e00
    mov word ptr [bp-2], ax
.endif
    retf
failed:
    mov ax, 0x4c01
    int 0x21
entry:
    .word OLD_IP, 0
phase:
    .byte 0
filename:
    .space 13
usage_message:
.if POWERBASIC
    .ascii "Usage: PBCL name[.BAS]\r\n$"
.else
    .ascii "Usage: TBCL name[.BAS]\r\n$"
.endif
missing_message:
    .ascii "Cannot open BASIC source.\r\n$"
