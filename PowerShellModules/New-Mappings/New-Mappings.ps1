<#
 =============================================================================
<copyright file="New-Mappings.ps1" company="John Merryweather Cooper">
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
This file "New-Mappings.ps1" is part of "New-Mappings".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID E5298CAD-4E37-46FB-B8DD-4B99382F6BE9

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .SYNOPSIS
    Generate new mappings for cmdlets to documentation groups.

    .DESCRIPTION
    `New-Mappings.ps1` generates new mappings for cmdlets to documentation groups.
#>

# Define parameters.
param(
    [string] $RootPath = "$PSScriptRoot\..\src",
    [string] $OutputFile = "$PSScriptRoot\groupMapping.json",
    [string] $WarningFile = "$PSScriptRoot\groupMappingWarnings.json",
    [string] $RulesFile = "$PSScriptRoot\CreateMappings_rules.json"
);

# Load rules file from JSON.
$rules = Get-Content -LiteralPath $RulesFile -Raw | ConvertFrom-Json;

# Initialize variables.
$results = @{};
$warnings = @();

& ($PSScriptRoot + "\PreloadToolDll.ps1")
$RootPath = Resolve-Path $RootPath
$RootPathRegex = [regex]::escape($RootPath) + "\\(\w*)(\\)(.*)"
# Find all cmdlet names by help file names in the repository.
$cmdlets = Get-ChildItem $RootPath -Recurse | Where-Object -FilterScript { $_.FullName -cmatch ".*\\help\\.*-.*.md" -and (-not [Tools.Common.Utilities.ModuleFilter]::IsAzureStackModule($_.FullName)) };

$cmdlets | ForEach-Object -Process {
    $cmdletPath = Split-Path $_.FullName -Parent;
    $module = $null;
    if($cmdletPath -cmatch $RootPathRegex) {
        $module = $Matches.1
    }
    $cmdlet = $_.BaseName;

    $matchedRule = $null;
    # First, match to module path.
    $matchedRule = @($rules | Where-Object -FilterScript { $_.Regex -ne $null -and $cmdletPath -cmatch ".*$($_.Regex).*" })[0];

    # Try to match this cmdlet with at least one rule.
    $possibleBetterMatch = @($rules | Where-Object -FilterScript { $_.Regex -ne $null -and $cmdlet -cmatch ".*$($_.Regex).*" })[0];

    # Look for the best match.
    if(
        # Did not find a match on the folder, but found a match on the cmdlet.
        (($matchedRule -eq $null) -and ($possibleBetterMatch -ne $null)) -or
        # Found a match on the module path, but found a better match for the cmdlet (`group` field agrees).
        (($matchedRule.Group -ne $null) -and ($matchedRule.Group -eq $possibleBetterMatch.Group)))
    {
        $matchedRule = $possibleBetterMatch;
    }

    $matchedModuleRule = $null; # clear before using
    [System.Array]$matchedModuleRules = @($rules | Where-Object -FilterScript { $_.Module -ne $null -and $module -eq $_.Module });
    if($matchedModuleRules.Length -eq 1) {
        # If only one rule maps to module, module name is prior than other rules.
        $matchedModuleRule = $matchedModuleRules[0];
    } elseif ($matchedModuleRules.Length -gt 1) {
        # If multiple rules map to module, the first regex is prior.
        $matchedModuleRule = @($matchedModuleRules | Where-Object -FilterScript { $_.Regex -ne $null -and $cmdlet -cmatch ".*$($_.Regex).*" })[0];
        if($null -eq $matchedModuleRule) {
            $matchedModuleRule = $matchedModuleRules[0];
        }
    }

    if($null -ne $matchedModuleRule) {
        $results[$cmdlet] = $matchedModuleRule.Alias;
    } elseif ($null -ne $matchedRule) {
        $results[$cmdlet] = $matchedRule.Alias;
    } else {
        # Take note of unmatched cmdlets and write to outputs.
        $warnings += $cmdlet;
        $results[$cmdlet] = "Other";
    }
};

# Write to files.
$warnings | ConvertTo-Json | Out-File $WarningFile -Encoding utf8;
$results | ConvertTo-Json | Out-File $OutputFile -Encoding utf8;

# Print conclusion.
Write-Information -MessageData ""
Write-Information -MessageData "$($results.Count) cmdlets successfully mapped: $($OutputFile)." -ForegroundColor Green;
Write-Information -MessageData ""

if($warnings.Count -gt 0) {
    Write-Information -MessageData "$($warnings.Count) cmdlets could not be mapped and were placed in 'Other': $($WarningFile)." -ForegroundColor Yellow;
    throw "Some cmdlets could not be properly mapped to a documentation grouping: $($warnings -join ", ").  Please add a mapping rule to $(Resolve-Path -Path $RulesFile).";
}
