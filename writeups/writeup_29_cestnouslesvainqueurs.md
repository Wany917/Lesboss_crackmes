Write-up : C'estnouslesvainqueurs

                                                               
┌──(kali㉿kali)-[~/Downloads]
└─$ file Cestnouslesvainqueurs
Cestnouslesvainqueurs: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

(kali㉿kali)-[~/Downloads]
└─$ objdump -t Cestnouslesvainqueurs | less


En analysant la table des symboles :


Cestnouslesvainqueurs:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 Cestnouslesvainqueurs.o
0000000000402000 l       .data  0000000000000000 msg_good
000000000000000a l       *ABS*  0000000000000000 msg_good_len
000000000040200a l       .data  0000000000000000 msg_bad
000000000000000e l       *ABS*  0000000000000000 msg_bad_len
0000000000402018 l       .data  0000000000000000 perm_table
0000000000402028 l       .data  0000000000000000 encrypted_flag
0000000000402038 l       .data  0000000000000000 decoder_encrypted
000000000000001a l       *ABS*  0000000000000000 decoder_len
0000000000402083 l       .bss   0000000000000000 input_buffer
00000000004020c3 l       .bss   0000000000000000 work_buffer
0000000000401035 l       .text  0000000000000000 check_length
000000000040110e l       .text  0000000000000000 fail_exit
0000000000401088 l       .text  0000000000000000 decode_loop
00000000004010ba l       .text  0000000000000000 compare_loop
0000000000401102 l       .text  0000000000000000 success_exit
0000000000402052 l       .data  0000000000000000 fake_data
0000000000401000 g       .text  0000000000000000 _start
0000000000402083 g       .bss   0000000000000000 __bss_start
0000000000402083 g       .data  0000000000000000 _edata
00000000004020e8 g       .bss   0000000000000000 _end


(END)

0000000000402028 l       .data  0000000000000000 encrypted_flag   nous saute aux yeux.

Convertion de l’adresse virtuelle en offset fichier : 

─(kali㉿kali)-[~/Downloads]
└─$ readelf -S Cestnouslesvainqueurs | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000


──(kali㉿kali)-[~/Downloads]
└─$ readelf -s Cestnouslesvainqueurs | grep encrypted_flag
     7: 0000000000402028     0 NOTYPE  LOCAL  DEFAULT    2 encrypted_flag


data_vma = 0x402000

data_off = 0x2000

sym_addr = 0x402028


Convertir adresse → offset fichier : 

file_offset = (sym_addr - data_vma) + data_off
            = (0x402028 - 0x402000) + 0x2000
            =              0x28     + 0x2000
            = 0x2028


Extraction des 16 octets : 

(kali㉿kali)-[~/Downloads]
└─$ xxd -g1 -s 0x2028 -l 16 Cestnouslesvainqueurs
00002028: 19 12 1b 17 0a 13 15 14 17 15 14 1c 08 1f 08 1f  ................

Bruteforce XOR : 

avec script python : 

┌──(kali㉿kali)-[~/Downloads]
└─$ python3                                                                                                                                                                             
Python 3.13.3 (main, Apr 10 2025, 21:38:51) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> cipher = bytes([
...     0x19, 0x12, 0x1B, 0x17, 0x0A, 0x13, 0x15, 0x14,
...     0x17, 0x15, 0x14, 0x1C, 0x08, 0x1F, 0x08, 0x1F
... ])
... for k in range(256):
...     p = bytes(b ^ k for b in cipher)
...     if all(32 <= c < 127 for c in p):
...         print(hex(k), p.decode())



0x5a CHAMPIONMONFRERE


Le flag trouvé est CHAMPIONMONFRERE