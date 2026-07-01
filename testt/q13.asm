org 0x7c00          ; Endereço de carga
bits 16

mov ax, 0           ; Configuração de segmentos
mov ds, ax
cli

call geti           ; Lê o número -> BX

cmp bx, 2           ; Se for 2, é primo
je e_primo
cmp bx, 1           ; Se for <= 1, não é primo
jle nao_eh_primo

mov cx, 2           ; Inicia divisor em 2
.loop:
    cmp cx, bx      ; Já testamos todos os divisores até n-1?
    je e_primo
    
    mov ax, bx      ; Prepara dividendo
    xor dx, dx      ; Limpa DX antes da divisão (Crucial!) [3, 4]
    div cx          ; AX = quociente, DX = resto
    
    cmp dx, 0       ; Se o resto for 0, encontramos um divisor
    je nao_eh_primo
    
    inc cx          ; Tenta o próximo número
    jmp .loop

nao_eh_primo:
    mov si, msg_nao
    call prints
    jmp fim

e_primo:
    mov si, msg_sim
    call prints

fim:
    hlt

; --- Sub-rotinas (Receitas 3 e 1) ---
geti:               ; Lê inteiro do teclado [5]
    xor bx, bx
.g: mov ah, 0
    int 0x16
    cmp al, 13
    je .e
    mov ah, 0x0e
    int 0x10
    sub al, '0'
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    xor ch, ch
    add bx, cx
    jmp .g
.e: ret

prints:             ; Imprime string [5]
    mov ah, 0x0e
.l: lodsb
    or al, al
    jz .r
    int 0x10
    jmp .l
.r: ret

msg_sim: db 13, 10, "EH PRIMO", 0
msg_nao: db 13, 10, "NAO EH PRIMO", 0

times 510 - ($-$$) db 0
dw 0xaa55
