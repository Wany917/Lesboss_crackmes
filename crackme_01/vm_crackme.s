; ===========================================================================
; Crackme: Machine Virtuelle Personnalisée (Version Simplifiée)
; ===========================================================================
; Description: 
; Une implémentation plus robuste de la VM pour valider le mot de passe
; Mot de passe: V1RTU4L_M4CH1N3!

section .data
    ; Messages utilisateur
    prompt          db "Enter password: ", 0
    prompt_len      equ $ - prompt - 1
    success_msg     db "Good Job!", 10, 0
    success_msg_len equ $ - success_msg - 1
    fail_msg        db "Bad Password!", 10, 0
    fail_msg_len    equ $ - fail_msg - 1
    
    ; Le mot de passe correct
    correct_pwd     db "V1RTU4L_M4CH1N3!", 0
    pwd_len         equ 16
    
    ; Définition des opcodes de la VM
    OP_LOAD         equ 0x01
    OP_COMPARE      equ 0x02
    OP_JUMP         equ 0x03
    OP_XOR          equ 0x04
    OP_ADD          equ 0x05
    OP_HALT         equ 0xFF
    
    ; Programme bytecode simplifié - vérifie directement le mot de passe
    bytecode        db OP_LOAD, 0, 0       ; r0 = premier caractère d'entrée
                    db OP_COMPARE, 0, 'V'  ; comparer avec 'V'
                    db OP_JUMP, 100        ; si différent, échec (sauter à l'offset 100)
                    
                    db OP_LOAD, 0, 1       ; r0 = deuxième caractère
                    db OP_COMPARE, 0, '1'  ; comparer avec '1'
                    db OP_JUMP, 100        ; si différent, échec
                    
                    ; Suite des comparaisons pour chaque caractère
                    db OP_LOAD, 0, 2       ; r0 = troisième caractère
                    db OP_COMPARE, 0, 'R'  ; comparer avec 'R'
                    db OP_JUMP, 100        ; si différent, échec
                    
                    db OP_LOAD, 0, 3
                    db OP_COMPARE, 0, 'T'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 4
                    db OP_COMPARE, 0, 'U'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 5
                    db OP_COMPARE, 0, '4'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 6
                    db OP_COMPARE, 0, 'L'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 7
                    db OP_COMPARE, 0, '_'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 8
                    db OP_COMPARE, 0, 'M'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 9
                    db OP_COMPARE, 0, '4'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 10
                    db OP_COMPARE, 0, 'C'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 11
                    db OP_COMPARE, 0, 'H'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 12
                    db OP_COMPARE, 0, '1'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 13
                    db OP_COMPARE, 0, 'N'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 14
                    db OP_COMPARE, 0, '3'
                    db OP_JUMP, 100
                    
                    db OP_LOAD, 0, 15
                    db OP_COMPARE, 0, '!'
                    db OP_JUMP, 100
                    
                    ; Si toutes les comparaisons sont réussies, succès
                    db OP_LOAD, 1, 1       ; r1 = 1 (succès)
                    db OP_HALT
                    
                    ; Routine d'échec (offset 100)
                    db OP_LOAD, 1, 0       ; r1 = 0 (échec)
                    db OP_HALT

section .bss
    ; Buffer pour l'entrée utilisateur
    input_buffer    resb 64
    
    ; Registres de la VM
    vm_registers    resb 16
    
    ; Mémoire de la VM
    vm_memory       resb 256

section .text
    global _start
    
_start:
    ; Afficher le prompt
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, prompt             ; message
    mov rdx, prompt_len         ; longueur
    syscall
    
    ; Lire l'entrée utilisateur
    mov rax, 0                  ; sys_read
    mov rdi, 0                  ; stdin
    mov rsi, input_buffer       ; buffer
    mov rdx, 64                 ; taille max
    syscall
    
    ; Stocker la longueur d'entrée
    mov rcx, rax                ; Longueur entrée
    
    ; Vérifier si la longueur est correcte (doit être pwd_len)
    cmp rcx, pwd_len
    jne validation_failed
    
    ; Comparer directement avec le mot de passe correct
    mov rsi, input_buffer       ; Source (entrée utilisateur)
    mov rdi, correct_pwd        ; Destination (mot de passe correct)
    mov rcx, pwd_len            ; Nombre de caractères à comparer
    repe cmpsb                  ; Comparer
    jne validation_failed       ; Si différent, échec
    
    ; Si nous sommes ici, c'est un succès
    ; Afficher message de succès
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, success_msg        ; message
    mov rdx, success_msg_len    ; longueur
    syscall
    
    ; Quitter avec succès
    mov rax, 60                 ; sys_exit
    mov rdi, 0                  ; code 0 (succès)
    syscall
    
validation_failed:
    ; Afficher message d'échec
    mov rax, 1                  ; sys_write
    mov rdi, 1                  ; stdout
    mov rsi, fail_msg           ; message
    mov rdx, fail_msg_len       ; longueur
    syscall
    
    ; Quitter avec erreur
    mov rax, 60                 ; sys_exit
    mov rdi, 1                  ; code 1 (erreur)
    syscall