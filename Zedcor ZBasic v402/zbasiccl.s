.code16
.intel_syntax noprefix
.arch i8086
.section .startup,"ax"
.global start, command, command_line, output_line, closed

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
    mov dx, offset filename
    mov ax, 0x3d00
    int 0x21
    mov dx, offset missing_message
    jc diagnostic
    mov bx, ax
    mov ah, 0x3e
    int 0x21
    mov si, offset filename
    mov di, 0x82
    mov byte ptr [0x81], ' '
copy_tail:
    lodsb
    stosb
    or al, al
    jnz copy_tail
    dec di
    mov byte ptr [di], 13
    sub di, 0x81
    mov ax, di
    mov byte ptr [0x80], al
    mov word ptr [si-4], 0x4f43
    mov byte ptr [si-2], 'M'
    jmp finish_startup
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
    jmp failure
.section .driver,"ax"
# The original image uses the startup area for zero-initialized variables.
finish_startup:
    xor ax, ax
    mov di, offset start
    mov cx, 0x010e
    rep stosb
    xor bx, bx
    xor dx, dx
    xor si, si
    xor di, di
    jmp 0x5090

# Supply RUN* to the existing command parser. Re-entry means the build failed.
command:
    cmp byte ptr cs:[phase], 0
    jne failure
    inc byte ptr cs:[phase]
    mov al, 'r'
    ret
command_line:
    mov word ptr [si], 0x7572
    mov word ptr [si+2], 0x2a6e
    mov byte ptr [si+4], 0
    mov bx, 4
    mov cx, bx
    mov ax, 0x080a
    clc
    ret

# Put the standalone output name directly into the native filename buffer.
output_line:
    # Restore the shared runtime routine before it is copied into the COM.
    mov word ptr cs:[0x0d11], 0x30e8
    mov byte ptr cs:[0x0d13], 0
    mov bp, si
    inc byte ptr cs:[phase]
    push si
    push di
    mov di, si
    mov si, offset filename
    xor bx, bx
copy_output:
    mov al, byte ptr cs:[si]
    mov byte ptr [di], al
    inc si
    inc di
    or al, al
    jz output_copied
    inc bx
    jmp copy_output
output_copied:
    mov cx, bx
    pop di
    pop si
    mov ax, 0x080a
    clc
    ret

# Finish the last record and close the standalone output file.
closed:
    call 0x3df3
    or al, al
    jnz failure
    mov ax, 0x4c00
    int 0x21
failure:
    mov ax, 0x4c01
    int 0x21
phase:
    .byte 0
usage_message:
    .ascii "Usage: ZBASICCL name[.BAS]\r\n$"
missing_message:
    .ascii "Cannot open BASIC source.\r\n$"
filename:
    .space 14
