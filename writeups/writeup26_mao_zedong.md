WRITEUP MAO ZEDONG : 

$ file mao\ zedong
mao zedong: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
                                                                                                     

Repérage de la section .data : 

$ readelf -S mao\ zedong | grep '\.data

$ readelf -S mao\ zedong | grep '\.data'
  [ 2] .data             PROGBITS         0000000000402000  00002000
                                                   
| Champ                     | Valeur           |
| ------------------------- | ---------------- |
| Adresse virtuelle (.data) | **0x402000**     |
| Offset dans le fichier    | **0x2000**       |
| Taille                    | 0x48 (72 octets) |


En consultant la section .data, on remarque qu'une séquence de 48 octets non imprimables précède les chaînes classiques "Good Job!" et "Bad Password!



$ xxd -s 0x2000 -l 0x48 mao\ zedong
00002000: e697 97e8 af95 e696 87e4 b8ad e9a3 8ee6  ................
00002010: b0b4 e794 b5e7 a791 e5af 86e7 a081 e5ad  ................
00002020: a6e4 b9a0 e9a9 ace9 be99 e899 8ee4 ba91  ................
00002030: 476f 6f64 204a 6f62 210a 4261 6420 5061  Good Job!.Bad Pa
00002040: 7373 776f 7264 210a                      ssword!.

Ces octets ne correspondent ni à du texte ASCII, ni à une suite chiffrée classique. On remarque aussi qu’ils ont une structure typique de l’UTF-8 :

Il y a beaucoup de octets commençant par e6, e7, e9, e5, etc. (courant en UTF-8 chinois/japonais coréen).

Une longueur de 48 octets, qui est un multiple de 3 → ça correspondrait à 16 caractères UTF-8 encodés sur 3 octets chacun.

Hypothèse : flag = texte chinois encodé en UTF-8
Pour valider cette hypothèse, on réinterprète les octets comme de l’UTF-8 :

$ xxd -p -s 0x2000 -l 0x30 mao\ zedong | tr -d '\n' | xxd -r -p | iconv -f UTF-8 -t UTF-8   (0x30 pour ne pas inclure d'autres chaines mais seulement le flag attendu)
旗试文中风水电科密码学习马龙虎云     

les 48 octets situés entre 0x402000 et 0x40202f sont un texte UTF-8 chinois composé de 16 caractères

les messages Good Job! et Bad Password! ils suivent immédiatement


objdump -d mao\ zedong | less

  40100a:       48 be 48 20 40 00 00    movabs $0x402048,%rsi
  401011:       00 00 00 
  401014:       ba 31 00 00 00          mov    $0x31,%edx
  401019:       0f 05                   syscall
  40101b:       48 89 c1                mov    %rax,%rcx
  40101e:       80 b9 47 20 40 00 0a    cmpb   $0xa,0x402047(%rcx)
  401025:       75 03                   jne    40102a <_start.no_newline>
  401027:       48 ff c9                dec    %rcx

000000000040102a <_start.no_newline>:
  40102a:       48 83 f9 30             cmp    $0x30,%rcx

0000000000401033 <compare_loop>:
  401033:       8a 83 48 20 40 00       mov    0x402048(%rbx),%al
  401039:       3a 83 00 20 40 00       cmp    0x402000(%rbx),%al
  40103f:       75 2e                   jne    40106f <mismatch>
  401041:       48 ff c3                inc    %rbx
  401044:       48 83 fb 30             cmp    $0x30,%rbx
  401048:       7c e9                   jl     401033 <compare_loop>

Aucune opération de déchiffrement :

le programme compare directement les 48 octets lus avec ceux stockés en .data
le mdp attendu est donc exactement la séquence UTF-8 repérée plutôt :

旗试文中风水电科密码学习马龙虎云 