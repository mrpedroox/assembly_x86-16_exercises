org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov si, prompt1
call print
call geti
mov ax, bx

mov si, prompt2
call print
call geti
mov dx, bx

mov si, prompt3
call geti
mov cl, bl

push ax
push dx
push cl

mov al, 0x13
mov ah, 0
int 0x10
mov bx, 0xA000
mov es, bx

pop cl
pop dx
pop ax

push ax
mov ax, 320
mul dx
mov di, ax
pop ax
add di, ax

mov byte [es:di], cl
hlt

print:
    push si
    push ax
    mov ah, 0x0e
.l:
    lodsb
    or al, al
    jz .r
    int 0x10
    jmp .l
.r:
    pop ax
    pop si
    ret




