<# 
    Script to clean Visual Studio solution folders.
#>
Param(
    [Parameter()][string]$projectPath = ".",
    [Parameter()][bool]$ignorePackages = $false
)

Get-ChildItem $ProjectPath -Recurse `
| Where { $_.Name.ToLower() -in ("bin", "obj", "testresults", "packages") } `
| ForEach `
    {
        $fullName = $_.FullName

        if ($_.FullName.Contains("packages") -and $ignorePackages)
        {
            Write-Host "Skipped $fullName" -ForegroundColor Cyan
        }
        else
        {
            #Remove-Item $fullName -Recurse -Force
            Write-Host "Removed $fullName" -ForegroundColor Red
        }
    }
