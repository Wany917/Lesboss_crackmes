Labyrinth — Write-up 


 Reconnaître le binaire : 

 file Labyrinth

 J’ai vérifié que c’était bien un exécutable Linux 64 bits

 chmod +x Labyrinth

 J’ai ajouté le bit d’exécution pour pouvoir le lancer.

 strings -n 4 Labyrinth | less

 Parmi les résultats, j’ai repéré : 

Bad Password!
Good Job!
ABCDEFGHIJKLMNOP
check_key
correct_flag
msg_good

La chaîne “ABCDEFGHIJKLMNOP” m'a sauté aux yeux : elle fait 16 caractères, exactement le format demandé pour le flag.

echo "ABCDEFGHIJKLMNOP" | ./Labyrinth
Good Job!

Vérification au niveau assembleur

Pour prouver que la comparaison est bien faite sur cette valeur :


objdump -d Labyrinth | grep -A4 -n "check_key"

Le désassemblage montre que la fonction check_key lit 16 octets et les compare au littéral 0x41…0x50 (les codes ASCII de A→P).

j’ai donc bouclé la boucle en lisant le code machine.