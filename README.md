
# Outils de prévisualisation locale - SquashTM Doc

Ce dépôt contient les outils nécessaires pour lancer rapidement les serveurs locaux de documentation (Français et Anglais), basculer sur les bonnes branches de travail, et ajouter des boutons d'accès rapide directement dans les Merge Requests (MR) de GitLab.

---

## 🛠️ Prérequis

1. Avoir cloné les dépôts `squashtm-doc-fr` et `squashtm-doc-en` dans le **même dossier parent** sur votre machine.
2. Avoir installé l'extension de navigateur [Tampermonkey](https://www.tampermonkey.net/).
3. Avoir installé Python et MkDocs (généralement déjà configuré si vous travaillez sur la doc).

---

## 🚀 Étape 1 : Installation du script de prévisualisation (GitLab)

Grâce à Tampermonkey, l'installation se fait en un seul clic :

1. Cliquez sur le lien suivant pour ouvrir le script brut : **[INSTALLER LE SCRIPT (cliquez ici)](https://raw.githubusercontent.com/VOTRE_PSEUDO/VOTRE_REPO/main/gitlab-doc-link.user.js)** *(pensez à remplacer ce lien par l'URL "Raw" de votre fichier dans votre dépôt)*.
2. Tampermonkey s'ouvrira automatiquement. Cliquez sur le bouton **Installer** (ou *Mettre à jour*).

### Fonctionnalités du script de navigation :
* **Fichiers Markdown (`.md`)** : Un bouton **📖 Doc** s'affiche à côté de chaque fichier modifié dans l'onglet *Changes* de la MR pour l'ouvrir directement sur votre serveur local.
* **Images modifiées (`.png`, `.jpg`, etc.)** : Un bouton **📖 Doc** s'affiche également à côté des images. 
  * *Au survol du bouton (hover)* : Le script interroge l'API de GitLab en arrière-plan pour trouver précisément la page de documentation qui utilise cette image. Si elle est trouvée, le bouton devient **📖 Doc 🎯** et vous redirige vers la page exacte.
  * *Par défaut / Hors-ligne* : Si l'image n'est pas encore référencée, le bouton vous redirige vers le dossier parent de l'image.

---

## 💻 Étape 2 : Configuration du script de lancement local (PowerShell)

Pour que les boutons de prévisualisation fonctionnent, vos serveurs locaux MkDocs doivent être lancés sur votre machine. Les scripts ont été optimisés sans caractères accentués afin de garantir une compatibilité totale sur tous les postes de l'équipe, sans problème d'encodage Windows.

1. Téléchargez (ou clonez) ce dépôt d'outils.
2. Copiez les deux fichiers suivants :
   * `launch-doc.ps1`
   * `launch-doc.cmd`
3. Collez-les dans le **dossier parent** de vos documentations (le dossier qui contient directement `squashtm-doc-fr` et `squashtm-doc-en`).

```text
📁 Dossier_Projets/ (votre dossier de travail)
├── 📁 squashtm-doc-fr/
├── 📁 squashtm-doc-en/
├── 📄 launch-doc.ps1     <-- Collé ici
└── 📄 launch-doc.cmd     <-- Collé ici
```

### Utilisation :
1. Double-cliquez simplement sur **`launch-doc.cmd`**.
2. Choisissez le mode de lancement :
   * **[1] (ou Entrée)** : Lancer les **deux serveurs** (Français et Anglais).
   * **[2] (ou taper `fr`)** : Lancer uniquement la **documentation française** (Port 8000).
   * **[3] (ou taper `en`)** : Lancer uniquement la **documentation anglaise** (Port 8001).
3. Renseignez la ou les branches demandées :
   * Si vous avez choisi les deux serveurs, vous pourrez choisir s'ils partagent le même nom de branche ou des noms distincts.
   * Si vous n'avez choisi qu'un seul serveur, seule la branche du dépôt concerné vous sera demandée.
4. Le script valide l'existence des branches, effectue le `git pull`, et ouvre le/les onglet(s) correspondant(s), accessibles aux adresses :
   * Version française : [http://127.0.0.1:8000](http://127.0.0.1:8000)
   * Version anglaise : [http://127.0.0.1:8001](http://127.0.0.1:8001)
