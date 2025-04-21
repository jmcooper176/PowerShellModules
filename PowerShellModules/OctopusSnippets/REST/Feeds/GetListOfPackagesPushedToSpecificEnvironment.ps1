<#
 =============================================================================
<copyright file="GetListOfPackagesPushedToSpecificEnvironment.ps1" company="John Merryweather Cooper
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
This file "GetListOfPackagesPushedToSpecificEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusUrl = "" # example https://myoctopus.something.com
$APIKey = ""
$environmentName = "Production"
$spaceName = "Default"

$header = @{ "X-Octopus-ApiKey" = $APIKey }

## First we need to find the space
$spaceList = Invoke-RestMethod "$OctopusUrl/api/spaces?Name=$spaceName" -Headers $header
$spaceFilter = @($spaceList.Items | Where-Object -FilterScript {$_.Name -eq $spaceName})
$spaceId = $spaceFilter[0].Id
Write-Information -MessageData "The spaceId for Space Name $spaceName is $spaceId"

## Next, let's find the environment
$environmentList = Invoke-RestMethod "$OctopusUrl/api/$spaceId/environments?skip=0&take=1000&name=$environmentName" -Headers $header
$environmentFilter = @($environmentList.Items | Where-Object -FilterScript {$_.Name -eq $environmentName})
$environmentId = $environmentFilter[0].Id
Write-Information -MessageData "The environmentId for Environment Name $environmentName in space $spaceName is $environmentId"

## Let's get a list of all the deployments which have gone to that environment
$deploymentList = Invoke-RestMethod "$octopusUrl/api/$spaceId/deployments?environments=$environmentId&skip=0&take=100000" -Headers $header
$packageList = @()
foreach ($deployment in $deploymentList.Items)
{
    $deploymentName = $deployment.Name
    $releaseId = $deployment.ReleaseId
    Write-Information -MessageData "Getting the release details for $releaseId for $deploymentName"
    $restUrl = $OctopusUrl + $deployment.Links.Release
    $release = Invoke-RestMethod $restUrl -Headers $header

    if ($release.SelectedPackages.Count -gt 0)
    {
        Write-Information -MessageData "The release has packages, getting the deployment process for $releaseId for $deploymentName"
        $restUrl = $OctopusUrl + $release.Links.ProjectDeploymentProcessSnapshot
        $deploymentProcess = Invoke-RestMethod $restUrl -Headers $header

        foreach($package in $release.SelectedPackages)
        {
            $deploymentStep = $deploymentProcess.Steps | Where-Object -FilterScript {$_.Name -eq $package.StepName}
            $action = $deploymentStep.Actions | Where-Object -FilterScript {$_.Name -eq $package.ActionName}

            if ($action.ActionType -eq "Octopus.DeployRelease")
            {
                $actionName = $package.ActionName
                Write-Information -MessageData "The 'package' for $actionName is really a deploy a release step, skipping this package"
            }
            else
            {
                foreach ($stepPackage in $action.Packages)
                {
                    $packageToAdd = @{
                        PackageId = $stepPackage.PackageId
                        Version = $package.Version
                    }

                    $packageVersion = $packageToAdd.Version
                    $packageName = $packageToAdd.PackageId

                    $existingPackage = @($packageList | Where-Object -FilterScript {$_.PackageId -eq $packageToAdd.PackageId -and $_.Version -eq $packageToAdd.Version})

                    if ($existingPackage.Count -eq 0)
                    {
                        Write-Information -MessageData "Adding package $packageName.$packageVersion to your list"
                        $packageList += $packageToAdd
                    }
                    else
                    {
                        Write-Information -MessageData "The package $packageName.$packageVersion has already been added to the list"
                    }
                }
            }
        }
    }
}

$packageCount = $packageList.Count
Write-Information -MessageData "Found $packageCount package(s) in $environmentName"
