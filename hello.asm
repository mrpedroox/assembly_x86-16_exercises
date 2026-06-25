org 0x7c00
bits 16

mov ax, 0
mov ds, ax

cli

main:
    mov si, msg
    mov ah, 0x0e

.loop:
    lodsb
    or al, al ; ou cmp al, 0
    jz fim
    int 0x10
    jmp .loop

fim:
    hlt

msg:
    db "hello world!"

times 510 - ($-$$) db 0
dw 0xaa55
