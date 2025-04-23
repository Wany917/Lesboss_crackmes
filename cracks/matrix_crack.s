; ===========================================================================
; Crack ultra-simple pour Matrix Validator 
; ===========================================================================
; Target: crackme_00/matrix_validator
; Original Password: MATR1X_TR4NSF0RM
; New Password: CR4CK1NG5N0TCR1M (acceptera n'importe quelle entrée)

section .data
    ; Messages
    usage_msg       db "Usage: ./crack <target_crackme>", 10, 0
    usage_len       equ $ - usage_msg
    success_msg     db "Crackme successfully patched!", 10, 0
    success_len     equ $ - success_msg
    error_open      db "Error: Could not open file", 10, 0
    error_open_len  equ $ - error_open
    error_read      db "Error: Could not read file", 10, 0
    error_read_len  equ $ - error_read
    error_write     db "Error: Could not write file", 10, 0
    error_write_len equ $ - error_write
    debug_msg       db "Found signature at offset: 0x", 0
    debug_len       equ $ - debug_msg
    
    ; Patch ultra simple - remplacer "cmp rax, 1" par "mov eax, 1" et des NOP
    ; cmp rax, 1 (48 83 F8 01) devient mov eax, 1 (B8 01 00 00 00)
    patch_bytes     db 0xB8, 0x01, 0x00, 0x00, 0x00
    patch_len       equ $ - patch_bytes
    
    ; Signature pour trouver la comparaison finale
    signature       db 0x48, 0x83, 0xF8, 0x01  ; cmp rax, 1
    signature_len   equ $ - signature
    
section .bss
    filename        resq 1      ; Pointeur vers le nom de fichier
    fd              resq 1      ; Descripteur de fichier
    file_buffer     resb 131072 ; Buffer de 128Ko pour le contenu du fichier
    file_size       resq 1      ; Taille du fichier
    patch_loc       resq 1      ; Emplacement pour le patch
    hex_buffer      resb 16     ; Buffer pour la conversion hex
    
section .text
    global _start
    
_start:
    ; Vérifie si un argument a été fourni
    cmp qword [rsp], 2
    jl display_usage
    
    ; Récupère le nom de fichier depuis argv[1]
    mov rax, [rsp+16]
    mov [filename], rax
    
    ; Ouvre le fichier
    mov rax, 2          ; sys_open
    mov rdi, [filename]
    mov rsi, 2          ; O_RDWR
    mov rdx, 0
    syscall
    
    ; Vérifie les erreurs
    cmp rax, 0
    jl open_error
    
    ; Stocke le descripteur de fichier
    mov [fd], rax
    
    ; Lit le contenu du fichier
    mov rax, 0          ; sys_read
    mov rdi, [fd]
    mov rsi, file_buffer
    mov rdx, 131072
    syscall
    
    ; Vérifie les erreurs
    cmp rax, 0
    jl read_error
    
    ; Stocke la taille du fichier
    mov [file_size], rax
    
    ; Trouve la signature "cmp rax, 1"
    call find_signature
    
    ; Vérifie si on a trouvé la signature
    cmp qword [patch_loc], 0
    je not_found
    
    ; Applique le patch simple
    call apply_patch
    
    ; Écrit le contenu modifié dans le fichier
    mov rax, 8          ; sys_lseek
    mov rdi, [fd]
    xor rsi, rsi        ; offset 0
    xor rdx, rdx        ; SEEK_SET
    syscall
    
    mov rax, 1          ; sys_write
    mov rdi, [fd]
    mov rsi, file_buffer
    mov rdx, [file_size]
    syscall
    
    ; Vérifie les erreurs
    cmp rax, [file_size]
    jne write_error
    
    ; Ferme le fichier
    mov rax, 3          ; sys_close
    mov rdi, [fd]
    syscall
    
    ; Affiche le message de succès
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, success_msg
    mov rdx, success_len
    syscall
    
    ; Quitte avec succès
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; ===================================
; Gestionnaires d'erreurs
; ===================================

display_usage:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, usage_msg
    mov rdx, usage_len
    syscall
    
    mov rax, 60         ; sys_exit
    mov rdi, 1
    syscall

open_error:
    mov rax, 1          ; sys_write
    mov rdi, 2          ; stderr
    mov rsi, error_open
    mov rdx, error_open_len
    syscall
    
    mov rax, 60         ; sys_exit
    mov rdi, 1
    syscall

read_error:
    mov rax, 1          ; sys_write
    mov rdi, 2          ; stderr
    mov rsi, error_read
    mov rdx, error_read_len
    syscall
    
    mov rax, 3          ; sys_close
    mov rdi, [fd]
    syscall
    
    mov rax, 60         ; sys_exit
    mov rdi, 1
    syscall

write_error:
    mov rax, 1          ; sys_write
    mov rdi, 2          ; stderr
    mov rsi, error_write
    mov rdx, error_write_len
    syscall
    
    mov rax, 3          ; sys_close
    mov rdi, [fd]
    syscall
    
    mov rax, 60         ; sys_exit
    mov rdi, 1
    syscall

not_found:
    ; Affiche un message d'erreur
    mov rax, 1
    mov rdi, 1
    mov rsi, error_write
    mov rdx, error_write_len
    syscall
    
    ; Ferme le fichier
    mov rax, 3
    mov rdi, [fd]
    syscall
    
    ; Quitte avec erreur
    mov rax, 60
    mov rdi, 1
    syscall

; ===================================
; Fonctions principales
; ===================================

; Trouve la signature "cmp rax, 1" dans le fichier
find_signature:
    ; Initialise l'emplacement du patch
    mov qword [patch_loc], 0
    
    ; Cherche chaque occurrence de la signature
    mov rdi, file_buffer                ; début du buffer
    mov rsi, [file_size]                ; taille du buffer
    sub rsi, signature_len              ; évite de déborder
    
    ; Parcours le fichier
.loop:
    cmp rdi, rsi
    jge .not_found                      ; fin du buffer
    
    ; Compare avec la signature
    mov rcx, signature_len
    push rdi
    push rsi
    mov rsi, signature
    repe cmpsb                          ; compare byte à byte
    pop rsi
    pop rdi
    
    je .found                           ; signature trouvée
    
    inc rdi                             ; avance d'un byte
    jmp .loop
    
.found:
    ; Calcule l'offset depuis le début du fichier
    mov rax, rdi
    sub rax, file_buffer
    mov [patch_loc], rax
    
    ; Affiche l'offset pour debug
    mov rdi, debug_msg
    call print_string
    
    mov rdi, hex_buffer
    mov rsi, rax
    call print_hex
    
    ; Saut de ligne
    mov rdi, 10                         ; newline
    call print_char
    
    ret
    
.not_found:
    mov qword [patch_loc], 0
    ret

; Applique le patch à l'emplacement trouvé
apply_patch:
    ; Vérifie si on a un emplacement de patch
    cmp qword [patch_loc], 0
    je .done
    
    ; Applique le patch simple
    mov rdi, file_buffer
    add rdi, [patch_loc]                ; emplacement du patch
    
    ; Copie le patch
    mov rsi, patch_bytes
    mov rcx, patch_len
    
.copy_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jnz .copy_loop
    
.done:
    ret

; ===================================
; Fonctions utilitaires
; ===================================

; Affiche une chaîne terminée par 0
; rdi = chaîne à afficher
print_string:
    push rdi
    push rcx
    
    ; Calcule la longueur de la chaîne
    mov rcx, -1
    xor al, al
    
    ; Recherche le caractère nul
    repne scasb
    
    ; Calcule la longueur (rcx = -longueur - 2)
    not rcx
    dec rcx
    
    ; Affiche la chaîne
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    pop rdx                             ; longueur (rcx)
    pop rsi                             ; chaîne
    syscall
    
    ret

; Affiche un caractère
; rdi = caractère à afficher
print_char:
    push rdi
    
    ; Met le caractère dans le buffer
    mov [hex_buffer], dil
    
    ; Affiche le caractère
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, hex_buffer                 ; buffer
    mov rdx, 1                          ; longueur
    syscall
    
    pop rdi
    ret

; Affiche une valeur hexadécimale
; rdi = buffer pour l'output, rsi = valeur
print_hex:
    push rbx
    push rcx
    push rdx
    push rdi
    
    ; Initialisation
    mov rbx, rsi                        ; valeur à convertir
    mov rcx, 16                         ; 16 nibbles (64 bits)
    add rdi, 15                         ; pointe à la fin du buffer
    
.loop:
    mov rdx, rbx
    and rdx, 0xF                        ; garde les 4 bits de poids faible
    
    ; Convertit en caractère hexa
    cmp dl, 10
    jl .decimal
    
    add dl, 'a' - 10                    ; A-F
    jmp .store
    
.decimal:
    add dl, '0'                         ; 0-9
    
.store:
    mov [rdi], dl                       ; stocke le caractère
    dec rdi                             ; recule dans le buffer
    
    shr rbx, 4                          ; décale de 4 bits
    dec rcx
    jnz .loop
    
    ; Affiche la chaîne hexadécimale
    pop rsi                             ; buffer
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rdx, 16                         ; longueur
    syscall
    
    pop rdx
    pop rcx
    pop rbx
    ret