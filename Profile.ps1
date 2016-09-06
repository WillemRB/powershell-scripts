# Set environment variables for Visual Studio 2015 Command Prompt
function VsCmd
{
    pushd "$env:VS140COMNTOOLS"
    cmd /c "vsvars32.bat&set" |
        ForEach {
            if ($_ -match "=") {
                $v = $_.split("="); Set-Item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
            }
        }
    popd
    
    Write-Host "`nVisual Studio 2015 Command Prompt variables set." -ForegroundColor Green
}
