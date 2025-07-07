Writeup 3 : 

Ce challenge consiste à reverse-engineer un exécutable Linux 3 qui demande un mot de passe donc flag de 16 caractères. Si le bon mot de passe est fourni, le programme affiche : Good Job!.

Infos générales : 

file 3
3: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped


objdump -t 3 | grep -v UNDEF



3:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 curiosity.s
0000000000402000 l       .data  0000000000000000 msg_good_enc
0000000000000009 l       *ABS*  0000000000000000 len_good
0000000000402009 l       .data  0000000000000000 msg_bad_enc
000000000000000c l       *ABS*  0000000000000000 len_bad
0000000000402015 l       .data  0000000000000000 vm_bytecode_enc
0000000000402046 l       .data  0000000000000000 flag_enc
0000000000000010 l       *ABS*  0000000000000000 flag_len
0000000000402056 l       .data  0000000000000000 dynamic_key
0000000000402066 l       .data  0000000000000000 key
0000000000402076 l       .data  0000000000000000 perm_table_xor
00000000000000a5 l       *ABS*  0000000000000000 perm_key
0000000000402086 l       .data  0000000000000000 expected_sum_xor
000000000040208e l       .data  0000000000000000 sum_key
0000000000402096 l       .data  0000000000000000 xor_key1
00000000004020a6 l       .data  0000000000000000 rol_key2
00000000004020b6 l       .data  0000000000000000 sbox
00000000004020c8 l       .bss   0000000000000000 input
00000000004020da l       .bss   0000000000000000 vm_bytecode
000000000040211a l       .bss   0000000000000000 msg_good
000000000040212a l       .bss   0000000000000000 msg_bad
000000000040213a l       .bss   0000000000000000 vm_key


....

On remarque :

run_vm

decrypt_vm_bytecode

decrypt_flag_fragmented

decrypt_msg_good

On devine que ce binaire exécute un bytecod, et qil y a de grande chose que le flag est vérifié dans une machine virtuelle (VM) interne.


Disassembly of section .text:

0000000000401000 <_start>:
  401000:       e8 f0 02 00 00          call   4012f5 <get_current_time>
  401005:       e8 09 03 00 00          call   401313 <generate_dynamic_key>
  40100a:       c6 04 25 3a 21 40 00    movb   $0xa5,0x40213a
  401011:       a5 
  401012:       e8 40 01 00 00          call   401157 <read_input>
  401017:       85 c0                   test   %eax,%eax
  401019:       0f 85 fe 01 00 00       jne    40121d <_fail>
  40101f:       e8 17 00 00 00          call   40103b <decrypt_vm_bytecode>
  401024:       e8 ae 00 00 00          call   4010d7 <run_vm>
  401029:       85 c0                   test   %eax,%eax
  40102b:       0f 85 ec 01 00 00       jne    40121d <_fail>
  401031:       e8 80 01 00 00          call   4011b6 <clean_memory>
  401036:       e9 bb 01 00 00          jmp    4011f6 <_success>

000000000040103b <decrypt_vm_bytecode>:
  40103b:       48 8d 34 25 15 20 40    lea    0x402015,%rsi
  401042:       00 
  401043:       48 8d 3c 25 da 20 40    lea    0x4020da,%rdi
  40104a:       00 
  40104b:       b9 31 00 00 00          mov    $0x31,%ecx
  401050:       8a 04 25 3a 21 40 00    mov    0x40213a,%al

0000000000401057 <decrypt_vm_bytecode.vm_dec_loop>:
:



.......


en parcourant cela, cela m'a permis de comprendre la logique de ce binaire  :

le programme lit 16 caractères de l’utilisateur (read_input).

il déchiffre un bytecode embarqué XORé avec 0xA5.

il l’exécute via run_vm, qui vérifie chaque caractère.

si tout est bon, on entre dans decrypt_msg_good qui va afficher "Good Job!"



on voit dans decrypt_vm_bytecode que le code est copié depuis 0x402015 pour une longueur de 0x31 --49--  octet.

et que .data commence à 0x402000, et que son offset dans le fichier est 0x2000, on fait le calcul :


dd if=3 bs=1 skip=$((0x2015)) count=$((0x31)) of=bytecode.enc 2>/dev/null

le bytecode est chiffré avec XOR 0xA5 :



python3 - <<'PY'
data=open('bytecode.enc','rb').read()
decrypted = bytes(b ^ 0xA5 for b in data)
print(decrypted.hex())
PY


Résultat hex :

01005301017601027401035a01045101055a01066a01075701087101096c010a77010b43010c75010d47010e61010f63ff

 analyse du bytecode : 

 on voit une suite d'instructions qui commence par 0x01, qui est probablement une instruction "check" de la forme :

 01 <index> <valeur>

reconstruction du flag
on extrait les paires index / valeur, puis on convertit les valeurs ASCII :

le flag trouvé : SvtZQZjWqlwCuGac
