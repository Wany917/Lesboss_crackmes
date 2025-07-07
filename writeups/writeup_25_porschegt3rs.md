WRITEUP PORSCHE GT3 RS : 

Reconnaissance du binaire : 

$ file Porsche_GT3_RS
Porsche_GT3_RS: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

$ readelf -S Porsche_GT3_RS | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000

| Champ                  | Valeur           |
| ---------------------- | ---------------- |
| VA (.data)             | **0x402000**     |
| Offset dans le fichier | **0x2000**       |
| Taille                 | 0x55 (85 octets) |


Trouver les 16 octets suspects : 

$ xxd -s 0x2000 -l 0x55 Porsche_GT3_RS
00002000: 456e 7465 7220 7061 7373 776f 7264 3a20  Enter password: 
00002010: 0042 6164 206c 656e 6774 680a 004e 6f20  .Bad length..No 
00002020: 6465 6275 6767 6572 210a 0047 6f6f 6420  debugger!..Good 
00002030: 4a6f 6221 0a00 4261 6420 5061 7373 776f  Job!..Bad Passwo
00002040: 7264 210a 00b5 aa0e e606 1f55 4ec3 28e8  rd!........UN.(.
00002050: c3a4 fe54 6a                             ...Tj
                                
Les derniers 16 octets (offset fichier 0x2045, VA 0x402045) semblent pas être imprimables : c’est notre enc_flag.                               


b5 aa 0e e6 06 1f 55 4e c3 28 e8 c3 a4 fe 54 6a


désassemblage et compréhension

On veut trouver du code qui lit 0x402045. 

objdump -d Porsche_GT3_RS | grep "402045"
On obtiens :

401069: mov 0x402045(%r13), %dl

le flag chiffré est lu octet par octet, avec r13 servant d’index.

on desassemble autour :


objdump -d --start-address=0x401050 --stop-address=0x401090 Porsche_GT3_RS

Résumé de la boucle trouvée

cmp     r13, 0x10               si i == 16 → fin
mov     dl, [0x402045 + r13]    enc_flag[i]
sub     dl, 0x5
mov     rcx, r13
imul    rcx, rcx, 3
add     rcx, 1
and     cl, 7
ror     dl, cl
mov     rax, r13
imul    rax, rax, 0x0D
add     rax, 7
mov     bl, al
xor     dl, bl                 flag[i] = ..


reconstitution de l'algorithme

voici la formule :


x = (enc_flag[i] - 0x5) & 0xFF
s = (3 * i + 1) & 0x7
x = ROR(x, s)
k = (13 * i + 7) & 0xFF
flag[i] = x ^ k




script de déchiffrement en python : 

enc = bytes.fromhex('b5aa0ee6061f554ec328e8c3a4fe546a')
flag = bytearray()
for i, b in enumerate(enc):
    x = (b - 0x5) & 0xFF
    s = (3 * i + 1) & 0x7
    x = ((x >> s) | (x << (8 - s))) & 0xFF
    k = (13 * i + 7) & 0xFF
    flag.append(x ^ k)
print(flag.decode())


Le flag trouvé est : _N3V3R_G0NN9_IT_
