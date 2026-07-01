org 0x7c00          ; Endereço de carga do bootloader [2, 3]
bits 16             ; Modo real de 16 bits [4, 5]

mov ax, 0           ; Configuração inicial de segmentos [6]
mov ds, ax
cli                 ; Desliga interrupções automáticas [5, 6]

call geti           ; Lê o número do teclado -> valor em BX [1, 7]
mov cx, 2           ; CX será o nosso fator atual (começa em 2) [1]

.outer:
    cmp bx, 1       ; Se o número no acumulador BX for 1 ou menos... [1]
    jle .done       ; ...a decomposição terminou [1]
    
    mov ax, bx      ; Prepara AX para a divisão [8, 9]
    xor dx, dx      ; LIMPEZA CRUCIAL: Zera DX antes da divisão [8, 10]
    div cx          ; AX = BX / CX, DX = Resto [8, 9]
    
    cmp dx, 0       ; O resto é zero? (É divisível?) [1]
    jne .next       ; Se não for, pula para tentar o próximo fator [1]
    
    mov bx, ax      ; Atualiza BX com o quociente (o número "encolhe") [1]
    push bx         ; Salva o número atual na pilha para não perder no puti [11]
    push cx         ; Salva o fator atual na pilha [11, 12]
    
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    mov ax, cx      ; Move o fator para AX para poder imprimir [13]
    call puti       ; Imprime o fator primo encontrado [1, 13]
    
    ; Imprime um espaço entre os fatores
    mov ah, 0x0e
    mov al, ' '
    int 0x10        ; BIOS Video Service [11, 14]
    
    pop cx          ; Restaura o fator atual [11, 12]
    pop bx          ; Restaura o número acumulado [11]
    jmp .outer      ; Tenta dividir pelo MESMO fator novamente [1]

.next:
    inc cx          ; Tenta o próximo divisor (incrementa CX) [1, 15]
    jmp .outer      ; Volta para testar a nova divisão [1]

.done:
    hlt             ; Congela o processador ao terminar [5, 16]

; --- Sub-rotinas (Receitas 3 e 4) ---

geti:               ; Receita 3: Lê inteiro do teclado -> BX [7, 17]
    xor bx, bx
.g: mov ah, 0
    int 0x16        ; Lê tecla [18, 19]
    cmp al, 13      ; É Enter? [13, 20]
    je .e
    mov ah, 0x0e
    int 0x10        ; Eco do caractere [18]
    sub al, '0'     ; ASCII -> Valor [13, 21]
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx          ; BX = BX * 10 [7]
    mov bx, ax
    xor ch, ch
    add bx, cx      ; Soma o novo dígito [7, 17]
    jmp .g
.e: ret

puti:               ; Receita 4: Imprime AX como decimal [1, 13]
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd: xor dx, dx
    div bx          ; AX = quociente, DX = resto [8, 9]
    push dx         ; Guarda dígito [13]
    inc cx
    or ax, ax       ; Ainda há número? [22]
    jnz .pd
.pp: pop dx
    add dl, '0'     ; Valor -> ASCII [13, 21]
    mov ah, 0x0e
    mov al, dl
    int 0x10        ; Imprime dígito [11, 14]
    loop .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

times 510 - ($-$$) db 0 ; Preenchimento de 512 bytes [3, 16]
dw 0xaa55               ; Assinatura de boot [2, 16]
