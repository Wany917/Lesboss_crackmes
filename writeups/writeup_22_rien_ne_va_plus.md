WRITEUP CRACKME : RIEN NE VAS PLUS 


file rien_ne_va_plus

rien_ne_va_plus: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

Exécutable ELF 64 bits, statique (toutes les libc intégrées) et – bonne nouvelle – non stripé, donc la table des symboles est encore là


Un coup d’oeil aux symboles

$ nm -C rien_ne_va_plus | grep -E "flag|prompt"
00000000004010d0 t check_flag
000000000040202b d flag
000000000040105d t flag_bad
0000000000401084 t flag_good
0000000000402000 d prompt
0000000000000011 a prompt_len

La variable flag est carrément présente dans .data à l’adresse virtuelle 0x40202b.
On sait déjà : c’est probablement notre flag en clair ou (au pire) un encodage de 16 octects

On a besoin du décalage réel dans le fichier pour en extraire les octets :

readelf -S rien_ne_va_plus | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000

  Base .data : VA = 0x402000, Offset = 0x2000

Décalage entre VA et offset : 0x400000
(0x402000 – 0x2000)

donc pour l’adresse 0x40202b

File offset = 0x40202b - 0x400000 = 0x202b

On extrait les 16 octets : 

xxd -s 0x202b -l 16 rien_ne_va_plus
0000202b: 4632 304f 3346 7538 3138 5045 653b 4145  F20O3Fu818PEe;AE

Flag est : F20O3Fu818PEe;AE