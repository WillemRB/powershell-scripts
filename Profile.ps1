# Set environment variables for Visual Studio 2015 Command Prompt
function VsCmd
{
    pushd "$env:VS140COMNTOOLS"
    cmd /c "vsvars32.bat&set" |
        ForEach {
            if ($_ -match "=") {
                $v = $_.split("="); 
                Set-Item -Force -Path "ENV:\$($v[0])" -Value "$($v[1])"
            }
        }
    popd
    
    Write-Host "Visual Studio 2015 Command Prompt variables set." -ForegroundColor Green
}
