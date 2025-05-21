SECTION .data

    encrypted_pass db 0x1A, 0x12, 0x05, 0x14, \
                    0x12, 0x13, 0x12, 0x04, \
                    0x32, 0x26, 0x2F, 0x11, \
                    0x18, 0x05, 0x0D, 0x16

    ; Table de permutation 
    perm_table    db 5, 2, 9, 0, 15, 7, 12, 4, \
                     3, 10, 14, 1, 11, 6, 8, 13

    xor_key       db 0x77
    pass_len      equ 16

    good_msg      db "Good Job!", 10, 0
    ; "Good Job!\n\0"

    bad_msg       db "Bad Password!", 10, 0
    ;  "Bad Password!\n\0"
SECTION .bss
    
    input_buffer resb 32

SECTION .text


_start:
    ; LiT jusqu'à 32 octets depuis STDIN
    mov rax, 0          ; sys_read
    mov rdi, 0          ; STDIN
    mov rsi, input_buffer
    mov rdx, 32
    syscall

    ; rax contient le nombre d'octets lus

    cmp rax, 16
    jl bad_pass

    cmp rax, 18
    jge bad_pass


    cmp rax, 17
    jne check_passwd

    mov al, [input_buffer + 16]
    cmp al, 10          ; c'est '\n' 
    jne bad_pass


    mov byte [input_buffer + 16], 0

check_passwd:

    mov rcx, 0
verify_loop:
    ; OBbtenir l'index à vérifier depuis la table de permutation
    movzx rdx, byte [perm_table + rcx]


    mov al, [input_buffer + rdx]

    ; 3) XOR avec la clé 0x77
    xor al, [xor_key]


    cmp al, [encrypted_pass + rdx]
    jne bad_pass

    inc rcx
    cmp rcx, pass_len
    jl verify_loop

    ; Si on a vérifié les 16 caractères sans échec : "Good Job!"

    mov rax, 1
    mov rdi, 1
    mov rsi, good_msg
    mov rdx, 10
    syscall

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall


bad_pass:

    mov rax, 1
    mov rdi, 1
    mov rsi, bad_msg
    mov rdx, 15
    syscall

    ; exit(1)
    mov rax, 60
    mov rdi, 1
    syscall