<#
 =============================================================================
<copyright file="GetAllPackageSizes.ps1" company="John Merryweather Cooper
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
This file "GetAllPackageSizes.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusApiKey = "YOUR API KEY"
$octopusUrl = "YOUR URL" 
$header = @{ "X-Octopus-ApiKey" = $octopusApiKey }

$spaceResults = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/spaces?skip=0&take=100000" -Headers $header
foreach ($space in $spaceResults.Items)
{
    Write-Information -MessageData $space.Name
    $spaceId = $space.id
    $feedList = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/Feeds" -Headers $header
    foreach ($feed in $feedList.Items)
    {
        if ($feed.FeedType -ne "BuiltIn")
        {
            continue
        }

        $packageList = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/feeds/$($feed.Id)/packages/search" -Headers $header     
        foreach ($package in $packageList.Items)
        {
            Write-Information -MessageData "    $($package.Name)"
            $packageVersionList = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/feeds/$($feed.Id)/packages/versions?packageId=$($package.Id)&skip=0&take=100000" -Headers $header
            foreach ($packageVersion in $packageVersionList.Items)
            {
                $sizeInKB = $packageVersion.SizeBytes / 1024
                Write-Information -MessageData "        $($packageVersion.Version) - $sizeInKB KB"
            }
        }
    }
}