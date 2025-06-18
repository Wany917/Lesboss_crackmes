# Writeup: Reconnaître le binaire

## Informations sur le Crackme

- **Équipe cible** : Non spécifiée
- **Nom du fichier** : writeup_10_labyrinthOK.txt
- **Difficulté estimée** : Non spécifiée
- **Flag découvert** : `ABCDEFGHIJKLMNOP`

## Résumé

Ce writeup analyse un crackme pour identifier son fonctionnement et retrouver le flag caché.

## Outils Utilisés

Analyse effectuée avec les outils standards pour reverse engineering (objdump, gdb, strings, scripts personnalisés).

## Analyse Statique

La chaîne “ABCDEFGHIJKLMNOP” m'a sauté aux yeux : elle fait 16 caractères, exactement le format demandé pour le flag.

## Analyse Dynamique

 J’ai ajouté le bit d’exécution pour pouvoir le lancer.

## Identification du Mécanisme de Validation

Vérification au niveau assembleur

Pour prouver que la comparaison est bien faite sur cette valeur :

```
objdump -d Labyrinth | grep -A4 -n "check_key"
```

Le désassemblage montre que la fonction check_key lit 16 octets et les compare au littéral 0x41…0x50 (les codes ASCII de A→P).

j’ai donc bouclé la boucle en lisant le code machine.

## Découverte du Flag

ABCDEFGHIJKLMNOP
check_key
correct_flag
msg_good

La chaîne “ABCDEFGHIJKLMNOP” m'a sauté aux yeux : elle fait 16 caractères, exactement le format demandé pour le flag.

```
echo "ABCDEFGHIJKLMNOP" | ./Labyrinth
Good Job!
```

## Conclusion

Ce crackme a été résolu en comprenant son mécanisme de validation et en élaborant une stratégie appropriée.
