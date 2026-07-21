# Noms des dossiers des dépôts
$RepoFr = "squashtm-doc-fr"
$RepoEn = "squashtm-doc-en"

# Vérification de l'existence des dossiers
if (!(Test-Path $RepoFr) -or !(Test-Path $RepoEn)) {
    Write-Error "Erreur : Les dossiers '$RepoFr' ou '$RepoEn' n'existent pas dans ce répertoire."
    Exit
}

# Demander le nom de la branche
$Branch = Read-Host "Entrez le nom de la branche sur laquelle vous positionner"

if ([string]::IsNullOrWhiteSpace($Branch)) {
    Write-Error "Erreur : Le nom de la branche ne peut pas être vide."
    Exit
}

# Fonction pour vérifier si la branche existe localement ou sur origin
function Test-BranchExists {
    param($RepoPath)
    Push-Location $RepoPath
    git fetch origin --quiet
    
    # Vérification locale
    git show-ref --verify --quiet "refs/heads/$Branch"
    $localExists = ($LASTEXITCODE -eq 0)
    
    # Vérification distante
    git show-ref --verify --quiet "refs/remotes/origin/$Branch"
    $remoteExists = ($LASTEXITCODE -eq 0)
    
    Pop-Location
    return ($localExists -or $remoteExists)
}

# Validation de la branche sur les deux dépôts
if (!(Test-BranchExists $RepoFr)) {
    Write-Error "Erreur : La branche '$Branch' n'existe pas dans $RepoFr."
    Exit
}
if (!(Test-BranchExists $RepoEn)) {
    Write-Error "Erreur : La branche '$Branch' n'existe pas dans $RepoEn."
    Exit
}

Write-Host "La branche '$Branch' est valide sur les deux dépôts." -ForegroundColor Green
$CurrentDir = Get-Location

# Vérification si Windows Terminal (wt.exe) est disponible sur la machine
$WTAvailable = $null -ne (Get-Command wt -ErrorAction SilentlyContinue)

if ($WTAvailable) {
    # Les points-virgules internes du bloc -Command sont échappés en \`; pour que Windows Terminal ne les fragmente pas.
    # Seul le point-virgule entre les deux commandes d'onglets (`;`) est conservé pour diviser la commande wt.
    wt -w 0 nt -d "$CurrentDir\$RepoFr" --title "Doc FR [$Branch]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc FR [$Branch]'\`; git checkout '$Branch'\`; git pull\`; mkdocs serve -a 127.0.0.1:8000" `; nt -d "$CurrentDir\$RepoEn" --title "Doc EN [$Branch]" powershell -NoExit -Command "`$Host.UI.RawUI.WindowTitle = 'Doc EN [$Branch]'\`; git checkout '$Branch'\`; git pull\`; mkdocs serve -a 127.0.0.1:8001"
} else {
    # Version de repli si Windows Terminal n'est pas présent
    Write-Warning "Windows Terminal n'a pas été détecté. Ouverture dans des fenêtres PowerShell classiques séparées."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoFr'; `$Host.UI.RawUI.WindowTitle = 'Doc FR [$Branch]'; git checkout '$Branch'; git pull; mkdocs serve -a 127.0.0.1:8000"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$CurrentDir\$RepoEn'; `$Host.UI.RawUI.WindowTitle = 'Doc EN [$Branch]'; git checkout '$Branch'; git pull; mkdocs serve -a 127.0.0.1:8001"
}
