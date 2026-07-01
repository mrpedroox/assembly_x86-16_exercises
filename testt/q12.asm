org 0x7c00          ; Esqueleto base [8, 9]
bits 16

mov ax, 0           ; Zerar segmentos [9]
mov ds, ax
cli

call geti           ; Lê n (vértices) -> valor em BX [5]

cmp bx, 0           ; Se n for 0, a altura é 0
je .is_zero

mov cx, -1          ; Contador de altura (log2)

.calc_height:       ; Laço para calcular log2(n) [4]
    inc cx          ; Incrementa altura
    shr bx, 1       ; Desloca bits para a direita (divide por 2) [3, 6]
    jnz .calc_height ; Repete enquanto BX não for zero
mov ah, 0x0e
mov al, 13
int 0x10
mov al, 10
int 0x10
mov ax, cx          ; Move resultado para AX para imprimir
call puti           ; Imprime a altura na tela [5]
jmp fim

.is_zero:
    mov ax, 0
    call puti

fim:
    hlt             ; Para o processador [9]

; --- Receitas Prontas (Parte 5 do Guia) ---

geti:               ; Lê inteiro do teclado -> BX [5]
    xor bx, bx
.g: mov ah, 0
    int 0x16        ; Interrupção de teclado [10, 11]
    cmp al, 13      ; Enter?
    je .e
    mov ah, 0x0e    ; Eco na tela [12, 13]
    int 0x10
    sub al, '0'     ; Converte ASCII para valor [5, 14]
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    xor ch, ch
    add bx, cx
    jmp .g
.e: ret

puti:               ; Imprime AX como decimal [5]
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd: xor dx, dx     ; Limpa DX antes da divisão [3, 15]
    div bx          ; AX = quociente, DX = resto
    push dx
    inc cx
    or ax, ax
    jnz .pd
.pp: pop dx
    add dl, '0'
    mov ah, 0x0e
    mov al, dl
    int 0x10
    loop .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

times 510 - ($-$$) db 0 ; Assinatura de boot [9, 16]
dw 0xaa55
