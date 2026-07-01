org 0x7c00          
bits 16             

; --- SETUP INICIAL ---
xor ax, ax          ; Zera AX
mov ds, ax

; Limpar a tela e definir o modo de vídeo (Texto 80x25)
mov ax, 0x0003      ; Função 0x00, Modo 0x03 da BIOS
int 0x10

mov ax, 0xB800      ; Segmento da memória de vídeo em modo texto
mov es, ax
xor di, di          ; Posição inicial: 0 (Canto superior esquerdo)

; Desenha o 'A' inicial
mov byte [es:di], 'A'
mov byte [es:di+1], 0x0F ; Branco sobre preto

; --- LOOP PRINCIPAL ---
.loop:
    mov ah, 0
    int 0x16        ; Espera e lê uma tecla (resultado em AL)
    
    ; Truque rápido: Converte letras maiúsculas (W,A,S,D) para minúsculas
    ; Isso garante que o programa funcione mesmo com o Caps Lock ativado
    or al, 0x20     

    ; 1. Apaga a posição antiga escrevendo um espaço (' ')
    mov byte [es:di], ' '
    mov byte [es:di+1], 0x0F ; Usar o atributo normal evita blocos pretos visíveis

    ; 2. Verifica a tecla
    cmp al, 'a'     ; Esquerda
    je .left
    cmp al, 'd'     ; Direita
    je .right
    cmp al, 'w'     ; Cima
    je .up
    cmp al, 's'     ; Baixo
    je .down
    jmp .draw       ; Tecla inválida: apenas redesenha no lugar

; --- LÓGICA DE MOVIMENTO E LIMITES (COLISÕES) ---
.left: 
    cmp di, 0       ; Já está no limite inicial da memória?
    je .draw        ; Se sim, não subtrai, apenas desenha de novo
    sub di, 2
    jmp .draw

.right: 
    cmp di, 3998    ; Limite máximo da tela (80 col * 25 lin * 2 bytes = 4000)
    jge .draw       ; Se for maior ou igual ao último pixel, cancela movimento
    add di, 2
    jmp .draw

.up:  
    cmp di, 160     ; Está na primeira linha (índices 0 a 158)?
    jl .draw        ; Se for menor que 160, não dá para subir
    sub di, 160
    jmp .draw

.down: 
    cmp di, 3840    ; Está na última linha (4000 - 160)?
    jge .draw       ; Se sim, não dá para descer mais
    add di, 160

; --- DESENHO E RETORNO ---
.draw:
    ; 3. Desenha o 'A' na nova posição
    mov byte [es:di], 'A'
    mov byte [es:di+1], 0x0F
    jmp .loop       ; Reinicia o ciclo

times 510 - ($-$$) db 0 
dw 0xaa55           ; Assinatura de boot obrigatória
