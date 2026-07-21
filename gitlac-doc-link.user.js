// ==UserScript==
// @name         GitLab - Lien direct vers Doc locale
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Ajoute un bouton pour ouvrir directement le rendu HTML local d'un fichier doc modifié dans une Merge Request GitLab.
// @author       MonPseudo
// @match        https://gitlab.com/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    // --- CONFIGURATION ---
    const BASE_URL_FR = 'http://127.0.0.1:8000';
    const BASE_URL_EN = 'http://127.0.0.1:8001';
    // ---------------------

    // Détermine l'adresse locale à utiliser en analysant l'URL GitLab actuelle
    function getLocalBaseUrl() {
        const currentUrl = window.location.href;
        if (currentUrl.includes('squashtm-doc-en')) {
            return BASE_URL_EN;
        }
        // Par défaut ou si l'URL contient squashtm-doc-fr
        return BASE_URL_FR;
    }

    function addDocButtons() {
        // Recherche des conteneurs de titre de fichier qui n'ont pas encore été traités
        const containers = document.querySelectorAll('div[data-testid="file-title-container"]:not([data-doc-preview-added])');
        const localBaseUrl = getLocalBaseUrl();

        containers.forEach(container => {
            // On marque le conteneur pour éviter d'ajouter le bouton plusieurs fois au cours des rendus de GitLab
            container.setAttribute('data-doc-preview-added', 'true');

            const filePath = container.getAttribute('data-qa-file-name');
            // On filtre pour ne traiter que les fichiers Markdown situés dans "docs/"
            if (!filePath || !filePath.startsWith('docs/') || !filePath.endsWith('.md')) {
                return;
            }

            // Transformation du chemin :
            // "docs/admin-guide/customize-entities/manage-prompt-sets.md" -> "admin-guide/customize-entities/manage-prompt-sets.html"
            const relativePath = filePath.replace(/^docs\//, '').replace(/\.md$/, '.html');
            const cleanBaseUrl = localBaseUrl.replace(/\/$/, '');
            const targetUrl = `${cleanBaseUrl}/${relativePath}`;

            // Récupération de la zone d'actions (à droite dans l'en-tête)
            const fileActions = container.querySelector('.file-actions');
            if (!fileActions) return;

            // Ciblage de la case "Viewed" pour pouvoir insérer notre bouton juste avant
            const viewedCheckbox = fileActions.querySelector('.gl-form-checkbox');

            // Création du bouton avec le style natif de GitLab
            const btn = document.createElement('a');
            btn.href = targetUrl;
            btn.target = '_blank';
            btn.rel = 'noopener noreferrer';
            // Reprise des classes CSS de GitLab pour une intégration visuelle discrète
            btn.className = 'btn gl-button btn-default btn-sm btn-default-tertiary gl-mr-3';
            btn.style.display = 'inline-flex';
            btn.style.alignItems = 'center';
            btn.innerHTML = '📖 Doc';

            if (viewedCheckbox) {
                fileActions.insertBefore(btn, viewedCheckbox);
            } else {
                // Fallback si la case "Viewed" n'est pas trouvée (par exemple si déjà cochée ou contexte différent)
                fileActions.appendChild(btn);
            }
        });
    }

    // GitLab utilise une architecture SPA (Single Page Application).
    // On observe donc les modifications du DOM pour injecter le bouton dès que de nouveaux éléments apparaissent.
    const observer = new MutationObserver(() => {
        addDocButtons();
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    // Premier essai au chargement initial de la page
    addDocButtons();
})();
