$DebugPreference = "Continue"

$FullSAPUI5Package = "C:\Toolkit\sapui5-rt-1.65.1"

$StrippedSAPUI5Package = "C:\Toolkit\sapui5-mobile-static-1.65.1"

# "C:\Toolkit\sapui5-rt-1.54.6\resources\sap\base\encoding\toHex.js"
# "C:\Toolkit\sapui5-rt-1.54.6\resources\sap\base\strings\normalize-polyfill.js"
# "C:\Toolkit\sapui5-rt-1.54.6\resources\sap\base\util\isPlainObject.js"
# "C:\Toolkit\sapui5-rt-1.54.6\resources\sap\base\util\isWindow.js"

# $SAPUI5Libs = @{}

# (Get-Content -Path (Join-Path -Path $FullSAPUI5Package -ChildPath "discovery\all_libs") | ConvertFrom-Json).all_libs | ForEach-Object {
#     $Lib = @{

#     }

#     $SAPUI5Libs.Add($PSItem.entry, $true)
# }

# return

$SAPUI5Libs = @{
    "sap/apf"=$false
    "sap/ca/scfld/md"=$false
    "sap/ca/ui"=$false
    "sap/chart"=$true
    "sap/collaboration"=$true
    "sap/f"=$true
    "sap/fe"=$false
    "sap/fileviewer"=$false
    "sap/fiori"=$true
    "sap/gantt"=$false
    "sap/landvisz"=$false
    "sap/m"=$true
    "sap/makit"=$false
    "sap/me"=$false
    "sap/ndc"=$false
    "sap/ovp"=$false
    "sap/portal/ui5"=$false
    "sap/rules/ui"=$false
    "sap/suite/ui/commons"=$true
    "sap/suite/ui/generic/template"=$true
    "sap/suite/ui/microchart"=$true
    "sap/tnt"=$false
    "sap/ui/codeeditor"=$true
    "sap/ui/commons"=$true
    "sap/ui/comp"=$true
    "sap/ui/core"=$true
    "sap/ui/dt"=$false
    "sap/ui/export"=$false
    "sap/ui/fl"=$true
    "sap/ui/generic/app"=$true
    "sap/ui/generic/template"=$false
    "sap/ui/layout"=$true
    "sap/ui/mdc"=$false
    "sap/ui/richtexteditor"=$false
    "sap/ui/rta"=$false
    "sap/ui/server/abap"=$false
    "sap/ui/server/java"=$false
    "sap/ui/suite"=$true
    "sap/ui/support"=$false
    "sap/ui/table"=$true
    "sap/ui/unified"=$true
    "sap/ui/ux3"=$true
    "sap/ui/vbm"=$false
    "sap/ui/vk"=$false
    "sap/ui/vtm"=$false
    "sap/uiext/inbox"=$false
    "sap/ushell"=$true
    "sap/ushell_abap"=$false
    "sap/uxap"=$true
    "sap/viz"=$true
    "sap/zen/commons"=$false
    "sap/zen/crosstab"=$false
    "sap/zen/dsh"=$false
}

$ResourcesPath = Join-Path -Path $FullSAPUI5Package -ChildPath "resources"

$RequiredFiles = Get-ChildItem -Path $ResourcesPath -Force -Recurse -File -Include "resources.json" | Where-Object {
    $ResourceListPath = $PSItem.FullName

    $RequiredLibrary = $true

    $SAPUI5Libs.GetEnumerator() | Where-Object { return -not $_.Value } | ForEach-Object {
        if ($ResourceListPath -match ($PSItem.Key -replace "/", "\\")) {
            $RequiredLibrary = $false
        }
    }

    return $RequiredLibrary
} | ForEach-Object {
    $ResourceListPath = $PSItem.FullName

    $LibraryPath = Split-Path -Path $PSItem.FullName -Parent

    (Get-Content -Path $ResourceListPath | ConvertFrom-Json).resources | Where-Object {
        if ($PSItem.isDebug -eq "true") {
            return $false
        }
        if ($PSItem.locale -and $PSItem.locale.Length -gt 0 -and $PSItem.locale -notmatch "(en|fr|nl).*") {
            return $false
        }
        if ($PSItem.theme -and $PSItem.theme -in ("sap_belize_hcb","sap_belize_hcw","sap_bluecrystal","sap_hcb","sap_mvi")) {
            return $false
        }
        if ($PSItem.name -match "-RTL") {
            return $false
        }
        return $true
    } | ForEach-Object {
        [PSCustomObject]@{
            Path = Join-Path -Path $LibraryPath -ChildPath $PSItem.name
        }

        if ($PSItem.required) {
            $PSItem.required | ForEach-Object {
                [PSCustomObject]@{
                    Path = Join-Path -Path $ResourcesPath -ChildPath $PSItem
                }
            }
        }
    }
} | Sort-Object -Property Path -Unique

Write-Debug "Files Count: $($RequiredFiles.Count)"

$RequiredFiles | ForEach-Object {
    if (Test-Path -Path $PSItem.Path) {
        $Destination = Join-Path -Path $StrippedSAPUI5Package -ChildPath $PSItem.Path.Substring($FullSAPUI5Package.Length)

        New-Item -ItemType File -Path $Destination -Force | Out-Null

        Copy-Item -Path $PSItem.Path -Destination $Destination -Force
    } else {
        $PSItem | Out-File -Append -FilePath "C:\Temp\missing.txt"
    }
}