# nova

Lance une commande et la surveille en arrière-plan : redémarrage automatique si elle s'arrête, et raccourcis clavier pour la piloter en direct.

## Installation

```bash
curl -fsSL https://ekith.github.io/nova/install.sh | bash
```

Installe `nova` dans `~/.local/bin` et sa complétion bash dans `~/.local/share/bash-completion/completions`.

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
