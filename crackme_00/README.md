# Matrix Transformation Validator

## Présentation

Ce crackme traite l'entrée utilisateur (un mot de passe de 16 caractères) comme une matrice 4x4 et lui applique des transformations mathématiques pour la valider. Il s'agit d'un défi de difficulté moyenne conçu pour explorer les concepts de transformation matricielle.

## Difficulté

**Niveau**: Moyen

## Mécanismes de protection

- Traitement de l'entrée utilisateur comme une matrice 4x4
- Transformations mathématiques basées sur la position
- Rotation de la matrice
- Multiplication matricielle avec matrice de transformation
- Opérations XOR dynamiques

## Indications

1. Le mot de passe est exactement 16 caractères
2. La matrice d'entrée subit plusieurs transformations:
   - XOR position-dépendant
   - Rotation de 90 degrés
   - Multiplication avec une matrice de transformation
   - Ajout d'une constante
3. La matrice finale doit correspondre à la matrice cible

## Utilisation

Pour tester ce crackme:

```bash
./matrix_validator
```

Entrez un mot de passe de 16 caractères et le programme affichera:

- Un flag au format `crk{...}` et un code de retour 0 si le mot de passe est correct
- "Bad Password!" et un code de retour 1 si le mot de passe est incorrect

> Note: Le mot de passe à utiliser pour les tests est : "M4TR1X_TR4NSF0RM"

## Approche architecturale

Le programme est structuré de manière modulaire avec des sections claires:

- Entrée/sortie utilisateur
- Fonctions de manipulation de matrices
- Fonctions de transformation
- Validation

Cette architecture facilite l'analyse en isolant les différentes fonctionnalités tout en rendant le reverse engineering suffisamment intéressant.
