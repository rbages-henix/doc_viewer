# Outils de prévisualisation locale - SquashTM Doc

Ce dépôt contient les outils nécessaires pour lancer rapidement les serveurs locaux de documentation SquashTM (Français et Anglais), cloner automatiquement les dépôts manquants, basculer sur les bonnes branches de travail, et ajouter des boutons d'accès rapide directement dans les Merge Requests de GitLab.

---

## 🛠️ Prérequis

1. Avoir [Git for Windows](https://git-scm.com/) installé sur votre machine.
2. Avoir installé l'extension de navigateur [Tampermonkey](https://www.tampermonkey.net/).
3. Avoir installé Python et MkDocs (`pip install mkdocs`).
4. *(Optionnel mais recommandé)* Utiliser **Windows Terminal** (inclus par défaut sur Windows 11) pour bénéficier de l'ouverture automatique sous forme d'onglets.

---

## 🚀 Étape 1 : Installation du script de prévisualisation (GitLab)

Grâce à Tampermonkey, l'installation se fait en un seul clic :

1. Cliquez sur le lien suivant pour ouvrir le script brut : **[INSTALLER LE SCRIPT (cliquez ici)](https://gitlab.com/henixdevelopment/squash/doc/VOTRE_PROJET_OUTILS/-/raw/main/gitlab-doc-link.user.js)** *(remplacez par l'URL "Raw" exacte de votre fichier)*.
2. Tampermonkey s'ouvre automatiquement dans votre navigateur. Cliquez sur **Installer** (ou *Mettre à jour*).

### Fonctionnalités dans vos Merge Requests :
* **Fichiers Markdown (`.md`)** : Un bouton **📖 Doc** apparaît à côté de chaque fichier `.md` modifié dans l'onglet *Changes* de la MR pour l'ouvrir directement sur votre serveur local.
* **Images modifiées (`.png`, `.jpg`, etc.)** : Un bouton **📖 Doc** apparaît également à côté des images :
  * *Au survol du bouton (hover)* : Le script interroge discrètement l'API de GitLab pour identifier la page `.md` exacte qui utilise cette image. Si elle est trouvée, le bouton se transforme en **📖 Doc 🎯** et pointe vers la page exacte.
  * *Par défaut / Hors-ligne* : Le bouton pointe vers le dossier parent de la section contenant l'image.

---

## 💻 Étape 2 : Lancement automatique des serveurs (PowerShell)

Vous n'avez pas besoin d'avoir cloné les documentations au préalable : le script s'occupe de tout.

1. Téléchargez (ou clonez) ce dépôt d'outils.
2. Copiez les deux fichiers suivants :
   * `launch-doc.ps1`
   * `launch-doc.cmd`
3. Collez-les dans le dossier où vous souhaitez héberger vos dépôts de documentation (ex: `C:\Projets\`).

```text
📁 C:\Projets\
├── 📄 launch-doc.ps1
└── 📄 launch-doc.cmd
```

---

## 📖 Utilisation

1. Double-cliquez simplement sur **`launch-doc.cmd`**.
2. **Choix du mode** :
   * **[1] (ou Entrée)** : Lancer les **deux serveurs** (Français + Anglais).
   * **[2] (ou taper `fr`)** : Lancer uniquement le serveur **Français** (Port 8000).
   * **[3] (ou taper `en`)** : Lancer uniquement le serveur **Anglais** (Port 8001).
3. **Clonage automatique (si premier lancement)** :
   * Si les dossiers `squashtm-doc-fr` ou `squashtm-doc-en` n'existent pas encore, le script vous proposera de les cloner automatiquement via HTTPS. Appuyez simplement sur **Entrée** pour valider.
4. **Choix de la / des branche(s)** :
   * Si vous lancez les deux serveurs, vous pouvez choisir d'utiliser une **branche commune** (ex: `doc-tm-15`) ou de renseigner des **branches différentes** pour le français et l'anglais.
5. **Démarrage** :
   * Le script valide l'existence des branches sur GitLab, effectue un `git checkout` suivi d'un `git pull`, puis démarre les serveurs MkDocs dans des onglets dédiés :
     * Version française : [http://127.0.0.1:8000](http://127.0.0.1:8000)
     * Version anglaise : [http://127.0.0.1:8001](http://127.0.0.1:8001)