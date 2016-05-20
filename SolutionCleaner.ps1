<#
	Another version of a Visual Studio Solution Cleaner
#>
Param(
		[Parameter()][string]$projectPath, 
		[Parameter()][bool]$ignorePackages = $false
)

# Pass . for starting in current folder
if ([System.String]::IsNullOrEmpty($projectPath))
{
    $projectPath = Read-Host -Prompt "Path to project"
}

function Remove-Packages($packagesPath) {
    Get-ChildItem $packagesPath | % {
        $fullName = $_.FullName
        
        if (-not ($fullname.Contains('repositories.config'))) {
            Write-Host "Removed $fullName" -ForegroundColor Red
            Remove-Item $fullName -Recurse -Force
        }
    }    
}

Get-ChildItem $ProjectPath -Recurse `
| Where { $_.Name.ToLower() -in ('bin', 'obj', 'TestResults', 'packages', '.vs') } `
| ForEach `
    {
        $fullName = $_.FullName

        if ($fullName.Contains("packages"))
        {
            if ($ignorePackages) {
                Write-Host "Skipped $fullName" -ForegroundColor Cyan
                # continue; werkt niet, sluit de hele ForEach af...
            }
            else {
                Remove-Packages $fullName
            }
        }
        else
        {
            Remove-Item $fullName -Recurse -Force
            Write-Host "Removed $fullName" -ForegroundColor Red
        }
    }
