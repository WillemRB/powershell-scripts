<#
    Script to clean Visual Studio solution folders.
#>
Param(
    [Parameter()][string]$projectPath = ".",
    [Parameter()][bool]$ignorePackages = $false
)

Clear-Host

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path

function RemoveDirIfEmpty($directory)
{
    if (($directory.GetFiles().Length -eq 0) -and ($directory.GetDirectories().Length -eq 0) )
    {
        Remove-Item $directory -Recurse -Force
        $name = $directory.BaseName
        Write-Host "Remove directory $name" -ForegroundColor Green
    }
}

Get-ChildItem $projectPath -Recurse `
| Where { $_.FullName.ToLower() -match "(\\bin\\|\\obj\\|\\packages\\|\\testresults\\)(?!packages\.config$)" } `
| ForEach `
    {
        $fullName = $_.FullName.Replace($scriptPath, "")

        if ($_.GetType().Name -eq "DirectoryInfo")
        {
            RemoveDirIfEmpty $_
        }
        elseif ($_.FullName.Contains("packages") -and $ignorePackages)
        {
            # If packages are not to be removed
            Write-Host "Skipped $fullName" -ForegroundColor Cyan
        }
        else
        {
            $directory = $_.Directory

            Remove-Item $_.FullName -Force
            Write-Host "Removed $fullName" -ForegroundColor Red

            RemoveDirIfEmpty $directory
        }
    }
