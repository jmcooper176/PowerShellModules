<#
 =============================================================================
<copyright file="Generate-CmdletDesignMarkdown.ps1" company="U.S. Office of Personnel
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
This file "Generate-CmdletDesignMarkdown.ps1" is part of "Generate-CmdletDesignMarkdown".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 7BA9DE5F-7344-4822-AE9D-1BD05B2FF91D

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom/Generate-CmdletDesignMarkdown

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES


    .PRIVATEDATA

#>

<#
    .SYNOPSIS
    Generate cmdlet design markdown for the specified azure module.

    .DESCRIPTION
    Generate cmdlet design markdown for the specified azure module. The script will generate the markdown file based on the cmdlet name order. The script will sort the cmdlets by the noun and verb, and then generate the markdown file based on the order.

    .PARAMETER Path
    The path is the docs folder path. Default current script path if not pass value.

    .PARAMETER OutPath
    The value the Path parameter and the OutPath parameter are the same if not passed OutPath parameter.

    .PARAMETER OutputFileName
    Automatically generate output file name if not passed value.

    .PARAMETER NounPriority
    Specify the order of cmdlets in the design document.

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    PS> GenerateCmdletDesignMarkdown.ps1 -Path 'azure-powershell\src\Databricks\docs' -OutPath 'azure-powershell\ModuleCmdletDesign' -OutputFileName 'Az.Databricks.Cmdlet.Design.md' -NounPriority 'AzDatabricksWorkspace','AzDatabricksVNetPeering'

    Generated azure-powershell\ModuleCmdletDesign\Az.Databricks.Cmdlet.Design.md completed.

    .NOTES
    Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
#>


#requires -version 7.4
#requires -Modules PowerShellModule

[CmdletBinding()]
param (
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $Path = $PSScriptRoot,

    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $OutPath = $PSScriptRoot,

    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $OutputFileName = 'Cmdlet.Design.md',

    [string[]]
    $NounPriority
)

$ScriptName = Initialize-PSScript -MyInvocation $MyInvocation

try {
    # Get all name and path of the cmdlets.
    Write-Verbose -Message "$($ScriptName):  Get all cmdlets md file under the $Path folder."
    $cmdlets = Get-ChildItem -LiteralPath $Path -Filter '*-*.md' | Select-Object -Property FullName, Name

    # Add Cmdlet, Verb, Noun property for sort object.
    $cmdlets | Add-Member -NotePropertyName Cmdlet -NotePropertyValue $null
    $cmdlets | Add-Member -NotePropertyName Verb -NotePropertyValue $null
    $cmdlets | Add-Member -NotePropertyName Noun -NotePropertyValue $null

    # set priority for the specified cmdlets.
    if (Test-PSParameter -Name 'NounPriority' -Parameters $PSBoundParameters) {
        $priority = 0
        $NounPriorityHash = @{}

        $NounPriority | ForEach-Object -Process {
            $NounPriorityHash.Add($_, $priority++)
        }
    }

    $outFilePath = Join-Path -Path $OutPath -ChildPath $OutputFileName

    # Try remove output file
    Write-Verbose -Message "$($ScriptName):  Delete the '$($OutputFileName)' file if it exists."
    Remove-Item -Path $outFilePath -Force

    $cmdlets | ForEach-Object -Process {
        # Join 0 prefix with New verb so that make New verb as top item in the same Noun.
        $verb = if ($_.Name.Split('-')[0] -eq 'New') { '0New' } else { $_.Name.Split('-')[0] }

        # Join priority with Noun.
        $originNoun = $_.Name.Split('-')[1].Split('.')[0];
        $Noun = if ($null -eq $NounPriorityHash) { $originNoun } else { (if ($null -eq $NounPriorityHash[$originNoun]) { $originNoun } else { $NounPriorityHash[$originNoun].ToString() + $originNoun }) }

        $_.Cmdlet = $_.Name.Split('.')[0];
        $_.Verb = $verb
        $_.Noun = $Noun
    } | Sort-Object -Property 'Noun', 'Verb' | ForEach-Object -Process {
            $contentStr = Get-Content -LiteralPath $_.FullName | Out-String
            $designDoc = $contentStr.Substring($contentStr.IndexOf("# $($_.Cmdlet)"), $contentStr.IndexOf('## PARAMETERS') - $contentStr.IndexOf("# $($_.Cmdlet)"))

            if ($designDoc.Contains('{{ Add title here }}')) {
                $designDoc = $designDoc.Remove($designDoc.IndexOf('## DESCRIPTION'))
            }
            else {
                $designDoc = $designDoc.Remove($designDoc.IndexOf('## DESCRIPTION'), $designDoc.IndexOf('## EXAMPLES') - $designDoc.IndexOf('## DESCRIPTION'))
            }

            $designDoc = $designDoc -replace '```(\r\n\w{1})', '```powershell$1'
            $designDoc = $designDoc -replace '###', '+'
            $designDoc = $designDoc -replace '#+', '####'

            $designDoc | Out-File -FilePath $outFilePath -Append -ErrorAction Stop
        }

    Write-Information -MessageData "$($ScriptName):  Generated '$($outFilePath)' completed." -InformationAction Continue
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    $PSCmdlet.ThrowTerminatingError($Error[0])
}
