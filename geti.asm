org 0x7c00
bits 16

; --- SETUP ---
xor ax, ax         ; Zero out AX
mov ds, ax         ; Set Data Segment (DS) to 0
cli                ; Clear interrupts (safety measure)

; --- MAIN PROGRAM ---
mov si, prompt     ; Point SI to the prompt string
call print         ; Print the prompt

call get_int       ; Read integer from keyboard, result stored in AX

push ax            ; Save the inputted number on the stack
mov si, reply      ; Point SI to the reply string
call print         ; Print the reply string
pop ax             ; Restore the inputted number to AX

call print_int     ; Print the integer in AX

hlt                ; Halt the processor

; --- SUBROUTINES ---

; 1. Print a string pointed to by SI
print:
    mov ah, 0x0e   ; BIOS teletype function
.loop:
    lodsb          ; Load byte at DS:SI into AL, increment SI
    or al, al      ; Check if AL is 0 (end of string)
    jz .done       ; If zero, jump to .done
    int 0x10       ; Print the character in AL
    jmp .loop      ; Repeat for next character
.done:
    ret

; 2. Read an integer from keyboard and store in AX
get_int:
    xor bx, bx     ; BX will hold our running total. Start at 0.
.get_char:
    mov ah, 0      ; BIOS wait for keypress function
    int 0x16       ; Call BIOS keyboard interrupt, character goes to AL
    
    cmp al, 13     ; Did the user press Enter (ASCII 13)?
    je .end_input  ; If yes, we are done reading
    
    mov ah, 0x0e   ; BIOS teletype function (to echo the key)
    int 0x10       ; Print the typed key to the screen
    
    sub al, '0'    ; Convert ASCII character to numeric value (e.g., '7' -> 7)
    xor ah, ah     ; Clear AH so AX just holds our new single digit
    
    push ax        ; Save the new digit temporarily
    mov ax, bx     ; Move our running total into AX for multiplication
    mov cx, 10     
    mul cx         ; AX = AX * 10
    mov bx, ax     ; Move the new total back to BX
    pop ax         ; Retrieve our new digit
    
    add bx, ax     ; Add the new digit to the running total
    jmp .get_char  ; Loop back to get the next key
.end_input:
    mov ax, bx     ; Move the final total from BX into AX to return it
    ret

; 3. Print the integer stored in AX
print_int:
    mov cx, 0      ; CX will count how many digits we push to the stack
    mov bx, 10     ; We will divide by 10 to extract digits
.extract_digits:
    xor dx, dx     ; Clear DX before division (div uses DX:AX)
    div bx         ; Divide AX by 10. Quotient in AX, Remainder in DX
    push dx        ; Push the remainder (the last digit) onto the stack
    inc cx         ; Increase our digit counter
    or ax, ax      ; Is the quotient 0? (Are we out of digits?)
    jnz .extract_digits ; If not, keep dividing
.print_digits:
    pop dx         ; Pop the most significant digit off the stack
    add dl, '0'    ; Convert the numeric value back to ASCII (e.g., 7 -> '7')
    mov ah, 0x0e   ; BIOS teletype function
    mov al, dl     ; Move the ASCII character to AL for printing
    int 0x10       ; Print the character
    dec cx         ; Decrease our digit counter
    jnz .print_digits ; If we still have digits left, keep printing
    ret

; --- DATA ---
prompt: db "Enter a number: ", 0
reply:  db 13, 10, "You entered: ", 0  ; 13, 10 are carriage return and line feed

times 510 - ($-$$) db 0  ; Pad the rest of the boot sector with zeros
dw 0xaa55                ; Boot signature
