# Writeup: – crackme_00

## Informations sur le Crackme

- **Équipe cible** : Non spécifiée
- **Nom du fichier** : writeup_13_crackme00.txt
- **Difficulté estimée** : Non spécifiée
- **Flag découvert** : `3sn-Z42-3l2-093p`

## Résumé

Objectif

Retrouver le flag caché dans le binaire fourni, un fichier ELF nommé crackme_00.
Le flag est une chaîne de 16 caractères.

## Outils Utilisés

Ensuite, j'ai utilisé la commande strings pour voir s'il y avait des chaînes intéressantes en clair :

## Analyse Statique

Résultat :

crackme_00: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

➔ C'est un exécutable 64 bits Linux, statiquement lié, non stripé (c'est-à-dire qu'il conserve ses symboles, ce qui est très utile pour l'analyse).

2. Recherche de chaînes de caractères

Ensuite, j'ai utilisé la commande strings pour voir s'il y avait des chaînes intéressantes en clair :

```
strings crackme_00 :
```

3sn-Z42-3l2-093p
Good Job!
Bad Password!
crackme_00.s
correct_pass
correct_len
msg_good

La chaîne 3sn-Z42-3l2-093p est particulièrement suspecte, car elle fait 16 caractères et semble formatée.

J'ai executé le binaire et tester la chaîne :

3sn-Z42-3l2-093p

## Analyse Dynamique

L'exécution du programme a permis d'observer son comportement et d'identifier les points de validation.

## Identification du Mécanisme de Validation

3sn-Z42-3l2-093p
Good Job!
Bad Password!
crackme_00.s
correct_pass
correct_len
msg_good

## Découverte du Flag

Résultat :

Good Job!

Cela confirme que 3sn-Z42-3l2-093p est le flag attendu.

## Conclusion

Ce crackme a été résolu en comprenant son mécanisme de validation et en élaborant une stratégie appropriée.

### Étapes réalisées

Étapes réalisées

1. Identification du fichier

Pour commencer, j'ai identifié la nature du fichier avec la commande suivante :

```
file crackme_00
```
