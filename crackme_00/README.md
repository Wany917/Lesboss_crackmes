# Crackme 00 - Validateur de Transformation Matricielle

## Description
Ce crackme simule un mécanisme de protection basé sur des transformations matricielles. L'entrée utilisateur est traitée comme une matrice 4x4 et subit plusieurs transformations mathématiques avant d'être validée.

## Niveau de difficulté
Moyen

## Mécanismes de protection
- Validation basée sur la transformation de matrices
- Algorithme de rotation matricielle
- Opérations XOR avec des clés statiques
- Pas de stockage en clair du mot de passe
- Génération dynamique du flag unique

## Mot de passe
Le mot de passe attendu est `MATR1X_TR4NSF0RM`

## Flag
Lorsque le mot de passe correct est entré, le programme génère et affiche un flag unique au format `HTB{...}`. Ce flag est différent du mot de passe et est obtenu par déchiffrement de données encodées.

## Compilation
```bash
nasm -f elf64 matrix_validator.s -o matrix_validator.o
ld matrix_validator.o -o matrix_validator
```

## Utilisation
```bash
./matrix_validator
# Saisir le mot de passe quand demandé
```

## Architecture Modulaire
Le code est organisé selon une architecture modulaire:

1. **Module d'Entrée/Sortie**: Gestion des interactions utilisateur
2. **Module de Transformation**: Opérations matricielles sur l'entrée
   - Initialisation de la matrice
   - Rotation de la matrice
   - Transformation XOR
3. **Module de Validation**: Comparaison avec la matrice attendue
4. **Module de Génération de Flag**: Génère un flag unique lorsque la validation réussit

## Challenge
Le véritable défi consiste à comprendre les transformations appliquées à l'entrée et à déterminer quel mot de passe produira une validation réussie, ce qui permettra d'obtenir le flag unique.

## Indices
- Le flag fait exactement 16 caractères
- Pensez aux opérations mathématiques classiques sur les matrices 4x4
- Les transformations sont appliquées séquentiellement 