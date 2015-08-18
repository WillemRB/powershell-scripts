<# 
    Scipts that creates backups or restores game files 

    Flags:
        -Force - Overwrite files that have no changes or would otherwise not be copied.
        -CleanTarget - Remove the $targetFile if the $sourceFile doesn't exist
                       Items are moved to the Recycle bin.
#>
Param(
    [Parameter(Mandatory = $True)]$Path,
    [Switch]$Force = $false,
    [Switch]$CleanTarget = $false
)

Add-Type -AssemblyName Microsoft.VisualBasic

$totalFileCount = 0
$global:filesHandledCount = 0

function Log([System.String]$file, [System.String]$status, [System.ConsoleColor]$color) 
{
    Write-Host "`t[" -NoNewline
    Write-Host $status -ForegroundColor $color -NoNewline
    Write-Host "] " -NoNewline
    Write-Host $file
}

function BackupFile([System.String]$fileName, [System.String]$sourceDir, [System.String]$targetDir) 
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

function TotalFileCount($games)
{
    $sum = 0

    $games.games | % `
    { 
        # Add file count
        $sum += $_.files.Length

        # Add file count of each directory
        foreach ($dir in $_.directories)
        {
            $fullPath = Join-Path $_.sourceDir $dir

            if (Test-Path $fullPath)
            {
                $sum += (Get-Item $fullPath).GetFiles().Length
            }
        }
    }

    Write-Host "$sum files in total"

    return $sum
}

function ProgressPercentage
{
    $global:filesHandledCount += 1

    return [int](($filesHandledCount / $totalFileCount) * 100)
}

if (Test-Path $Path)
{
    $games =  (Get-Content $Path | Out-String | ConvertFrom-Json)

    $totalFileCount = TotalFileCount $games

    foreach ($game in $games.games)
    {
        Write-Host $game.name
        foreach ($file in $game.files)
        {
            Write-Progress -Activity $game.name -Status $file -PercentComplete $(ProgressPercentage)
            BackupFile $file $game.sourceDir $game.targetDir
        }
        foreach ($dir in $game.directories)
        {
            $dirPath = Join-Path $game.sourceDir $dir

            if (Test-Path $dirPath)
            {
                (Get-Item $dirPath).GetFiles() | % `
                { 
                    Write-Progress -Activity $game.name -Status $dir -PercentComplete $(ProgressPercentage)
                    BackupFile $_.Name $dirPath $game.targetDir
                }
            }
        }
    }
}
else
{
    Write-Host "File '$Path' does not exist!" -ForegroundColor Red
}
