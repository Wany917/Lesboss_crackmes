WRITEUP : Crackstation 

Infos générales : 


file crackstation 
crackstation: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped

on repère le décrypteur dans le desassembleur : 



objdump -d -M intel crackstation | less


crackstation:     file format elf64-x86-64

objdump -h crackstation

crackstation:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000110  0000000000401000  0000000000401000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         00000068  0000000000402000  0000000000402000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
                                                                  


Disassembly of section .text:

0000000000401000 <.text>:
  401000:       b8 65 00 00 00          mov    $0x65,%eax
  401005:       bf 00 00 00 00          mov    $0x0,%edi
  40100a:       48 31 f6                xor    %rsi,%rsi
  40100d:       48 31 d2                xor    %rdx,%rdx
  401010:       4d 31 d2                xor    %r10,%r10
  401013:       0f 05                   syscall
  401015:       48 83 f8 00             cmp    $0x0,%rax
  401019:       0f 85 bf 00 00 00       jne    0x4010de
  40101f:       48 31 c9                xor    %rcx,%rcx
  401022:       8a 81 00 20 40 00       mov    0x402000(%rcx),%al
  401028:       34 aa                   xor    $0xaa,%al
  40102a:       88 81 00 20 40 00       mov    %al,0x402000(%rcx)
  401030:       48 ff c1                inc    %rcx


   401033:       48 83 f9 10             cmp    $0x10,%rcx
  401037:       7c e9                   jl     0x401022
  401039:       b8 00 00 00 00          mov    $0x0,%eax

 Cela indique que les 16 premiers octets de la section .data sont déchiffrés avec un XOR 0xAA.

Puis le programme lit l’entrée utilisateur

Les caractères sont comparés directement à ceux du tableau déchiffré



On récupère les 16 premiers octets de .data (avant déchiffrement) :

objdump -s -j .data crackstation   

crackstation:     file format elf64-x86-64




Contents of section .data:
 402000 89f8e989 e1c5c0dd f8e0faf9 dd89e9e7  ................
 402010 476f6f64 204a6f62 210a4261 64205061  Good Job!.Bad Pa
 402020 7373776f 7264210a 00000000 00000000  ssword!.........
 402030 00000000 00000000 00000000 00000000  ................
 402040 00000000 00000000 00000000 00000000  ................
 402050 00000000 00000000 00000000 00000000  ................
 402060 00000000 00000000                    ........     



Chaque octet est XORé avec 0xAA :



┌──(kali㉿kali)-[~/Downloads]
└─$ python3
Python 3.13.2 (main, Mar 13 2025, 14:29:07) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> encoded = bytes.fromhex("89f8e989e1c5c0ddf8e0faf9dd89e9e7")
... flag = bytes(b ^ 0xAA for b in encoded)
... print(flag.decode())
... 
#RC#KojwRJPSw#CM
>>> 
>>> 

Le flag est : #RC#KojwRJPSw#CM