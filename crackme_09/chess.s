section .data
    welcome_msg     db "Bienvenue dans le Crackme 'Chess Cipher' !", 0xA, 0
    input_msg       db "Entrez le flag (16 caractères exactement) : ", 0
    good_msg        db "Good Job!", 0xA, 0
    bad_msg         db "Bad Password!", 0xA, 0

    ; Tableau de transformation représentant les mouvements d'échecs
    chess_moves     db 71, 32, 59, 18, 97, 45, 28, 83, 62, 91, 14, 36, 50, 77, 23, 68
    chess_values    db 31, 12, 49, 87, 22, 61, 94, 37, 73, 19, 54, 82, 41, 25, 68, 93
    
    ; Le flag attendu - masqué dans une chaîne plus longue pour obfuscation
    flag_data       db "X4Hz8Ch3ss1sCrypt1c4LpQ7Yt2R", 0
    flag_offset     equ 5  ; Position du vrai flag dans la chaîne

section .bss
    input_buffer    resb 64
    processed       resb 16
    expected        resb 16

section .text
    global _start

_start:
    ; on extrait le flag attendu et on le traite avec notre  algorithmee
    call prepare_expected
    
    ; Afficher le message de bienvenue
    
    mov rdi, welcome_msg
    call print_string
    
    ; Demander l'entrée
    
    mov rdi, input_msg
    call print_string
    
    ;   Lire l'entrée
    
    mov rdi, input_buffer
    mov rsi, 64
    call read_input
    
    ; Vérifier la longueur (doit être 16)
    
     mov rdi, input_buffer
    call string_length
    cmp rax, 16
    jne invalid_flag
    
    ; Appliquer le chiffrement "Chess Cipher" à l'entrée utilisateur
    
    mov rdi, input_buffer
    mov rsi, processed
    call chess_cipher
    
    ; Compare le résultat avec la valeur attendue
    
    mov rdi, processed
    mov rsi, expected
    mov rdx, 16
    call memcmp
    
    test rax, rax
    jz valid_flag
    

invalid_flag:
    
    mov rdi, bad_msg
    call print_string
    mov rdi, 1
    jmp exit
    


valid_flag:

    mov rdi, good_msg
    call print_string
    mov rdi, 0
    
exit:

    ; Appell système exit
    mov rax, 60
    syscall

; extraire le flag attendu et le transformer
prepare_expected:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; Copier le flag de flag_data+offset vers un buffer ttemporaire

    mov rcx, 16  ; longueur du flag (16 caractères)
    lea rsi, [flag_data+flag_offset]  ; source (flag caché dans une chaîne plus longue)
    mov rdi, input_buffer  ; destination temporaire
    
    rep movsb  ; copier rcx octets de rsi vers rdi
    
    ; applique l'algorithme au flag correct

    mov rdi, input_buffer  ; buffer contenant le flag
    mov rsi, expected      ; destination pour le résultat
    call chess_cipher
    
    mov rsp, rbp
    pop rbp
    ret

; Fonction qui applique notre "Chess Cipher"

chess_cipher:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi        ; Input buffer
    mov r13, rsi        ; Output buffer
    
    xor rbx, rbx        ; Index dans le buffer (0-15)
    
cipher_loop:

    cmp rbx, 16
    jge cipher_done
    
    ; ca charge le caractère courant
    movzx rax, byte [r12+rbx]
    
    ; Phase 1: XOR avec la vvaleur de chess_moves
    movzx rcx, byte [chess_moves+rbx]
    xor al, cl
    
    ; Phase 2: Rotation à gauche de 3 bits
    rol al, 3
    
    ; Phase 3: Addition avec valeur de chess_values
    movzx rcx, byte [chess_values+rbx]
    add al, cl
    
    ; Phase 4: XOR avec valeur calculée (2*index+5)
    mov rdx, rbx
    shl rdx, 1
    add rdx, 5
    xor al, dl
    
    ; Phase 5: NOT (inversion des bits)
    not al
    
    ; Phase 6: Rotation à droite de 2 bits
    ror al, 2
    
    ; Stocker le résultat
    mov [r13+rbx], al
    
    inc rbx
    jmp cipher_loop
    
cipher_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Fonction pour imprimer une chaîne (null-terminated)
print_string:
    push rbp
    mov rbp, rsp
    
    ; Calculer la longueur
    push rdi
    call string_length
    mov rdx, rax        ; rdx = longueur
    pop rsi             ; rsi = chaîne
    
    ; Appel système write
    mov rax, 1          ; syscall pour write
    mov rdi, 1          ; stdout
    syscall
    
    pop rbp
    ret

; Fonction pour lire l'entrée
read_input:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    
    mov r12, rdi        ; buffer
    mov r13, rsi        ; taille max
    
    ; Appel système read
    mov rax, 0          ; syscall pour read
    mov rdi, 0          ; stdin
    mov rsi, r12        ; buffer
    mov rdx, r13        ; taille max
    syscall
    
    ; Vérifier si read a réussi
    cmp rax, 0
    jl read_error
    
    ; Supprimer le caractère newline s'il existe
    cmp rax, 0
    je read_error
    
    ; Trouver la position du newline et le remplacer par un null
    mov rcx, 0
read_newline_loop:
    cmp rcx, rax
    jge read_no_newline
    
    cmp byte [r12+rcx], 10  ; 10 = '\n'
    je read_found_newline
    
    inc rcx
    jmp read_newline_loop
    
read_found_newline:
    mov byte [r12+rcx], 0
    jmp read_done
    
read_no_newline:
    ; Aucun newline trouvé, mais s'assurer que la chaîne est terminée par un null
    mov byte [r12+rax], 0
    
read_done:
read_error:
    pop r13
    pop r12
    pop rbp
    ret

; Fonction pour calculer la longueur d'une chaîne
string_length:
    push rbp
    mov rbp, rsp
    
    mov rax, 0
length_loop:
    cmp byte [rdi+rax], 0
    je length_done
    inc rax
    jmp length_loop
length_done:
    pop rbp
    ret

; Fonction pour comparer deux blocs de mémoire
memcmp:
    push rbp
    mov rbp, rsp
    push rbx
    
    xor rcx, rcx
    xor rax, rax        ; rax = 0 cela veut dire que les blocs sont identiques
    
memcmp_loop:
    cmp rcx, rdx
    je memcmp_done
    
    ; Comparer les octets actuels
    movzx r8, byte [rdi+rcx]
    movzx r9, byte [rsi+rcx]
    
    cmp r8, r9
    je memcmp_continue
    
    ; Si différent, signaler et terminer
    mov rax, 1
    jmp memcmp_done
    
memcmp_continue:
    inc rcx
    jmp memcmp_loop
    
memcmp_done:
    pop rbx
    pop rbp
    ret