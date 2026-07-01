org 0x7c00          ; Endereço de carga do bootloader [3]
bits 16             ; Modo real de 16 bits [4]

mov ax, 0           ; Configuração inicial de segmentos [4, 5]
mov ds, ax
cli

call getbin         ; Lê a sequência de bits -> resultado em BX
mov ah, 0x0e
mov al, 13
int 0x10
mov al, 10
int 0x10
mov ax, bx
call puti           ; Imprime o número em decimal na tela [2]

hlt                 ; Para o processador [4, 6]

; --- Sub-rotinas ---

getbin:             ; Lê binário do teclado e converte para número
    xor bx, bx      ; Zera o acumulador [7]
.g: mov ah, 0
    int 0x16        ; Lê tecla (caractere em AL) [8, 9]
    cmp al, 13      ; Verifica se é Enter (ASCII 13) [10, 11]
    je .e           ; Se for Enter, termina a leitura
    
    push ax         ; Salva a tecla para fazer o "eco"
    mov ah, 0x0e
    int 0x10        ; Mostra o bit digitado na tela [8, 12]
    pop ax
    
    sub al, '0'     ; Converte caractere '0' ou '1' para valor 0 ou 1 [2, 11]
    shl bx, 1       ; Multiplica o acumulador por 2 (abre espaço para o bit) [13]
    xor ah, ah
    add bx, ax      ; Soma o novo bit ao total
    jmp .g
.e: ret

puti:               ; Receita 4: Imprime o número em AX como decimal [2]
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd: xor dx, dx     ; Limpa DX antes da divisão [7, 14]
    div bx          ; AX = quociente, DX = resto (dígito) [15, 16]
    push dx         ; Guarda o dígito na pilha
    inc cx
    or ax, ax       ; Verifica se ainda há número [17]
    jnz .pd
.pp: pop dx         ; Recupera os dígitos na ordem correta
    add dl, '0'     ; Converte número para caractere ASCII [2, 11]
    mov ah, 0x0e
    mov al, dl
    int 0x10        ; Imprime o dígito [8, 12]
    loop .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

times 510 - ($-$$) db 0 ; Preenche até 510 bytes [4, 6]
dw 0xaa55               ; Assinatura de boot [4, 6]
