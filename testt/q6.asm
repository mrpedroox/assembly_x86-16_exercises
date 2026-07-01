org 0x7c00          ; Endereço de carga do bootloader [2, 3]
bits 16             ; Modo real de 16 bits [2, 4]

mov ax, 0           ; Configuração inicial de segmentos [4]
mov ds, ax
cli                 ; Desliga interrupções automáticas [4, 5]

; 1. Entrar no modo gráfico VGA (320x200, 256 cores)
mov al, 0x13        ; Serviço 0x13 da INT 0x10 [6, 7]
mov ah, 0
int 0x10

; 2. Apontar ES para a memória de vídeo gráfica
mov ax, 0xA000      ; Endereço base da memória de vídeo [7-9]
mov es, ax

xor bp, bp          ; BP será nosso deslocamento (offset) de cor inicial

.redraw:
    mov di, 0       ; DI aponta para o início da memória de vídeo [7]
    mov dx, 0       ; DX será o contador de linhas (0 a 199) [9]

.line:
    mov bx, dx      ; Pega o número da linha atual
    add bx, bp      ; Soma o deslocamento (cor seguinte ao passo anterior) [1]
    mov al, bl      ; Define o índice da cor do pixel
    mov cx, 320     ; 320 pixels por linha [9, 10]

.pix:
    mov [es:di], al ; Pinta o pixel na memória [9, 10]
    inc di          ; Avança para o próximo pixel
    loop .pix       ; Repete para toda a largura da linha [11]

    inc dx          ; Avança para a próxima linha
    cmp dx, 200     ; Verifica se pintou as 200 linhas da tela [9, 12]
    jne .line       ; Continua se não terminou a tela

    inc bp          ; Incrementa a cor inicial para o próximo passo [12]
    jmp .redraw     ; Loop infinito: reinicia a pintura imediatamente [13, 14]

times 510 - ($-$$) db 0 ; Preenchimento de 512 bytes [3, 5, 15]
dw 0xaa55               ; Assinatura de boot [2, 5, 15]