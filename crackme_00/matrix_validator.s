; ===========================================================================
; Crackme: Matrix Transformation Validator
; ===========================================================================
; Mot de passe attendu: M4TR1XXTR4NSF0RM

section .data
    good_msg        db "Good Job!", 10
    good_msg_len    equ $ - good_msg
    bad_msg         db "Bad Password!", 10
    bad_msg_len     equ $ - bad_msg
    
    ; Matrice cible calculée pour "M4TR1XXTR4NSF0RM"
    target_matrix:
        db 0x7D, 0x91, 0x7D, 0x91
        db 0x86, 0x56, 0x86, 0x56
        db 0x67, 0xB3, 0x67, 0xB3
        db 0x92, 0x54, 0x92, 0x54
    
    ; Matrice de transformation
    transform_matrix db 1, 0, 1, 0
                     db 0, 1, 0, 1
                     db 1, 0, 1, 0
                     db 0, 1, 0, 1
    
    ; Clés XOR
    xor_keys        db 0x10, 0x20, 0x30, 0x40
                    db 0x50, 0x60, 0x70, 0x80
                    db 0x90, 0xA0, 0xB0, 0xC0
                    db 0xD0, 0xE0, 0xF0, 0x01

section .bss
    input_buffer    resb 64
    input_matrix    resb 16
    working_matrix  resb 16
    temp_matrix     resb 16

section .text
    global _start
    
_start:
    ; Lire l'entrée
    mov rax, 0                 
    mov rdi, 0                 
    mov rsi, input_buffer      
    mov rdx, 64                
    syscall
    
    ; Vérifier que la longueur est exactement 17 (16 + newline)
    cmp rax, 17                 
    jne validation_failed    ; Si différent, échec (trop court ou trop long)
    
    ; Convertir en matrice
    call convert_input_to_matrix
    
    ; Appliquer les transformations
    call transform_matrix_input
    
    ; Valider
    call validate_matrix
    
    cmp rax, 1
    je validation_success
    
validation_failed:
    mov rax, 1
    mov rdi, 1
    mov rsi, bad_msg            
    mov rdx, bad_msg_len
    syscall
    
    mov rax, 60
    mov rdi, 1
    syscall
    
validation_success:
    mov rax, 1
    mov rdi, 1
    mov rsi, good_msg
    mov rdx, good_msg_len
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall

convert_input_to_matrix:
    xor rcx, rcx               
    mov rsi, input_buffer
    mov rdi, input_matrix
    
.copy_loop:
    cmp rcx, 16
    je .done
    
    mov al, [rsi]               
    mov [rdi], al               
    inc rsi                     
    inc rdi                     
    inc rcx                     
    jmp .copy_loop
    
.done:
    mov rsi, input_matrix       
    mov rdi, working_matrix     
    mov rcx, 16                 
    rep movsb                  
    ret

transform_matrix_input:
    call apply_positional_xor
    call rotate_matrix
    call apply_matrix_multiply
    call apply_final_transform
    ret

apply_positional_xor:
    mov rsi, working_matrix     
    mov rdi, xor_keys          
    mov rcx, 16                
    
.xor_loop:
    mov al, [rsi]
    xor al, [rdi]
    mov [rsi], al
    
    inc rsi
    inc rdi
    dec rcx
    jnz .xor_loop
    
    ret

rotate_matrix:
    mov rdi, temp_matrix
    xor rax, rax
    mov rcx, 16
    rep stosb
    
    xor rcx, rcx
    
.rotate_loop:
    mov rax, rcx
    mov rbx, 4
    xor rdx, rdx
    div rbx
    
    mov r8, 3
    sub r8, rax
    mov r9, rdx
    
    mov rax, rcx                
    
    mov rbx, r9                 
    imul rbx, 4                 
    add rbx, r8                 

    mov dl, [working_matrix + rax]
    mov [temp_matrix + rbx], dl
    
    inc rcx                     
    cmp rcx, 16                 
    jl .rotate_loop             
    
    mov rsi, temp_matrix        
    mov rdi, working_matrix     
    mov rcx, 16                 
    rep movsb                   
    
    ret

apply_matrix_multiply:
    mov rdi, temp_matrix
    xor rax, rax
    mov rcx, 16
    rep stosb
    
    xor r10, r10                
    
.mult_row_loop:
    xor r11, r11                
    
.mult_col_loop:
    xor r12, r12                
    xor r15, r15                
    
.dot_product_loop:
    mov rax, r10
    imul rax, 4
    add rax, r15
    
    cmp rax, 16
    jge .skip_multiply          
    
    movzx rax, byte [working_matrix + rax]    
    
    mov rbx, r15
    imul rbx, 4
    add rbx, r11
    
    cmp rbx, 16
    jge .skip_multiply          
    
    movzx rbx, byte [transform_matrix + rbx]  
    
    imul rax, rbx               
    add r12, rax                
    
.skip_multiply:
    inc r15                     
    cmp r15, 4                  
    jl .dot_product_loop
    
    mov rax, r10
    imul rax, 4
    add rax, r11
    
    cmp rax, 16
    jge .skip_store             
    
    shr r12, 1                  
    mov [temp_matrix + rax], r12b
    
.skip_store:
    inc r11                     
    cmp r11, 4                  
    jl .mult_col_loop
    
    inc r10                     
    cmp r10, 4                  
    jl .mult_row_loop
    
    mov rsi, temp_matrix        
    mov rdi, working_matrix     
    mov rcx, 16                 
    rep movsb                   
    
    ret

apply_final_transform:
    mov rsi, working_matrix
    mov rcx, 16
    
.final_loop:
    mov al, [rsi]
    add al, 0x02                
    mov [rsi], al
    
    inc rsi
    dec rcx
    jnz .final_loop
    
    ret

validate_matrix:
    mov rsi, working_matrix     
    mov rdi, target_matrix      
    mov rcx, 16                 
    
.compare_loop:
    mov al, [rsi]               
    cmp al, [rdi]               
    jne .validation_failed      
    
    inc rsi                     
    inc rdi                     
    dec rcx                     
    jnz .compare_loop           
    
    mov rax, 1                  
    ret
    
.validation_failed:
    xor rax, rax                
    ret