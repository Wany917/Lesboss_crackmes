
Writeup KIRIVACHE : 

Analyse rapide : 

$ file KiriVache    

KiriVache: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped


Outils utilisés : objdump -h, objdump -d -M intel, un petit script Python.


Carto rapide du binaire : 

$ objdump -h KiriVache

KiriVache:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000292  0000000000401000  0000000000401000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         0000004a  0000000000402000  0000000000402000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000304  000000000040204c  000000000040204c  0000204a  2**2
                  ALLOC


On désassemble le programme : 

objdump -d -Mintel KiriVache > disas.txt
less disas.txt

Cela va permettre d'analyser le code assembleur, identifier les appels système (read, write) et voir comment le mot de passe est traité.


KiriVache:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <.text>:
  401000:       b8 00 00 00 00          mov    eax,0x0
  401005:       bf 00 00 00 00          mov    edi,0x0
  40100a:       48 be 4c 20 40 00 00    movabs rsi,0x40204c
  401011:       00 00 00 
  401014:       ba ff 00 00 00          mov    edx,0xff
  401019:       0f 05                   syscall
  40101b:       48 85 c0                test   rax,rax
  40101e:       0f 8e 89 00 00 00       jle    0x4010ad
  401024:       b9 00 00 00 00          mov    ecx,0x0
  401029:       48 bf 4c 20 40 00 00    movabs rdi,0x40204c
  401030:       00 00 00 
  401033:       80 3c 0f 0a             cmp    BYTE PTR [rdi+rcx*1],0xa
  401037:       74 11                   je     0x40104a
  401039:       80 3c 0f 00             cmp    BYTE PTR [rdi+rcx*1],0x0
  40103d:       74 0b                   je     0x40104a
  40103f:       48 ff c1                inc    rcx
  401042:       48 83 f9 10             cmp    rcx,0x10
  401046:       76 eb                   jbe    0x401033
  401048:       eb 63                   jmp    0x4010ad
  40104a:       48 83 f9 10             cmp    rcx,0x10
  40104e:       75 5d                   jne    0x4010ad
  401050:       80 3c 0f 0a             cmp    BYTE PTR [rdi+rcx*1],0xa
  401054:       75 04                   jne    0x40105a
  401056:       c6 04 0f 00             mov    BYTE PTR [rdi+rcx*1],0x0
  40105a:       b8 23 00 00 00          mov    eax,0x23
  40105f:       48 bf 2a 20 40 00 00    movabs rdi,0x40202a
  401066:       00 00 00 
....

40107f:       e8 75 00 00 00          call   0x4010f9   : ; appel fonction d'obfuscation
401084:       48 be 4c 20 40 00 00    movabs rsi,0x40204c : buffer modifié
40108e:       48 bf 3a 20 40 00 00    movabs rdi,0x40203a : référence de comparaison
 401098:       b9 10 00 00 00          mov    ecx,0x10 : 


la comparaison se fait avec 16 octets stockés à l’adresse 0x40203a


On extrait la chaîne de référence (flag chiffré)

offset = 0x2000 + (0x40203a - 0x402000)
       = 0x2000 + 0x3a
       = 0x203a



──(kali㉿kali)-[~/Downloads]
└─$ xxd -s 0x203a -l 16 KiriVache

0000203a: c841 6f7a 4945 75b2 5954 6d71 4c53 6b64  .AozIEu.YTmqLSkd
                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]
└─$ 


Déobfuscation du flag : 
seuls les 8 premiers octets sont XORés avec :


r8 = 0xC000000000000098
# soit en bytes (little-endian) :
mask = 98 00 00 00 00 00 00 C0

On utilise ce code python :

python3 -c 'const=bytes.fromhex("c8416f7a494575b259546d714c536b64");mask=bytes.fromhex("98000000000000c0");print((bytes([c^m for c,m in zip(const[:8], mask)])+const[8:]).decode())'


┌──(kali㉿kali)-[~/Downloads]
└─$ python3 -c 'const=bytes.fromhex("c8416f7a494575b259546d714c536b64");mask=bytes.fromhex("98000000000000c0");print((bytes([c^m for c,m in zip(const[:8], mask)])+const[8:]).decode())'

PAozIEurYTmqLSkd
                                                                                                                                                                                    
┌──(kali㉿kali)-[~/Downloads]
└─$ 

Flag trouvé est : PAozIEurYTmqLSkd 