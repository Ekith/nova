## Changelog — Non publié

### Corrections
- `kill_process` envoie désormais un `SIGKILL` de secours si le `SIGTERM` initial n'a pas suffi à arrêter le processus et ses enfants dans le délai imparti

## Changelog — 1.1.1 (2026-08-06)

### Ajouts
- Page des versions avec récupération dynamique du numéro de version
- Page de changelog

### Corrections
- Les arguments de la commande lancée (espaces, guillemets) ne sont plus fractionnés au relancement du processus
- `kill_process` n'affiche plus d'erreur quand le processus est déjà arrêté

### Améliorations
- Amélioration de l'ergonomie et du style des commandes d'installation
- Ajout des descriptions de commandes dans le tableau d'utilisation de la page d'accueil
- Précision dans le message de lancement et la doc : `Ctrl+C` redémarre le processus (comme `R`), il n'arrête pas nova
- `nova --uninstall` demande désormais confirmation avant de supprimer les fichiers installés
- Message d'usage traduit en français, code mort supprimé
