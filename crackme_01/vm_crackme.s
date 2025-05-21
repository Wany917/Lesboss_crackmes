section .data
    success_msg db "Good Job!", 10
    success_msg_len equ $ - success_msg
    fail_msg db "Bad Password!", 10  
    fail_msg_len equ $ - fail_msg
    
    ; Définition des opcodes
    OP_LOAD     equ 0x01
    OP_COMPARE  equ 0x02
    OP_JUMP     equ 0x03
    OP_XOR      equ 0x04
    OP_ADD      equ 0x05
    OP_HALT     equ 0xFF
    
    ; Bytecode qui vérifie vraiment le mot de passe
    bytecode:
        db OP_LOAD, 1, 0       ; r1 = 0 (compteur de succès)
        
        ; Vérifier la longueur (16 caractères + newline = 17)
        db OP_COMPARE, 3, 17   ; comparer r3 (longueur input) avec 17
        db OP_JUMP, 200        ; si différent, échec
        
        ; Vérifier chaque caractère
        db OP_LOAD, 0, 0       ; r0 = input[0]
        db OP_COMPARE, 0, 'V'  ; compare avec 'V'
        db OP_JUMP, 200        
        
        db OP_LOAD, 0, 1       
        db OP_COMPARE, 0, '1'  
        db OP_JUMP, 200        
        
        db OP_LOAD, 0, 2       
        db OP_COMPARE, 0, 'R'  
        db OP_JUMP, 200        
        
        db OP_LOAD, 0, 3
        db OP_COMPARE, 0, 'T'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 4
        db OP_COMPARE, 0, 'U'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 5
        db OP_COMPARE, 0, '4'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 6
        db OP_COMPARE, 0, 'L'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 7
        db OP_COMPARE, 0, 'L'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 8
        db OP_COMPARE, 0, 'M'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 9
        db OP_COMPARE, 0, '4'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 10
        db OP_COMPARE, 0, 'C'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 11
        db OP_COMPARE, 0, 'H'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 12
        db OP_COMPARE, 0, '1'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 13
        db OP_COMPARE, 0, 'N'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 14
        db OP_COMPARE, 0, '3'
        db OP_JUMP, 200
        
        db OP_LOAD, 0, 15
        db OP_COMPARE, 0, 'E'  ; Le caractère 'E' à la place de '!'
        db OP_JUMP, 200
        
        ; Vérifier que le 17ème caractère est un newline
        db OP_LOAD, 0, 16
        db OP_COMPARE, 0, 10   ; 10 = '\n' (newline)
        db OP_JUMP, 200
        
        ; Succès
        db OP_LOAD, 1, 1       ; r1 = 1 (succès)
        db OP_HALT
        
        ; Position 200 : échec  
        times 200-($-bytecode) db 0x00
        db OP_LOAD, 1, 0       ; r1 = 0 (échec)
        db OP_HALT

section .bss
    input resb 128
    registers resq 16

section .text
    global _start
    
_start:
    ; Lire l'input
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 128
    syscall
    
    ; Sauvegarder la longueur
    mov r15, rax
    
    ; Initialiser les registres
    xor rcx, rcx
init_regs:
    mov qword [registers + rcx*8], 0
    inc rcx
    cmp rcx, 16
    jl init_regs
    
    ; Sauvegarder la longueur dans r3
    mov qword [registers + 3*8], r15
    
    ; Pointeur sur le bytecode
    mov r12, bytecode
    mov qword [registers + 15*8], 0  ; flag de comparaison
    
vm_loop:
    movzx rax, byte [r12]    ; lire l'instruction
    
    cmp al, OP_HALT
    je vm_halt
    
    cmp al, OP_LOAD
    je inst_load
    
    cmp al, OP_COMPARE
    je inst_compare
    
    cmp al, OP_JUMP
    je inst_jump
    
    cmp al, OP_XOR
    je inst_xor
    
    cmp al, OP_ADD
    je inst_add
    
    jmp vm_halt              ; instruction invalide

inst_load:
    movzx rbx, byte [r12+1]  ; registre destination
    movzx rcx, byte [r12+2]  ; valeur ou index
    
    cmp rbx, 0               ; si c'est r0
    jne load_value
    
    ; Charger depuis input[rcx]
    cmp rcx, r15             ; vérifier les bounds
    jae load_zero
    movzx rdx, byte [input + rcx]
    mov [registers + rbx*8], rdx
    jmp load_done
    
load_zero:
    mov qword [registers + rbx*8], 0
    jmp load_done
    
load_value:
    mov [registers + rbx*8], rcx
    
load_done:
    add r12, 3
    jmp vm_loop

inst_compare:
    movzx rbx, byte [r12+1]  ; registre
    movzx rcx, byte [r12+2]  ; valeur à comparer
    
    mov rdx, [registers + rbx*8]
    cmp rdx, rcx
    
    je compare_equal
    mov qword [registers + 15*8], 1  ; différent
    jmp compare_done
    
compare_equal:
    mov qword [registers + 15*8], 0  ; égal
    
compare_done:
    add r12, 3
    jmp vm_loop

inst_jump:
    movzx rbx, byte [r12+1]  ; offset
    
    ; Vérifier si on doit sauter (flag != 0)
    cmp qword [registers + 15*8], 0
    je jump_skip
    
    ; Faire le jump
    mov r12, bytecode
    add r12, rbx
    jmp vm_loop
    
jump_skip:
    add r12, 2
    jmp vm_loop

inst_xor:
    movzx rbx, byte [r12+1]  ; registre destination
    movzx rcx, byte [r12+2]  ; valeur à XOR
    
    mov rdx, [registers + rbx*8]
    xor rdx, rcx
    mov [registers + rbx*8], rdx
    
    add r12, 3
    jmp vm_loop

inst_add:
    movzx rbx, byte [r12+1]  ; registre
    movzx rcx, byte [r12+2]  ; valeur à ajouter
    
    add [registers + rbx*8], rcx
    add r12, 3
    jmp vm_loop

vm_halt:
    ; Vérifier le résultat dans r1
    mov rax, [registers + 1*8]
    test rax, rax
    jz fail
    
    ; Succès
    mov rax, 1
    mov rdi, 1
    mov rsi, success_msg
    mov rdx, success_msg_len
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall
    
fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, fail_msg
    mov rdx, fail_msg_len
    syscall
    
    mov rax, 60
    mov rdi, 1
    syscall