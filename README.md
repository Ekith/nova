<h1><img src="docs/assets/logo.svg" alt="" width="32" height="32" align="center"> nova</h1>

Lance une commande et la surveille en arrière-plan : redémarrage automatique si elle s'arrête, et raccourcis clavier pour la piloter en direct.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Ekith/nova/release/install.sh | bash
```

Installe `nova` dans `~/.local/bin` et sa complétion bash dans `~/.local/share/bash-completion/completions`.

Pour installer une version précise (un tag existant, ex. `1.0.1`) plutôt que la dernière release :

```bash
curl -fsSL https://raw.githubusercontent.com/Ekith/nova/release/install.sh | bash -s -- 1.0.1
```

Si la version demandée n'existe pas, l'installation échoue.

## Usage

```bash
nova <commande à lancer>
```

Une fois lancé :

| Touche | Action |
| --- | --- |
| `R` | Redémarrer le processus |
| `K` | Arrêter nova |
| `C` | Effacer la console |
| `N` | Nettoyer puis redémarrer le processus |

Le processus est aussi redémarré automatiquement s'il s'arrête tout seul.

## Gestion

```bash
nova --help               # ou nova -h : affiche l'aide
nova --upgrade            # ou nova -u : met à jour nova vers la dernière version
nova --install <version>  # ou nova -i <version> : installe une version précise
nova --uninstall          # désinstalle nova
nova --version            # ou nova -v : affiche la version installée
```
