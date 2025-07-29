WRITEUP : CrackBruhhv4 


(kali㉿kali)-[~/Downloads]
└─$ file CrackBruhh_v4
CrackBruhh_v4: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

Liste des sections du binaire : 


┌──(kali㉿kali)-[~/Downloads]
└─$ objdump -h ./CrackBruhh_v4


./CrackBruhh_v4:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000134  0000000000401000  0000000000401000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         0000004a  0000000000402000  0000000000402000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000014  000000000040204c  000000000040204c  0000204a  2**2
                  ALLOC
                                                                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]



Désassemblage : :
                                                         
┌──(kali㉿kali)-[~/Downloads]
└─$ objdump -D -M intel ./CrackBruhh_v4 > disas3.txt

                                                                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]
└─$ cat disas3.txt 

./CrackBruhh_v4:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <_start>:
  401000:       b8 00 00 00 00          mov    eax,0x0
  401005:       bf 00 00 00 00          mov    edi,0x0
  40100a:       48 8d 35 3b 10 00 00    lea    rsi,[rip+0x103b]        # 40204c <__bss_start>
  401011:       ba 11 00 00 00          mov    edx,0x11
  401016:       0f 05                   syscall


  ....




┌──(kali㉿kali)-[~/Downloads]
└─$ grep -n "40204c" disas.txt

10:  40100a:    48 8d 35 3b 10 00 00    lea    rsi,[rip+0x103b]        # 40204c <__bss_start>
18:  40102b:    80 b8 4c 20 40 00 0a    cmp    BYTE PTR [rax+0x40204c],0xa
20:  401034:    c6 80 4c 20 40 00 00    mov    BYTE PTR [rax+0x40204c],0x0
26:  401048:    48 8d 35 fd 0f 00 00    lea    rsi,[rip+0xffd]        # 40204c <__bss_start>
                                                                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]
└─$ 

Juste après la lecture, le programme commence systématiquement la vérif du mot de passe : c’est l’endroit à analyser.

Chercher en clair l’adresse du buffer ne sert qu’une fois :


grep -n "40204c" disas.txt

seulement 4 entrées

ensuite le code accède aux octets via RSI, donc l’adresse ne réapparaît plus.

il faut maintenant repérer la vérif par forme d’instructions, pas par une constante.

il faut trouver la boucle de hash

Pourquoi chercher « imul … rbx » ?


on s’attend à un hash (mélange + diffusion).	Les hash simples (genre : FNV-1a, DJB2, CRC homemade) font un XOR puis une multiplication ou un shift/addd

Dans du code normal, voir imul rax, rbx avec RBX constant est super rare.	Si on le voit en boucle après la lecture utilisateur,  y a 99 % de chance que ce soit un hash FNV
FNV-1a 64 bits utilise la constante 0x100000001B3

on cherche le motif xor al, dl + imul rax, rbx est donc la manière la plus fiable d’isoler la routine de hash, même si les labels sont brouillons

┌──(kali㉿kali)-[~/Downloads]
└─$ grep -n -A5 -B10 "imul.*rbx" disas.txt
24-  40103e:    49 83 f8 10             cmp    r8,0x10
25-  401042:    0f 85 c8 00 00 00       jne    401110 <poiuytrfedsqjhuyg>
26-  401048:    48 8d 35 fd 0f 00 00    lea    rsi,[rip+0xffd]        # 40204c <__bss_start>
27-  40104f:    48 8b 1d b2 0f 00 00    mov    rbx,QWORD PTR [rip+0xfb2]        # 402008 <oiuytgfdfgyhujhgfv>
28-  401056:    b9 04 00 00 00          mov    ecx,0x4
29-  40105b:    48 8b 05 9e 0f 00 00    mov    rax,QWORD PTR [rip+0xf9e]        # 402000 <zdefrgrthgygqfzfegrhtd>
30-
31-0000000000401062 <kjhgfdfghjhgfd>:
32-  401062:    8a 16                   mov    dl,BYTE PTR [rsi]
33-  401064:    30 d0                   xor    al,dl
34:  401066:    48 0f af c3             imul   rax,rbx
35-  40106a:    48 ff c6                inc    rsi
36-  40106d:    48 ff c9                dec    rcx
37-  401070:    75 f0                   jne    401062 <kjhgfdfghjhgfd>
38-  401072:    48 3b 05 97 0f 00 00    cmp    rax,QWORD PTR [rip+0xf97]        # 402010 <aqqwsxzsd>

Ce qu’on déduit de cette boucle
ecx = 4  la boucle traite 4 octets à la fois.

rbx vient d’un mov rbx,[rip+…] juste avant la boucle - c’est une constante

rax est initialisé à une autre constante avant la boucle -->> c’est la graine

Résultat : on a la signature parfaite d’un FNV-1a 64 bits appliqué sur des blocs de 4 octets.


(kali㉿kali)-[~/Downloads]
└─$ xxd -g1 -u -s 0x2000 -l 0x30 CrackBruhh_v4

00002000: 25 23 22 84 E4 9C F2 CB B3 01 00 00 00 01 00 00  %#".............
00002010: 25 2E 90 7D FA A7 D8 0E 00 64 EB E6 42 B8 DE 0D  %..}.....d..B...
00002020: C8 D1 BE 3F 2C 80 59 57 35 5A 29 10 C0 EA 55 8E  ...?,.YW5Z)...U.
                                                                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]
└─$ 

Little-endian → on renverse chaque bloc de 8 octets :

Adresse	Valeur 64 bits	Rôle
402000	0xCBF29CE484222325	OFFSET_BASIS
402008	0x100000001B3	FNV_PRIME
402010	0x0ED8A7FA7D902E25	Hash bloc 1
402018	0x0DDEB842E6EB6400	Hash bloc 2
402020	0x5759802C3FBED1C8	Hash bloc 3
402028	0x8E55EAC010295A35	Hash bloc 4



on inverse les quatre blocs de 4 octets


5-2. Script Python condensé


OFFSET = 0xCBF29CE484222325
PRIME  = 0x100000001B3
INV    = pow(PRIME, -1, 1 << 64)
targets = [0x0ED8A7FA7D902E25,
           0x0DDEB842E6EB6400,
           0x5759802C3FBED1C8,
           0x8E55EAC010295A35]
MOD = 1 << 64

def fwd2(a,b):
    h=(OFFSET^a)*PRIME&MOD-1
    h=(h^b)*PRIME&MOD-1
    return h

def solve(t):
    tb={fwd2(x,y):(x,y) for x in range(256) for y in range(256)}
    for b2 in range(256):
      for b3 in range(256):
        h3=t*INV&MOD-1
        h2=(h3^b3)*INV&MOD-1
        h2^=b2
        if h2 in tb:
          b0,b1=tb[h2]
          return bytes([b0,b1,b2,b3])

flag=b''.join(solve(t) for t in targets)
print(flag.decode()) 


Le flag trouvé est : TEST_FOUR_BLOCKS