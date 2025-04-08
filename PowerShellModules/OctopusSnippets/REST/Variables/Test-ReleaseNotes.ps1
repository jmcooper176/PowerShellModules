<#
 =============================================================================
<copyright file="Test-ReleaseNotes.ps1" company="John Merryweather Cooper
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
This file "Test-ReleaseNotes.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ReleaseNotes = @"
* [311006](https://AzureDevOps/DefaultCollection/83aaace0-5e0f-4553-b3d1-5060e8012bb0/_workitems/edit/311006): My Reports History:: error creating report but status in grid is In Progress <span class='label'>Ready for Test</span>  
* [311833](https://AzureDevOps/DefaultCollection/83aaace0-5e0f-4553-b3d1-5060e8012bb0/_workitems/edit/311833): [Generic Installer App] "Browser not supported" issue on iPhone <span class='label'>Ready for Test</span>  
* [311835](https://AzureDevOps/DefaultCollection/83aaace0-5e0f-4553-b3d1-5060e8012bb0/_workitems/edit/311835): Returns 504 error when attempting to generate for entire base <span class='label'>Merged Into Next Release</span> <span class='label label-info'>performance</span> 
"@
$ReleaseNotes = $ReleaseNotes.Replace('"','\"')

$ReleaseNotes

octo create-release --apiKey "API-BTVNKGWA5YKPNASEMEFR8QYMGEQ" --server "https://octopus.markharrison.dev" --project "Azure CLI play" --version "1.0.1" --ignoreExisting --releaseNotes $($ReleaseNotes)