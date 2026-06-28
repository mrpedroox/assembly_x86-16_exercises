org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov si, prompt1
call print

call geti
mov cx, bx

mov si, prompt2
call print

call geti
add cx, bx  ;   cx(last number stored) + bx(new number)
mov ax, cx  ;   result in ax

mov si, result
call print

call puti

hlt

;   subroutines
print:
    push si
    push ax
    mov ah, 0x0e
.loop:
    lodsb
    or al, al
    jz .r
    int 0x10
    jmp .loop
.r:
    pop ax
    pop si
    ret

geti:
    push ax         ; salva AX
    push cx         ; FIX: salva CX para nao perder o 1º numero do main
    push dx         ; FIX: salva DX porque mul altera o registrador DX
                    ; NAO salva BX — ele é o retorno da funcao
    xor bx, bx
.g: mov ah, 0
    int 0x16
    cmp al, 13
    je .e
    mov ah, 0x0e
    int 0x10
    push ax
    mov ax, bx
    mov cx, 10
    mul cx
    mov bx, ax
    pop ax
    sub al, '0'
    xor ah, ah
    add bx, ax
    jmp .g
.e: mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    pop dx          ; FIX: restaura DX
    pop cx          ; FIX: restaura CX
    pop ax          ; restaura AX
    ret             ; BX tem o resultado — nao mexe nele

puti:
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd:
    xor dx, dx
    div bx  ;   ax = ax/10, dx = mod
    push dx
    inc cx  
    or ax, ax
    jnz .pd
.pp:
    pop dx
    add dl, '0'
    mov ah, 0x0e
    mov al, dl
    int 0x10
    dec cx
    jnz .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;   data
prompt1: db "First number: ", 0
prompt2: db "Second number: ", 0
result: db 13, 10, "Sum: ", 0

times 510 - ($-$$) db 0
dw 0xaa55
