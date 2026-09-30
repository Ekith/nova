## Changelog — 1.2.0 (2026-09-30)

### Ajouts
- Redémarrage du processus depuis un autre terminal avec `kill -USR1 <pid>`, y compris quand nova tourne en arrière-plan
- Section « Signaux » dans `nova --help`, rappel de `SIGUSR1` dans le message de lancement, et documentation du pilotage par signaux dans le README et la page d'accueil

### Améliorations
- Touches et signaux passent par une même fonction `handle_action` : un signal reçu pendant une action (redémarrage en cours, par exemple) est mis en attente puis exécuté, au lieu de s'imbriquer dans l'action en cours
- Une action demandée par signal n'est plus perdue quand une touche est pressée au même moment : les deux s'exécutent l'une après l'autre

## Changelog — 1.1.2 (2026-08-06)

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
