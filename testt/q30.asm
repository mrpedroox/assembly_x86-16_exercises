org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov si, prompt1
call print
call geti
mov [n1], ax

mov si, prompt2
call print
call geti
mov [n2], ax

mov ax, [n1]
add ax, [n2]
mov bx, 2
xor dx, dx
div bx            ; AX = Mean

cmp ax, 7
jl .reprov
mov si, msg_aprov
call print
jmp fim

.reprov:
    mov si, msg_reprov
    call print

fim:
    hlt

; --- Subroutines ---
print:
    push si 
    push ax 
    mov ah, 0x0e
.plop:
    lodsb
    or al, al 
    jz .pend
    int 0x10
    jmp .plop
.pend:
    pop ax
    pop si
    ret

geti:
    push bx
    push cx
    push dx
    xor bx, bx
.loop2:
    mov ah, 0
    int 0x16
    cmp al, 13
    je .end2
    mov ah, 0x0e
    int 0x10
    sub al, '0'
    xor ah, ah
    push ax
    mov ax, bx
    mov cx, 10
    mul cx
    mov bx, ax 
    pop ax
    add bx, ax
    jmp .loop2
.end2:
    mov ax, bx    ; Return the result in AX
    pop dx
    pop cx
    pop bx
    ret

prompt1: db "First test: ", 0
prompt2: db 13, 10, "Second test: ", 0
msg_aprov: db 13, 10, "Approved!", 0
msg_reprov: db 13, 10, "Failed!", 0
n1: dw 0
n2: dw 0

times 510 - ($-$$) db 0
dw 0xaa55