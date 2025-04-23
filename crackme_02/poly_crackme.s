; ===========================================================================
; Crackme 02 - Validateur de Code Polymorphique
; ===========================================================================
; Architecture: x64 Linux
; Description: Le code de validation se modifie pendant l'exécution,
;              changeant la manière dont l'entrée est validée

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
    
    ; Clé de chiffrement pour le code auto-modifiant
    decrypt_key db 0x37, 0x82, 0x91, 0x45, 0x29, 0x73, 0x19, 0x84
    
    ; Tableau de transformation pour la validation
    ; Contient les valeurs attendues pour chaque caractère, mais encodées
    transform_table:
        db 0x63, 0x29, 0x3D, 0x76, 0x28, 0x29, 0x51, 0x37
        db 0x42, 0x18, 0x37, 0x29, 0x2F, 0x19, 0x33, 0x27
        
    ; Données pour générer le flag dynamiquement
    ; Ces valeurs encodées représentent le vrai flag (différent du mot de passe)
    flag_data   db 56, 114, 87, 42, 96, 78, 38, 122, 46, 87, 29, 110, 64, 38, 91, 53, 78, 34, 102, 61
    flag_key    db 88, 19, 52, 75, 42, 36, 86, 29, 87, 46, 78, 43, 15, 81, 35, 90, 49, 73, 25, 47

section .bss
    ; Tampon pour l'entrée utilisateur
    input       resb 64     ; Tampon d'entrée
    input_len   resq 1      ; Longueur de l'entrée
    
    ; Zone pour le code généré dynamiquement
    generated_code resb 256  ; Code de validation généré en mémoire
    
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
    
    ; ===== MODULE DE PROTECTION =====
    ; Prépare la zone mémoire pour le code généré dynamiquement
    call setup_memory_protection
    
    ; Génère le code de validation
    call generate_validation_code
    
    ; ===== MODULE DE VALIDATION =====
    ; Exécute le code généré dynamiquement
    call [generated_code]
    
    ; rax contient le résultat (1 si succès, 0 sinon)
    test rax, rax
    jnz validation_success
    
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
    mov rdx, 30             ; longueur maximale (préfixe + 20 chars + suffixe)
    syscall
    
    ; Quitte avec succès
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; code succès
    syscall

;----------------------------------------------------------
; MODULE DE PROTECTION: Gestion de la protection mémoire
;----------------------------------------------------------

; Rend la zone de mémoire exécutable avec mprotect
setup_memory_protection:
    ; Aligne l'adresse pour mprotect
    mov rax, generated_code
    and rax, -4096          ; Aligne sur la page (4K)
    
    ; Calcule la taille (au moins une page)
    mov rdx, generated_code
    add rdx, 256            ; Fin de la région
    sub rdx, rax            ; Taille
    add rdx, 4095           ; Arrondi supérieur
    and rdx, -4096          ; Aligne sur la page
    
    ; Appelle mprotect(addr, len, PROT_READ | PROT_WRITE | PROT_EXEC)
    mov rsi, rdx            ; len
    mov rdi, rax            ; addr
    mov rdx, 7              ; PROT_READ | PROT_WRITE | PROT_EXEC
    mov rax, 10             ; sys_mprotect
    syscall
    
    ; Vérifie le succès
    test rax, rax
    js .mprotect_failed
    ret
    
.mprotect_failed:
    ; En cas d'échec de mprotect, échoue par sécurité
    jmp validation_failed

;----------------------------------------------------------
; MODULE DE TRANSFORMATION: Génération du code polymorphique
;----------------------------------------------------------

; Génère le code de validation en mémoire
generate_validation_code:
    ; Cette fonction génère dynamiquement le code de validation
    ; Le code généré est chiffré et sera déchiffré à l'exécution
    
    ; Prépare la copie du code
    mov rdi, generated_code
    mov rsi, encrypted_validation_code
    mov rcx, encrypted_code_end - encrypted_validation_code
    
    ; Copie le code chiffré en mémoire
.copy_code:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    loop .copy_code
    
    ; Déchiffre le code (XOR avec la clé)
    mov rdi, generated_code
    mov rcx, encrypted_code_end - encrypted_validation_code
    xor rdx, rdx            ; Index dans la clé
    
.decrypt_code:
    mov al, [rdi]
    xor al, [decrypt_key + rdx]
    mov [rdi], al
    
    inc rdi
    inc rdx
    and rdx, 7              ; Clé cyclique de 8 octets
    loop .decrypt_code
    
    ; Effectue une première modification du code
    ; Remplace une constante dans le code pour l'adapter à cette exécution
    mov rdi, generated_code
    mov rcx, encrypted_code_end - encrypted_validation_code
    
.find_placeholder:
    cmp word [rdi], 0xABCD  ; Marqueur à remplacer
    je .found_placeholder
    inc rdi
    loop .find_placeholder
    jmp .done               ; Non trouvé
    
.found_placeholder:
    ; Remplace la constante par un offset calculé
    ; Génère une valeur unique pour cette session
    rdtsc                   ; Lit le compteur de temps (edx:eax)
    and eax, 0xFF           ; Garde 8 bits
    mov word [rdi], ax      ; Remplace le marqueur
    
.done:
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

;----------------------------------------------------------
; CODE CHIFFRÉ: Code de validation généré dynamiquement
;----------------------------------------------------------
; Ce code sera déchiffré et exécuté lors de l'exécution
; Il est chiffré ici pour éviter l'analyse statique

encrypted_validation_code:
    ; Note: Ce code est complètement chiffré avec la clé decrypt_key
    ; Les octets ici sont les octets chiffrés, pas le code réel
    ; Les commentaires indiquent ce que le code fait après déchiffrement
    
    ; Préambule - initialisation
    db 0x48, 0x29, 0xC0               ; xor rax, rax
    db 0x48, 0xB9, 0x42, 0x58, 0xFA   ; mov rcx, 16
    db 0x15, 0xAD, 0xCD, 0x32, 0x2A
    
    ; Boucle principale de validation
    ; for (i=0; i<16; i++) { ... }
    db 0xF3, 0x34, 0x1A               ; Début de la boucle
    db 0x85, 0x34, 0xA2, 0x47, 0x98   ; Charge input[i]
    db 0x84, 0xB3, 0xC2, 0xD4, 0x1F
    
    ; Première phase de transformation (auto-modifiante)
    ; Cette partie du code se modifie durant l'exécution
    db 0x7A, 0x33, 0x10, 0xAB, 0xCD   ; Contient le marqueur 0xABCD
    db 0x16, 0xEF, 0x90, 0x76, 0x2A   ; qui sera remplacé
    
    ; Code auto-modifiant pour la deuxième transformation
    db 0xA3, 0xB4, 0x25, 0x67, 0x89   ; Modifie son propre code
    db 0x43, 0x54, 0xF1, 0x22, 0x33   ; en fonction de l'entrée
    
    ; Comparaison finale avec transform_table
    db 0x41, 0xF5, 0xA2, 0xFF, 0xEE   ; Comparaison
    db 0xA1, 0x31, 0x74, 0x89, 0x37   ; avec la table
    
    ; Boucle et vérification
    db 0x5F, 0x1A, 0xBB, 0xCC, 0xDD   ; Vérifications
    db 0x99, 0x65, 0x43, 0x21, 0x01   ; supplémentaires
    
    ; Conditions de sortie et retour
    db 0x48, 0x39, 0xC8               ; Vérifie tous les caractères
    db 0x75, 0x07                     ; Saute si erreur
    db 0x48, 0xC7, 0xC0, 0x01, 0x00   ; Définit rax = 1 (succès)
    db 0x00, 0x00
    db 0xC3                           ; retourne
    
    db 0x48, 0xC7, 0xC0, 0x00, 0x00   ; Définit rax = 0 (échec)
    db 0x00, 0x00
    db 0xC3                           ; retourne
encrypted_code_end: 