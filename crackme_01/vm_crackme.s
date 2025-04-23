; ===========================================================================
; Crackme 01 - Machine Virtuelle Personnalisée
; ===========================================================================
; Architecture: x64 Linux
; Description: Implémente une machine virtuelle simple qui exécute du bytecode
;              personnalisé pour valider l'entrée.

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
    
    ; Définition des opcodes de la VM
    OP_LOAD     equ 0x01     ; Charge une valeur dans un registre
    OP_STORE    equ 0x02     ; Stocke le contenu d'un registre dans la mémoire
    OP_XOR      equ 0x03     ; XOR entre deux registres
    OP_ADD      equ 0x04     ; Addition entre deux registres
    OP_SUB      equ 0x05     ; Soustraction entre deux registres
    OP_ROTATE   equ 0x06     ; Rotation des bits dans un registre
    OP_CMP      equ 0x07     ; Compare deux registres
    OP_JNE      equ 0x08     ; Saut si non égal
    OP_JMP      equ 0x09     ; Saut inconditionnel
    OP_HALT     equ 0xFF     ; Arrêt de la VM
    
    ; Programme bytecode pour la validation (encodé/obscurci)
    ; Ce bytecode implémente l'algorithme de validation du mot de passe
    ; Format: opcode, operand1, operand2, operand3
    bytecode    db OP_LOAD, 0, 0, 0    ; Charge le compteur à 0 dans r0
                db OP_LOAD, 1, 16, 0   ; Charge la longueur 16 dans r1
                db OP_LOAD, 10, 1, 0   ; Initialise le résultat à 1 (true) dans r10
                
                ; Boucle principale - vérification caractère par caractère
                db OP_CMP, 0, 1, 0     ; Compare r0 (compteur) et r1 (longueur)
                db OP_JNE, 8, 0, 0     ; Si égaux, saute à la fin (instruction + 8)
                
                ; Charge le caractère d'entrée
                db OP_LOAD, 2, 0, 1    ; Charge caractère entrée[r0] dans r2
                
                ; Transformation du caractère
                db OP_LOAD, 3, 42, 0   ; Charge clé de transformation dans r3
                db OP_XOR, 2, 3, 0     ; r2 = r2 XOR r3
                db OP_ROTATE, 2, 2, 0  ; Rotation des bits dans r2
                
                ; Charge la valeur attendue codée en dur (valeur pré-calculée)
                db OP_LOAD, 3, 0, 2    ; Charge la valeur attendue dans r3
                
                ; Compare avec la valeur attendue
                db OP_CMP, 2, 3, 0     ; Compare r2 et r3
                db OP_JNE, 2, 0, 0     ; Si différents, saute à l'échec
                
                ; Avance au caractère suivant
                db OP_ADD, 0, 1, 0     ; Incrémente le compteur r0
                db OP_JMP, -13, 0, 0   ; Retourne au début de la boucle
                
                ; Échec de validation
                db OP_LOAD, 10, 0, 0   ; Définit le résultat comme false
                
                ; Fin du programme
                db OP_HALT, 0, 0, 0    ; Fin de l'exécution
    
    ; Tableau de valeurs attendues encodées (pré-calculées pour le flag)
    ; Ces valeurs sont le résultat de XOR + rotation sur chaque caractère du flag
    expected    db 70, 109, 122, 79, 91, 69, 74, 126, 101, 73, 75, 77, 113, 126, 77, 93
    
    ; Données pour générer le flag dynamiquement
    ; Ces valeurs encodées représentent le vrai flag (différent du mot de passe)
    flag_data   db 72, 98, 43, 102, 123, 54, 78, 89, 39, 111, 87, 36, 92, 64, 29, 102, 114, 76, 56, 43
    flag_key    db 41, 17, 76, 43, 87, 22, 39, 44, 72, 55, 23, 81, 48, 19, 76, 63, 85, 35, 17, 92

section .bss
    ; Tampon pour l'entrée utilisateur
    input       resb 64     ; Tampon d'entrée
    input_len   resq 1      ; Longueur de l'entrée
    
    ; État de la machine virtuelle
    vm_regs     resb 16     ; 16 registres de 1 octet (r0-r15)
    vm_pc       resq 1      ; Compteur de programme
    vm_flags    resb 1      ; Drapeaux (bit 0: Zero Flag)
    
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
    
    ; ===== MODULE D'EXÉCUTION DE LA VM =====
    ; Initialise la VM
    call vm_init
    
    ; Exécute le bytecode
    call vm_execute
    
    ; ===== MODULE DE VALIDATION =====
    ; Vérifie le résultat dans r10 (1 = succès, 0 = échec)
    xor rax, rax
    mov al, [vm_regs + 10]
    test al, al
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
; MODULE VM: Fonctions de la Machine Virtuelle
;----------------------------------------------------------

; Initialise l'état de la machine virtuelle
vm_init:
    ; Efface tous les registres
    xor rcx, rcx
    
.clear_regs:
    cmp rcx, 16
    jge .done
    
    mov byte [vm_regs + rcx], 0
    inc rcx
    jmp .clear_regs
    
.done:
    ; Initialise le compteur de programme
    mov qword [vm_pc], 0
    
    ; Efface les drapeaux
    mov byte [vm_flags], 0
    
    ret

; Exécute le bytecode de la VM
vm_execute:
    ; Exécute les instructions jusqu'à OP_HALT
.execute_loop:
    ; Récupère l'opcode à [vm_pc]
    mov rbx, [vm_pc]
    movzx rax, byte [bytecode + rbx]
    
    ; Incrémente le PC pour l'opérande 1
    add qword [vm_pc], 1
    
    ; Traitement selon l'opcode
    cmp al, OP_LOAD
    je .op_load
    cmp al, OP_STORE
    je .op_store
    cmp al, OP_XOR
    je .op_xor
    cmp al, OP_ADD
    je .op_add
    cmp al, OP_SUB
    je .op_sub
    cmp al, OP_ROTATE
    je .op_rotate
    cmp al, OP_CMP
    je .op_cmp
    cmp al, OP_JNE
    je .op_jne
    cmp al, OP_JMP
    je .op_jmp
    cmp al, OP_HALT
    je .op_halt
    
    ; Opcode inconnu - continue simplement
    jmp .next_instruction
    
.op_load:
    ; Charge une valeur dans un registre
    ; Format: LOAD reg, val, is_indirect
    
    ; Récupère l'opérande 1 (numéro de registre)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = numéro de registre
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (valeur ou adresse)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = valeur
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 3 (mode adressage: 0=immédiat, 1=registre, 2=valeur attendue)
    mov rbx, [vm_pc]
    movzx r10, byte [bytecode + rbx]  ; r10 = mode adressage
    add qword [vm_pc], 1
    
    ; Traite selon le mode d'adressage
    cmp r10, 0
    je .load_immediate
    cmp r10, 1
    je .load_from_input
    cmp r10, 2
    je .load_from_expected
    
    jmp .next_instruction
    
.load_immediate:
    ; Charge une valeur immédiate
    mov [vm_regs + r8], r9b
    jmp .next_instruction
    
.load_from_input:
    ; Charge un caractère depuis l'entrée
    ; r9 contient l'index (souvent le contenu d'un registre)
    movzx r11, byte [vm_regs + r9]  ; r11 = index
    movzx r9, byte [input + r11]    ; r9 = input[index]
    mov [vm_regs + r8], r9b
    jmp .next_instruction
    
.load_from_expected:
    ; Charge une valeur depuis la table expected
    ; r9 contient l'index (souvent le contenu d'un registre)
    movzx r11, byte [vm_regs + r9]  ; r11 = index
    movzx r9, byte [expected + r11] ; r9 = expected[index]
    mov [vm_regs + r8], r9b
    jmp .next_instruction
    
.op_store:
    ; TODO: Store register to memory if needed
    ; For this crackme, we don't use memory store
    add qword [vm_pc], 3  ; Skip operands
    jmp .next_instruction
    
.op_xor:
    ; XOR deux registres
    ; Format: XOR dest, src, _
    
    ; Récupère l'opérande 1 (registre destination)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = registre destination
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (registre source)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = registre source
    add qword [vm_pc], 2  ; Skip unused operand
    
    ; Exécute XOR
    movzx r10, byte [vm_regs + r8]  ; r10 = regs[dest]
    movzx r11, byte [vm_regs + r9]  ; r11 = regs[src]
    xor r10, r11
    mov [vm_regs + r8], r10b
    
    jmp .next_instruction
    
.op_add:
    ; Addition de deux registres
    ; Format: ADD dest, src, _
    
    ; Récupère l'opérande 1 (registre destination)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = registre destination
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (registre source)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = registre source
    add qword [vm_pc], 2  ; Skip unused operand
    
    ; Exécute ADD
    movzx r10, byte [vm_regs + r8]  ; r10 = regs[dest]
    movzx r11, byte [vm_regs + r9]  ; r11 = regs[src]
    add r10, r11
    mov [vm_regs + r8], r10b
    
    jmp .next_instruction
    
.op_sub:
    ; Soustraction de deux registres
    ; Format: SUB dest, src, _
    
    ; Récupère l'opérande 1 (registre destination)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = registre destination
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (registre source)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = registre source
    add qword [vm_pc], 2  ; Skip unused operand
    
    ; Exécute SUB
    movzx r10, byte [vm_regs + r8]  ; r10 = regs[dest]
    movzx r11, byte [vm_regs + r9]  ; r11 = regs[src]
    sub r10, r11
    mov [vm_regs + r8], r10b
    
    ; Set flags
    test r10, r10
    setz byte [vm_flags]  ; Zero flag
    
    jmp .next_instruction
    
.op_rotate:
    ; Rotation des bits dans un registre
    ; Format: ROTATE reg, amount, _
    
    ; Récupère l'opérande 1 (registre)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = registre
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (quantité de rotation)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = quantité
    add qword [vm_pc], 2  ; Skip unused operand
    
    ; Exécute ROTATE (rotation à gauche)
    movzx r10, byte [vm_regs + r8]  ; r10 = regs[reg]
    mov cl, r9b                    ; cl = amount
    rol r10b, cl
    mov [vm_regs + r8], r10b
    
    jmp .next_instruction
    
.op_cmp:
    ; Compare deux registres
    ; Format: CMP reg1, reg2, _
    
    ; Récupère l'opérande 1 (premier registre)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = premier registre
    add qword [vm_pc], 1
    
    ; Récupère l'opérande 2 (second registre)
    mov rbx, [vm_pc]
    movzx r9, byte [bytecode + rbx]  ; r9 = second registre
    add qword [vm_pc], 2  ; Skip unused operand
    
    ; Exécute CMP
    movzx r10, byte [vm_regs + r8]  ; r10 = regs[reg1]
    movzx r11, byte [vm_regs + r9]  ; r11 = regs[reg2]
    cmp r10, r11
    
    ; Set flags
    setz byte [vm_flags]  ; Zero flag
    
    jmp .next_instruction
    
.op_jne:
    ; Saut si non égal
    ; Format: JNE offset, _, _
    
    ; Récupère l'opérande 1 (offset)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = offset
    add qword [vm_pc], 3  ; Skip all operands
    
    ; Vérifie le Zero flag
    test byte [vm_flags], 1
    jnz .next_instruction  ; Si égal, pas de saut
    
    ; Applique l'offset au PC (saute)
    add qword [vm_pc], r8
    jmp .execute_loop  ; Retourne à la boucle sans incrémentation
    
.op_jmp:
    ; Saut inconditionnel
    ; Format: JMP offset, _, _
    
    ; Récupère l'opérande 1 (offset)
    mov rbx, [vm_pc]
    movzx r8, byte [bytecode + rbx]  ; r8 = offset
    add qword [vm_pc], 3  ; Skip all operands
    
    ; Applique l'offset au PC
    movsx r9, r8b  ; Extension de signe (permet offsets négatifs)
    add qword [vm_pc], r9
    jmp .execute_loop  ; Retourne à la boucle sans incrémentation
    
.op_halt:
    ; Arrêt de la VM
    ret
    
.next_instruction:
    jmp .execute_loop

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