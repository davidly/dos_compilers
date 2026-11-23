.intel_syntax noprefix
.code16
.arch i8086
.section .driver,"ax"
.global entry, failure, make_output, close_output
entry:
    call parse_tail
    mov byte ptr [diagnostics_flag], 1
    call load_diagnostics
    call reset_source
    mov word ptr [missing_vector], missing_source
    call prepare_source
    call load_source
    mov byte ptr [compile_mode], 2
    call compile_source
    mov ax, 0x4c00
    int 0x21

# The caller expects the original DOS result and flags.
make_output:
    call dos_make
.if uses_fcb
    cmp al, 0xff
    je make_done
.else
    jc make_done
.endif
    mov byte ptr cs:[created], 1
make_done:
    ret

close_output:
    call dos_close
.if uses_fcb
    cmp al, 0xff
    je write_error
.else
    jc write_error
.endif
    ret
write_error:
    jmp disk_error

failure:
    cmp byte ptr cs:[created], 0
    je failed
    mov dx, output_name
.if uses_fcb
    mov ah, 0x10
    int 0x21
    mov dx, output_name
    mov ah, 0x13
.else
    mov ah, 0x41
.endif
    int 0x21
failed:
    mov ax, 0x4c01
    int 0x21

created: .byte 0

.section .parser,"ax"
.global parse_tail
# DOS stores the command tail at CS:80h. Turbo has already changed DS.
# Save the validated basename in code-segment scratch space until the
# message overlay has loaded, then build the compiler's filename record.
parse_tail:
    cld
    xor cx, cx
    mov cl, byte ptr cs:[0x80]
    mov si, 0x81
    mov di, offset basename
    xor bx, bx
skip_spaces:
    jcxz usage
    call next_char
    cmp al, ' '
    je skip_spaces
stem:
    cmp al, '.'
    je extension
    cmp al, ' '
    je trailing
    cmp al, 'A'
    jb digit
    cmp al, 'Z'
    jbe store
digit:
    cmp al, '0'
    jb check_punctuation
    cmp al, '9'
    jbe store
check_punctuation:
    cmp al, '_'
    je store
    cmp al, '-'
    jne usage
store:
    cmp bl, 8
    je usage
    mov byte ptr cs:[di], al
    inc di
    inc bl
    jcxz check_stem
    call next_char
    jmp stem
extension:
    cmp cl, 3
    jb usage
    call next_char
    cmp al, 'P'
    jne usage
    call next_char
    cmp al, 'A'
    jne usage
    call next_char
    cmp al, 'S'
    jne usage
trailing:
    jcxz check_stem
    call next_char
    cmp al, ' '
    je trailing
    jmp usage
check_stem:
    test bl, bl
    jz usage
    ret

next_char:
    cs lodsb
    dec cx
    cmp al, 'a'
    jb uppercase_done
    cmp al, 'z'
    ja uppercase_done
    sub al, 32
uppercase_done:
    ret

usage:
    push cs
    pop ds
    mov dx, offset help
    mov ah, 9
    int 0x21
    jmp failure

basename: .ascii "        "

# Restore the input name in the record format expected by the IDE loader.
.section .driver,"ax"
help: .ascii "Usage: TURBOCL name[.PAS]\r\n$"
prepare_source:
    push ds
    pop es
    mov si, offset basename
    mov di, source_name
.if uses_fcb
    mov ah, 0x19
    int 0x21
    inc al
    stosb
    mov cx, 8
    cs rep movsb
    mov ax, 0x4150
    stosw
    mov al, 'S'
    stosb
.else
copy_name:
    cs lodsb
    cmp al, ' '
    je name_done
    stosb
    cmp si, offset basename + 8
    jb copy_name
name_done:
    mov ax, 0x502e
    stosw
    mov ax, 0x5341
    stosw
    xor al, al
    stosb
.endif
    ret
