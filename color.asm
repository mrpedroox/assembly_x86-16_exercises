org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov al, 0x13
mov ah, 0
int 0x10
mov ax, 0xA000
mov es, ax

mov cx, 16000
mov di, 0

loop:
    mov [es:di], byte 50
    inc di
    dec cx
    jnz loop
    hlt

times 510 - ($-$$) db 0
dw 0xaa55
