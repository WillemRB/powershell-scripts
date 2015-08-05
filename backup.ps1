<# 
    Scipts that creates backups or restores game files 

    Flags:
        -Force - Overwrite files that have no changes or would otherwise not be copied.
        -CleanTarget - Remove the $targetFile if the $sourceFile doesn't exist
                       Items are moved to the Recycle bin.
#>
Param(
    [Parameter(Mandatory = $True)]$Path,
    [Switch]$Force = $False,
    [Switch]$CleanTarget = $False
)

Add-Type -AssemblyName Microsoft.VisualBasic

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
        if ($CleanTarget -and (Test-Path $targetPath))
        {
            Log $fileName "REMOVE" Red
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($targetPath, 'OnlyErrorDialogs', 'SendToRecycleBin')
            return
        }

        Log $fileName " GONE " Red
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
        if ($Force)
        {
            Log $fileName "FORCED" Magenta
            Copy-Item $sourcePath $targetPath
            return
        }

        Log $fileName " SKIP " Gray
        return
    }
    elseif ($sourceFile.LastWriteTime -lt $targetFile.LastWriteTime) 
    {
        if ($Force)
        {
            Log $fileName "FORCED" Magenta
            Copy-Item $sourcePath $targetPath
        }
        else
        {
            Log $fileName " WARN " Yellow
        }

        Write-Host "`t`tTarget is newer than Source"
        return
    }
}

if (Test-Path $Path)
{
    $games =  (Get-Content $Path | Out-String | ConvertFrom-Json)

    foreach ($game in $games.games)
    {
        Write-Host $game.name
        foreach ($file in $game.files)
        {
            CopyIfNewer $file $game.baseDir $game.targetDir
        }
    }
}
else
{
    Write-Host "File '$Path' does not exist!" -ForegroundColor Red
}
