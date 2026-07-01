org 0x7c00          ; Endereço de carga do bootloader
bits 16             ; Modo real de 16 bits

mov ax, 0           ; Configuração inicial de segmentos
mov ds, ax
cli

call geti           ; Lê n do teclado -> resultado em BX [2]

mov ax, 1           ; Inicializa o acumulador do fatorial com 1 (0! e 1! = 1)

.loop:
    cmp bx, 1       ; Verifica se n é menor ou igual a 1
    jle .done       ; Se for, a conta acabou
    mul bx          ; AX = AX * BX (Calcula o fatorial)
    dec bx          ; Decrementa BX (próximo multiplicador)
    jmp .loop       ; Repete o ciclo

.done:
    push ax
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    pop ax
    call puti       ; Imprime o resultado contido em AX [2]

hlt                 ; Para o processador

; --- Sub-rotinas (Receitas 3 e 4 do Guia) ---

geti:               ; Lê inteiro do teclado -> BX [2]
    xor bx, bx
.g: mov ah, 0
    int 0x16
    cmp al, 13      ; Enter?
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

puti:               ; Imprime AX como decimal [2, 3]
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd: xor dx, dx
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

times 510 - ($-$$) db 0
dw 0xaa55           ; Assinatura de boot
