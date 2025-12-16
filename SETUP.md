# Configuration du Repository

## Structure du Repository

Votre repository est maintenant correctement structuré pour Home Assistant :

```
azuracast-addon-ha/
├── repository.json          # Configuration du repository
├── README.md               # Documentation principale
├── .gitignore             # Fichiers à ignorer
└── azuracast/             # Dossier de l'add-on
    ├── config.yaml        # Configuration de l'add-on
    ├── Dockerfile         # Image Docker
    ├── run.sh            # Script de démarrage
    ├── ha_integration.py # Intégration Home Assistant
    ├── build.yaml        # Configuration de build
    ├── icon.png          # Icône (à remplacer)
    ├── logo.png          # Logo (à remplacer)
    ├── README.md         # Documentation de l'add-on
    ├── DOCS.md           # Documentation détaillée
    ├── ARCHITECTURE.md   # Documentation technique
    ├── CHANGELOG.md      # Historique des versions
    └── LICENSE           # Licence
```

## Prochaines Étapes

### 1. Remplacer les Images Placeholder

Vous devez remplacer les fichiers placeholder par de vraies images PNG :
- `azuracast/icon.png` : 120x120 pixels (icône dans le store)
- `azuracast/logo.png` : 600x600 pixels (logo détaillé)

Vous pouvez utiliser le logo officiel d'AzuraCast ou créer le vôtre.

### 2. Commit et Push sur GitHub

```bash
cd /Users/julienortscheid/Documents/devs/azuracast-addon-ha
git add .
git commit -m "Initial setup of AzuraCast add-on repository"
git remote add origin https://github.com/roulianosss/azuracast-addon-ha.git
git push -u origin main
```

### 3. Ajouter le Repository dans Home Assistant

1. Dans Home Assistant, allez dans **Paramètres** → **Modules complémentaires** → **Boutique de modules complémentaires**
2. Cliquez sur les trois points en haut à droite → **Dépôts**
3. Ajoutez l'URL : `https://github.com/roulianosss/azuracast-addon-ha`
4. Cliquez sur **Ajouter**

### 4. Configuration GitHub Actions (Optionnel mais Recommandé)

Pour construire automatiquement les images Docker pour toutes les architectures, créez le fichier `.github/workflows/builder.yaml` :

```yaml
name: Builder

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    name: Build ${{ matrix.arch }} ${{ matrix.addon }}
    strategy:
      matrix:
        arch: ["aarch64", "amd64", "armv7"]
        addon: ["azuracast"]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Get information
        id: info
        uses: home-assistant/actions/helpers/info@master
        with:
          path: "./${{ matrix.addon }}"

      - name: Build ${{ matrix.addon }} for ${{ matrix.arch }}
        uses: home-assistant/builder@master
        with:
          args: |
            --${{ matrix.arch }} \
            --target /data/${{ matrix.addon }} \
            --image "${{ steps.info.outputs.name }}" \
            --docker-hub "${{ secrets.DOCKERHUB_USERNAME }}" \
            --docker-user "${{ secrets.DOCKERHUB_USERNAME }}" \
            --docker-password "${{ secrets.DOCKERHUB_TOKEN }}"
```

### 5. Tester l'Add-on

Une fois installé :
1. Configurez les paramètres (ports, mots de passe MySQL)
2. Démarrez l'add-on
3. Consultez les logs pour vérifier que tout fonctionne
4. Accédez à l'interface web sur le port configuré (par défaut 8080)

## Problèmes Connus et Solutions

### Erreur "not a valid add-on repository"

**Cause** : Structure de repository incorrecte ou fichier `repository.json` manquant

**Solution** :
- Vérifiez que `repository.json` existe à la racine
- Vérifiez que l'add-on est dans un sous-dossier (pas directement à la racine)
- Le fichier `config.yaml` doit être présent dans le dossier de l'add-on

### L'add-on ne démarre pas

**Vérifiez** :
1. Les logs de l'add-on dans Home Assistant
2. Que les ports ne sont pas déjà utilisés
3. Que vous avez suffisamment de RAM (2GB minimum)
4. Les permissions du dossier `/data`

### Problèmes de base de données

Si la base de données ne s'initialise pas :
1. Arrêtez l'add-on
2. Supprimez `/data/azuracast/db`
3. Redémarrez l'add-on

## Architecture Technique

### Composants Principaux

1. **MariaDB** : Base de données pour AzuraCast
2. **PHP-FPM + Nginx** : Serveur web et application
3. **Icecast** : Serveur de streaming audio
4. **Liquidsoap** : Moteur AutoDJ (à ajouter si besoin)
5. **Python Integration** : Monitoring pour Home Assistant

### Points d'Amélioration Futurs

- [ ] Intégration MQTT Discovery pour les sensors
- [ ] Support de Liquidsoap pour l'AutoDJ complet
- [ ] Webhooks pour événements temps réel
- [ ] Interface de contrôle via dashboard HA
- [ ] Support multi-instances

## Support

Pour toute question ou problème :
- Ouvrez une issue sur [GitHub](https://github.com/roulianosss/azuracast-addon-ha/issues)
- Consultez la [documentation AzuraCast](https://docs.azuracast.com/)
- Consultez [ARCHITECTURE.md](azuracast/ARCHITECTURE.md) pour les détails techniques

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche pour votre feature
3. Commiter vos changements
4. Ouvrir une Pull Request

## Licence

MIT License - Voir le fichier LICENSE pour plus de détails.
