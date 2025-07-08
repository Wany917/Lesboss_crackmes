WRITEUP lrcrackme01 : 


Info générales : 

file lrcrackme_01

lrcrackme_01: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

chmod +x lrcrackme_01 

file indique : ELF 64-bit x86-64.

On liste les symboles utiles : 

objdump -t lrcrackme_01          

lrcrackme_01:     file format elf64-x86-64

SYMBOL TABLE:
0000000000401000 l    d  .text  0000000000000000 .text
0000000000402000 l    d  .data  0000000000000000 .data
0000000000402028 l    d  .bss   0000000000000000 .bss
0000000000000000 l    df *ABS*  0000000000000000 crackme_no_vm.s
0000000000402000 l       .data  0000000000000000 good_msg
000000000000000a l       *ABS*  0000000000000000 good_len
000000000040200a l       .data  0000000000000000 bad_msg
000000000000000e l       *ABS*  0000000000000000 bad_len
0000000000402018 l       .data  0000000000000000 flag
0000000000000042 l       *ABS*  0000000000000000 xor_key
0000000000402028 l       .bss   0000000000000000 input
0000000000401048 l       .text  0000000000000000 check_loop
000000000040105b l       .text  0000000000000000 good
0000000000401080 l       .text  0000000000000000 bad
0000000000401000 g       .text  0000000000000000 _start
0000000000402028 g       .bss   0000000000000000 __bss_start
0000000000402028 g       .data  0000000000000000 _edata
0000000000402048 g       .bss   0000000000000000 _end


objdump -t lrcrackme_01 | grep -E 'flag|xor_key|check_loop'
0000000000402018 l       .data  0000000000000000 flag
0000000000000042 l       *ABS*  0000000000000000 xor_key
0000000000401048 l       .text  0000000000000000 check_loop
                                                               

On peut noter que : 

flag est en section .data à l’adresse virtuelle 0x402018.

xor_key vaut 0x42 c'est la clé utilisé pour chiffrer/dechiffrer chaque octet


On repère l'offset de .data : 

readelf -S lrcrackme_01 | grep '\.data'

  [ 2] .data             PROGBITS         0000000000402000  00002000
                                                                          


  On peut en déduire que : 

  Donc :

base .data : VA 0x402000 → offset fichier 0x2000

flag : VA 0x402018 → offset fichier 0x2018
(0x402018 - 0x402000 + 0x2000)


Ensuite, il faut extraire les 16 octets chiffrés du flag:

dd if=lrcrackme_01 bs=1 skip=$((0x2018)) count=16 of=flag.enc 2>/dev/null
hexdump -C flag.enc

00000000  01 17 10 0b 0d 11 0b 16  1b 73 70 71 76 77 74 75  |.........spqvwtu|
00000010


enfin, il suffit de déchiffrer avec la clé XOR 0x42 avec python script :  

python3 - <<'PY'
data = open('flag.enc','rb').read()
print(bytes(b ^ 0x42 for b in data).decode())
PY

CURIOSITY1234567
                    

Le bon flag trouvé :  CURIOSITY1234567