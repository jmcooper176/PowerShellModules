<#
 =============================================================================
<copyright file="UpdateStepOrder.ps1" company="U.S. Office of Personnel
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
This file "UpdateStepOrder.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-####"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "YOUR_PROJECT_NAME"
$stepNameToMove = "YOUR_STEP_NAME"
$newIndexForStep = 1 #Index is n-1 from the step number in the UI
 
# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript { $_.Name -eq $spaceName }
 
# Get project
$project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object -FilterScript { $_.Name -eq $projectName }

# Get deployment process
$deploymentProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL/$($project.Links.DeploymentProcess)" -Headers $header)

# Vars to loop through steps and find existing index
$stepCounter = 0
$oldIndexForStep = $newIndexForStep

# Find the index of the existing step
foreach ($step in $deploymentProcess.Steps){
    if($step.Name -eq $stepNameToMove){
        Write-Information -MessageData "Found $($step.Name) to move at index $stepCounter"
        $oldIndexForStep = $stepCounter
    }
    $stepCounter++
}

$newSteps = @() # Record new order of steps
$oldStepCounter = 0 # Keep track of where we are in the original steps

# Loop through and add the steps in the new order
if ($oldIndexForStep -ne $newIndexForStep){
    for ($i=0; $i -lt $deploymentProcess.Steps.Length; $i++){
        if($i -eq $newIndexForStep){
            Write-Information -MessageData "--Hit new index for step at $newIndexForStep, inserting $($deploymentProcess.Steps[$oldIndexForStep].Name) from old index $oldIndexForStep"
            $newSteps += $deploymentProcess.Steps[$oldIndexForStep]
        }
        elseif($oldStepCounter -eq $oldIndexForStep){
            Write-Information -MessageData "--Hit old index for step at $oldIndexForStep, skipping $($deploymentProcess.Steps[$oldIndexForStep].Name) from old index $oldIndexForStep, adding $($deploymentProcess.Steps[$i+1].Name) at index $($i+1)"
            $oldStepCounter++
            $newSteps += $deploymentProcess.Steps[$oldStepCounter]
            $oldStepCounter++
        }
        else{
            Write-Information -MessageData "--Adding step $($deploymentProcess.Steps[$oldStepCounter].Name) at index $i"
            $newSteps += $deploymentProcess.Steps[$oldStepCounter]
            $oldStepCounter++
        }
    }
    # Update steps to new order
    $deploymentProcess.Steps = $newSteps
    
    # Write out new step order (for debug)
    Write-Information -MessageData "New step order:"
    foreach($step in $newSteps){
        Write-Information -MessageData "$($step.Name)"
    }
    # Commit changes to process - comment out this line to preview changes before committing
    Invoke-RestMethod -Method Put -Uri "$octopusURL/$($project.Links.DeploymentProcess)" -Headers $header -Body ($deploymentProcess | ConvertTo-Json -Depth 100)
}
else{
    Write-Information -MessageData "New index for step is the same as existing index for step or step name not found, no steps moved."
}
