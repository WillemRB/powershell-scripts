Param(
    [ValidateScript({ Test-Path $_ })]
    [string]$inputFile
)

[xml]$unityConfig = Get-Content -Path $inputFile

$unityConfig.unity.container.register | ForEach-Object {
    $registerType = $_.type
    $registerMapTo = $_.mapTo

    $aliasFrom = $unityConfig.unity.alias | Where-Object { $_.alias -eq $registerType }
    $aliasTo = $unityConfig.unity.alias | Where-Object { $_.alias -eq $registerMapTo }

    $fullFromType = $aliasFrom.type.Split(',')[0]
    $fullToType = $aliasTo.type.Split(',')[0]

    $fromType = $fullFromType.Split('.')[-1]
    $toType = $fullToType.Split('.')[-1]

    if ($fromType -ne "I${toType}") {
        Write-Host "container.RegisterType<$fullFromType, $fullToType>();"
    }
}
