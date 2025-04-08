<#
 =============================================================================
<copyright file="GetVariableInProject.ps1" company="John Merryweather Cooper
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
This file "GetVariableInProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#Returns the variable value based on space. If you want the variable scoped, you must provide environment name and spaceId
Function Get-VariableValue {
    param (
        $Options,
        $VariableSet,
        $VariableName,
        $Environment
    )

    $outputVariable = $null
    $envScopeValueSet = $False
    $foundEnvironmentWithinVariable = $false

    if ($Environment) {
        $environmentList = Invoke-RestMethod "$($Options.OctopusUrl)/environments/all" -Headers $Options.Headers
        $environment = $environmentList | Where-Object -FilterScript { $_.Name -eq $environment }
        $environmentId = $environment.Id
    }

    #Find matching varable by name
    $variables = $VariableSet.Variables | Where-Object -FilterScript { $_.Name -eq $VariableName }

    #Loop through the variable
    ForEach ($variable in $variables) {
        #Check if it has an environment scope. If it doesnt, and no EnvScopeValue has been found and set, set it.
        if (!$variable.Scope.Environment -and !$envScopeValueSet) {
            $outputVariable = $variable.Value
        }
        #If there is a scoped environment and variable has not been set
        if ($variable.Scope.Environment -and !$envScopeValueSet) {
            #Iterate through the environments and see if our environment is one of them. Set flag to true if it is.
            ForEach ($element in $variable.Scope.Environment) {
                if ($element -eq $environmentId) {
                    $foundEnvironmentWithinVariable = $true
                }
            }
            #If we have found the environment earlier, set the value, set the flag that we've set the value.
            if ($foundEnvironmentWithinVariable) {
                $outputVariable = $variable.Value
                $envScopeValueSet = $True
            }
        }
    }

    return $outputVariable
}

################ INPUT THESE VALUES ################
$OctopusServerUrl = "" #PUT YOUR SERVER LOCATION HERE. (e.g. http://localhost)
$ApiKey = "" #PUT YOUR API KEY HERE
$ProjectName = "" #PUT THE NAME OF THE PROJECT THAT HOUSES THE VARIABLES HERE
$SpaceName = ""         #PUT THE NAME OF THE SPACE THAT HAS THE PROJECT IN IT
$CurrentEnv = "" #PUT ENVIRONMENT NAME HERE

################ INPUT THESE VALUES #################

try {
    $headers = @{ "X-Octopus-ApiKey" = $ApiKey }
    $spaceList = Invoke-RestMethod "$OctopusServerUrl/api/spaces/all" -Headers $headers
    $space = $spaceList | Where-Object -FilterScript { $_.Name -eq $SpaceName }

    $url = "$OctopusServerUrl/api/$($space.Id)"
    $headers = @{ "X-Octopus-ApiKey" = $ApiKey }

    # Get Variable set
    $projectList = Invoke-RestMethod "$url/projects/all" -Headers $headers
    $project = $projectList | Where-Object -FilterScript { $_.Name -eq $ProjectName }
    $projectVariableSetId = $project.VariableSetId

    $variableSet = Invoke-RestMethod -Method "get" -Uri "$url/variables/$projectVariableSetId" -Headers $headers
    $Options = @{
        OctopusUrl = "$OctopusServerUrl/api/$($space.Id)"
        Headers    = @{ "X-Octopus-ApiKey" = $ApiKey }
        }

    #### EXAMPLE ####
    $tempValue = Get-VariableValue -Options $Options -VariableSet $VariableSet -VariableName "Test" -Environment $CurrentEnv
    Write-Information -MessageData "Should be Old: "$tempValue
    ################ GET YOUR VARIABLE AND STORE IT HERE ################


    ################ GET YOUR VARIABLE AND STORE IT HERE ################
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    throw $Error[0]
}
