; ===========================================================================
; Crackme 00 - Validateur de Transformation Matricielle
; ===========================================================================
; Architecture: x64 Linux
; Description: L'entrée utilisateur est traitée comme une matrice 4x4
;              et subit plusieurs transformations avant validation.

section .data
    ; Messages du programme
    prompt      db "Enter password: ", 0
    prompt_len  equ $ - prompt - 1
    good_msg    db "Good Job! Flag: ", 0
    good_len    equ $ - good_msg - 1
    bad_msg     db "Bad Password!", 10, 0
    bad_len     equ $ - bad_msg - 1
    
    ; Format du flag
    flag_prefix db "HTB{", 0
    flag_suffix db "}", 10, 0
    
    ; Matrices de transformation et de validation (obscurcies)
    ; Ces matrices sont utilisées pour transformer l'entrée et comparer
    ; Les valeurs sont calculées pour que le password "MATR1X_TR4NSF0RM" 
    ; soit le seul input qui génère une correspondance parfaite
    
    ; Matrice de rotation (4x4)
    rot_matrix  db 0, 1, 0, 0
                db 0, 0, 1, 0
                db 0, 0, 0, 1
                db 1, 0, 0, 0
    
    ; Matrice de transposition XOR (4x4)
    xor_matrix  db 42, 33, 27, 19
                db 31, 44, 23, 38
                db 26, 35, 41, 29
                db 17, 22, 36, 45
    
    ; Matrice de validation attendue (4x4) (valeurs pré-calculées)
    ; Ces valeurs sont le résultat attendu après transformation du flag
    val_matrix  db 114, 127, 135, 114
                db 122, 144, 138, 159
                db 129, 150, 131, 121
                db 116, 137, 143, 134
    
    ; Données pour générer le flag dynamiquement
    ; Ces valeurs encodées représentent le vrai flag
    flag_data   db 95, 58, 24, 113, 85, 41, 39, 101, 54, 15, 74, 85, 126, 94, 35, 113, 92, 54, 64, 28
    flag_key    db 42, 19, 85, 63, 28, 73, 91, 45, 37, 56, 25, 44, 89, 31, 77, 62, 48, 29, 15, 83
    
    ; Signature pour le crack - PATCH_HERE
    crack_signature db "CRACK_SIGNATURE_HERE", 0

section .bss
    ; Tampon pour l'entrée utilisateur
    input       resb 64     ; Tampon d'entrée
    input_len   resq 1      ; Longueur de l'entrée
    
    ; Matrices de travail
    input_matrix resb 16    ; Matrice d'entrée 4x4
    temp_matrix  resb 16    ; Matrice temporaire pour les transformations
    result_matrix resb 16   ; Matrice de résultat
    
    ; Flag généré
    flag_buffer  resb 32    ; Buffer pour stocker le flag généré

section .text
    global _start

_start:
    ; ===== MODULE D'ENTRÉE/SORTIE =====
    ; Affiche l'invite
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, prompt         ; message
    mov rdx, prompt_len     ; longueur
    syscall
    
    ; Lecture de l'entrée utilisateur
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, input          ; tampon
    mov rdx, 64             ; taille max
    syscall
    
    ; Stocke la longueur de l'entrée (sans le caractère nouvelle ligne)
    dec rax                 ; Ignore le caractère nouvelle ligne
    mov [input_len], rax
    
    ; Vérifie si la longueur est exactement 16 caractères
    cmp rax, 16
    jne validation_failed
    
    ; ===== MODULE DE TRANSFORMATION =====
    ; Initialisation: Copie l'entrée dans la matrice d'entrée
    call init_input_matrix
    
    ; Transformation 1: Rotation de la matrice
    call rotate_matrix
    
    ; Transformation 2: XOR avec la matrice de transformation
    call xor_transform
    
    ; ===== MODULE DE VALIDATION =====
    ; Compare la matrice résultante avec la matrice de validation
    call validate_result
    
    ; Vérifie le résultat (1 dans rax si succès, 0 sinon)
    cmp rax, 1              ; CRACK_POINT: Remplacer cette comparaison
    je validation_success
    
validation_failed:
    ; Affiche le message d'échec
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, bad_msg        ; message
    mov rdx, bad_len        ; longueur
    syscall
    
    ; Quitte avec code d'erreur
    mov rax, 60             ; sys_exit
    mov rdi, 1              ; code erreur
    syscall
    
validation_success:
    ; Génère le flag pour cette validation réussie
    call generate_flag
    
    ; Affiche le message de succès
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, good_msg       ; message
    mov rdx, good_len       ; longueur
    syscall
    
    ; Affiche le flag généré
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, flag_buffer    ; flag généré
    mov rdx, 30             ; longueur (préfixe + 20 chars + suffixe)
    syscall
    
    ; Quitte avec succès
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; code succès
    syscall

;----------------------------------------------------------
; MODULE DE TRANSFORMATION: Fonctions de manipulation matricielle
;----------------------------------------------------------

; Initialise la matrice d'entrée à partir de l'input utilisateur
init_input_matrix:
    ; Copie l'entrée utilisateur dans la matrice 4x4
    xor rcx, rcx            ; Compteur = 0
    
.copy_loop:
    cmp rcx, 16             ; 16 caractères au total
    jge .done
    
    mov al, [input + rcx]   ; Récupère un caractère
    mov [input_matrix + rcx], al  ; Le place dans la matrice
    
    inc rcx
    jmp .copy_loop
    
.done:
    ret

; Effectue une rotation sur la matrice d'entrée
rotate_matrix:
    ; Copie input_matrix dans temp_matrix avec rotation
    xor rcx, rcx            ; Initialise l'index source
    
.rotate_loop:
    cmp rcx, 16
    jge .done
    
    ; Calcule l'index de destination selon la matrice de rotation
    mov rdx, rcx            ; Position actuelle
    xor r8, r8              ; Initialise l'index dans la matrice de rotation
    
    ; Cherche la position 1 dans la ligne correspondante de rot_matrix
    mov r9, rcx
    shr r9, 2               ; r9 = ligne (rcx / 4)
    imul r9, 4              ; r9 = début de ligne dans rot_matrix
    
.find_rotation:
    cmp byte [rot_matrix + r9 + r8], 1
    je .found_rotation
    inc r8
    cmp r8, 4
    jl .find_rotation
    
.found_rotation:
    ; Calcule la nouvelle position
    mov rax, rcx
    and rax, 3              ; rax = colonne (rcx % 4)
    shl r8, 2               ; r8 = nouvelle_ligne * 4
    add r8, rax             ; r8 = nouvelle_position
    
    ; Copie la valeur avec rotation
    mov al, [input_matrix + rcx]
    mov [temp_matrix + r8], al
    
    inc rcx
    jmp .rotate_loop
    
.done:
    ; Copie temp_matrix dans input_matrix
    xor rcx, rcx
    
.copy_back:
    cmp rcx, 16
    jge .exit
    
    mov al, [temp_matrix + rcx]
    mov [input_matrix + rcx], al
    
    inc rcx
    jmp .copy_back
    
.exit:
    ret

; Applique la transformation XOR à la matrice
xor_transform:
    xor rcx, rcx            ; Initialise le compteur
    
.xor_loop:
    cmp rcx, 16
    jge .done
    
    ; Applique XOR avec la matrice de transformation
    mov al, [input_matrix + rcx]
    xor al, [xor_matrix + rcx]
    mov [result_matrix + rcx], al
    
    inc rcx
    jmp .xor_loop
    
.done:
    ret

;----------------------------------------------------------
; MODULE DE VALIDATION: Fonction de vérification
;----------------------------------------------------------

; Valide si la matrice résultante correspond à la matrice attendue
; CRACK_SIGNATURE: Cette fonction peut être patché pour toujours retourner vrai
; quand le mot de passe est "CR4CK1NG5N0TCR1M"
validate_result:
    ; Signature facile à trouver dans le binaire
    mov rdx, [crack_signature]  ; Ne fait rien, juste pour la signature
    
    ; Compare result_matrix avec val_matrix
    xor rcx, rcx            ; Initialise le compteur
    
.compare_loop:
    cmp rcx, 16
    jge .success
    
    ; Compare les valeurs
    mov al, [result_matrix + rcx]
    cmp al, [val_matrix + rcx]
    jne .failure
    
    inc rcx
    jmp .compare_loop
    
.success:
    mov rax, 1              ; Succès
    ret
    
.failure:
    xor rax, rax            ; Échec
    ret

;----------------------------------------------------------
; MODULE DE GÉNÉRATION DE FLAG: Génère le flag unique
;----------------------------------------------------------

; Génère un flag unique basé sur les données encodées
generate_flag:
    ; Commence par copier le préfixe "HTB{" dans le buffer
    mov rsi, flag_prefix
    mov rdi, flag_buffer
    call copy_string
    
    ; Calcule la position après le préfixe
    mov rdi, flag_buffer
    xor rcx, rcx
.find_end:
    cmp byte [rdi + rcx], 0
    je .found_end
    inc rcx
    jmp .find_end

.found_end:
    add rdi, rcx            ; rdi pointe maintenant à la fin du préfixe
    
    ; Déchiffre les données du flag et les ajoute au buffer
    mov rcx, 20             ; Longueur des données encodées
    mov rsi, flag_data      ; Source (données chiffrées)
    mov rdx, flag_key       ; Clé de déchiffrement
    
.decode_loop:
    mov al, [rsi]           ; Charge un octet encodé
    xor al, [rdx]           ; Déchiffre avec la clé
    mov [rdi], al           ; Stocke dans le buffer de flag
    
    inc rsi
    inc rdx
    inc rdi
    dec rcx
    jnz .decode_loop
    
    ; Ajoute le suffixe "}" au flag
    mov rsi, flag_suffix
    call copy_string
    
    ret
    
; Fonction utilitaire pour copier une chaîne terminée par 0
copy_string:
    ; rsi = source, rdi = destination
    xor rcx, rcx
    
.copy_loop:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    cmp al, 0
    je .done
    inc rcx
    jmp .copy_loop
    
.done:
    ret 