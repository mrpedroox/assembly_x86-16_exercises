org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov si, str1
call print

mov si, str2
call print

hlt

; print function/routine
print:
    push si     ;       stores whats in the register by enqueuing it
    push ax     ;       same
    mov ah, 0x0e    ;   print comando on the register ah, for int 0x10
.loop:
    lodsb       ;       al = msg[si], in the first case, the byte "y", and then si = si + 1
    or al, al       ;   checks if al is 0 (end of the string)
    jz .r       ;       if 0, returns
    int 0x10    ;   prints whats on al (the byte) by the command in ah (print)
    jmp .loop   ;   back to the loop
.r:
    pop ax      ;      dequeuing 
    pop si
    ret

; data
str1: db "yoooooo", 13, 10, 0   ;   13: moves the cursor to the beggining, 10: skips a line
str2: db "what am i", 13, 10, 0

times 510 - ($-$$) db 0
dw 0xaa55
