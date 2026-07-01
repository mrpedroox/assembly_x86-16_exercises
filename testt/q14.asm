org 0x7c00          ; Endereço de carga do bootloader
bits 16             ; Modo real de 16 bits

mov ax, 0           ; Configuração inicial de segmentos
mov ds, ax
cli

call geti           ; Lê 'n' do teclado -> valor em BX
mov cx, bx          ; Move para o contador CX

; Pular linha para organizar a tela
mov ah, 0x0e
mov al, 13
int 0x10
mov al, 10
int 0x10

; --- Tratamento de casos base ---
cmp cx, 1
je .ret_zero        ; Se n=1, resultado é 0
cmp cx, 2
je .ret_one         ; Se n=2, resultado é 1

; --- Cálculo iterativo para n > 2 ---
sub cx, 2           ; Subtrai os 2 primeiros termos já conhecidos
mov ax, 0           ; Primeiro termo (n-2)
mov bx, 1           ; Segundo termo (n-1)

.loop:
    mov dx, ax      ; Salva n-2 temporariamente
    add dx, bx      ; DX = (n-2) + (n-1) -> Novo Termo
    mov ax, bx      ; n-2 vira n-1 para o próximo passo
    mov bx, dx      ; n-1 vira o Novo Termo
    loop .loop      ; Decrementa CX e repete até chegar ao n-ésimo

    mov ax, bx      ; Coloca o resultado final em AX para imprimir
    call puti
    jmp fim

.ret_zero:
    mov ax, 0
    call puti
    jmp fim

.ret_one:
    mov ax, 1
    call puti

fim: hlt

; --- Sub-rotinas (Receitas 3 e 4) ---

geti:               ; Lê inteiro do teclado -> BX
    xor bx, bx
.g: mov ah, 0
    int 0x16
    cmp al, 13
    je .e
    mov ah, 0x0e
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
.e: ret

puti:               ; Imprime AX como decimal
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd: xor dx, dx
    div bx          ; Divide por 10 para pegar os dígitos
    push dx
    inc cx
    or ax, ax
    jnz .pd
.pp: pop dx
    add dl, '0'
    mov ah, 0x0e
    mov al, dl
    int 0x10
    loop .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

times 510 - ($-$$) db 0
dw 0xaa55
