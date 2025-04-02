<#
 =============================================================================
<copyright file="FindDeployedByUser.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-2-25</date>
<summary>
This file "FindDeployedByUser.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/

Set-Location -LiteralPath C:\MyScripts\Octopus.Client
Add-Type -AssemblyName 'Octopus.Client'

$apikey = 'API-KEY' # Get this from your profile
$octopusURI = 'https://octopus.url' # Your server address

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

# This script searches the Events (Audit log) for events of Category Queued and looks into the RelatedDocumentIds field for further refining.
# This script will return the name of a user who started a deployment (queued), but you need to enter one or more of the following.
#
# Properties of the RelatedDocumentIds for DeploymentQueued.
# Projects-342, Releases-965, Environments-1, ServerTasks-159414, Channels-362, ProjectGroups-1
#
# The easiest way to find a single result is by using the ServerTasks-ID in my example below. (Searching time can vary based on amount of events)

$serverTasksID = "ServerTasks-159414"

#Using lambda expression to filter events using the FindMany method
$repository.Events.FindMany(
    {param ($e) if(($e.Category -match "Queued") -and ($e.RelatedDocumentIds -contains $serverTasksID))
        {
        #$True # Uncomment this to return the entire object.
        Write-Information -MessageData "The account which :" $e.message ": Was :" $e.username
        }
    })
