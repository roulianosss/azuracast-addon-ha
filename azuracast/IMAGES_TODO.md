# Images à Remplacer

## ⚠️ Action Requise

Les fichiers suivants sont actuellement des placeholders texte et **doivent être remplacés** par de vraies images PNG avant publication :

### 1. icon.png
- **Taille** : 120x120 pixels
- **Format** : PNG avec transparence
- **Usage** : Icône dans la boutique d'add-ons Home Assistant

### 2. logo.png
- **Taille** : 600x600 pixels (ou plus)
- **Format** : PNG avec transparence
- **Usage** : Logo détaillé dans la page de l'add-on

## 🎨 Options pour les Images

### Option 1 : Logo AzuraCast Officiel
Téléchargez depuis le repository officiel :
- GitHub : https://github.com/AzuraCast/AzuraCast
- Site web : https://www.azuracast.com/

### Option 2 : Créer Votre Propre Logo
Si vous créez un logo personnalisé, assurez-vous de :
- Respecter la licence Apache 2.0 d'AzuraCast
- Indiquer clairement qu'il s'agit d'un add-on non-officiel
- Ne pas violer les marques déposées

### Option 3 : Logo Générique
Créez un logo simple avec :
- Icône de radio/musique
- Texte "AzuraCast"
- Couleurs : Bleu (#2196F3) et blanc

## 📝 Instructions pour Remplacer

### Méthode Manuelle
```bash
# 1. Téléchargez vos images
# 2. Renommez-les
mv votre-icone.png icon.png
mv votre-logo.png logo.png

# 3. Copiez dans le dossier
cp icon.png /chemin/vers/azuracast-addon-ha/azuracast/
cp logo.png /chemin/vers/azuracast-addon-ha/azuracast/

# 4. Commitez les changements
git add azuracast/icon.png azuracast/logo.png
git commit -m "Add addon icons and logo"
git push
```

### Méthode avec ImageMagick (si installé)
```bash
# Créer une icône simple avec ImageMagick
convert -size 120x120 xc:transparent \
  -fill "#2196F3" -draw "circle 60,60 60,10" \
  -fill white -pointsize 40 -gravity center \
  -annotate 0 "AC" icon.png

convert -size 600x600 xc:transparent \
  -fill "#2196F3" -draw "circle 300,300 300,50" \
  -fill white -pointsize 150 -gravity center \
  -annotate 0 "AC" logo.png
```

## ✅ Vérification

Avant de commiter, vérifiez :
- [ ] Les fichiers sont au format PNG
- [ ] Les dimensions sont correctes
- [ ] Les images ont une transparence (optionnel mais recommandé)
- [ ] Les fichiers ne sont pas trop lourds (<100KB pour icon, <500KB pour logo)

## 🔍 Test

Pour tester vos images :
```bash
# Vérifier les dimensions
file azuracast/icon.png
file azuracast/logo.png

# Vérifier la taille des fichiers
ls -lh azuracast/*.png
```

---

**Note** : Les images actuelles (placeholders texte) empêcheront l'add-on de s'afficher correctement dans Home Assistant. Remplacez-les dès que possible !
