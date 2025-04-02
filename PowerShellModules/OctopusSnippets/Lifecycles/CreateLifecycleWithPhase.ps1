<#
 =============================================================================
<copyright file="CreateLifecycleWithPhase.ps1" company="U.S. Office of Personnel
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
This file "CreateLifecycleWithPhase.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
#Add-Type -AssemblyName 'Octopus.Client' 

$apikey = '' # Get this from your profile
$octopusURI = '' # Your Octopus Server address

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI,$apikey 
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint

#Creating lifecycle
$lifecycle = New-Object -TypeName Octopus.Client.Model.LifecycleResource
$lifecycle.Name = '' #Name of the lifecycle

#Default Retention Policy
$lifecycle.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items) #Unlimmited Releases
#$lifecycle.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(2,[Octopus.Client.Model.RetentionUnit]::Days) #2 days
$lifecycle.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items)
#$lifecycle.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(10,[Octopus.Client.Model.RetentionUnit]::Days) #10 days

#Creating Phase
$phase = New-Object -TypeName Octopus.Client.Model.PhaseResource

$phase.Name = "Dev" #Name of the phase
$phase.OptionalDeploymentTargets.Add("Environments-1") #Adding optional Environment to phase
#$phase.AutomaticDeploymentTargets.Add("Environments-30") #Automatic Environment
$phase.MinimumEnvironmentsBeforePromotion = 0

#Phase's retention Policy
$phase.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items) #Unlimmited Releases
#$phase.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(2,[Octopus.Client.Model.RetentionUnit]::Days) #2 days
$phase.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items)
#$phase.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(10,[Octopus.Client.Model.RetentionUnit]::Days) #10 days

#Adding phase to new lifecycle
$lifecycle.Phases.Add($phase)

#Saving new lifecycle to DB
$repository.Lifecycles.Create($lifecycle)