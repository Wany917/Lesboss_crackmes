Write-up : « brrr_brrr_patapim »

reconnaissance rapide du binaire

file brrr_brrr_patapim

brrr_brrr_patapim: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, with debug_info, not stripped

On cherche les données intéressantes : 

readelf -S brrr_brrr_patapim | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000

  | Paramètre | Valeur       |
| --------- | ------------ |
| VA .data  | **0x402000** |
| Offset    | **0x2000**   |
| Taille    | 0x38 (= 56)  |


dump de la section :

$ xxd -s 0x2000 -l 0x38 brrr_brrr_patapim
00002000: 0001 0203 0405 0607 0809 0a0b 0c0d 0e0f  ................
00002010: 181b 1669 0813 141b 196e 0a0f 196b 146e  ...i.....n...k.n
00002020: 476f 6f64 204a 6f62 210a 4261 6420 5061  Good Job!.Bad Pa
00002030: 7373 776f 7264 210a                      ssword!.
                             

Les 16 premiers octets 00 01 … 0F correspondent à la variable perm

Les 16 octets suivants (adresse 0x402010) sont enc_flag

Puis suivent les messages Good Job! et Bad Password!



 Il faut comprendre l’algorithme de décodage : 

 Un coup d'oeil au désassemblage (symbole _start.decode_loop) :

 0000000000401071 <_start.decode_loop>:
  401071:       ac                      lods   %ds:(%rsi),%al
  401072:       34 aa                   xor    $0xaa,%al
  401074:       aa                      stos   %al,%es:(%rdi)
  401075:       e2 fa                   loop   401071 <_start.decode_loop>
  401077:       48 31 c9                xor    %rcx,%rcx

Cette boucle déchiffre un second morceau de code qui est (stocké entre

flag_decoder_enc et flag_decoder_end) en lui appliquant un XOR 0xAA

Le code ainsi reconstruit est lui-même un mini-décoder :


xor     rcx,rcx
decode_loop:

    movzx eax, byte [rdx + rcx]        -->   eax = perm[i]
    mov    bl,  byte [rsi + rcx]       -->  bl  = enc_flag[i]
    xor    bl, 0x5A                    -->  décodeur 2
    mov    [rdi + rax], bl             -->   flag[perm[i]] = bl
    inc    rcx
    cmp    rcx, 0x10
    jne    decode_loop
    ret


perm est simplement la suite 0..15 donc y'a aucune permutation réelle.

la véritable opération est donc :


flag[i] = enc_flag[i] XOR 0x5A


script python pour trouver  le flag : 

<<'PY'
enc = bytes.fromhex('181b16690813141b196e0a0f196b146e')
flag = bytes(b ^ 0x5A for b in enc)
print(flag.decode())
PY

>>> 'PY'
... enc = bytes.fromhex('181b16690813141b196e0a0f196b146e')
... flag = bytes(b ^ 0x5A for b in enc)
... print(flag.decode())
... PY
... 


BAL3RINAC4PUC1N4  est le bon flag trouvé