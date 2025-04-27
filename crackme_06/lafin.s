
section .data
    
    prompt          db "Entrez le flag: ", 0
    good_msg        db "Good Job!", 10, 0
    bad_msg         db "Bad Password!", 10, 0
    
    ; Données de distraction
    
    fake_flag1      db "H3ARTBEATS100K_D", 0
    fake_flag2      db "SKIN_LARGEST0RG", 0
    fake_data       db "XNEURONSBI11I0NX", 0
    
    ; Flag encodé pour rendre la rétro-ingénierie plus difficile
    
    encoded_flag    db 0x42, 0x52, 0x41, 0x49, 0x4E, 0x57, 0x45, 0x49, 0x47, 0x48, 0x53, 0x31, 0x35, 0x30, 0x30, 0x47
    
    ; Clé de décodage (valeur sans effet réel - fausse piste)
    
    decode_key      db 0x33, 0x12, 0x87, 0xA4, 0x5B, 0x9F, 0xC2, 0x1D, 0x67, 0xE9, 0x44, 0x0B, 0x75, 0x3C, 0x8F, 0x21
    
    ; Constantes pour les opérations
   
    magic_number    dq 0x1337DEADBEEF
    flag_len        equ 16
    checksum        dd 0xCAFEBABE

section .bss
    user_flag       resb 100        
    temp_buffer     resb 32         ; Buffer temporaire pour les calculs
    checksum_result resq 1          ; Pour stocker le résultat du checksum
    clean_input     resb 32         

section .text
    global _start


; Fonction inutile pour distraire (fausse piste)
calculate_checksum:
    
    ; Sauvegarde des registres
    
    push rbx
    push rcx
    push rdx
    
    ; Code de checksum qui ne fait rien d'utile
    
    mov rax, [rsp+32]
    xor rbx, rbx
    mov rcx, 16
    
checksum_loop:
    
    rol rax, 7
    xor rax, [magic_number]
    add rbx, rax
    loop checksum_loop
    
    ; Restauration des registres
    
    
    pop rdx
    pop rcx
    pop rbx
    ret

; Fonction de décodage inutile (fausse piste)
decode_buffer:
    ; Sauvegarde des registres
    
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Faux algorithme de décodage
    
    mov rsi, [rsp+48]  ; Premier argument (entrée)
    mov rdi, [rsp+56]  ; Deuxième argument (sortie)
    mov rcx, 16       ; Longueur à décoder
    
decode_loop:
    
    mov al, [rsi]
    xor al, [decode_key + rcx - 1]
    ror al, 3
    mov [rdi], al
    inc rsi
    inc rdi
    loop decode_loop
    
    ; Restauration des registres
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    ; Saut inutile pour compliquer l'analyse statique
    jmp real_start
    
fake_routine:
    ; Code mort qui ne sera jamais exécuté
    
    mov rax, 123
    xor rbx, rbx
    call calculate_checksum
    ret
    
real_start:
    ; Initialisation inutile des registres
    
    xor rax, rax
    mov rbx, [magic_number]
    xor rcx, rcx
    xor rdx, rdx
    
    ; Affiche l'invite
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, prompt                
    mov rdx, 15                     
    syscall
    
    ; Appel factice à une fonction qui n'est pas utilisée (fausse piste)
    
    cmp rbx, 0x1337BEEF
    je fake_routine
    
    ; Lit l'entrée utilisateur
    
    mov rax, 0                     
    mov rdi, 0                    
    mov rsi, user_flag              
    mov rdx, 100                    
    syscall
    mov r15, rax                   
    
    ; Nettoyer l'entrée et la copier dans clean_input
    
    xor rcx, rcx                   
    xor rdx, rdx                    
    
clean_loop:
    cmp rcx, r15                    
    jge end_clean                   
    
    mov al, [user_flag + rcx]       
    cmp al, 10                      
    je skip_char                    
    cmp al, 13                      
    je skip_char                    
    
    ; Si ce n'est pas un caractère à ignorer, le copier
    
    mov [clean_input + rdx], al
    inc rdx
    
skip_char:
   
    inc rcx
    jmp clean_loop
    
end_clean:
    mov byte [clean_input + rdx], 0 ; Ajouter un terminateur nul
    
    ; Opérations mathématiques inutiles, juste pour distraire
   
    mov r8, [magic_number]
    ror r8, 13
    xor r8, rax
    
    ; Vérification factice (fausse piste)
    
    cmp r8, [checksum]
    jne continue_check
    call calculate_checksum
    
continue_check:
    ; direction de saut factice (fausse piste)
    
    cmp rax, 0
    jl bad_password_fake
    
    ; Véritable routine de vérification
    
    mov rsi, clean_input            ; Entrée utilisateur nettoyée
    lea rdi, [encoded_flag]        
    
    ; verifier la longueur d'abord
    
    xor rcx, rcx
length_check:
    cmp byte [rsi + rcx], 0
    je end_length_check
    inc rcx
    jmp length_check
    
end_length_check:
    cmp rcx, flag_len
    jne complicated_bad_path        ;si la longueur ne correspond pas, mauvais mot de passe
    
    ; maintenant comparer caractère par caractère
    xor rcx, rcx                    ; Réinitialiser le compteur
    
compare_loop:
    cmp rcx, flag_len
    jge obfuscated_good_password    ; Si on a comparé tous les caractères, c'est bon
    
    mov al, byte [rsi + rcx]        ; Caractère de l'entrée nettoyée
    
    ; ici, nous faisons une opération XOR factice avant de comparer
    ; qui n'a pas d'effet réel car nous XORons avec 0
    xor al, 0
    
    ; Ajout de complexité inutil
    push rcx
    mov r9, rcx
    xor r9, [magic_number]
    and r9, 0xF
    mov rcx, r9
    rol al, cl
    ror al, cl  ; Effet nul: on annule la rotation
    pop rcx
    
    mov bl, byte [rdi + rcx]        ; Caractère du flag correct
    cmp al, bl                      
    jne complicated_bad_path        ; Si différent, chemin complexe vers mauvais mot de passe
    
    inc rcx                         ; Incrémenter l'index
    jmp compare_loop                ; Continuer la boucle

; Chemin inutile jamais emprunté
bad_password_fake:
    
    mov rax, 0xDEAD
    xor rax, [magic_number]
    cmp rax, 0
    je good_password                ; Fausse piste
    jmp bad_password                

complicated_bad_path:
    ; Chemin complexe pour compliquer l'analyse statique
    
    xor rax, rax
    mov rax, 0xBAD
    shl rax, 4
    xor rax, 0x5555
    cmp rax, 0x1234
    je end_clean                    ; Fausse piste
    jmp bad_password                

obfuscated_good_password:
    ; Rend l'accès au bon mot de passe plus difficile à suivre
    
    xor rax, rax
    add rax, 0xCAFE
    sub rax, 0xCAFE                 ; Égal à zéro
    cmp rax, 0
    jne bad_password                ; Ne sera jamais pris
    jmp good_password               ; Direction réelle

good_password:
    ; Affiche "Good Job!"
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, good_msg              
    mov rdx, 10                     
    syscall
    
    ; Sortie avec code 0
    mov rax, 60                     
    mov rdi, 0                      
    syscall

bad_password:
    ; Affiche "Bad Password!"
    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, bad_msg                
    mov rdx, 14                     
    syscall
    
    ; Sortie avec code 1
    mov rax, 60                     
    mov rdi, 1                     
    syscall