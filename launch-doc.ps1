# Forcer PowerShell a utiliser l'UTF-8 pour l'affichage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Noms des dossiers des depots
$RepoFr = "squashtm-doc-fr"
$RepoEn = "squashtm-doc-en"

# --- CONFIGURATION DES URLS DE CLONAGE ---
$DefaultGitUrlFr = "https://gitlab.com/henixdevelopment/squash/doc/squashtm-doc-fr.git"
$DefaultGitUrlEn = "https://gitlab.com/henixdevelopment/squash/doc/squashtm-doc-en.git"
# -----------------------------------------

# Fonction utilitaire pour afficher une erreur et bloquer la fermeture automatique de la fenetre
function Stop-Script {
    param([string]$Message)
    Write-Host "`n[ERREUR] $Message" -ForegroundColor Red
    Write-Host "`nAppuyez sur Entree pour fermer cette fenetre..." -ForegroundColor Yellow
    $null = Read-Host
    Exit 1
}

# 1. Choix du mode de lancement
Write-Host "Quel(s) serveur(s) souhaitez-vous lancer ?" -ForegroundColor Cyan
Write-Host "  [1] Les deux (FR + EN) [Defaut]"
Write-Host "  [2] Francais uniquement (FR - Port 8000)"
Write-Host "  [3] Anglais uniquement (EN - Port 8001)"
$Mode = Read-Host "Votre choix (1/2/3) [Defaut: 1]"

$LaunchFr = $false
$LaunchEn = $false

if ($Mode.Trim() -eq '2' -or $Mode.Trim().ToUpper() -eq 'FR' -or $Mode.Trim().ToUpper() -eq 'F') {
    $LaunchFr = $true
} elseif ($Mode.Trim() -eq '3' -or $Mode.Trim().ToUpper() -eq 'EN' -or $Mode.Trim().ToUpper() -eq 'E') {
    $LaunchEn = $true
} else {
    $LaunchFr = $true
    $LaunchEn = $true
}

# Fonction pour verifier et proposer de cloner un depot s'il est manquant
function Ensure-RepoExists {
    param(
        [string]$RepoPath,
        [string]$DefaultUrl
    )
    if (!(Test-Path $RepoPath)) {
        Write-Warning "Le dossier '$RepoPath' n'existe pas dans le repertoire courant."
        $CloneChoice = Read-Host "Souhaitez-vous cloner le depot '$RepoPath' maintenant ? (O/N) [Defaut: O]"
        
        if ([string]::IsNullOrWhiteSpace($CloneChoice) -or $CloneChoice.Trim().ToUpper() -eq 'O' -or $CloneChoice.Trim().ToUpper() -eq 'Y') {
            $UrlToUse = $DefaultUrl
            
            if ([string]::IsNullOrWhiteSpace($UrlToUse)) {
                $UrlToUse = Read-Host "Entrez l'URL Git de clonage pour $RepoPath (SSH ou HTTPS)"
            } else {
                $CustomUrl = Read-Host "Entrez l'URL Git [Defaut: $UrlToUse]"
                if (![string]::IsNullOrWhiteSpace($CustomUrl)) {
                    $UrlToUse = $CustomUrl
                }
            }
            
            if ([string]::IsNullOrWhiteSpace($UrlToUse)) {
                Stop-Script "L'URL de clonage est requise pour cloner le depot."
            }
            
            Write-Host "Clonage de '$RepoPath' en cours depuis $UrlToUse..." -ForegroundColor Cyan
            git clone $UrlToUse $RepoPath
            
            if ($LASTEXITCODE -ne 0 -or !(Test-Path $RepoPath)) {
                Stop-Script "Le clonage du depot '$RepoPath' a echoue. Verifiez l'URL et vos identifiants d'acces."
            }
            Write-Host "Depot '$RepoPath' clone avec succes." -ForegroundColor Green
        } else {
            Stop-Script "Le dossier '$RepoPath' est requis pour continuer."
        }
    }
}

# 2. Verification et proposition de clonage automatique
if ($LaunchFr) {
    Ensure-RepoExists -RepoPath $RepoFr -DefaultUrl $DefaultGitUrlFr
}

if ($LaunchEn) {
    Ensure-RepoExists -RepoPath $RepoEn -DefaultUrl $DefaultGitUrlEn
}

# 3. Collecte des noms de branches selon le mode choisi
if ($LaunchFr -and $LaunchEn) {
    $Choice = Read-Host "Utiliser la meme branche pour les deux depots ? (O/N) [Defaut: O]"
    if ([string]::IsNullOrWhiteSpace($Choice) -or $Choice.Trim().ToUpper() -eq 'O' -or $Choice.Trim().ToUpper() -eq 'Y') {
        $Branch = Read-Host "Entrez le nom de la branche commune"
        if ([string]::IsNullOrWhiteSpace($Branch)) {
            Stop-Script "Le nom de la branche ne peut pas etre vide."
        }
        $BranchFr = $Branch
        $BranchEn = $Branch
    } else {
        $BranchFr = Read-Host "Entrez le nom de la branche pour le depot FR ($RepoFr)"
        if ([string]::IsNullOrWhiteSpace($BranchFr)) {
            Stop-Script "Le nom de la branche FR ne peut pas etre vide."
        }
        $BranchEn = Read-Host "Entrez le nom de la branche pour le depot EN ($RepoEn)"
        if ([string]::IsNullOrWhiteSpace($BranchEn)) {
            Stop-Script "Le nom de la branche EN ne peut pas etre vide."
        }
    }
} elseif ($LaunchFr) {
    $BranchFr = Read-Host "Entrez le nom de la branche pour le depot FR ($RepoFr)"
    if ([string]::IsNullOrWhiteSpace($BranchFr)) {
        Stop-Script "Le nom de la branche FR ne peut pas etre vide."
    }
} elseif ($LaunchEn) {
    $BranchEn = Read-Host "Entrez le nom de la branche pour le depot EN ($RepoEn)"
    if ([string]::IsNullOrWhiteSpace($BranchEn)) {
        Stop-Script "Le nom de la branche EN ne peut pas etre vide."
    }
}

# Fonction pour verifier si une branche existe (localement ou sur origin) dans un depot specifique
function Test-BranchExists {
    param(
        [string]$RepoPath,
        [string]$BranchName
    )
    Push-Location $RepoPath
    git fetch origin --quiet
    
    # Verification locale
    git show-ref --verify --quiet "refs/heads/$BranchName"
    $localExists = ($LASTEXITCODE -eq 0)
    
    # Verification distante
    git show-ref --verify --quiet "refs/remotes/origin/$BranchName"
    $remoteExists = ($LASTEXITCODE -eq 0)
    
    Pop-Location
    return ($localExists -or $remoteExists)
}

# 4. Validation des branches sur les depots presents
if ($LaunchFr) {
    if (!(Test-BranchExists -RepoPath $RepoFr -BranchName $BranchFr)) {
        Stop-Script "La branche '$BranchFr' n'existe pas dans le depot $RepoFr."
    }
}

if ($LaunchEn) {
    if (!(Test-BranchExists -RepoPath $RepoEn -BranchName $BranchEn)) {
        Stop-Script "La branche '$BranchEn' n'existe pas dans le depot $RepoEn."
    }
}

Write-Host "Validation reussie des branches." -ForegroundColor Green
$CurrentDir = Get-Location

# 5. Lancement des onglets (Windows Terminal) ou fenetres separees (Fallback)
$WTAvailable = $null -ne (Get-Command wt -ErrorAction SilentlyContinue)

if ($WTAvailable) {
    if ($LaunchFr -and $LaunchEn) {
        wt -w 0 nt -d "$CurrentDir\$RepoFr" --title "Doc FR [$BranchFr]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc FR [$BranchFr]'\`; git checkout '$BranchFr'\`; git pull\`; mkdocs serve -a 127.0.0.1:8000" `; nt -d "$CurrentDir\$RepoEn" --title "Doc EN [$BranchEn]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc EN [$BranchEn]'\`; git checkout '$BranchEn'\`; git pull\`; mkdocs serve -a 127.0.0.1:8001"
    } elseif ($LaunchFr) {
        wt -w 0 nt -d "$CurrentDir\$RepoFr" --title "Doc FR [$BranchFr]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc FR [$BranchFr]'\`; git checkout '$BranchFr'\`; git pull\`; mkdocs serve -a 127.0.0.1:8000"
    } elseif ($LaunchEn) {
        wt -w 0 nt -d "$CurrentDir\$RepoEn" --title "Doc EN [$BranchEn]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc EN [$BranchEn]'\`; git checkout '$BranchEn'\`; git pull\`; mkdocs serve -a 127.0.0.1:8001"
    }
} else {
    Write-Warning "Windows Terminal n'a pas ete detecte. Ouverture dans des fenetres PowerShell classiques separees."
    if ($LaunchFr) {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoFr'; `$Host.UI.RawUI.WindowTitle = 'Doc FR [$BranchFr]'; git checkout '$BranchFr'; git pull; mkdocs serve -a 127.0.0.1:8000"
    }
    if ($LaunchEn) {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoEn'; `$Host.UI.RawUI.WindowTitle = 'Doc EN [$BranchEn]'; git checkout '$BranchEn'; git pull; mkdocs serve -a 127.0.0.1:8001"
    }
}