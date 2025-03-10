<#
 =============================================================================
<copyright file="Build-Drop.ps1" company="John Merryweather Cooper">
    Copyright © 2022-2025, John Merryweather Cooper.
    All Rights Reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

       1. Redistributions of source code must retain the above
          copyright notice, this list of conditions and the following
          disclaimer.

       2. Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials
          provided with the distribution.

       3. Neither the name of the copyright holder nor the names of
          its contributors may be used to endorse or promote products
          derived from this software without specific prior written
          permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
</copyright>
<author>John Merryweather Cooper</author>
<date>Created:  2024-9-12</date>
<summary>
This file "Build-Drop.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID A33FA8B2-6ABF-4FDF-9D8A-CF2B907E53E9

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/BuildScripts

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Drop the build artifacts to the shared location.

    .EXAMPLE
    PS> .\BuildDrop.ps1 -BuildArtifactsPath "SAMPLE_PATH\archive" -PSVersion "2.1.0" -CodePlexUsername "cormacpayne" -CodePlexFork "ps0901" -ReleaseDate "2016-09-08" -PathToShared "SAMPLE_PATH\PowerShell"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True, Position = 0)]
    [String]$BuildArtifactsPath,
    [Parameter(Mandatory = $True, Position = 1)]
    [String]$PSVersion,
    [Parameter(Mandatory = $True, Position = 2)]
    [String]$CodePlexUsername,
    [Parameter(Mandatory = $True, Position = 3)]
    [String]$CodePlexFork,
    [Parameter(Mandatory = $True, Position = 4)]
    [String]$ReleaseDate,
    [Parameter(Mandatory = $True, Position = 5)]
    [String]$PathToShared
)

# This function will get the ProductCode from a given msi file
function Get-ProductCode {
    param(
        [Parameter(Mandatory = $True)]
        [System.IO.FileInfo]$Path
    )

    try {
        # Read property from MSI database
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($Path.FullName, 0))
        $Query = "SELECT Value FROM Property WHERE Property = 'ProductCode'"
        $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($Query))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
        $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
        $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)

        # Commit database and close view
        $MSIDatabase.GetType().InvokeMember("Commit", "InvokeMethod", $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember("Close", "InvokeMethod", $null, $View, $null)
        $MSIDatabase = $null
        $View = $null

        # Return the value
        return $Value
    }
    catch {
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    }
}

# ==================================================================================================
# Getting the ProductCode from the msi
# ==================================================================================================

Rename-Item "$BuildArtifactsPath\signed\AzurePowerShell.msi" "azure-powershell.$PSVersion.msi"

# Get the ProductCode of the msi
$msiFile = Get-Item "$BuildArtifactsPath\signed\azure-powershell.$PSVersion.msi"
$ProductCode = ([string](Get-ProductCode $msiFile)).Trim()

# ==================================================================================================
# Cloning CodePlex WebPI feed and creating the new branch
# ==================================================================================================

# Clone your fork of the CodePlex WebPI repository
$fork = "https://git01.codeplex.com/forks/$CodePlexUsername/$CodePlexFork"
git clone $fork $CodePlexFork

Set-Location -LiteralPath $CodePlexFork

# Create a branch that's in the format of YYYY-MM-DDTHH-MM
$date = Microsoft.PowerShell.Utility\Get-Date -Format u
$branch = $date.Substring(0, $date.Length - 4).Replace(":", "-").Replace(" ", "T")
git checkout -b $branch

# ==================================================================================================
# Update the DH_AzurePS.xml file
# ==================================================================================================

Set-Location -LiteralPath "Src\azuresdk\AzurePS"

# Get the text for DH_AzurePS.xml
$content = Get-Content -LiteralPath "DH_AzurePS.xml"

# $newContent will be the text for the updated DH_AzurePS.xml
$newContentLength = $content.Length + 3
$newContent = New-Object -TypeName string[] -ArgumentList $newContentLength

$VSFeedSeen = $False
$PSGetSeen = $False
$buffer = 0

for ($idx = 0; $idx -lt $content.Length; $idx++) {
    # Flag that we will be looking at the entries for DH_WindowsAzurePowerShellVSFeed next
    if ($content[$idx] -like "*VSFeed*") {
        $VSFeedSeen = $True
    }

    # Flag that we will be looking at the entry for DH_WindowsAzurePowerShellGet next
    if ($content[$idx] -like "*PowerShellGet*") {
        $PSGetSeen = $True
    }

    # Check if we are looking at the DiscoveryHints for DH_WindowsAzurePowerShellVSFeed
    # and if we have reached the end of the entry so we can add the new msi Product Code
    if ($VSFeedSeen -and $content[$idx] -like "*</or>*") {
        $newContent[$idx] = "      <discoveryHint>"
        $newContent[$idx + 1] = "        <msiProductCode>$ProductCode</msiProductCode>"
        $newContent[$idx + 2] = "      </discoveryHint>"

        # Change the buffer size to include the three lines just added
        $buffer = 3

        # Flag that we are no longer in the VSFeed entry
        $VSFeedSeen = $False
    }

    # Check if we are looking at the entry for DH_WindowsAzurePowerShellGet
    if ($PSGetSeen -and $content[$idx] -like "*msiProductCode*") {
        $content[$idx] = "   <msiProductCode>$ProductCode</msiProductCode>"

        # Flag that we are no longer in the PSGet entry
        $PSGetSeen = $False
    }

    $newContent[$idx + $buffer] = $content[$idx]
}

# Replace the contents of the current file with the updated content
$result = $newContent -join [Environment]::NewLine
$tempFile = Get-Item "DH_AzurePS.xml"

[System.IO.File]::WriteAllText($tempFile.FullName, $result)

# ==================================================================================================
# Update the WebProductList_AzurePS.xml file
# ==================================================================================================

# Get the text for WebProductList_AzurePS.xml
$content = Get-Content -LiteralPath "WebProductList_AzurePS.xml"

$PSGetSeen = $false

for ($idx = 0; $idx -lt $content.Length; $idx++) {
    # Flag that we will be looking at the entry for WindowsAzurePowerShellGet next
    if ($content[$idx] -contains "  <productId>WindowsAzurePowershellGet</productId>") {
        $PSGetSeen = $true
    }

    # If we are in the WindowsAzurePowerShellGet entry, replace the necessary lines
    if ($PSGetSeen) {
        if ($content[$idx] -like "*<version>*") {
            $content[$idx] = "  <version>$PSVersion</version>"
        }

        if ($content[$idx] -like "*<published>*") {
            $content[$idx] = "  <published>$($ReleaseDate)T12:00:00Z</published>"
        }

        if ($content[$idx] -like "*<updated>*") {
            $content[$idx] = "  <updated>$($ReleaseDate)T12:00:00Z</updated>"
        }

        if ($content[$idx] -like "*<trackingURL>*") {
            $content[$idx] = "        <trackingURL>http://www.microsoft.com/web/handlers/webpi.ashx?command=incrementproddownloadcount&amp;prodid=WindowsAzurePowershell&amp;version=$PSVersion&amp;prodlang=en</trackingURL>"
        }

        if ($content[$idx] -like "*</entry>*") {
            $PSGetSeen = $False
        }
    }
}

# Replace the contents of the current file with the updated content
$result = $content -join [Environment]::NewLine
$tempFile = Get-Item "WebProductList_AzurePS.xml"

[System.IO.File]::WriteAllText($tempFile.FullName, $result)

# ==================================================================================================
# Create registry entry, and rename any prior release candidates
# ==================================================================================================

# Get the name of the folder - YYYY_MM_DD_PowerShell
$entryName = "$($ReleaseDate.Replace("-", "_"))_PowerShell"

# If the folder already exists, we need to rename it to what RC version it is
if (Test-Path -LiteralPath "$PathToShared\$entryName" -PathType Container) {
    $id = 1

    # Keep incrementing the RC verison until we find the version we are on
    while (Test-Path -LiteralPath "$PathToShared\$($entryName)_RC$id" -PathType Container) {
        $id++
    }

    # Rename the folder to include the RC version
    Rename-Item "$PathToShared\$entryName" "$($entryName)_RC$id"
}

# Create the new folder
New-Item "$PathToShared\$entryName" -Type Directory > $null
New-Item "$PathToShared\$entryName\pkgs" -Type Directory > $null

# Copy all of the scripts and WebPI items into the new folder
Copy-Item "$PathToShared\PSReleaseDrop\*" "$PathToShared\$entryName" -Recurse

# Copy the msi and packages into the new folder
Copy-Item $msiFile.FullName "$PathToShared\$entryName"
Copy-Item "$BuildArtifactsPath\artifacts\*.nupkg" "$PathToShared\$entryName\pkgs"

# ==================================================================================================
# Update other xml files using Build.sh and copy them to entry
# ==================================================================================================

Set-Location -LiteralPath ../../../Tools

.\Build.cmd

Set-Location -LiteralPath ../bin

Copy-Item -Path .\* -Destination $PathToShared\$entryName

# ==================================================================================================
# Commit and push changes to CodePlex
# ==================================================================================================

Set-Location -LiteralPath ..

git add .

git commit -m "Update DH_AzurePS.xml and WebProductList_AzurePS.xml"

git push origin $branch
