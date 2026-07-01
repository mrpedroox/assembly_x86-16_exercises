org 0x7c00          ; Endereço de carga do bootloader
bits 16             ; Modo real de 16 bits

mov ax, 0           ; Configuração de segmentos
mov ds, ax
mov ax, 0xB800      ; Segmento da memória de vídeo (texto)
mov es, ax

.show:
    mov si, str     ; Ponteiro para a string
    mov di, 0       ; Início da tela (linha 0, coluna 0)
    mov cx, 8       ; FIX: Define que apenas 8 caracteres serão impressos
.draw:
    lodsb           ; Carrega caractere de [SI] em AL e avança SI
    mov [es:di], al ; Escreve o caractere na memória de vídeo
    mov byte [es:di+1], 0x0F ; Define cor: branco sobre preto
    add di, 2       ; Avança para a próxima célula (2 bytes por char)
    loop .draw      ; FIX: Repete o bloco .draw exatamente 8 vezes (diminui CX)

.wait:
    mov ah, 0
    int 0x16        ; Interrupção de teclado: lê tecla
    cmp al, 13      ; Verifica se a tecla pressionada foi Enter (ASCII 13)
    jne .wait       ; Se não for Enter, ignora e continua esperando

    ; Lógica de Rotação: Desloca a string 1 caractere para a esquerda
    mov al, [str]   ; Salva o 1º caractere em AL
    mov si, str     ; Reinicia ponteiro no início da string
.rot:
    mov bl, [si+1]  ; Pega o caractere da frente
    mov [si], bl    ; Move-o para a posição atual
    inc si
    cmp byte [si+1], 0 ; Verifica se o próximo é o fim da string (0)
    jne .rot        ; Continua o deslocamento da memória até o fim
    
    mov [si], al    ; Coloca o antigo 1º caractere no final da string
    jmp .show       ; Redesenha os primeiros 8 caracteres da nova string

; FIX: String atualizada com o asterisco conforme o exemplo
str: db "Ola,mundo!*", 0 

times 510 - ($-$$) db 0 
dw 0xaa55           ; Assinatura de boot obrigatória
