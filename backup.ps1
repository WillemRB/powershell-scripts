<# Scipts that creates backups or restores game files #>


function Log([System.String]$file, [System.String]$status, [System.ConsoleColor]$color) 
{
    Write-Host "`t[" -NoNewline
    Write-Host $status -ForegroundColor $color -NoNewline
    Write-Host "] " -NoNewline
    Write-Host $file
}

function CopyIfNewer([System.String]$fileName, [System.String]$sourceDir, [System.String]$targetDir) 
{
    $sourcePath = Join-Path $sourceDir $fileName
    $targetPath = Join-Path $targetDir $fileName

    if (-not (Test-Path $sourcePath)) 
    {
        Log $fileName "REMOVE" Red
        return
    }

    if (-not (Test-Path $targetPath)) 
    {
        Log $fileName "CREATE" Green
        Copy-Item $sourcePath $targetPath
        return
    }
    
    $sourceFile = Get-Item $sourcePath
    $targetFile = Get-Item $targetPath

    if ($sourceFile.LastWriteTime -gt $targetFile.LastWriteTime) 
    {
        Log $fileName "UPDATE" Green
        Copy-Item $sourcePath $targetPath
        return
    }
    elseif ($sourceFile.LastWriteTime -eq $targetFile.LastWriteTime) 
    {
        Log $fileName " SKIP " Gray
        return
    }
    elseif ($sourceFile.LastWriteTime -lt $targetFile.LastWriteTime) 
    {
        Log $fileName " WARN " Yellow
        Write-Host "`t`tTarget is newer than Source"
        return
    }
}

$games =  (Get-Content .\data.json | Out-String | ConvertFrom-Json)

foreach ($game in $games.games)
{
    Write-Host $game.name
    foreach ($file in $game.files)
    {
        CopyIfNewer $file $game.baseDir $game.targetDir
    }
}
