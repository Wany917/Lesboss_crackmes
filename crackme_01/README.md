# Machine Virtuelle Personnalisée

## Description

Ce crackme implémente une machine virtuelle simple pour valider le mot de passe. Il interprète un bytecode personnalisé qui effectue la vérification caractère par caractère.

## Caractéristiques techniques

- **Machine virtuelle**: Interprète un jeu d'instructions simplifié
- **Bytecode personnalisé**: Code-octet spécifique qui effectue les opérations de vérification
- **Jeu d'instructions minimaliste**: LOAD, COMPARE, JUMP, XOR, ADD, HALT
- **Registres virtuels**: Ensemble de registres utilisés par le bytecode

## Niveau de difficulté

**Moyen** - Ce crackme nécessite une compréhension du fonctionnement des machines virtuelles et l'analyse du bytecode.

## Instructions supportées

- `LOAD reg, val` - Charge une valeur dans un registre
- `COMPARE reg, val` - Compare le contenu d'un registre avec une valeur
- `JUMP offset` - Saute à un offset spécifié dans le bytecode
- `XOR reg, val` - Effectue un XOR sur un registre avec une valeur
- `ADD reg, val` - Ajoute une valeur à un registre
- `HALT` - Arrête l'exécution

## Indices

- Le bytecode vérifie chaque caractère du mot de passe séquentiellement
- Chaque opération COMPARE est suivie d'une opération JUMP
- Le registre r1 est utilisé pour stocker le résultat final (1 = succès, 0 = échec)

## Compilation

```bash
nasm -f elf64 vm_crackme.s -o vm_crackme.o
ld vm_crackme.o -o vm_crackme
```

## Utilisation

```bash
./vm_crackme
```

## Approche de reverse engineering

Pour résoudre ce crackme, un reverse engineer devra:

1. Comprendre le fonctionnement de la machine virtuelle implémentée
2. Analyser le bytecode pour déterminer les comparaisons effectuées
3. Reconstruire le mot de passe attendu à partir des opérations COMPARE
4. Soumettre le mot de passe correct: "V1RTU4L_M4CH1N3!"
