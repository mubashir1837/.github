param(
    [int]$Count = 10,
    [int]$DelaySeconds = 2,
    [string]$RepoPath = (Get-Location).Path,
    [string]$Branch = "main",
    [switch]$Continuous
)

Set-Location $RepoPath

# A list of random commit messages to make them look a bit more realistic
$messages = @(
    "Update commits.md with new log entry",
    "Minor adjustment for commit tracking",
    "Enhanced commit history monitoring",
    "Routine maintenance of commits.md",
    "Refactoring commit log update logic",
    "Bugfix for commit tracking entry",
    "Added additional metadata for commitments",
    "Commit tracker daily update",
    "CI: Automatically updating commits status",
    "Update commit history log",
    "Optimize commit metadata structure",
    "Syncing commits with origin",
    "Daily maintenance of commits log",
    "Adding timestamp for better tracking",
    "Fixing issues in commit reporting",
    "Improving log file format"
)

$mode = if ($Continuous) { "infinite" } else { "$Count" }
Write-Host "Starting Auto Committer for $mode iterations..." -ForegroundColor Cyan

$i = 1
while ($true) {
    if (-not $Continuous -and $i -gt $Count) {
        break
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.ffffff"
    $msg = $messages[(Get-Random -Minimum 0 -Maximum $messages.Count)]
    
    Write-Host "[$i] Message: $msg" -ForegroundColor Green

    # Change the file
    "# Auto Commit at $timestamp" | Out-File -FilePath commits.md -Encoding utf8 -Append
    
    # Wait for the file to be written
    Start-Sleep -Milliseconds 200

    # Git operations
    git add commits.md
    git commit -m "$msg [id: $i]"
    git push origin $Branch

    if ($Continuous -or $i -lt $Count) {
        # Random sleep if continuous to avoid rate limiting
        $sleepTime = if ($Continuous) { Get-Random -Minimum 5 -Maximum 60 } else { $DelaySeconds }
        Write-Host "Waiting $sleepTime seconds before next commit..." -ForegroundColor Gray
        Start-Sleep -Seconds $sleepTime
    }
    
    $i++
}

Write-Host "Process complete. $i commits pushed." -ForegroundColor Yellow

