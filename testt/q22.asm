org 0x7c00          ; Endereço de carga do bootloader [3, 4]
bits 16             ; Modo real de 16 bits [5]

mov ax, 0           ; Configuração inicial de segmentos [6]
mov ds, ax
cli

; 1. Leitura dos 4 parâmetros (Índice, R, G, B)
call geti           ; Lê índice da paleta -> BX [7]
mov [idx], bl
call geti           ; Lê intensidade de Vermelho (0-63) -> BX [1]
mov [r], bl
call geti           ; Lê intensidade de Verde (0-63) -> BX [1]
mov [g], bl
call geti           ; Lê intensidade de Azul (0-63) -> BX [1]
mov [b], bl

; 2. Atualização da Paleta de Cores via Portas de Hardware
mov dx, 0x3C8       ; Porta para selecionar o índice a ser alterado [1, 8]
mov al, [idx]
out dx, al          ; Envia o índice escolhido [9]

mov dx, 0x3C9       ; Porta para enviar os valores RGB [8, 9]
mov al, [r]
out dx, al          ; Envia componente Vermelha
mov al, [g]
out dx, al          ; Envia componente Verde
mov al, [b]
out dx, al          ; Envia componente Azul

; 3. Entrar no modo gráfico VGA (320x200, 256 cores)
mov al, 0x13        ; Serviço 0x13 da INT 0x10 [10, 11]
mov ah, 0
int 0x10

; 4. Desenhar a sequência da paleta (2560 pixels)
mov ax, 0xA000      ; Endereço da memória de vídeo gráfica [12, 13]
mov es, ax
xor di, di          ; Começa no pixel 0
xor bl, bl          ; BL será o índice da cor atual (0 a 255)

.color_loop:
    mov cx, 10      ; Desenha 10 pixels por cor [2]
.pixel:
    mov [es:di], bl ; Pinta o pixel na memória [14]
    inc di
    loop .pixel     ; Repete 10 vezes
    
    inc bl          ; Passa para a próxima cor da paleta
    jnz .color_loop ; Repete até bl voltar a 0 (após a cor 255)

hlt                 ; Congela o processador [15]

; Variáveis de armazenamento
idx: db 0
r: db 0
g: db 0
b: db 0

; Sub-rotina para ler um número inteiro (Receita 3) [7]
geti:
    xor bx, bx
.g: mov ah, 0
    int 0x16        ; Lê tecla [10]
    cmp al, 13      ; É Enter? [16]
    je .e
    mov ah, 0x0e    ; Eco do caractere na tela [17]
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
.e: mov ah, 0x0e
    mov al, 13      ; Carriage Return (Volta ao início da linha)
    int 0x10
    mov al, 10      ; Line Feed (Desce uma linha)
    int 0x10
    ret

times 510 - ($-$$) db 0 ; Preenchimento obrigatório [4, 15]
dw 0xaa55               ; Assinatura de boot [4, 18]
