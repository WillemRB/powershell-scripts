<#
    Script to clean Visual Studio solution folders.
#>
Param(
    [Parameter()][string]$projectPath = ".",
    [Parameter()][bool]$ignorePackages = $false
)

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path

Get-ChildItem $projectPath -Recurse `
| Where { $_.FullName.ToLower() -match "(\\bin\\|\\obj\\|\\packages\\|\\testresults\\)" } `
| ForEach `
    {
        $fullName = $_.FullName.Replace($scriptPath, "")

        if ($_.FullName.Contains("packages") -and $ignorePackages)
        {
            Write-Host "Skipped $fullName" -ForegroundColor Cyan
        }
        else
        {
            Remove-Item $fullName -Recurse -Force
            Write-Host "Removed $fullName" -ForegroundColor Red
        }
    }
