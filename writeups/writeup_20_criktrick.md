Writeup : CRIKTRICK

$ file criktrick 
criktrick: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
                                                                                                  


Construction d’une table secrète :	lea rsi, 0x40117c & lea rdi, 0x4033d8, puis une boucle qui copie 16 octets en les xXORant


4010b3:       48 8d 34 25 7c 11 40    lea    rsi,ds:0x40117c
4010ba:       00                                                                                                  
4010bb:       48 8d 3c 25 d8 33 40    lea    rdi,ds:0x4033d8

Comparaison	lea rsi, 0x4033b8 (entrée) vs lea rdi, 0x4033d8 (table), boucle cmp al, bl ---> Good/Bad


4010dc:       48 8d 34 25 b8 33 40    lea    rsi,ds:0x4033b8


etape 3: Trouver le tableau caché : 

on voit que le programme fait une boucle avec des XOR :


  4010c8:       8a 06                   mov    al,BYTE PTR [rsi]
  4010ca:       34 33                   xor    al,0x33
  4010cc:       34 5a                   xor    al,0x5a
  4010ce:       34 42                   xor    al,0x42
  4010d0:       34 55                   xor    al,0x55
  4010d2:       88 07                   mov    BYTE PTR [rdi],al

  Ces XOR sont associatifs donc :


0x33 ^ 0x5A ^ 0x42 ^ 0x55 = 0x7E


Donc le programme XOR chaque octet d’un tableau avec 0x7E.

Ce tableau est à l’adresse 0x40117c : 


On va afficher le contenu brut à l’adresse 0x40117
objdump -s -j .text ./criktrick | less : 

54490720  ......<.....TI. 
 401180 0a4a424c 1c08495b 544c5d1b

petit script python pour trouver le flag : 

secret = bytes.fromhex("54 49 07 20 0a 4a 42 4c 1c 08 49 5b 54 4c 5d 1b")
flag = ''.join(chr(b ^ 0x7E) for b in secret)
print("Flag :", flag)


En lancant le scriptle flag est : Flag : *7y^t4<2bv7%*2#e
