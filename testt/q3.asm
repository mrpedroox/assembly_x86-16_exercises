org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov ax, 0xB800      ; segmento de memória de vídeo em modo texto
mov es, ax
mov di, 0           ; di = índice (offset) dentro da memória de vídeo

main:
    mov ah, 0
    int 0x16             ; lê tecla pressionada -> AL = código ASCII

    mov [es:di], al      ; grava o caractere na tela
    mov [es:di+1], al    ; grava a cor = código ASCII do próprio caractere

    add di, 2            ; avança para a próxima posição (próximo caractere)
    jmp main             ; volta a ler a próxima tecla (loop infinito)

times 510 - ($-$$) db 0
dw 0xaa55