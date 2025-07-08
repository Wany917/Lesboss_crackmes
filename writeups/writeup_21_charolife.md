WRITEUP : CHAROLIFE 

$ file Charolife 
Charolife: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped



objdump -d Charolife | less


Charolife:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <.text>:
  401000:       b8 65 00 00 00          mov    $0x65,%eax
  401005:       48 31 ff                xor    %rdi,%rdi
  401008:       0f 05                   syscall
  40100a:       b9 10 00 00 00          mov    $0x10,%ecx
  40100f:       48 be e5 10 40 00 00    movabs $0x4010e5,%rsi
  401016:       00 00 00 
  401019:       48 bf 20 20 40 00 00    movabs $0x402020,%rdi
  401020:       00 00 00 
  401023:       b0 42                   mov    $0x42,%al
  401025:       8a 1e                   mov    (%rsi),%bl
  401027:       30 c3                   xor    %al,%bl
  401029:       88 1f                   mov    %bl,(%rdi)
  40102b:       48 ff c6                inc    %rsi
  40102e:       48 ff c7                inc    %rdi
  401031:       e2 f2                   loop   0x401025
  401033:       b8 00 00 00 00          mov    $0x0,%eax
  401038:       bf 00 00 00 00          mov    $0x0,%edi
  40103d:       48 be 00 20 40 00 00    movabs $0x402000,%rsi
  401044:       00 00 00 
  401047:       ba 20 00 00 00          mov    $0x20,%edx
  40104c:       0f 05                   syscall
  40104e:       48 89 c3                mov    %rax,%rbx
  401051:       48 83 f8 10             cmp    $0x10,%rax
  401055:       74 11                   je     0x401068
  401057:       48 83 f8 11             cmp    $0x11,%rax
  40105b:       75 61                   jne    0x4010be
  40105d:       8a 04 25 10 20 40 00    mov    0x402010,%al
  401064:       3c 0a                   cmp    $0xa,%al



Points clefs repérées:


401000	mov eax,0x65 : syscall	ptrace(PTRACE_TRACEME,…) – anti-débug
40100f	movabs rsi,0x4010e5	début d’un tableau de 16 octets
401019	movabs rdi,0x402020	zone tampon dans .bss
401023	mov al,0x42	constante 0x42
boucle	xor bl,al ; mov (rdi),bl	chaque octet est XOR 0x42 puis stockée
40103d	read(0,0x402000,0x20)	lecture de  saisie
401089	comparaison octet à octet entre la saisie et 0x402020	
Si OK	impression du message : Good Job! 



Conclusion :
le flag attendu = 16 octets situés à l’adresse 0x4010e5, XORés par 0x42


$ objdump -h Charolife


Charolife:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         0000010d  0000000000401000  0000000000401000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .bss          00000030  0000000000402000  0000000000402000  00002000  2**2
                  ALLOC
                               


.text commence dans le fichier à l’offset 0x1000.
 0x4010e5 - 0x401000 = 0xE5.

Offset final dans le fichier = 0x1000 + 0xE5 = 0x10E5


Extraction des 16 octets chiffrés


xxd -s 0x10E5 -l 0x10 Charolife
000010e5: 3a1a 0e72 2572 202b 0130 2b2f 732c 762e  :..r%r +.0+/s,v.


Décodage (XOR 0x42)


python3 - <<'PY'
hex_bytes = "3a1a0e722572202b01302b2f732c762e"
raw = bytes.fromhex(hex_bytes)
flag = bytes(b ^ 0x42 for b in raw)
print(flag.decode())
PY
cela affiche :

xXL0g0biCrim1n4l

>>> hex_bytes = "3a1a0e722572202b01302b2f732c762e"
... raw = bytes.fromhex(hex_bytes)
... flag = bytes(b ^ 0x42 for b in raw)
... print(flag.decode())
... PY
... 
xXL0g0biCrim1n4l

Le flag trouvé est :xXL0g0biCrim1n4l












