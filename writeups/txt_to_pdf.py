import os
import subprocess
import argparse
import sys
import tempfile
from pathlib import Path
from datetime import datetime
import weasyprint

CSS_TEMPLATE = '''
@page {
    margin: 2.5cm 2cm;
    @top-left {
        content: string(title);
        font-size: 9pt;
        color: #666;
    }
    @top-right {
        content: counter(page) "/" counter(pages);
        font-size: 9pt;
        color: #666;
    }
    @bottom-center {
        content: "$footer$";
        font-size: 9pt;
        color: #666;
    }
}

@page :first {
    margin: 2.5cm 2cm;
    @top-left { content: normal; }
    @top-right { content: normal; }
    @bottom-center { content: normal; }
}

html {
    font-size: 11pt;
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro", "SF Pro Text", "Avenir", "Helvetica Neue", sans-serif;
    line-height: 1.6;
    color: #333;
}

body {
    max-width: 100%;
    margin: 0;
    padding: 0;
    string-set: title "$title$";
}

h1, h2, h3, h4, h5, h6 {
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Avenir Next", "Helvetica Neue", sans-serif;
    color: #0066cc;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
}

h1 {
    font-size: 2.2em;
    border-bottom: 1px solid #ddd;
    padding-bottom: 0.3em;
}

h2 {
    font-size: 1.8em;
}

h3 {
    font-size: 1.5em;
}

code {
    font-family: "SF Mono", Menlo, Consolas, Monaco, monospace;
    background-color: #f5f5f5;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
}

pre {
    background-color: #f5f5f5;
    padding: 1em;
    border-radius: 5px;
    overflow-x: auto;
    border: 1px solid #ddd;
    page-break-inside: avoid;
}

pre code {
    background-color: transparent;
    padding: 0;
}

blockquote {
    margin-left: 0;
    padding-left: 1em;
    border-left: 4px solid #ddd;
    color: #666;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
    page-break-inside: avoid;
}

th, td {
    padding: 0.5em;
    border: 1px solid #ddd;
}

th {
    background-color: #f5f5f5;
    font-weight: bold;
}

img {
    max-width: 100%;
    height: auto;
}

a {
    color: #007aff;
    text-decoration: none;
}

.title-page {
    text-align: center;
    margin-bottom: 4em;
    page-break-after: always;
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.title-page h1 {
    font-size: 2.5em;
    border: none;
    margin-top: 0;
}

.title-page .subtitle {
    font-size: 1.5em;
    font-style: italic;
    margin-top: 1em;
    color: #666;
}

.title-page .author {
    margin-top: 4em;
    font-size: 1.2em;
}

.title-page .date {
    margin-top: 0.5em;
    color: #666;
}

.toc {
    page-break-after: always;
}

.toc a {
    text-decoration: none;
    color: #333;
}

.toc .toc-h1 {
    margin-left: 0;
    font-weight: bold;
}

.toc .toc-h2 {
    margin-left: 2em;
}

.toc .toc-h3 {
    margin-left: 4em;
}

section {
    page-break-inside: avoid;
}
'''

def create_temp_css(options):
    """Crée un fichier CSS temporaire avec les options spécifiées."""
    css_content = CSS_TEMPLATE
    for key, value in options.items():
        if value:
            css_content = css_content.replace(f"${key}$", value)
        else:
            css_content = css_content.replace(f"${key}$", "")
    
    fd, path = tempfile.mkstemp(suffix=".css")
    with os.fdopen(fd, 'w') as f:
        f.write(css_content)
    return path

def get_title_from_md(md_file):
    """Extrait le titre du fichier Markdown."""
    try:
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.readlines()
            for line in content:
                if line.startswith('# '):
                    return line[2:].strip()
    except Exception as e:
        print(f"Attention: Erreur lors de l'extraction du titre: {e}")
    
    # Si aucun titre n'est trouvé, utilise le nom du fichier
    return Path(md_file).stem

def create_title_page_html(options):
    """Crée une page de titre HTML."""
    title = options.get('title', 'Rapport d\'analyse')
    subtitle = options.get('subtitle', 'Rapport d\'analyse - Crackme')
    author = options.get('author', '')
    date = datetime.now().strftime("%d %B %Y")
    
    html = f'''
    <div class="title-page">
        <h1>{title}</h1>
        <div class="subtitle">{subtitle}</div>
        <div class="author">{author}</div>
        <div class="date">{date}</div>
    </div>
    '''
    return html

def md_to_pdf(md_file, output_dir=None, options=None):
    """Convertit un fichier Markdown en PDF en utilisant WeasyPrint."""
    if options is None:
        options = {}
    
    # Définir le chemin de sortie
    pdf_file = Path(md_file).with_suffix('.pdf')
    if output_dir:
        pdf_file = Path(output_dir) / pdf_file.name
    
    # Créer des fichiers temporaires
    html_fd, html_path = tempfile.mkstemp(suffix=".html")
    
    try:
        # Extraire le titre s'il n'est pas spécifié
        if 'title' not in options or not options['title']:
            options['title'] = get_title_from_md(md_file)
        
        # Créer le CSS avec les options
        css_path = create_temp_css(options)
        
        # Première étape : convertir MD en HTML
        md_to_html_cmd = [
            'pandoc',
            str(md_file),
            '-o', html_path,
            '--standalone',
            '--highlight-style=tango',
            '--toc',
            '--toc-depth=3',
            '--metadata', f'title={options.get("title", "Rapport")}',
        ]
        
        if options.get('author'):
            md_to_html_cmd.extend(['--metadata', f'author={options["author"]}'])
        
        subprocess.run(md_to_html_cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Ajouter la page de titre
        with open(html_path, 'r', encoding='utf-8') as f:
            html_content = f.read()
        
        title_page = create_title_page_html(options)
        modified_html = html_content.replace('<body>', f'<body>{title_page}')
        
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(modified_html)
        
        # Convertir HTML en PDF avec WeasyPrint
        html = weasyprint.HTML(filename=html_path)
        css = weasyprint.CSS(filename=css_path)
        html.write_pdf(pdf_file, stylesheets=[css])
        
        print(f"Converti: {md_file} -> {pdf_file}")
        return pdf_file
    
    except subprocess.CalledProcessError as e:
        print(f"Erreur lors de la conversion de {md_file}:")
        print(f"Stderr: {e.stderr.decode('utf-8')}")
        return None
    
    except Exception as e:
        print(f"Exception inattendue: {e}")
        return None
    
    finally:
        # Nettoyage
        os.close(html_fd)
        if os.path.exists(html_path):
            os.remove(html_path)
        if 'css_path' in locals() and os.path.exists(css_path):
            os.remove(css_path)

def compare_pdfs(pdf1, pdf2, output=None):
    """Compare deux fichiers PDF et génère optionnellement un PDF avec les différences."""
    try:
        cmd = ["diff-pdf"]
        
        if output:
            cmd.extend(["--output-diff", output])
        else:
            cmd.append("--view")
        
        cmd.extend([str(pdf1), str(pdf2)])
        
        subprocess.run(cmd, check=True)
        print(f"Comparaison effectuée entre {pdf1} et {pdf2}")
        if output:
            print(f"Différences enregistrées dans {output}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Erreur lors de la comparaison de PDFs: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description="Convertit des fichiers Markdown en PDF et compare optionnellement des PDFs."
    )
    parser.add_argument("-i", "--input", help="Dossier contenant les fichiers .md", default=".")
    parser.add_argument("-o", "--output", help="Dossier de sortie pour les PDFs", default=None)
    parser.add_argument("-c", "--compare", nargs=2, metavar=("PDF1", "PDF2"), help="Compare deux fichiers PDF")
    parser.add_argument("-d", "--diff-output", help="Fichier de sortie pour les différences (utilisé avec -c)")
    parser.add_argument("--all", action="store_true", help="Convertit tous les fichiers .md trouvés")
    parser.add_argument("files", nargs="*", help="Fichiers .md spécifiques à convertir")
    
    # Options de style
    style_group = parser.add_argument_group('options de style')
    style_group.add_argument("--author", help="Nom de l'auteur")
    style_group.add_argument("--title", help="Titre du document (par défaut: extrait du Markdown)")
    style_group.add_argument("--subtitle", help="Sous-titre du document (défaut: 'Rapport d'analyse - Crackme')")
    style_group.add_argument("--footer", help="Texte du pied de page (défaut: 'Writeup Report')")
    
    args = parser.parse_args()
    
    # Créer le dossier de sortie s'il n'existe pas
    if args.output:
        os.makedirs(args.output, exist_ok=True)
    
    # Préparer les options de style
    style_options = {
        'author': args.author,
        'title': args.title,
        'subtitle': args.subtitle,
        'footer': args.footer or 'Writeup Report'
    }
    # Filtrer les options None
    style_options = {k: v for k, v in style_options.items() if v is not None}
    
    # Convertir les fichiers .md en PDF
    if args.all or args.files:
        if args.all:
            md_files = list(Path(args.input).glob("*.md"))
        else:
            md_files = [Path(f) for f in args.files]
            
        if not md_files:
            print("Aucun fichier .md trouvé.")
            return
            
        for md_file in md_files:
            md_to_pdf(md_file, args.output, style_options)
    
    # Comparer deux PDFs si demandé
    if args.compare:
        pdf1, pdf2 = args.compare
        compare_pdfs(pdf1, pdf2, args.diff_output)

if __name__ == "__main__":
    main()