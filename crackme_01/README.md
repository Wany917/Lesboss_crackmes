# Crackme 01 - Machine Virtuelle Personnalisée

## Description
Ce crackme implémente une machine virtuelle simple qui exécute un bytecode personnalisé pour valider l'entrée utilisateur. Le mot de passe correct est caché dans le bytecode et la logique de validation.

## Niveau de difficulté
Moyen : - Ce crackme nécessite une compréhension du fonctionnement des machines virtuelles et l'analyse du bytecode.

## Caractéristiques techniques

Machine virtuelle: Interprète un jeu d'instructions simplifié
Bytecode personnalisé: Code-octet spécifique qui effectue les opérations de vérification
Jeu d'instructions minimaliste: LOAD, COMPARE, JUMP, XOR, ADD, HALT
Registres virtuels: Ensemble de registres utilisés par le bytecode

## Mot de passe
Le mot de passe attendu est `V1RTU4LLM4CH1N3E`

## Instructions supportées

LOAD reg, val - Charge une valeur dans un registre
COMPARE reg, val - Compare le contenu d'un registre avec une valeur
JUMP offset - Saute à un offset spécifié dans le bytecode
XOR reg, val - Effectue un XOR sur un registre avec une valeur
ADD reg, val - Ajoute une valeur à un registre
HALT - Arrête l'exécution

## Compilation

nasm -f elf64 vm_crackme.s -o vm_crackme.o
ld vm_crackme.o -o vm_crackme

## Utilisation

./vm_crackme


## Approche de reverse engineering

Pour résoudre ce crackme, un reverse engineer devra:

Comprendre le fonctionnement de la machine virtuelle implémentée
Analyser le bytecode pour déterminer les comparaisons effectuées
Reconstruire le mot de passe attendu à partir des opérations COMPARE
Soumettre le mot de passe correct: "V1RTU4LLM4CH1N3E"