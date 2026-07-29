# Forcer PowerShell a utiliser l'UTF-8 pour l'affichage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Noms des dossiers des depots
$RepoFr = "squashtm-doc-fr"
$RepoEn = "squashtm-doc-en"

# Verification de l'existence des dossiers
if (!(Test-Path $RepoFr) -or !(Test-Path $RepoEn)) {
    Write-Error "Erreur : Les dossiers '$RepoFr' ou '$RepoEn' n'existent pas dans ce repertoire."
    Exit
}

# 1. Demander si la branche est commune
$Choice = Read-Host "Utiliser la meme branche pour les deux depots ? (O/N) [Defaut: O]"
if ([string]::IsNullOrWhiteSpace($Choice) -or $Choice.Trim().ToUpper() -eq 'O' -or $Choice.Trim().ToUpper() -eq 'Y') {
    $CommonBranch = $true
} else {
    $CommonBranch = $false
}

# 2. Collecter les noms des branches selon le choix
if ($CommonBranch) {
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

# 3. Validation individuelle des branches
if (!(Test-BranchExists -RepoPath $RepoFr -BranchName $BranchFr)) {
    Write-Error "Erreur : La branche '$BranchFr' n'existe pas dans le depot $RepoFr."
    Exit
}

if (!(Test-BranchExists -RepoPath $RepoEn -BranchName $BranchEn)) {
    Write-Error "Erreur : La branche '$BranchEn' n'existe pas dans le depot $RepoEn."
    Exit
}

# Message de succes de validation
if ($CommonBranch) {
    Write-Host "La branche '$BranchFr' est valide sur les deux depots." -ForegroundColor Green
} else {
    Write-Host "Validation reussie : branche FR '$BranchFr' et branche EN '$BranchEn' sont valides." -ForegroundColor Green
}

$CurrentDir = Get-Location

# 4. Lancement des onglets / fenetres
$WTAvailable = $null -ne (Get-Command wt -ErrorAction SilentlyContinue)

if ($WTAvailable) {
    wt -w 0 nt -d "$CurrentDir\$RepoFr" --title "Doc FR [$BranchFr]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc FR [$BranchFr]'\`; git checkout '$BranchFr'\`; git pull\`; mkdocs serve -a 127.0.0.1:8000" `; nt -d "$CurrentDir\$RepoEn" --title "Doc EN [$BranchEn]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc EN [$BranchEn]'\`; git checkout '$BranchEn'\`; git pull\`; mkdocs serve -a 127.0.0.1:8001"
} else {
    Write-Warning "Windows Terminal n'a pas ete detecte. Ouverture dans des fenetres PowerShell classiques separees."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoFr'; `$Host.UI.RawUI.WindowTitle = 'Doc FR [$BranchFr]'; git checkout '$BranchFr'; git pull; mkdocs serve -a 127.0.0.1:8000"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoEn'; `$Host.UI.RawUI.WindowTitle = 'Doc EN [$BranchEn]'; git checkout '$BranchEn'; git pull; mkdocs serve -a 127.0.0.1:8001"
}