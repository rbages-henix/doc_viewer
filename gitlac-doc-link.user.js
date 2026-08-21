// ==UserScript==
// @name         GitLab - Lien direct vers Doc locale
// @namespace    http://tampermonkey.net/
// @version      1.4
// @description  Ajoute un bouton pour ouvrir directement le rendu HTML local d'un fichier doc (.md ou image) modifié dans une Merge Request GitLab.
// @author       rbages
// @match        https://gitlab.com/*
// @updateURL    https://github.com/rbages-henix/doc_viewer/raw/refs/heads/main/gitlac-doc-link.user.js
// @downloadURL  https://github.com/rbages-henix/doc_viewer/raw/refs/heads/main/gitlac-doc-link.user.js
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
        return BASE_URL_FR;
    }

    // Récupère l'ID du projet GitLab actuel depuis le DOM ou l'objet global gon
    function getProjectId() {
        if (window.gon && window.gon.project_id) {
            return window.gon.project_id;
        }
        const bodyProjectId = document.body.getAttribute('data-project-id');
        if (bodyProjectId) {
            return bodyProjectId;
        }
        const inputProjectId = document.getElementById('project_id') || document.querySelector('input[name="project_id"]');
        if (inputProjectId) {
            return inputProjectId.value;
        }
        return null;
    }

    // Recherche via l'API GitLab quel fichier .md fait référence à cette image
    async function findMarkdownReferencingImage(projectId, filename) {
        try {
            const response = await fetch(`/api/v4/projects/${projectId}/search?scope=blobs&search=${encodeURIComponent(filename)}`, {
                credentials: 'same-origin'
            });
            if (!response.ok) return null;
            const results = await response.json();

            if (Array.isArray(results)) {
                // On cherche le premier fichier se terminant par .md qui mentionne l'image
                const mdMatch = results.find(item => {
                    const path = item.path || item.filename;
                    return path && path.endsWith('.md');
                });
                if (mdMatch) {
                    return mdMatch.path || mdMatch.filename;
                }
            }
        } catch (error) {
            console.warn("[Tampermonkey] Impossible de rechercher la référence de l'image via l'API GitLab", error);
        }
        return null;
    }

    function addDocButtons() {
        // Sélecteur plus large pour trouver les en-têtes de fichiers
        const containers = document.querySelectorAll('div[data-testid="file-title-container"]:not([data-doc-preview-added]), .file-header-content:not([data-doc-preview-added])');
        const localBaseUrl = getLocalBaseUrl();

        containers.forEach(container => {
            container.setAttribute('data-doc-preview-added', 'true');

            // Recherche multi-sources pour récupérer le nom du fichier
            let filePath = container.getAttribute('data-qa-file-name') 
                        || container.getAttribute('data-file-path')
                        || container.querySelector('.file-title-name, strong, a.file-header-link')?.innerText?.trim();

            if (!filePath || !filePath.includes('docs/')) {
                return;
            }

            // Nettoyage au cas où le chemin contienne des espaces ou retours à la ligne
            filePath = filePath.replace(/^[^\w\/]*/, '').trim();

            const isMarkdown = filePath.endsWith('.md');
            const isImage = /\.(png|jpe?g|gif|svg|webp|bmp|tiff)$/i.test(filePath);

            if (!isMarkdown && !isImage) {
                return;
            }

            let relativePath;
            if (isMarkdown) {
                relativePath = filePath.replace(/^.*?docs\//, '').replace(/\.md$/, '.html');
            } else if (isImage) {
                if (/\/(resources|images|img|assets|pictures|media)\//i.test(filePath)) {
                    relativePath = filePath.replace(/\/(resources|images|img|assets|pictures|media)\/.*$/i, '/');
                } else {
                    relativePath = filePath.substring(0, filePath.lastIndexOf('/') + 1);
                }
                relativePath = relativePath.replace(/^.*?docs\//, '');
            }

            const cleanBaseUrl = localBaseUrl.replace(/\/$/, '');
            const targetUrl = `${cleanBaseUrl}/${relativePath}`;

            // Recherche élargie de la zone où accrocher le bouton
            const fileActions = container.closest('.file-holder, .diff-file, [data-testid="diff-file"]')
                                ?.querySelector('.file-actions, [data-testid="file-actions"]') 
                             || container.querySelector('.file-actions');

            if (!fileActions) return;

            const viewedCheckbox = fileActions.querySelector('.gl-form-checkbox');

            const btn = document.createElement('a');
            btn.href = targetUrl;
            btn.target = '_blank';
            btn.rel = 'noopener noreferrer';
            btn.className = 'btn gl-button btn-default btn-sm btn-default-tertiary gl-mr-3';
            btn.style.display = 'inline-flex';
            btn.style.alignItems = 'center';
            btn.innerHTML = '📖 Doc';
            btn.title = isImage 
                ? "Ouvre le dossier de l'image (Recherche de la page exacte au survol...)" 
                : "Ouvrir le rendu de la page";

            if (isImage) {
                btn.addEventListener('mouseenter', () => {
                    if (btn.getAttribute('data-precise-found') === 'true' || btn.getAttribute('data-searching') === 'true') return;
                    btn.setAttribute('data-searching', 'true');
                    const projectId = getProjectId();
                    if (projectId) {
                        const filename = filePath.split('/').pop();
                        findMarkdownReferencingImage(projectId, filename).then(mdPath => {
                            btn.setAttribute('data-searching', 'false');
                            if (mdPath) {
                                const preciseRelativePath = mdPath.replace(/^.*?docs\//, '').replace(/\.md$/, '.html');
                                btn.href = `${cleanBaseUrl}/${preciseRelativePath}`;
                                btn.title = `Page exacte trouvée : ${preciseRelativePath}`;
                                btn.innerHTML = '📖 Doc 🎯';
                                btn.setAttribute('data-precise-found', 'true');
                            }
                        });
                    }
                }, { once: true });
            }

            if (viewedCheckbox) {
                fileActions.insertBefore(btn, viewedCheckbox);
            } else {
                fileActions.appendChild(btn);
            }
        });
    }

    // Observation des modifications du DOM (architecture SPA de GitLab)
    const observer = new MutationObserver(() => {
        addDocButtons();
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    addDocButtons();
})();