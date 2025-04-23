# Projet Crackmes

Ce projet contient les crackmes et cracks développés dans le cadre du challenge de Reverse Engineering. Chaque crackme est un programme qui simule des mécanismes de protection logicielle et contient un flag caché à découvrir.

## Structure du projet

```
Lesboss_crackmes/
├── AUTHORS.md           # Noms des membres de l'équipe
├── crackme_00/          # Premier crackme
│   ├── crackme.s        # Code source en assembleur
│   └── README.md        # Documentation du crackme
├── crackme_01/          # Deuxième crackme
│   ├── crackme.s        # Code source en assembleur
│   └── README.md        # Documentation du crackme
├── writeups/            # Documentation des solutions
│   └── crackme_XX.pdf   # Explication détaillée de la solution
├── cracks/              # Programmes pour modifier les crackmes
│   └── crack_XX.s       # Code source du crack
├── targets/             # Crackmes d'autres équipes à analyser
│   └── team_name/       # Dossier par équipe
├── scripts/             # Scripts utilitaires
│   ├── build.sh         # Script de compilation
│   ├── test.sh          # Script de test des crackmes
│   ├── crack-test.sh    # Script de test des cracks
│   ├── analyze.sh       # Script d'analyse de binaires
│   └── crack_template.s # Template pour développer des cracks
├── Dockerfile           # Configuration de l'environnement Docker
├── docker-compose.yml   # Configuration des services Docker
└── Makefile             # Automatisation des tâches courantes
```

## Environnement de développement

Ce projet utilise Docker pour fournir un environnement de développement isolé et cohérent. L'environnement inclut tous les outils nécessaires pour développer et tester des crackmes en assembleur x64, ainsi que pour analyser et cracker les crackmes d'autres équipes.

### Prérequis

- Docker
- Docker Compose
- Make (optionnel, pour utiliser les commandes du Makefile)

### Configuration initiale

1. Clonez ce dépôt :

   ```bash
   git clone <url-du-repo>
   cd Lesboss_crackmes
   ```

2. Configurez le projet :

   ```bash
   make setup
   ```

3. Construisez l'environnement Docker :

   ```bash
   make build-env
   ```

### Utilisation pour le Développement

#### Démarrer l'environnement

```bash
make start
```

#### Accéder à l'environnement de développement

```bash
make shell
```

#### Compiler un crackme

Dans l'environnement Docker :

```bash
build crackme_00/mon_crackme.s
```

#### Tester un crackme

Dans l'environnement Docker :

```bash
test crackme_00/mon_crackme "MON_FLAG_SECRET16"
```

#### Arrêter l'environnement

```bash
make stop
```

### Utilisation pour le Reverse Engineering

#### Importer un crackme d'une autre équipe

```bash
make import-target
```

#### Analyser un crackme importé

```bash
make analyze-target TARGET=targets/team_name/their_crackme
```

#### Créer un nouveau crack

```bash
make new-crack TARGET=targets/team_name/their_crackme
```

#### Tester un crack

Dans l'environnement Docker :

```bash
crack-test cracks/mon_crack targets/team_name/their_crackme "FLAG_ORIGINAL"
```

## Développement de Crackmes

### Exigences Techniques

- Les crackmes doivent être développés exclusivement en assembleur x64 pour Linux
- Aucune bibliothèque externe n'est autorisée
- Les flags doivent faire exactement 16 caractères
- Chaque crackme doit se comporter comme suit :
  - Avec le bon flag : affiche "Good Job!" et retourne le code 0
  - Avec un mauvais flag : affiche "Bad Password!" et retourne le code 1

### Approche Modulaire

Notre approche de développement met l'accent sur une architecture modulaire :

- Séparation claire des responsabilités (entrée/sortie, validation, protection)
- Interfaces bien définies entre les modules
- Code structuré et bien commenté

## Cracking des Crackmes

### Processus de Reverse Engineering

1. Importer et analyser le binaire cible
2. Identifier les mécanismes de protection et de validation
3. Développer une stratégie de patching
4. Implémenter et tester le crack

### Exigences des Cracks

- Les cracks doivent modifier chirurgicalement le binaire cible
- Le binaire patché doit conserver sa taille d'origine
- L'adresse de l'instruction finale (sys_exit) doit rester inchangée
- Le nouveau flag doit être "CR4CK1NG5N0TCR1M"

## Notation

- Un crackme validé rapporte 20 points (dégressif dans le temps)
- Un minimum d'un crackme par binôme est requis
- Un crackme adverse flagué c'est : +2 points à la team (4 en firstblood), -1 point au score du crackme
- Un writeup pdf ou md est obligatoire pour chaque crackme résolu
