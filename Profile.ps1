# Set environment variables for Visual Studio 2015 Command Prompt
function VsCmd
{
    Push-Location "$env:VS140COMNTOOLS"
    cmd /c "vsvars32.bat&set" |
        ForEach-Object {
            if ($_ -match "=") {
                $v = $_.split("=");
                Set-Item -Force -Path "ENV:\$($v[0])" -Value "$($v[1])"
            }
        }
    Pop-Location
    
    Write-Host "Visual Studio 2015 Command Prompt variables set." -ForegroundColor Green
}

# Add additional paths for use in PowerShell
#$env:Path += ";C:\Tools"

# Set a default starting location
Set-Location \
