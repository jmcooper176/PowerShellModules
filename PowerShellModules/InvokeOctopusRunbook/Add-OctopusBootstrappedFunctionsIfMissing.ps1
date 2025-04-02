<#
 =============================================================================
<copyright file="Add-OctopusBootstrappedFunctionsIfMissing.ps1" company="U.S. Office of Personnel
Management">
    Copyright © 2025, U.S. Office of Personnel Management.
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
<date>Created:  2025-2-19</date>
<summary>
This file "Add-OctopusBootstrappedFunctionsIfMissing.ps1" is part of "InvokeOctopusRunbook".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

.VERSION 3.0

.GUID 9c4b21e5-1d9e-4fa5-91c6-22e59ce7296a

.AUTHOR John Merryweather Cooper

.COMPANYNAME U.S. Office of Personnel Management

.COPYRIGHT Copyright (c) 2023-2025, U.S. Office of Personnel Management.  All Rights Reserved.

.TAGS octopus, deploy, remove, package, version, unused

.LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

.PROJECTURI https://github.com/OPM-OCIO-FITBS-HRSITPMO/RunbookDependencies

.ICONURI

.EXTERNALMODULEDEPENDENCIES NuGetModule, OctopusClientModule, OctopusRestModule, PathModule

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<#
    .LINK
    https://github.com/OctopusDeploy/Calamari/blob/master/source/Calamari.Common/Features/Scripting/WindowsPowerShell/Bootstrap.ps1
#>

if (-not (Test-Path Function:\Write-Highlight)) {
    function Write-Highlight {
        [CmdletBinding()]
        param ([Parameter(ValueFromPipeline = $true)][string]$Message)

        process { Write-Information -MessageData $Message }
    }
}

if (-not (Test-Path Function:\Fail-Step)) {
    function Fail-Step([string]$Message) {
        throw $Message
    }
}

if (-not (Test-Path Function:\Execute-WithRetry)) {
    function Execute-WithRetry([ScriptBlock] $command, [int] $maxFailures = 3, [int] $sleepBetweenFailures = 1) {
        $attemptCount = 0
        $operationIncomplete = $true

        while ($operationIncomplete -and $attemptCount -lt $maxFailures) {
            $attemptCount = ($attemptCount + 1)

            if ($attemptCount -ge 2) {
                Write-Information -MessageData "Waiting for $sleepBetweenFailures seconds before retrying..."
                Start-Sleep -s $sleepBetweenFailures
                Write-Information -MessageData "Retrying..."
            }

            try {
                & $command

                $operationIncomplete = $false
            }
            catch [System.Exception] {
                if ($attemptCount -lt ($maxFailures)) {
                    Write-Information -MessageData ("Attempt $attemptCount of $maxFailures failed: " + $_.Exception.Message)
                }
                else {
                    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
                    throw $Error[0]
                }
            }
        }
    }
}

# OK this one is our own; it's not in the Octopus bootstrap scipt
if (-not (Test-Path Function:\Execute-WithTimeout)) {
    function Execute-WithTimeout(
        [ScriptBlock] $EwtCommand, [ScriptBlock] $EwtCompletedCondition = { $true },
        [string] $EwtDescription, [timespan] $EwtTimeout, [timespan] $EwtCheckInterval = [timespan]::Zero) {
        Write-Information -MessageData "Performing action: $EwtDescription"
        $ewtTimeInitiated = [System.DateTimeOffset]::Now
        $ewtFirstIteration = $true
        do {
            if (-not $ewtFirstIteration) {
                if ([System.DateTimeOffset]::Now.Subtract($ewtTimeInitiated).Add($EwtCheckInterval) -ge $EwtTimeout) {
                    Fail-Step "Exceeded timeout ($($EwtTimeout.TotalSeconds) seconds) performing action: $EwtDescription"
                }
                Start-Sleep -Milliseconds $EwtCheckInterval.TotalMilliseconds
            }
            else {
                $ewtFirstIteration = $false
            }
            # Execute the scriptblock in the current scope to allow CompletedCondition to work
            $ewtCommandOutput = . $EwtCommand
        } until (. $EwtCompletedCondition)

        $ewtSecondsElapsed = [Math]::Truncate([System.DateTimeOffset]::Now.Subtract($ewtTimeInitiated).TotalSeconds)
        Write-Information -MessageData "Completed in $ewtSecondsElapsed seconds: $EwtDescription"
        $ewtCommandOutput
    }
}
