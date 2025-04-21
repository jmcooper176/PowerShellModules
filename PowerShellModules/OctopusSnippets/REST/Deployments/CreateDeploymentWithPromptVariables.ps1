<#
 =============================================================================
<copyright file="CreateDeploymentWithPromptVariables.ps1" company="John Merryweather Cooper
">
    Copyright © 2025, John Merryweather Cooper.
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
<date>Created:  2025-2-25</date>
<summary>
This file "CreateDeploymentWithPromptVariables.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG##
$apiKey = "Your API Key"
$OctopusURL = "Your Octopus URL"

$ProjectName = "Your Project Name"
$EnvironmentName = "Your Environment Name"
$ReleaseNumber = "Your Release Number"
$spaceName = "Your Space Name"
$promptedVariableValue = "VariableName::Variable Value"

##PROCESS##
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }

$spaceList = Invoke-RestMethod "$OctopusUrl/api/spaces?partialName=$([System.Web.HTTPUtility]::UrlEncode($spaceName))&skip=0&take=1" -Headers $Header
$spaceId = $spaceList.Items[0].Id

$ProjectList = Invoke-RestMethod "$OctopusURL/api/$spaceId/projects?name=$([System.Web.HTTPUtility]::UrlEncode($projectName))&skip=0&take=1" -Headers $header
$ProjectId = $ProjectList.Items[0].Id

$EnvironmentList = Invoke-RestMethod -Uri "$OctopusURL/api/$spaceId/Environments?name=$([System.Web.HTTPUtility]::UrlEncode($EnvironmentName))&skip=0&take=1" -Headers $Header
$EnvironmentId = $EnvironmentList.Items[0].Id

$ReleaseList = Invoke-RestMethod -Uri "$OctopusURL/api/$spaceId/projects/$ProjectId/releases?searchByVersion=$([System.Web.HTTPUtility]::UrlEncode($releaseNumber))&skip=0&take=1" -Headers $Header
$ReleaseId = $ReleaseList.Items[0].Id

$deploymentPreview = Invoke-RestMethod "$OctopusUrl/api/$spaceId/releases/$releaseId/deployments/preview/$($EnvironmentId)?includeDisabledSteps=true" -Headers $Header

$deploymentFormValues = @{}
$promptedValueList = @(($promptedVariableValue -Split "`n").Trim())

foreach($element in $deploymentPreview.Form.Elements)
{
    $nameToSearchFor = $element.Control.Name
    $uniqueName = $element.Name
    $isRequired = $element.Control.Required

    $promptedVariablefound = $false

    Write-Information -MessageData "Looking for the prompted variable value for $nameToSearchFor"
    foreach ($promptedValue in $promptedValueList)
    {
        $splitValue = $promptedValue -Split "::"
        Write-Information -MessageData "Comparing $nameToSearchFor with provided prompted variable $($promptedValue[$nameToSearchFor])"
        if ($splitValue.Length -gt 1)
        {
            if ($nameToSearchFor -eq $splitValue[0])
            {
                Write-Information -MessageData "Found the prompted variable value $nameToSearchFor"
                $deploymentFormValues[$uniqueName] = $splitValue[1]
                $promptedVariableFound = $true
                break
            }
        }
    }

    if ($promptedVariableFound -eq $false -and $isRequired -eq $true)
    {
        Write-Highlight "Unable to find a value for the required prompted variable $nameToSearchFor, exiting"
        Exit 1
    }
}

#Creating deployment and setting value to the only prompt variable I have on $p.Form.Elements. You're gonna have to do some digging if you have more variables
$DeploymentBody = @{
            ReleaseID = $releaseId #mandatory
            EnvironmentID = $EnvironmentId #mandatory
            FormValues = $deploymentFormValues
            ForcePackageDownload=$False
            ForcePackageRedeployment=$False
            UseGuidedFailure=$False
          } | ConvertTo-Json

Invoke-RestMethod -Uri "$OctopusURL/api/$spaceId/deployments" -Method Post -Headers $Header -Body $DeploymentBody
