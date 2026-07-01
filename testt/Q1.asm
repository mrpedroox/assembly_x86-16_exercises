org 0x7c00
bits 16

; --- SETUP ---
xor ax, ax         ; Zero out AX
mov ds, ax         ; Set Data Segment to 0
cli                ; Clear interrupts

; --- MAIN LOOP ---
.read_key:
    ; 1. Wait for a keystroke silently
    mov ah, 0x00   ; BIOS function: Read keyboard input
    int 0x16       ; AL will contain the ASCII character of the pressed key
    
    ; 2. Check for the 'Enter' key to halt the program
    cmp al, 13     ; ASCII 13 is Carriage Return (Enter)
    je .end        ; If 'Enter' is pressed, jump to the end
    
    ; 3. Apply the Encryption Rule
    sub al, 3      ; Subtract 3 from the ASCII value in AL
    
    ; 4. Print the Encrypted Character
    mov ah, 0x0e   ; BIOS function: Teletype output
    int 0x10       ; Print the character currently in AL
    
    ; 5. Repeat
    jmp .read_key  ; Jump back to wait for the next key

; --- END ---
.end:
    hlt            ; Halt the processor

times 510 - ($-$$) db 0  ; Pad the rest of the boot sector
dw 0xaa55                ; Boot signature