import os
import re

TEMPLATE = '''# Writeup: {titre}

## Informations sur le Crackme

- **Équipe cible** : {equipe}
- **Nom du fichier** : {fichier}
- **Difficulté estimée** : {difficulte}
- **Flag découvert** : `{flag}`

## Résumé

{resume}

## Outils Utilisés

{outils}

## Analyse Statique

{statique}

## Analyse Dynamique

{dynamique}

## Identification du Mécanisme de Validation

{validation}

## Découverte du Flag

{decouverte}

## Conclusion

{conclusion}

{autres}
'''

# Définition étendue des sections et de leurs mots-clés pour une meilleure détection
SECTIONS = [
    ("resume", ["Résumé", "Analyse initiale", "Introduction", "Contexte", "Reconnaissance", "Informations initiales", 
               "Write-up", "Objectif", "Informations générales", "Premiers réflexes", "Etape 1", "étape 1"]),
    ("outils", ["Outils", "Outils utilisés", "Tools", "Logiciels", "Les outils utilisés", "j'ai utilisé"]),
    ("statique", ["Analyse statique", "Désassemblage", "Analyse initiale", "Désassemblage du binaire", 
                 "Exploration des symboles", "Examen des symboles", "Extraction des chaînes", "Analyse des sections",
                 "objdump", "readelf", "strings", "Inspection des sections", "dump des données", "Carto des sections"]),
    ("dynamique", ["Analyse dynamique", "Comportement", "Exécution", "Débogage", "Débugging", "Runtime", "gdb"]),
    ("validation", ["Validation", "Mécanisme", "Comparaison", "Vérification", "Mécanisme de validation", "Vérifier", 
                   "Good Job", "echo", "./", "Entrez le mot de passe"]),
    ("decouverte", ["Flag", "Découverte", "Identification du flag", "Solution", "Résolution", "Calcul du mot de passe", 
                   "Extraction du flag", "Le bon flag", "flag trouvé", "cela donne", "Donc :", "Résultat :", "password"]),
    ("conclusion", ["Conclusion", "Résumé final", "Pour conclure", "En résumé", "Protection", "méthode"]),
]

# Détection par contenu plutôt que par titre
CONTENT_INDICATORS = {
    "resume": ["objectif", "binaire", "fichier", "but", "analyse", "introduction"],
    "outils": ["utilisé", "radare", "gdb", "objdump", "strings", "cyberchef", "python", "script"],
    "statique": ["adresse", "désassemblage", "section", "code", "symbole", "fonction", "chaîne", "offset", "hexdump", "dump", "contenu"],
    "dynamique": ["exécution", "lancer", "runtime", "debug", "trace", "mémoire"],
    "validation": ["compare", "comparaison", "vérifie", "good job", "correct", "mot de passe", "valide", "test"],
    "decouverte": ["flag", "password", "solution", "résultat", "trouvé", "décodage", "obtenu"],
    "conclusion": ["conclusion", "résumé", "protection", "méthode", "approche"]
}

def format_code_blocks(text):
    """Détecte et formate les blocs de code en syntaxe Markdown"""
    lines = text.split('\n')
    formatted_lines = []
    in_code_block = False
    code_pattern = re.compile(r'^\s*(objdump|gdb|file|strings|readelf|python|javascript|bash|nm|xxd|echo|\$|def\s|from\s|import\s|const\s|r2|aaa|afl|s |px|hexdump|readelf|\.\/)')
    
    for i, line in enumerate(lines):
        # Détecte le début potentiel d'un bloc de code
        if (code_pattern.match(line) or 
            (i > 0 and lines[i-1].strip() == '' and line.startswith('  ')) or
            line.strip().startswith('0x') or 
            re.match(r'^\s*[0-9a-fA-F]{8}:', line)):
            if not in_code_block:
                formatted_lines.append('```')
                in_code_block = True
        # Détecte la fin potentielle d'un bloc de code
        elif in_code_block and line.strip() == '' and (i+1 < len(lines) and not lines[i+1].startswith('  ') and not code_pattern.match(lines[i+1])):
            formatted_lines.append('```')
            in_code_block = False
        
        formatted_lines.append(line)
    
    if in_code_block:
        formatted_lines.append('```')
    
    return '\n'.join(formatted_lines)

def find_section_by_content(text, sections_already_found):
    """Identifie la section la plus probable basée sur le contenu du texte"""
    best_section = None
    max_score = -1
    
    for section, indicators in CONTENT_INDICATORS.items():
        if section in sections_already_found:
            continue
        
        score = 0
        text_lower = text.lower()
        for indicator in indicators:
            score += text_lower.count(indicator)
        
        if score > max_score:
            max_score = score
            best_section = section
    
    return best_section if max_score > 0 else None

def extraire_infos(contenu, nom_fichier):
    """Extrait les informations clés du contenu avec une approche plus intelligente"""
    # Titre
    titre_patterns = [
        r'Writeup[:\-\s]+(.*)', 
        r'Write-up[:\-\s]+(.*)', 
        r'^# +(.+)',
    ]
    
    titre = None
    for pattern in titre_patterns:
        match = re.search(pattern, contenu, re.IGNORECASE)
        if match:
            titre = match.group(1).strip()
            break
    
    if not titre:
        titre = os.path.basename(nom_fichier).replace('.txt', '')

    # Équipe
    equipe = re.search(r'[ÉE]quipe\s*[:\-]?\s*(.*)', contenu)
    equipe = equipe.group(1).strip() if equipe else 'Non spécifiée'

    # Difficulté
    difficulte = re.search(r'Difficulté\s*[:\-]?\s*(.*)', contenu)
    difficulte = difficulte.group(1).strip() if difficulte else 'Non spécifiée'

    # Flag (recherche améliorée)
    flag_patterns = [
        r'flag\s*(est|:)?\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Flag explicite
        r'mot de passe\s*(est|:)?\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Mot de passe
        r'Le bon flag\s*(est|:)?\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Bon flag
        r'flag\s*correct\s*(est|:)?\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Flag correct
        r'flag\s*assemblé\s*:\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Flag assemblé
        r'flag\s*.*trouvé\s*:\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Flag trouvé
        r'Good Job!\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Après Good Job
        r'accès autorisé.*\n\s*([\w{}\-!@#\$%\^&\*\(\)\[\]\']+)',  # Après accès autorisé
    ]
    
    flag = None
    for pattern in flag_patterns:
        match = re.search(pattern, contenu, re.IGNORECASE)
        if match:
            flag = match.group(2).strip() if match.lastindex == 2 else match.group(1).strip()
            break
    
    if not flag:
        # Recherche de mots qui ressemblent à des flags
        flag_candidates = re.findall(r'([A-Za-z0-9_\-\{\}\']{8,})', contenu)
        for candidate in flag_candidates:
            if len(candidate) >= 8 and not re.match(r'^(file|strings|objdump|python|javascript|bash|gdb|readelf)$', candidate.lower()):
                flag = candidate.strip()
                break
    
    if not flag:
        flag = 'Non découvert'

    # Extraction des sections traditionnelle
    sections, autres = extraire_sections_exhaustif(contenu)
    
    # Recherche de contenu pour les sections manquantes
    section_keys = [key for key, _ in SECTIONS]
    for key in section_keys:
        if key not in sections or not sections[key].strip():
            for paragraph in contenu.split('\n\n'):
                if len(paragraph.strip()) > 50:  # Paragraphe substantiel
                    best_section = find_section_by_content(paragraph, sections.keys())
                    if best_section == key:
                        sections[key] = paragraph
                        break
    
    # Formatage du contenu des sections
    for key in sections:
        sections[key] = format_code_blocks(sections[key])

    # Remplir avec des valeurs contextuelles pour les sections manquantes
    infos = {
        'titre': titre,
        'equipe': equipe,
        'fichier': nom_fichier,
        'difficulte': difficulte,
        'flag': flag,
        'autres': format_code_blocks(autres)
    }
    
    default_descriptions = {
        "resume": "Ce writeup analyse un crackme pour identifier son fonctionnement et retrouver le flag caché.",
        "outils": "Analyse effectuée avec les outils standards pour reverse engineering (objdump, gdb, strings, scripts personnalisés).",
        "statique": "L'analyse statique a révélé la structure du binaire et les mécanismes potentiels de vérification.",
        "dynamique": "L'exécution du programme a permis d'observer son comportement et d'identifier les points de validation.",
        "validation": "Le programme valide l'entrée utilisateur via une série de transformations et de comparaisons.",
        "decouverte": "Le flag a été découvert en analysant le mécanisme de vérification et en inversant l'algorithme.",
        "conclusion": "Ce crackme a été résolu en comprenant son mécanisme de validation et en élaborant une stratégie appropriée."
    }
    
    for key, _ in SECTIONS:
        if key in sections and sections[key].strip():
            infos[key] = sections[key]
        else:
            infos[key] = default_descriptions[key]
    
    return infos

def extraire_sections_exhaustif(contenu):
    """Extrait toutes les sections du contenu de manière plus intelligente"""
    # On cherche tous les titres potentiels
    titre_regex = r'^(?P<titre>[A-ZÉÈÊÀÂÎÔÛÇ][\w\s\-_/]+)(:|\n)'  # Titre en début de ligne
    titres = []
    for match in re.finditer(titre_regex, contenu, re.MULTILINE):
        titres.append((match.start(), match.group('titre').strip()))
    
    # Ajoute également les titres en format markdown
    md_titre_regex = r'^#+\s+(?P<titre>.+)$'  # Titre markdown style (#, ##, etc.)
    for match in re.finditer(md_titre_regex, contenu, re.MULTILINE):
        titres.append((match.start(), match.group('titre').strip()))
    
    # Ajoute la fin du fichier
    titres.append((len(contenu), None))
    
    # Trie les titres par position
    titres.sort(key=lambda x: x[0])
    
    # Extraction des blocs
    sections = {}
    autres_sections = []
    
    for i in range(len(titres)-1):
        start, titre = titres[i]
        end = titres[i+1][0]
        bloc = contenu[start:end].strip()
        titre_clean = titre if titre else ''
        
        # Vérifie si ce titre correspond à une section du template
        found = False
        for key, mots_cles in SECTIONS:
            for mot in mots_cles:
                if (titre_clean.lower().startswith(mot.lower()) or 
                    mot.lower() in titre_clean.lower() or
                    re.search(r'\b' + re.escape(mot.lower()) + r'\b', titre_clean.lower())):
                    if key in sections:
                        sections[key] += '\n\n' + bloc
                    else:
                        sections[key] = bloc
                    found = True
                    break
            if found:
                break
        
        if not found and titre_clean:
            # Essayer de détecter par contenu
            best_section = find_section_by_content(bloc, sections.keys())
            if best_section:
                if best_section in sections:
                    sections[best_section] += '\n\n' + bloc
                else:
                    sections[best_section] = bloc
            else:
                # Ajoute comme section additionnelle
                autres_sections.append(f'### {titre_clean}\n{bloc}')
        elif not found and not titre_clean and bloc:
            # Texte sans titre, essayer de l'attribuer par contenu
            best_section = find_section_by_content(bloc, sections.keys())
            if best_section:
                if best_section in sections:
                    sections[best_section] += '\n\n' + bloc
                else:
                    sections[best_section] = bloc
            else:
                autres_sections.append(f'{bloc}')
    
    autres = '\n\n'.join(autres_sections) if autres_sections else ''
    return sections, autres

def convertir_txt_a_md():
    """Convertit tous les fichiers .txt en .md dans le dossier courant"""
    FOLDER = os.path.dirname(os.path.abspath(__file__))
    
    for filename in os.listdir(FOLDER):
        if filename.endswith('.txt'):
            txt_path = os.path.join(FOLDER, filename)
            md_path = os.path.join(FOLDER, filename[:-4] + '.md')
            
            with open(txt_path, 'r', encoding='utf-8') as f:
                contenu = f.read()
            
            infos = extraire_infos(contenu, filename)
            
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(TEMPLATE.format(**infos))
            
            print(f"Converti : {filename} -> {os.path.basename(md_path)}")
    
    print("Conversion .txt -> .md terminée !")

if __name__ == "__main__":
    convertir_txt_a_md()