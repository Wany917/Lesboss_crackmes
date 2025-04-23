# Crackme 01 - Machine Virtuelle Personnalisée

## Description
Ce crackme implémente une machine virtuelle simple qui exécute un bytecode personnalisé pour valider l'entrée utilisateur. Le mot de passe correct est caché dans le bytecode et la logique de validation.

## Niveau de difficulté
Difficile

## Mécanismes de protection
- Interpréteur de bytecode personnalisé
- Set d'instructions défini sur mesure
- Algorithme de validation implémenté en bytecode
- Valeurs attendues encodées
- Génération dynamique du flag unique

## Mot de passe
Le mot de passe attendu est `V1RTU4L_M4CH1N3!`

## Flag
Lorsque le mot de passe correct est entré, le programme génère et affiche un flag unique au format `HTB{...}`. Ce flag est différent du mot de passe et est obtenu par déchiffrement de données encodées.

## Compilation
```bash
nasm -f elf64 vm_crackme.s -o vm_crackme.o
ld vm_crackme.o -o vm_crackme
```

## Utilisation
```bash
./vm_crackme
# Saisir le mot de passe quand demandé
```

## Architecture Modulaire
Le code est organisé selon une architecture modulaire:

1. **Module d'Entrée/Sortie**: Gestion des interactions utilisateur
2. **Module VM**: Implémentation de la machine virtuelle
   - Initialisation de la VM
   - Exécution des instructions bytecode
   - Gestion des registres et drapeaux
3. **Module de Validation**: Vérification du résultat de la VM
4. **Module de Génération de Flag**: Génère un flag unique lorsque la validation réussit

## Opcodes de la VM
- `0x01`: LOAD - Charge une valeur dans un registre
- `0x02`: STORE - Stocke une valeur en mémoire
- `0x03`: XOR - Opération XOR entre registres
- `0x04`: ADD - Addition entre registres
- `0x05`: SUB - Soustraction entre registres
- `0x06`: ROTATE - Rotation des bits d'un registre
- `0x07`: CMP - Compare deux registres
- `0x08`: JNE - Saut si non égal
- `0x09`: JMP - Saut inconditionnel
- `0xFF`: HALT - Arrêt de la VM

## Challenge
Le véritable défi consiste à comprendre et inverser le fonctionnement de la VM, à analyser le bytecode qu'elle exécute, et à déterminer quel mot de passe produira une validation réussie, ce qui permettra d'obtenir le flag unique.

## Indices
- Le flag fait exactement 16 caractères
- Regardez comment le bytecode transforme chaque caractère d'entrée
- Les transformations appliquées impliquent XOR et rotation de bits 