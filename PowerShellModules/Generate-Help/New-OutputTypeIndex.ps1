<#
 =============================================================================
<copyright file="New-OutputTypeIndex.ps1" company="John Merryweather Cooper">
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
This file "New-OutputTypeIndex.ps1" is part of "Generate-Help".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 27EE627D-B62E-4A01-9F92-9626CE673C27

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Generate a list of all output types in the module.
#>

[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]
    $BuildConfig = 'Debug',

    [string]
    $OutputFile = "$PSScriptRoot/outputtypes.json"
)

# Get all psd1 files
$psd1Files = Get-Item $PSScriptRoot\..\artifacts\$BuildConfig\Az.*\Az.*.psd1

$profilePsd1 = $psd1Files | Where-Object -Property Name -like "*Az.Accounts.psd1"
Import-LocalizedData -BindingVariable "psd1File" -BaseDirectory $profilePsd1.DirectoryName -FileName $profilePsd1.Name

foreach ($nestedModule in $psd1File.RequiredAssemblies)
{
    $dllPath = Join-Path -Path $profilePsd1.DirectoryName -ChildPath $nestedModule
    $Assembly = [Reflection.Assembly]::LoadFrom($dllPath)
}

$outputTypes = New-Object -TypeName System.Collections.Generic.HashSet[string]

$psd1Files | ForEach -Process {
    Import-LocalizedData -BindingVariable "psd1File" -BaseDirectory $_.DirectoryName -FileName $_.Name

    foreach ($nestedModule in $psd1File.NestedModules)
    {
        if('.dll' -ne [System.IO.Path]::GetExtension($nestedModule))
        {
            continue
        }

        $dllPath = Join-Path -Path $_.DirectoryName -ChildPath $nestedModule
        $Assembly = [Reflection.Assembly]::LoadFrom($dllPath)
        $exportedTypes = $Assembly.GetTypes()

        foreach ($exportedType in $exportedTypes)
        {
            foreach ($attribute in $exportedType.CustomAttributes)
            {
                if ($attribute.AttributeType.Name -eq "OutputTypeAttribute")
                {
                    $cmdletOutputTypes = $attribute.ConstructorArguments.Value.Value
                    foreach ($cmdletOutputType in $cmdletOutputTypes)
                    {
                        $outputTypes.Add($cmdletOutputType.FullName) | Out-Null
                    }
                }
            }

            foreach ($property in $exportedType.GetProperties() | Where-Object -Property CustomAttributes.AttributeType.Name -contains "ParameterAttribute")
            {
                if ($property.PropertyType.FullName -like "*System.Nullable*``[``[*")
                {
                    $outputTypes.Add(($property.PropertyType.BaseType.FullName -replace "[][]", "")) | Out-Null
                }
                elseif ($property.PropertyType.FullName -notlike "*``[``[*")
                {
                    $outputTypes.Add(($property.PropertyType.FullName -replace "[][]", "")) | Out-Null
                }
            }
        }
    }
}

$json = ConvertTo-Json $outputTypes
$json | Out-File "$OutputFile"
