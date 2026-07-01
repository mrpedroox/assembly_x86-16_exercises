org 0x7c00          ; Endereço de carga do bootloader [4, 5]
bits 16             ; Modo real de 16 bits [5, 6]

mov ax, 0           ; Configuração inicial de segmentos [5, 7]
mov ds, ax
cli                 ; Desliga interrupções automáticas [5, 7]

xor dx, dx          ; Inicializa linha (DH) e coluna (DL) em 0 [3, 8]

.loop:
    mov ah, 0
    int 0x16        ; Espera e lê uma tecla do teclado (resultado em AL) [9, 10]

    mov bh, 0       ; Página de vídeo 0 [3]
    mov ah, 2
    int 0x10        ; Move o cursor para a posição definida em DH e DL [3]

    mov ah, 0x0e
    int 0x10        ; Imprime o caractere que está em AL [9, 11]

    inc dh          ; Incrementa a linha para o próximo caractere [1, 12]
    inc dl          ; Incrementa a coluna para o próximo caractere [1, 12]
    
    ; Opcional: reiniciar no topo se atingir o limite da tela (25 linhas)
    cmp dh, 25      
    jne .loop
    xor dx, dx      ; Se chegou na linha 25, reseta para (0,0) [3, 13]
    jmp .loop

times 510 - ($-$$) db 0 ; Preenchimento para completar 512 bytes [5, 14]
dw 0xaa55               ; Assinatura de boot obrigatória [5, 15]
