; ===========================================================================
; Crackme: Matrix Transformation Validator (Version Finale)
; ===========================================================================
; Description: 
; Ce crackme traite un mot de passe de 16 caractères comme une matrice 4x4
; et lui applique des transformations pour le valider.
; Difficulté: Moyenne
; Mécanisme de protection: Transformations matricielles

section .data
    prompt          db "Enter password: ", 0
    prompt_len      equ $ - prompt - 1
    good_msg        db "Good Job!", 10, 0
    good_msg_len    equ $ - good_msg - 1
    bad_msg         db "Bad Password!", 10, 0
    bad_msg_len     equ $ - bad_msg - 1
    
    ; Le flag correct: M4TR1X_TR4NSF0RM (exactement 16 caractères)
    correct_pwd     db "M4TR1X_TR4NSF0RM", 0
    
    ; Matrice cible après transformations
    target_matrix   db 0x0F, 0x53, 0x57, 0x09
                    db 0x54, 0x07, 0x58, 0x55
                    db 0x5B, 0x5D, 0x03, 0x5A
                    db 0x02, 0x51, 0x08, 0x56
                    
    ; Matrice de transformation pour les opérations
    transform_matrix db 1, 0, 1, 0
                     db 0, 1, 0, 1
                     db 1, 0, 1, 0
                     db 0, 1, 0, 1
                    
    ; Clés XOR pour le chiffrement positionnel
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
    mov rax, 1                  
    mov rdi, 1
    mov rsi, prompt             
    mov rdx, prompt_len         
    syscall
    
    mov rax, 0                 
    mov rdi, 0                 
    mov rsi, input_buffer      
    mov rdx, 64                
    syscall
    
    
    cmp rax, 16                 
    jl validation_failed
    
    
    call convert_input_to_matrix
    
    
    mov rsi, input_matrix       
    mov rdi, correct_pwd        
    mov rcx, 16                 
    repe cmpsb                  
    jne apply_transformations  
    jmp validation_success     
    
apply_transformations:
    call transform_matrix_input
    
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

; ===========================================================================
; Fonctions de manipulation matricielle
; ===========================================================================

convert_input_to_matrix:
    xor rcx, rcx               
    mov rsi, input_buffer
    mov rdi, input_matrix
    
.copy_loop:
    cmp rcx, 16
    je .done
    
    mov al, [rsi]               
    inc rsi                     
    
    cmp al, 10                  
    je .copy_loop               
    
    mov [rdi], al               
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
    
    inc rcx                     ; Position suivante
    cmp rcx, 16                 ; Vérifier si terminé
    jl .rotate_loop             ; Continuer si pas terminé
    
    ; Copier le résultat dans la matrice de travail
    mov rsi, temp_matrix        ; La source est la matrice temporaire
    mov rdi, working_matrix     ; La destination est la matrice de travail
    mov rcx, 16                 ; 16 octets à copier
    rep movsb                   ; Copier les octets
    
    ret

; Appliquer la multiplication matricielle avec la matrice de transformation
apply_matrix_multiply:
    ; Effacer la matrice temporaire pour le résultat de multiplication
    mov rdi, temp_matrix
    xor rax, rax
    mov rcx, 16
    rep stosb
    
    ; Pour chaque élément dans la matrice résultante
    xor r10, r10                ; r10 = ligne du résultat
    
.mult_row_loop:
    xor r11, r11                ; r11 = colonne du résultat
    
.mult_col_loop:
    xor r12, r12                ; r12 = accumulateur pour le produit scalaire
    
    ; Calculer le produit scalaire de la ligne r10 avec la colonne r11
    xor r15, r15                ; r15 = index pour le produit scalaire
    
.dot_product_loop:
    ; working_matrix[r10*4 + r15] * transform_matrix[r15*4 + r11]
    mov rax, r10
    imul rax, 4
    add rax, r15
    
    ; Vérifier les limites
    cmp rax, 16
    jge .skip_multiply          ; Ignorer si hors limites
    
    movzx rax, byte [working_matrix + rax]    ; Obtenir l'élément de la matrice de travail
    
    mov rbx, r15
    imul rbx, 4
    add rbx, r11
    
    ; Vérifier les limites
    cmp rbx, 16
    jge .skip_multiply          ; Ignorer si hors limites
    
    movzx rbx, byte [transform_matrix + rbx]  ; Obtenir l'élément de la matrice de transformation
    
    imul rax, rbx               ; Multiplier les éléments
    add r12, rax                ; Ajouter à l'accumulateur
    
.skip_multiply:
    inc r15                     ; Élément suivant dans le produit scalaire
    cmp r15, 4                  ; Vérifier si terminé avec ce produit scalaire
    jl .dot_product_loop
    
    ; Stocker le résultat dans temp_matrix[r10*4 + r11]
    mov rax, r10
    imul rax, 4
    add rax, r11
    
    ; Vérifier les limites
    cmp rax, 16
    jge .skip_store             ; Ignorer si hors limites
    
    ; Mettre à l'échelle le résultat pour éviter les dépassements
    shr r12, 1                  ; Diviser par 2 pour diminuer l'échelle
    mov [temp_matrix + rax], r12b
    
.skip_store:
    inc r11                     ; Colonne suivante
    cmp r11, 4                  ; Vérifier si terminé avec cette ligne
    jl .mult_col_loop
    
    inc r10                     ; Ligne suivante
    cmp r10, 4                  ; Vérifier si terminé avec toutes les lignes
    jl .mult_row_loop
    
    ; Copier le résultat dans la matrice de travail
    mov rsi, temp_matrix        ; La source est la matrice temporaire
    mov rdi, working_matrix     ; La destination est la matrice de travail
    mov rcx, 16                 ; 16 octets à copier
    rep movsb                   ; Copier les octets
    
    ret

; Appliquer la transformation finale pour préparer la validation
apply_final_transform:
    ; Ajouter une constante à chaque élément
    mov rsi, working_matrix
    mov rcx, 16
    
.final_loop:
    mov al, [rsi]
    add al, 0x02                ; Ajouter une valeur constante
    mov [rsi], al
    
    inc rsi
    dec rcx
    jnz .final_loop
    
    ret

; Valider la matrice transformée par rapport à la cible
validate_matrix:
    mov rsi, working_matrix     ; Source (matrice de travail)
    mov rdi, target_matrix      ; Cible à comparer
    mov rcx, 16                 ; 16 positions à vérifier
    
.compare_loop:
    mov al, [rsi]               ; Obtenir la valeur transformée
    cmp al, [rdi]               ; Comparer avec la cible
    jne .validation_failed      ; Si différent, la validation échoue
    
    inc rsi                     ; Valeur transformée suivante
    inc rdi                     ; Valeur cible suivante
    dec rcx                     ; Décrémenter le compteur
    jnz .compare_loop           ; Continuer jusqu'à vérification complète
    
    ; Si nous arrivons ici, toutes les valeurs correspondent
    mov rax, 1                  ; Retourner succès (1)
    ret
    
.validation_failed:
    xor rax, rax                ; Retourner échec (0)
    ret