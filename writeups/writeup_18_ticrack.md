WRITEUP TICRACK : 


Infos générales : 


file ticrack     
ticrack: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped

chmod +x ticrack


objdump -d -M intel ticrack | less


ticrack:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <.text>:
  401000:       b8 39 00 00 00          mov    eax,0x39
  401005:       0f 05                   syscall
  401007:       48 85 c0                test   rax,rax
  40100a:       0f 88 23 01 00 00       js     0x401133
  401010:       0f 84 29 01 00 00       je     0x40113f
  401016:       48 89 c7                mov    rdi,rax
  401019:       b8 3e 00 00 00          mov    eax,0x3e
  40101e:       48 31 f6                xor    rsi,rsi
  401021:       0f 05                   syscall
  401023:       48 89 f0                mov    rax,rsi
  401026:       48 83 e0 7f             and    rax,0x7f
  40102a:       48 83 f8 00             cmp    rax,0x0
  40102e:       0f 85 ff 00 00 00       jne    0x401133
  401034:       48 c1 ee 08             shr    rsi,0x8
  401038:       40 80 fe 01             cmp    sil,0x1
  40103c:       0f 84 f1 00 00 00       je     0x401133
  401042:       48 8d 35 3a 01 00 00    lea    rsi,[rip+0x13a]        # 0x401183
  401049:       48 8d 3d c8 0f 00 00    lea    rdi,[rip+0xfc8]        # 0x402018
  401050:       b9 10 00 00 00          mov    ecx,0x10
  401055:       48 31 db                xor    rbx,rbx
  401058:       8a 04 1e                mov    al,BYTE PTR [rsi+rbx*1]
  40105b:       34 13                   xor    al,0x13
  40105d:       88 04 1f                mov    BYTE PTR [rdi+rbx*1],al


.....


en analysant cela on remarque : 

deux boucles successives :

XOR 0x13 sur 16 octets situés dans le .text (0x401183 – 0x401192)
résultat copié en .bss à 0x402018.

ADD 0x5 sur ces mêmes 16 octets
résultat final copié à 0x402028.


donc le bon mot de passe est exactement les 16 octets produits par les deux transformations :

On extrait l'empreinte de départ : 


L’adresse virtuelle : 0x401183
.text commence à 0x401000, offset fichier 0x1000.



dd if=ticrack bs=1 skip=$((0x1183)) count=16 of=enc.bin 2>/dev/null
hexdump -C enc.bin
00000000  32 78 0d 22 22 53 27 2c  7b 4a 52 55 61 7f 32 79  |2x.""S',{JRUa.2y|
00000010


On reproduit les deux opérations en Python :: 

python3 - <<'PY'
enc = open("enc.bin","rb").read()
step1 = bytes(b ^ 0x13 for b in enc)       #XOR 0x13
flag  = bytes((b + 5) & 0xff for b in step1)  #+5
print(flag.decode())
PY


&p#66E9Dm^FKwq&o

Le bon flag trouvé : &p#66E9Dm^FKwq&o