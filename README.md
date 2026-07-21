# doc_viewer
# Outils de prévisualisation locale - SquashTM Doc

Ce dépôt contient les outils nécessaires pour lancer rapidement les serveurs locaux de documentation (Français et Anglais) et ajouter des boutons d'accès rapide directement dans les Merge Requests de GitLab.

---

## 🛠️ Prérequis

1. Avoir cloné les dépôts `squashtm-doc-fr` et `squashtm-doc-en` dans le **même dossier parent** sur votre machine.
2. Avoir installé l'extension de navigateur [Tampermonkey](https://www.tampermonkey.net/).
3. Avoir installé Python et MkDocs (généralement déjà configuré si vous travaillez sur la doc).

---

## 🚀 Étape 1 : Installation du script de prévisualisation (GitLab)

Grâce à Tampermonkey, l'installation se fait en un clic :

1. Cliquez sur le lien suivant pour ouvrir le script brut : **[INSTALLER LE SCRIPT (cliquez ici)](https://raw.githubusercontent.com/VOTRE_PSEUDO/VOTRE_REPO/main/gitlab-doc-link.user.js)** *(remplacez par votre vrai lien Raw)*.
2. Tampermonkey va s'ouvrir automatiquement. Cliquez sur le bouton **Installer** (ou *Mettre à jour*).

*Désormais, lorsque vous visiterez une Merge Request contenant des fichiers `.md` modifiés dans le dossier `docs/`, un bouton **📖 Doc** apparaîtra à côté de chaque fichier.*

---

## 💻 Étape 2 : Configuration du script de lancement local (PowerShell)

Pour que les boutons de prévisualisation fonctionnent, vos serveurs locaux MkDocs doivent être lancés.

1. Téléchargez (ou clonez) ce dépôt d'outils.
2. Copiez les deux fichiers suivants :
   * `launch-doc.ps1`
   * `launch-doc.cmd`
3. Collez-les dans le **dossier parent** de vos documentations (celui qui contient directement les dossiers `squashtm-doc-fr` et `squashtm-doc-en`).

### Utilisation :
* Double-cliquez simplement sur **`launch-doc.cmd`**.
* Saisissez le nom de la branche souhaitée (ex: `doc-tm-15`).
* Le script va valider la branche, faire un `git pull` sur les deux dépôts, puis ouvrir deux onglets dans votre terminal aux adresses :
  * Version française : [http://127.0.0.1:8000](http://127.0.0.1:8000)
  * Version anglaise : [http://127.0.0.1:8001](http://127.0.0.1:8001)
