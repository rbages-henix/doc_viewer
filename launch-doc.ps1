# Forcer PowerShell a utiliser l'UTF-8 pour l'affichage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Noms des dossiers des depots
$RepoFr = "squashtm-doc-fr"
$RepoEn = "squashtm-doc-en"

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
    # Option par defaut (1 ou appui direct sur Entree) : Les deux
    $LaunchFr = $true
    $LaunchEn = $true
}

# 2. Collecte des noms de branches selon le mode choisi
if ($LaunchFr -and $LaunchEn) {
    $Choice = Read-Host "Utiliser la meme branche pour les deux depots ? (O/N) [Defaut: O]"
    if ([string]::IsNullOrWhiteSpace($Choice) -or $Choice.Trim().ToUpper() -eq 'O' -or $Choice.Trim().ToUpper() -eq 'Y') {
        $Branch = Read-Host "Entrez le nom de la branche commune"
        if ([string]::IsNullOrWhiteSpace($Branch)) {
            Write-Error "Erreur : Le nom de la branche ne peut pas etre vide."
            Exit
        }
        $BranchFr = $Branch
        $BranchEn = $Branch
    } else {
        $BranchFr = Read-Host "Entrez le nom de la branche pour le depot FR ($RepoFr)"
        if ([string]::IsNullOrWhiteSpace($BranchFr)) {
            Write-Error "Erreur : Le nom de la branche FR ne peut pas etre vide."
            Exit
        }
        $BranchEn = Read-Host "Entrez le nom de la branche pour le depot EN ($RepoEn)"
        if ([string]::IsNullOrWhiteSpace($BranchEn)) {
            Write-Error "Erreur : Le nom de la branche EN ne peut pas etre vide."
            Exit
        }
    }
} elseif ($LaunchFr) {
    $BranchFr = Read-Host "Entrez le nom de la branche pour le depot FR ($RepoFr)"
    if ([string]::IsNullOrWhiteSpace($BranchFr)) {
        Write-Error "Erreur : Le nom de la branche FR ne peut pas etre vide."
        Exit
    }
} elseif ($LaunchEn) {
    $BranchEn = Read-Host "Entrez le nom de la branche pour le depot EN ($RepoEn)"
    if ([string]::IsNullOrWhiteSpace($BranchEn)) {
        Write-Error "Erreur : Le nom de la branche EN ne peut pas etre vide."
        Exit
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

# 3. Verification des dossiers et validation des branches nécessaires
if ($LaunchFr) {
    if (!(Test-Path $RepoFr)) {
        Write-Error "Erreur : Le dossier '$RepoFr' n'existe pas dans ce repertoire."
        Exit
    }
    if (!(Test-BranchExists -RepoPath $RepoFr -BranchName $BranchFr)) {
        Write-Error "Erreur : La branche '$BranchFr' n'existe pas dans le depot $RepoFr."
        Exit
    }
}

if ($LaunchEn) {
    if (!(Test-Path $RepoEn)) {
        Write-Error "Erreur : Le dossier '$RepoEn' n'existe pas dans ce repertoire."
        Exit
    }
    if (!(Test-BranchExists -RepoPath $RepoEn -BranchName $BranchEn)) {
        Write-Error "Erreur : La branche '$BranchEn' n'existe pas dans le depot $RepoEn."
        Exit
    }
}

Write-Host "Validation reussie des branches." -ForegroundColor Green
$CurrentDir = Get-Location

# 4. Lancement des onglets (Windows Terminal) ou fenetres separees (Fallback)
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