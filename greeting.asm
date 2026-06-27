org 0x7c00
bits 16

mov ax, 0
mov ds, ax
cli

mov si, prompt
call print

mov si, name
call getname

mov si, grt
call print

mov si, name
call print

hlt

;   subroutines
print:
    push si 
    push ax
    mov ah, 0x0e
.loop:
    lodsb
    or al, al
    jz .r
    int 0x10
    jmp .loop
.r:
    pop ax
    pop si
    ret

getname:
    push si
    push ax
    push bx
    mov si, name
.read:
    mov ah, 0
    int 0x16    ;   waits for a char to put in AL
    cmp al, 13  ;   checks if its enter
    je fim     ;   stops if enter  
    mov ah, 0x0e    ;   print command
    int 0x10
    mov [si], al
    inc si
    jmp .read
fim: 
    mov byte [si], 0    ;   puts 0 to finish the string
    mov ah, 0x0e
    mov al, 13      ;   \n  
    int 0x10        ;   prints \n
    mov al, 10      ;   move to the beggining of the line
    int 0x10
    pop bx
    pop ax
    pop si
    ret

;   data
prompt: db "Enter your name: ", 0
grt: db "Hello, ", 0
name: times 64 db 0     ;   reserves 64 bytes in memory for the input


times 510 - ($-$$) db 0
dw 0xaa55
