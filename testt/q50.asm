org 0x7c00          ; Endereço de carga do bootloader [2]
bits 16             ; Modo real de 16 bits [2]

mov ax, 0           ; Configuração de segmentos [3]
mov ds, ax
cli

call getnum         ; Lê o ano do teclado -> valor em BX [4]

; 1. Verificar se é divisível por 400 (Sempre bissexto)
mov ax, bx
xor dx, dx          ; Limpar DX antes da divisão [5]
mov cx, 400
div cx
cmp dx, 0           ; Resto 0? [6]
je bissexto

; 2. Verificar se é divisível por 100 (Não bissexto, exceto se passou na anterior)
mov ax, bx
xor dx, dx
mov cx, 100
div cx
cmp dx, 0
je nao_bissexto

; 3. Verificar se é divisível por 4
mov ax, bx
xor dx, dx
mov cx, 4
div cx
cmp dx, 0
je bissexto

nao_bissexto:
    mov si, msg_nao
    call prints
    jmp fim

bissexto:
    mov si, msg_sim
    call prints

fim:
    hlt             ; Para o processador [7]

; --- Sub-rotinas ---

getnum:             ; Receita 3: Lê inteiro do teclado [4]
    xor bx, bx
.g: mov ah, 0
    int 0x16        ; Lê tecla [8]
    cmp al, 13      ; É Enter? [9]
    je .e
    mov ah, 0x0e
    int 0x10
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    sub cl, '0'     ; Converte ASCII para número [10]
    xor ch, ch
    add bx, cx
    jmp .g
.e: ret

prints:             ; Receita 1: Imprime string [10]
    mov ah, 0x0e    ; Serviço de vídeo BIOS [8]
.l: lodsb
    or al, al
    jz .r
    int 0x10        ; Imprime caractere [11]
    jmp .l
.r: ret

msg_sim: db 13, 10, "ANO BISSEXTO", 0
msg_nao: db 13, 10, "NAO EH BISSEXTO", 0

times 510 - ($-$$) db 0 ; Preenchimento [2]
dw 0xaa55               ; Assinatura de boot [2]
