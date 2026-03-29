$url = "https://mubashirali.vercel.app/"
$userAgent = "Mozilla/5.0"

try {
    Write-Host "Fetching website..."
    $html = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing | Select-Object -ExpandProperty Content
    
    # Remove scripts, styles and HTML tags
    $cleanText = $html -replace '(?is)<script[^>]*>.*?</script>', '' -replace '(?is)<style[^>]*>.*?</style>', '' -replace '<[^>]+>', ' '
    
    # Normalize spaces
    $cleanText = $cleanText -replace '\s+', ' '
    
    # Pick a meaningful sentence (min 30 chars), split by period
    $sentences = $cleanText -split '\.' | Where-Object { $_.Trim().Length -ge 30 }
    
    if ($sentences.Count -gt 0) {
        $randomSentence = $sentences | Get-Random
        $finalText = $randomSentence.Trim()
        
        # Max length 160
        if ($finalText.Length -gt 160) {
            $finalText = $finalText.Substring(0, 160)
        }
    } else {
        $finalText = "Mubashir Ali is actively working on AI, ML and Data Science projects."
    }
} catch {
    Write-Host "Error fetching website. Using fallback text."
    $finalText = "Mubashir Ali is actively working on AI, ML and Data Science projects."
}

# Create or append to commits.md
$dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if (-not (Test-Path "commits.md")) {
    $header = "# Mubashir AI Activity Log`n`nAuto-generated from mubashirali.vercel.app scraping.`n"
    Set-Content -Path "commits.md" -Value $header
}

$logEntry = "### $dateStr`n- $finalText`n"
Add-Content -Path "commits.md" -Value $logEntry

Write-Host "Committing and pushing..."

# Ensure config is correct
git config user.name "Mubashir Ali"
git config user.email "mubashirali1837@gmail.com"

git add commits.md

# Only commit if there are changes
$status = git status --porcelain
if ($status -match "commits.md") {
    git commit -m "AI Scraper update from website"
    # Pull latest changes first just in case there were parallel commits
    git pull --rebase origin main
    git push origin main
    Write-Host "Successfully committed and pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "Nothing to commit." -ForegroundColor Yellow
}
