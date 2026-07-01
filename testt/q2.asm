org 0x7c00
bits 16

; --- SETUP ---
xor ax, ax
mov ds, ax
cli

; --- MAIN PROGRAM ---
mov si, prompt
call print

call get_int       ; Read the integer from the user, result goes into AX

; --- THE PARITY CHECK ---
test ax, 1         ; Bitwise AND between AX and 1 (checks the lowest bit)
jz .is_even        ; If the lowest bit is 0 (Zero flag set), jump to .is_even

; If we didn't jump, it's odd
mov si, msg_odd
call print
jmp .end

.is_even:
mov si, msg_even
call print

.end:
hlt

; --- SUBROUTINES ---

; 1. Print string pointed to by SI
print:
    push ax
    mov ah, 0x0e
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    pop ax
    ret

; 2. Get integer (returns final number in AX)
get_int:
    push bx
    push cx
    push dx
    xor bx, bx         ; BX holds the running total
.g: 
    mov ah, 0
    int 0x16           ; Wait for key
    
    cmp al, 13         ; Is it 'Enter'?
    je .e
    
    ; Basic validation: Ignore keys outside '0'-'9'
    cmp al, '0'
    jl .g
    cmp al, '9'
    jg .g
    
    mov ah, 0x0e
    int 0x10           ; Echo character to screen
    
    sub al, '0'        ; Convert to integer
    xor ah, ah
    
    push ax
    mov ax, bx
    mov cx, 10
    mul cx             ; Multiply running total by 10
    mov bx, ax
    pop ax
    
    add bx, ax         ; Add new digit
    jmp .g
    
.e: 
    mov ax, bx         ; Move result to AX for return
    pop dx
    pop cx
    pop bx
    ret

; --- DATA ---
prompt:   db "Digite um numero: ", 0
msg_even: db 13, 10, "O numero e PAR.", 0
msg_odd:  db 13, 10, "O numero e IMPAR.", 0

times 510 - ($-$$) db 0
dw 0xaa55