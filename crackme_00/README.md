# Matrix Transformation Validator

## Présentation

Ce crackme traite l'entrée utilisateur (un mot de passe de 16 caractères) comme une matrice 4x4 et lui applique des transformations mathématiques pour la valider. Il s'agit d'un défi de difficulté moyenne conçu pour explorer les concepts de transformation matricielle.

## Difficulté

**Niveau**: Moyen

## Mécanismes de protection

-Traitement de l'entrée utilisateur comme une matrice 4x4
-Transformations mathématiques basées sur la position
-Rotation de la matrice
-Multiplication matricielle avec matrice de transformation
-Opérations XOR dynamiques

## Mot de passe
Le mot de passe attendu est `M4TR1XXTR4NSF0RM`



## Compilation

nasm -f elf64 matrix_validator.s -o matrix_validator.o
ld matrix_validator.o -o matrix_validator


## Utilisation

./matrix_validator
# Saisir le mot de passe quand demandé

## Challenge
Le véritable défi consiste à comprendre les transformations appliquées à l'entrée et à déterminer quel mot de passe produira une validation réussie, ce qui permettra de résoudre le défi.

## Indices
- Le flag fait exactement 16 caractères
- Pensez aux opérations mathématiques classiques sur les matrices 4x4
- Les transformations sont appliquées séquentiellement 

## Indications

La matrice d'entrée subit plusieurs transformations:
XOR position-dépendant
Rotation de 90 degrés
Multiplication avec une matrice de transformation
Ajout d'une constante
La matrice finale doit correspondre à la matrice cible
