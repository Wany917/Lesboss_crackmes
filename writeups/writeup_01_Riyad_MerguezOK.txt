Writeup: Crackme Riyad Merguez


Analyse initiale


J'ai commencé par examiner le fichier avec la commande file pour identifier son type:
bashfile "Riyad Merguez"
Le résultat a montré qu'il s'agissait d'un exécutable ELF 64-bit pour système Linux.
Désassemblage du binaire
J'ai utilisé objdump pour désassembler le binaire et mieux comprendre son fonctionnement:
objdump -d "Riyad Merguez" > disassembly.txt

En analysant le code désassemblé, j'ai trouvé plusieurs éléments intéressants:


Le programme lit 17 octets (0x11) depuis l'entrée standard (syscall à l'adresse 0x401017)
Il vérifie que le dernier caractère est un saut de ligne (0x0A) à l'adresse 0x40101f
À l'adresse 0x401029, il charge la valeur 0x10 (16) dans ecx, ce qui suggère que le flag a une longueur de 16 caractères
Le programme compare l'entrée utilisateur avec un contenu stocké à l'adresse 0x402000 (adresse chargée dans rdi à 0x401036)

Identification du flag

Pour trouver le flag stocké dans le binaire, j'ai examiné la section .data:
objdump -s -j .data "Riyad Merguez"

Ce qui a retourné:

Contents of section .data:
 402000 6772314c 6c616433 734d3372 6775657a  gr1Llad3sM3rguez
 402010 00476f6f 64204a6f 62210a42 6164204a  .Good Job!.Bad J
 402020 6f62210a                             ob!.

                                                                     

J'ai pu identifier directement le flag dans la première ligne: gr1Llad3sM3rguez


Vérification


Pour confirmer, j'ai exécuté le programme et entré ce flag:

Le programme a affiché "Good Job!", confirmant que le flag était correct.


Conclusion
Le crackme "Riyad Merguez" stockait le flag directement dans sa section .data à l'adresse 0x402000. L'analyse du désassemblage a montré que le programme fait une simple comparaison entre l'entrée utilisateur et cette valeur stockée. 
Le flag est gr1Llad3sM3rguez.