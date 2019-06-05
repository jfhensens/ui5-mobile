$StrippedSAPUI5Package = "C:\Toolkit\sapui5-mobile-static-1.65.1"

$utf8BOM = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $true

Get-ChildItem -Path $StrippedSAPUI5Package -Filter *.js -Recurse | ForEach-Object {
    $contents = (Get-Content -Path $PSItem.FullName -Encoding UTF8)

    if ([string]::IsNullOrEmpty($contents)) {
        $contents = @()
    }

    [System.IO.File]::WriteAllLines($PSItem.FullName, $contents, $utf8BOM)
}