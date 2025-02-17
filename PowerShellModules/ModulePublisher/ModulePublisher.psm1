<#
 =============================================================================
<copyright file="ModulePublisher.psm1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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
This file "ModulePublisher.psm1" is part of "ModulePublisher".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Get-ModuleOrder
#>
function Get-ModuleOrder
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $directory)

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "Az(ureRM)?\.[0-9].*"
    $orderedPackages = @()
    $packages = (Get-ChildItem -LiteralPath $directory -Filter "*.nupkg")
    $profileExtension = $packages | Where-Object -FilterScript {$_.Name.Contains(".Accounts.") -or $_.Name.Contains(".Profile.")}
    $storage = $packages | Where-Object -FilterScript {$_.Name.Contains("Azure.Storage.") -or $_.Name.Contains("Az.Storage.")}
    $azurerm = $packages | Where-Object -FilterScript {$regex.IsMatch($_.Name)}

    if ($null -ne $profileExtension -and $profileExtension.Length -gt 0)
    {
        $orderedPackages += $profileExtension[0]
    }

    if ($null -ne $storage -and $storage.Length -gt 0)
    {
        $orderedPackages += $storage
    }

    foreach ($package in $packages)
    {
        if (!$package.Name.Contains(".Accounts.") -and `
            !$package.Name.Contains(".Profile.") -and `
            !$package.Name.Contains("Azure.Storage.") -and `
            !$package.Name.Contains("Az.Storage.") -and `
            !$regex.IsMatch($package.Name))
        {
            $orderedPackages += $package
        }
    }

    if ($null -ne $azurerm -and $azurerm.Length -gt 0)
    {
        $orderedPackages += $azurerm[0]
    }

    $orderedPackages | Write-Output
}

function Get-RepoLocation
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $repoName)

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $location = "https://www.poshtestgallery.com/api/v2/package/"

    if ($repoName -eq "PSGallery")
    {
        $location = "https://www.powershellgallery.com/api/v2/package/"
    }

    $location | Write-Output
}

function Get-ApiKey
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $repoName)

        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $vaultKey = "PSTestGalleryApiKey"

        if ($repoName -eq "PSGallery")
        {
            $vaultKey = "PowerShellGalleryApiKey"
        }

        $context = (Get-AzContext -ErrorAction Ignore)

        if ($null -eq $context -or $null -eq $context.Account -or $null -eq $context.Account.Id)
        {
            Connect-AzAccount -ErrorAction Stop
        }

        $secret = Get-AzKeyVaultSecret -VaultName kv-azuresdk -Name $vaultKey -ErrorAction Stop

        if($null -eq $secret.SecretValueText)
        {
            $secret = Get-AzKeyVaultSecret -VaultName kv-azuresdk -Name $vaultKey -ErrorAction Stop
            $secretPlainText = ConvertFrom-SecureString -SecureString $secret.SecretValue -AsPlainText
            $secretPlainText | Write-Output
        }
        else
        {
            $secret.SecretValueText | Write-Output
        }
}

function Update-NugetPackage
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NugetExe
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList  "([0-9\.]+)nupkg$"
        $regex2 = "<requireLicenseAcceptance>false</requireLicenseAcceptance>"
    }

    PROCESS
    {
        $file = Get-Item -LiteralPath $Path

        $zipPath = $file.FullName.Replace(".nupkg", ".zip")
        $dirName = $regex.Replace($file.Name, [string]::Empty)
        $dirPath = Join-Path -Path $file.Directory.FullName -ChildPath $dirName
        Rename-Item -Path $file.FullName -NewName $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $dirPath
        $relDir = Join-Path -Path -Path $dirPath -ChildPath '`[Content_Types`].xml'
        $packPath = Join-Path -Path $dirPath -ChildPath "package"
        $modulePath = Join-Path -Path $dirPath -ChildPath ($dirName + ".nuspec")
        Remove-Item -Recurse -Path $relDir -Force
        Remove-Item -Recurse -Path $packPath -Force
        Remove-Item -Path $contentPath -Force
        $content = (Get-Content -LiteralPath $modulePath) -join "`r`n"
        $content = $content -replace $regex2, ("<licenseUrl>https://raw.githubusercontent.com/Azure/azure-powershell/dev/LICENSE.txt</licenseUrl>`r`n    <projectUrl>https://github.com/Azure/azure-powershell</projectUrl>`r`n    <requireLicenseAcceptance>true</requireLicenseAcceptance>")
        $content | Out-File -FilePath $modulePath -Force

        if ($PSCmdlet.ShouldProcess($modulePath, $CmdletName)) {
            &$NugetExe pack $modulePath -OutputDirectory $file.Directory.FullName
        }
    }
}

function Remove-RMPackage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]
        $ModuleInfo,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepoLocation,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NugetExe = (Join-Path -Path $PSScriptRoot -ChildPath "NuGet.exe"))

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name = $ModuleINfo.Name
        $Version = $ModuleInfo.Version

        if ($PSCmdlet.ShouldProcess(
            "Removing Nuget Package using command $NugetExe delete $Name $Version $ApiKey -Source $RepoLocation -Verbosity detailed", $CmdletName)) {
            &$NugetExe delete $Name $Version $ApiKey -Source $RepoLocation -Verbosity detailed -NoPrompt
        }
    }
}

function Remove-RMPackage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleNameString,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NugetExe = (Join-Path -Path $PSScriptRoot -ChildPath "NuGet.exe"),

        [Parameter(ParameterSetName="ByName", Mandatory)]
        [ValidateSet('TestGallery', 'PSGallery')]
        [string]
        $RepoName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $RepoLocation = (Get-RepoLocation -repoName $RepoName)
        $ApiKey = (Get-ApiKey -repoName $RepoName)
        $modules = (Find-Module -Name $ModuleNameString -Repository $RepoName)
        $modules | ForEach-Object -Process { Find-Module -Name $_.Name -Repository $RepoName -AllVersions } | Remove-RMPackage -RepoLocation $RepoLocation -ApiKey $ApiKey -NugetExe $NugetExe -WhatIf:([bool]$WhatIfPreference) -ErrorAction Stop
    }
}

function Update-Package
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NugetExe
        )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS
    {
        $modules = (Get-ModuleOrder -directory $Path)

        foreach ($package in $modules)
        {
            if ($PSCmdlet.ShouldProcess($package, $CmdletName)) {
                Update-NugetPackage -Path $package -NugetExe $NugetExe
            }
        }
    }
}

function Publish-RMModule
{
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $Path,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NugetExe = (Join-Path -Path $PSScriptRoot -ChildPath "NuGet.exe"),

        [Parameter(ParameterSetName="ByLocation", Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepoLocation,

        [Parameter(ParameterSetName="ByLocation", Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(ParameterSetName="ByName", Mandatory)]
        [ValidateSet('TestGallery', 'PSGallery')]
        [string]
        $RepoName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS
    {
        if ($PSCmdlet.ParameterSetName -eq "ByName")
        {
            $RepoLocation = (Get-RepoLocation -repoName $RepoName)
            $ApiKey = (Get-ApiKey -repoName $RepoName)
        }

        $modules = (Get-ModuleOrder -directory $Path)

        foreach ($package in $modules)
        {
          $packagePath = $package.FullName

          if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf))
          {
            throw "Module at $packagePath does not exist"
          }

          if ($PSCmdlet.ShouldProcess($packagePath, "Pushing package $packagePath to nuget source $RepoLocation using command '$NugetExe push $packagePath $ApiKey -Source $RepoLocation'"))
          {
            Write-Information -MessageData "Pushing package $packagePath to nuget source $RepoLocation" -InformationAction Continue
            &$NugetExe push $packagePath $ApiKey -Source $RepoLocation -Verbosity detailed
            Write-Information -MessageData "Pushed package $packagePath to nuget source $RepoLocation" -InformationAction Continue
          }
        }
    }
}
