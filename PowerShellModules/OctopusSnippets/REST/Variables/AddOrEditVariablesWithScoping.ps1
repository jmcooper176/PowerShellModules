<#
 =============================================================================
<copyright file="AddOrEditVariablesWithScoping.ps1" company="John Merryweather Cooper
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
This file "AddOrEditVariablesWithScoping.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

Function Get-OctopusProject {
    # Define parameters
    param (
        $OctopusServerUrl,
        $ApiKey,
        $ProjectName,
        $SpaceId
    )
    # Call API to get all projects, then filter on name
    $octopusProject = Invoke-RestMethod -Method "get" -Uri "$OctopusServerUrl/api/$spaceId/projects/all" -Headers @{"X-Octopus-ApiKey" = "$ApiKey" }

    # return the specific project
    return ($octopusProject | Where-Object -FilterScript { $_.Name -eq $ProjectName })
}

Function Get-OctopusProjectVariables {
    # Define parameters
    param (
        $OctopusDeployProject,
        $OctopusServerUrl,
        $ApiKey,
        $SpaceId
    )
    # Get reference to the variable list
    return (Invoke-RestMethod -Method "get" -Uri "$OctopusServerUrl/api/$spaceId/variables/$($OctopusDeployProject.VariableSetId)" -Headers @{"X-Octopus-ApiKey" = "$ApiKey" })
}

Function Get-SpaceId {
    # Define parameters
    param (
        $Space
    )
    $spaceName = $Space
    $spaceList = Invoke-RestMethod "$OctopusServerUrl/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers @{"X-Octopus-ApiKey" = $ApiKey }
    $spaceFilter = @($spaceList.Items | Where-Object -FilterScript { $_.Name -eq $spaceName })
    $spaceId = $spaceFilter[0].Id
    return $spaceId
}

Function Get-EnvironmentId {
    # Define parameters
    param (
        $EnvironmentName,
        $SpaceId
    )
    $environmentList = Invoke-RestMethod "$OctopusServerUrl/api/$spaceId/environments?skip=0&take=1000&name=$environmentName" -Headers @{"X-Octopus-ApiKey" = $ApiKey }
    $environmentFilter = @($environmentList.Items | Where-Object -FilterScript { $_.Name -eq $environmentName })
    $environmentId = $environmentFilter[0].Id
    return $environmentId
}

Function Modify-Variable {
    # Define parameters
    param (
        $VariableSet,
        $VariableName,
        $VariableValue,
        $VariableEnvScope,
        $SpaceName
    )

    #If given a scope parameter, find the matching variable with scope and modify the value
    if ($VariableEnvScope) {
        #Code to transform the environment name to environment ID.
        $SpaceId = Get-SpaceId -Space $SpaceName
        $environmentId = Get-EnvironmentId -EnvironmentName $VariableEnvScope -SpaceId $SpaceId

        #loop through all variables and change the value if the name and environment ID match
        ForEach ($variable in $VariableSet.Variables) {
            if ($variable.Name -eq $VariableName -and $variable.Scope.Environment -eq $environmentId) {
                $variable.Value = $VariableValue
            }
        }
    }
    #When a scope parameter is not given
    else {
        #Find the variable you want to edit by name, then edit the value. Only edit if the variable is unscoped.
        ForEach ($variable in $VariableSet.Variables) {
            if ($variable.Name -eq $VariableName -and !$variable.Scope.Environment) {
                $variable.Value = $VariableValue
            }
        }
    }
}

Function Add-Variable {
    # Define parameters
    param (
        $VariableSet,
        $VariableName,
        $VariableValue,
        $VariableEnvScope,
        $VariableRoleScope,
        $IsSensitive = $false

    )
    #Create the variable object
    $obj = New-Object -TypeName PSObject -Property @{
        'Name'        = $($VariableName)
        'Value'       = $($VariableValue)
        'Type'        = 'String'
        'IsSensitive' = $IsSensitive
        'Scope'       = @{
            'Environment' = @()
            'Role'        = @()
        }
    }

    #Check to see if an environment was passed, add it to the object if it was
    if ($VariableEnvScope) {
        #If the environment passed was an array, add them all
        if ($VariableEnvScope -is [array]) {
            foreach ($environment in $variableenvscope) {
                $environmentObj = $VariableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $environment } | Select-Object -First 1
                $obj.scope.Environment += $environmentObj.Id
            }
        }
        #If it's not an array, just add the one.
        else {
            $environmentObj = $VariableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $VariableEnvScope } | Select-Object -First 1
            $obj.scope.environment += $environmentObj.Id
        }
    }

    #Check to see if a role was passed, add it to the object if it was
    if ($VariableRoleScope) {
        #If the role passed was an array, add them all
        if ($VariableRoleScope -is [array]) {
            foreach ($role in $VariableRoleScope) {
                $obj.scope.role += $VariableRoleScope
            }
        }
        #If it's not an array, just add the one.
        else {
            $obj.scope.role += $VariableRoleScope
        }
    }
    #add the variable to the variable set
    $VariableSet.Variables += $obj
}

Function Remove-Variable {
    param (
        $VariableSet,
        $VariableName
    )

    $tempVars = @()

    foreach ($variable in $VariableSet.Variables) {
        if ($variable.Name -ne $VariableName) {
            $tempVars += $variable
        }
    }
    $variableset.Variables = $tempVars
}

Function Modify-Scope {
    param (
        $VariableSet,
        $VariableName,
        $VariableEnvScope,
        $VariableRoleScope,
        $ExistingEnvScope,
        $ExistingRoleScope,
        $IsSensitive = $false
    )
    $tempVars = @()
    #Create the variable object
    $obj = New-Object -TypeName PSObject -Property @{
        'Name'        = $($VariableName)
        'Value'       = $($VariableValue)
        'Type'        = 'String'
        'IsSensitive' = $IsSensitive
        'Scope'       = @{
            'Environment' = @()
            'Role'        = @()
        }
    }

    if ($VariableRoleScope) {
        #If the role passed was an array, add them all
        if ($VariableRoleScope -is [array]) {
            foreach ($role in $VariableRoleScope) {
                $obj.scope.role += $role
            }
        }
        #If it's not an array, just add the one.
        else {
            $obj.scope.role += $VariableRoleScope
        }
    }

    if ($VariableEnvScope) {
        #If the environment passed was an array, add them all
        if ($VariableEnvScope -is [array]) {
            foreach ($environment in $variableenvscope) {
                $environmentObj = $VariableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $environment } | Select-Object -First 1
                $obj.scope.Environment += $environmentObj.Id
            }
        }
        #If it's not an array, just add the one.
        else {
            $environmentObj = $VariableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $VariableEnvScope } | Select-Object -First 1
            $obj.scope.environment += $environmentObj.Id
        }
    }
    #iterate each variable to match on the one we want to modify
    foreach ($variable in $VariableSet.Variables) {
        $envmatch = $null
        $rolematch = $null
        $temprolelist = @()
        $tempenvlist = @()
        $tempExistList = @()
        $envDiffs = $null
        $roleDiffs = $null
        #create list of environments based on IDs
        foreach ($env in $ExistingEnvScope) {
            $tempId = $VariableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $env } | Select-Object -First 1
            $tempExistList += $tempId.Id
        }

        #put the scopes in a format we can compare
        foreach ($env in $variable.Scope.Environment) {
            $tempenvlist += $env
        }
        #Sort-Object to compare
        $tempenvlist = $tempenvlist | Sort-Object
        $tempExistList = $tempExistList | Sort-Object
        #test compare
        if ($null -ne $tempenvlist -and $null -ne $tempExistList) {
            $envDiffs = Compare-Object -ReferenceObject $tempenvlist -DifferenceObject $tempExistList -PassThru
        }

        $envmatch  =($null -eq $envDiffs)

        # Same as above but for roles
        foreach ($role in $variable.Scope.Role) {
            $temprolelist += $role
        }
        $temprolelist = $temprolelist | Sort-Object
        $ExistingRoleScope = $ExistingRoleScope | Sort-Object

        if (!$null -eq $temprolelist -and !$null -eq $ExistingRoleScope) {
            $roleDiffs = Compare-Object -ReferenceObject $temprolelist -DifferenceObject $ExistingRoleScope -PassThru
        }

        $rolematch = ($null -eq $roleDiffs)

        # If everything matches, add the value from the matched variable and add the dummy variable to the set
        if (($variable.Name -eq $VariableName) -and ($rolematch) -and ($envmatch)) {
            $obj.Value = $variable.Value

            # Keep original Machine/Action/Channel/ProcessOwner scopes
            if ($variable.Scope.Machine) {
                $obj.Scope.Machine = $variable.Scope.Machine
            }
            if ($variable.Scope.Action) {
                $obj.Scope.Action = $variable.Scope.Action
            }
            if ($variable.Scope.Channel) {
                $obj.Scope.Channel = $variable.Scope.Channel
            }
            if ($variable.Scope.ProcessOwner) {
                $obj.Scope.ProcessOwner = $variable.Scope.ProcessOwner
            }
            $tempVars += $obj
        }
        #otherwise add the variable without modifying
        else {
            $tempVars += $variable
        }
    }

    $variableset.Variables = $tempVars
}

### INPUT THESE VALUES ####

$OctopusServerUrl = ""  #PUT YOUR SERVER LOCATION HERE. (e.g. http://localhost)
$ApiKey = ""   #PUT YOUR API KEY HERE
$ProjectName = ""   #PUT THE NAME OF THE PROJECT THAT HOUSES THE VARIABLES HERE
$SpaceName = "" #PUT THE NAME OF THE SPACE THAT HOUSES THE PROJECT HERE

### INPUT THESE VALUES ####
try {
    # Convert SpaceName to SpaceId
    $SpaceId = Get-SpaceId -Space $SpaceName
    # Get reference to project
    $octopusProject = Get-OctopusProject -OctopusServerUrl $OctopusServerUrl -ApiKey $ApiKey -ProjectName $ProjectName -SpaceId $SpaceId
    # Get list of existing variables
    $octopusProjectVariables = Get-OctopusProjectVariables -OctopusDeployProject $octopusProject -OctopusServerUrl $OctopusServerUrl -ApiKey $ApiKey -SpaceId $SpaceId

    ###Examples###

    #--------------------------
    #Modify-Variable Information
    #--------------------------
    #If you want to modify an Environmentally scoped variable, you must pass the Environment with -VariableEnvScope and the Space with -SpaceName. Note, if you have multiple environments scoped if it matches on one it will modify the variable, it doesn't need to match on all.

    #Modify-Variable -VariableSet $octopusProjectVariables -VariableName "Test" -VariableValue "New"
    #Modify-Variable -VariableSet $octopusProjectVariables -VariableName "Test2" -VariableValue "New2" -VariableEnvScope "Development" -SpaceName "Default"

    #--------------------------
    #Add-Variable Information
    #--------------------------
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "TestNew555" -VariableValue "Nothing scoped"
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "TestNewEnv2" -VariableValue "Env Scoped" -VariableEnvScope "Development"
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "TestNewRole" -VariableValue "Role Scoped" -VariableRoleScope "Web"
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "ObjectTesting2" -VariableValue "Both Env and Role Scoped" -VariableEnvScope "Development" -VariableRoleScope "Web"

    #If you want to add a variable as sensitive, set the parameter -IsSensitive $true. It will default to $false otherwise.

    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "SensitiveVariable" -VariableValue "SENSITIVE" -VariableEnvScope "Development" -VariableRoleScope "Web" -IsSensitive $true
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "NOTSensitiveVariable" -VariableValue "not SENSITIVE" -VariableEnvScope "Development" -VariableRoleScope "Web"

    ###Example of adding multiple Environments or Roles###

    #$environments = "Development","Test","Production"
    #$roles = "Web","Web-Local"
    #Add-Variable -VariableSet $octopusProjectVariables -VariableName "ArrayTesting2" -VariableValue "multi environment and role scope" -VariableEnvScope $environments -VariableRoleScope $roles

    #--------------------------
    #Remove-Variable Information
    #--------------------------
    #Remove-Variable will delete any variable with the name regardless of scoping

    #Remove-Variable -VariableSet $octopusProjectVariables -VariableName "RemoveThis"

    #--------------------------
    #Modify-Scope Information
    #--------------------------
    #To use this function, you have to define both the existing environments+roles on the variable in array format, and the resulting environments+roles that you want it to have at the end of the function, also in array format.

    #For example, this would find the variable with Env scope of Development, and role scope of Web, then remove both of them.
    #$newEnvironments = @()
    #$newRoles = @()
    #$existingEnvironments = @("Development")
    #$existingRoles = @("Web")
    #Modify-Scope -VariableSet $octopusProjectVariables -VariableName "ObjectTesting2" -VariableEnvScope $newEnvironments -VariableRoleScope $newRoles -ExistingEnvScope $existingEnvironments  -ExistingRoleScope $existingRoles

    #In this example, this would find the variable with Env scope of Development, and role scope of Web, then add the Test environment, and the Windows role scopes.
    #$newEnvironments = @("Development","Test")
    #$newRoles = @("Web","Windows")
    #$existingEnvironments = @("Development")
    #$existingRoles = @("Web")
    #Modify-Scope -VariableSet $octopusProjectVariables -VariableName "ObjectTesting2" -VariableEnvScope $newEnvironments -VariableRoleScope $newRoles -ExistingEnvScope $existingEnvironments  -ExistingRoleScope $existingRoles

    ##### PUT ANY MODIFY AND ADD COMMANDS HERE #####

    ##### PUT ANY MODIFY AND ADD COMMANDS HERE #####

    # Convert object to json to upload it
    #$octopusProjectVariables.Version++
    $jsonBody = $octopusProjectVariables | ConvertTo-Json -Depth 10
    #Write-Information -MessageData $jsonBody
    # Save the variables to the variable set
    Invoke-RestMethod -Method "put" -Uri "$OctopusServerUrl/api/$spaceId/variables/$($octopusProjectVariables.Id)" -Body $jsonBody -Headers @{"X-Octopus-ApiKey" = $ApiKey }
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    throw $Error[0]
}
