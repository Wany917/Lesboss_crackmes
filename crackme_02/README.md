# Crackme 02 - Validateur de Code Polymorphique

## Description
Ce crackme utilise du code auto-modifiant (polymorphique) pour valider l'entrée utilisateur. Le code de validation est chiffré, puis déchiffré à l'exécution, et change son comportement pendant l'exécution.

## Niveau de difficulté
Très difficile

## Mécanismes de protection
- Code auto-modifiant
- Génération dynamique de code
- Chiffrement du code de validation
- Protection mémoire avec mprotect
- Valeurs attendues encodées
- Génération dynamique du flag unique

## Mot de passe
Le mot de passe attendu est `P0LYM0RPH1C_C0D3`

## Flag
Lorsque le mot de passe correct est entré, le programme génère et affiche un flag unique au format `HTB{...}`. Ce flag est différent du mot de passe et est obtenu par déchiffrement de données encodées.

## Compilation
```bash
nasm -f elf64 poly_crackme.s -o poly_crackme.o
ld poly_crackme.o -o poly_crackme
```

## Utilisation
```bash
./poly_crackme
# Saisir le mot de passe quand demandé
```

## Architecture Modulaire
Le code est organisé selon une architecture modulaire:

1. **Module d'Entrée/Sortie**: Gestion des interactions utilisateur
2. **Module de Protection**: Gestion des protections mémoire
   - Configuration de mprotect
   - Détection des erreurs de protection
3. **Module de Transformation**: Génération du code polymorphique
   - Déchiffrement du code
   - Modification dynamique du code
4. **Module de Validation**: Code auto-modifiant pour la validation
5. **Module de Génération de Flag**: Génère un flag unique lorsque la validation réussit

## Aspects techniques
- Utilisation de `mprotect` pour rendre la mémoire exécutable
- Technique de génération de code à l'exécution
- Chiffrement par XOR du code de validation
- Code qui modifie son propre comportement durant l'exécution
- Dérivation d'un flag unique à partir de données encodées

## Challenge
Le véritable défi consiste à comprendre le mécanisme de code polymorphique, à analyser le code déchiffré et auto-modifiant, et à déterminer quel mot de passe produira une validation réussie, ce qui permettra d'obtenir le flag unique.

## Indices
- Le flag fait exactement 16 caractères
- Le code de validation est généré à l'exécution
- Le comportement change à chaque exécution
- Les transformations incluent des opérations bit à bit 