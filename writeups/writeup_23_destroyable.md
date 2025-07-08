WRITEUP : DESTROYABLE 

1. Première reconnaissance

file Destroyable
Destroyable: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

le binaire est ELF 64, statique et non-stripé : on garde les symboles et les offsets exactes

2. On repère la section .data

readelf -S Destroyable | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000

Adresse virtuelle .data : 0x402000

Offset dans le fichier : 0x2000

Taille : 0x28 (40) octet

On examine le contenu : 

xxd -s 0x2000 -l 0x28 Destroyable
00002000: 476f 6f64 204a 6f62 210a 4261 6420 5061  Good Job!.Bad Pa
00002010: 7373 776f 7264 210a eed8 decf d8c9 fbd1  ssword!.........
00002020: dcda 8d84 858a 8b88  

Les 24 premiers octets contiennent les messages Good Job! et Bad Password!

Les 16 octets restants (adresse virtuelle 0x402018, offset 0x2018) forment vraisemblablement le flag chiffré :

EE D8 DE CF D8 C9 FB D1 DC DA 8D 84 85 8A 8B 88

a l’entrée (0x401000) :

mov    eax,0             ; sys_read
mov    edi,0             ; STDIN
mov    rsi,0x402028      ; buffer
mov    edx,0x20
syscall
cmp    rax,0x11          ; 17 octets attendus (16 + '\n')
jne    bad


Puis deux boucles :

déchiffrement du flag (rsi = 0x402018, rdi = 0x402048, ecx = 16)


L1:
  mov  al,[rsi]       ; octet chiffré
  not  al             ; bitwise NOT
  xor  al,0x42        ; XOR 0x42
  mov  [rdi],al       ; écrit l'octet déchiffré
  inc  rsi
  inc  rdi
  loop L1

Comparaison des 16 octets tapés avec le flag décodé ; tout écart ou “\n” prématuré déclenche Bad Password!.

Formule : flag[i] = (~enc[i] & 0xFF) ^ 0x42


On décode le flag avec un script python : 

python3 - <<'PY'
enc = bytes.fromhex('eed8decfd8c9fbd1dcda8d84858a8b88')
flag = bytes((~b & 0xff) ^ 0x42 for b in enc)
print(flag.decode())
PY

>>> 'PY'
... enc = bytes.fromhex('eed8decfd8c9fbd1dcda8d84858a8b88')
... flag = bytes((~b & 0xff) ^ 0x42 for b in enc)
... print(flag.decode())
... PY
... 
SecretFlag098765     --> correspond au flag trouvé.
