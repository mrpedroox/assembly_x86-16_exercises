org 0x7c00          ; Esqueleto base: endereço de carga [1, 3]
bits 16             ; Modo 16 bits [1, 3]

mov ax, 0           ; Zerar estado inicial [1, 3]
mov ds, ax
cli

; 1. Entrar em modo gráfico (320x200, 256 cores)
mov al, 0x13        ; Serviço 0x13 da INT 0x10 [1, 4]
mov ah, 0
int 0x10

; 2. Apontar ES para o segmento de memória gráfica
mov ax, 0xA000      ; Endereço base da memória de vídeo gráfica [1, 5]
mov es, ax

main_loop:
    call geti       ; Recebe a linha do teclado -> valor em BX [1]
    mov si, bx      ; Salva o valor da linha em SI [1]
    call geti       ; Recebe a coluna do teclado -> valor em BX [1]
    
    ; 3. Cálculo do endereço: AX = 320 * linha + coluna
    mov ax, 320     ; Largura da tela em pixels [1, 5]
    mul si          ; AX = 320 * SI (linha) [1]
    add ax, bx      ; Adiciona a coluna (BX) ao resultado [1]
    
    mov di, ax      ; Move o endereço calculado para o registrador de índice [1]
    mov byte [es:di], 15 ; Pinta o pixel na memória com a cor 15 (branco) [1, 5]
    
    jmp main_loop   ; Retorna ao início para aceitar novas coordenadas [1, 2]

; Sub-rotina para ler um número inteiro do teclado (Receita 3) [1, 6, 7]
geti:
    xor bx, bx      ; Zera o acumulador do número
.g: mov ah, 0
    int 0x16        ; Lê tecla (caractere em AL) [1, 8]
    cmp al, 13      ; Verifica se é "Enter" (ASCII 13) [7, 9]
    je .e           ; Se for Enter, termina a leitura
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx          ; Multiplica o valor atual por 10 [1, 6]
    mov bx, ax
    sub cl, '0'     ; Converte caractere ASCII para valor numérico [7, 10]
    xor ch, ch
    add bx, cx      ; Adiciona o novo dígito ao total
    jmp .g
.e: ret

times 510 - ($-$$) db 0 ; Preenche com zeros até o byte 510 [1, 3]
dw 0xaa55               ; Assinatura de boot obrigatória [1, 3]