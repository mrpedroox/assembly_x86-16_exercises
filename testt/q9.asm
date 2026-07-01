org 0x7c00          ; Endereço de carga do bootloader
bits 16             ; Modo real de 16 bits

mov ax, 0           ; Configuração inicial de segmentos
mov ds, ax
cli

; 1. Entrar no modo gráfico VGA (320x200, 256 cores)
mov al, 0x13        
mov ah, 0
int 0x10            

; 2. Apontar ES para a memória de vídeo gráfica
mov ax, 0xA000      
mov es, ax

; 3. Coordenadas iniciais (centro da tela)
mov bx, 160         ; Coluna X (mantemos em BX)
mov cx, 100         ; Linha Y (MUDAMOS PARA CX PARA PROTEGER DO MUL)

.draw:
    ; Cálculo do endereço: AX = 320 * Y + X
    mov ax, 320     ; Largura da tela
    mul cx          ; AX = 320 * CX (linha). O DX é sobrescrito aqui, mas não tem problema!
    add ax, bx      ; Adiciona a coluna ao resultado (X)
    mov di, ax      ; DI agora contém o endereço exato do pixel
    
    mov byte [es:di], 15 ; Pinta o pixel de branco (cor 15)

.loop:
    mov ah, 0       ; Serviço de leitura de tecla
    int 0x16        ; Espera usuário apertar tecla (retorna em AL)

    or al, 0x20     ; TRUQUE: Converte para minúscula (evita bugs com Caps Lock)

    ; Verifica as teclas de direção (A, S, D, W)
    cmp al, 'a'     
    je .left
    cmp al, 'd'     
    je .right
    cmp al, 'w'     
    je .up
    cmp al, 's'     
    je .down
    jmp .loop       ; Tecla inválida: ignora e continua esperando

.left:  
    dec bx          ; Move X para a esquerda
    jmp .draw
.right: 
    inc bx          ; Move X para a direita
    jmp .draw
.up:    
    dec cx          ; Move Y para cima (usando CX)
    jmp .draw
.down:  
    inc cx          ; Move Y para baixo (usando CX)
    jmp .draw

times 510 - ($-$$) db 0 ; Preenchimento obrigatório
dw 0xaa55           ; Assinatura de boot
