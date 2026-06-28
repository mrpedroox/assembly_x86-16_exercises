org 0x7c00
bits 16

; --- SETUP ---
; It is good practice to initialize segment registers and the stack pointer
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00  ; Stack grows downwards from our bootloader
cli

; --- INPUT ---
; Get first number
mov si, prompt1
call print
call geti
mov [num1], bx  ; Save to memory

; Get second number
mov si, prompt2
call print
call geti
mov [num2], bx  ; Save to memory

; --- ADDITION ---
mov si, res_add
call print
mov ax, [num1]
add ax, [num2]
call puti

; --- SUBTRACTION ---
mov si, res_sub
call print
mov ax, [num1]
cmp ax, [num2]
jge .positive_sub
; If num1 < num2, print a '-' and swap the subtraction order
push ax
mov al, '-'
mov ah, 0x0e
int 0x10
pop ax
mov ax, [num2]
sub ax, [num1]
jmp .print_sub
.positive_sub:
sub ax, [num2]
.print_sub:
call puti

; --- MULTIPLICATION ---
mov si, res_mul
call print
mov ax, [num1]
mul word [num2]
; Note: mul produces a 32-bit result in DX:AX. 
; To keep puti simple, we only print AX (assumes result <= 65535)
call puti

; --- DIVISION ---
mov si, res_div
call print
mov cx, [num2]
or cx, cx
jz .div_zero       ; Avoid division by zero crash!

mov ax, [num1]
xor dx, dx         ; Clear DX (division uses DX:AX / CX)
div cx             ; AX = quotient, DX = remainder
call puti          ; Print quotient

mov si, res_rem
call print
mov ax, dx         ; Move remainder to AX to print it
call puti
jmp .end

.div_zero:
mov si, err_div
call print

.end:
hlt

; --- SUBROUTINES ---
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

geti:
    push ax
    push cx
    push dx
    xor bx, bx
.g: mov ah, 0
    int 0x16
    cmp al, 13
    je .e
    mov ah, 0x0e
    int 0x10
    push ax
    mov ax, bx
    mov cx, 10
    mul cx
    mov bx, ax
    pop ax
    sub al, '0'
    xor ah, ah
    add bx, ax
    jmp .g
.e: mov ah, 0x0e
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    pop dx
    pop cx
    pop ax
    ret

puti:
    push ax
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
.pd:
    xor dx, dx
    div bx
    push dx
    inc cx
    or ax, ax
    jnz .pd
.pp:
    pop dx
    add dl, '0'
    mov ah, 0x0e
    mov al, dl
    int 0x10
    dec cx
    jnz .pp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; --- DATA SECTION ---
prompt1: db "First number: ", 0
prompt2: db "Second number: ", 0
res_add: db 13, 10, "Sum: ", 0
res_sub: db 13, 10, "Sub: ", 0
res_mul: db 13, 10, "Mul: ", 0
res_div: db 13, 10, "Div: ", 0
res_rem: db " Rem: ", 0
err_div: db "Error: Div by 0!", 0

; Variables to store user input
num1: dw 0
num2: dw 0

times 510 - ($-$$) db 0
dw 0xaa55
