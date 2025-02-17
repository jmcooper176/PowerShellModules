<#
 =============================================================================
<copyright file="PathModule.psm1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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
<date>Created:  2024-9-12</date>
<summary>
This file "PathModule.psm1" is part of "PathModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Get-PathAlias
#>
function Get-PathAlias {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = 'Alias'
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-Cmdlet
#>
function Get-Cmdlet {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = 'Cmdlet'
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-Executable
#>
function Get-Executable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = @('Application', 'ExternalScript')
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-Filter
#>
function Get-Filter {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.FunctionInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = 'Filter'
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-Function
#>
function Get-Function {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.FunctionInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = 'Function'
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-ModuleExecutable
#>
function Get-ModuleExecutale {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Module,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = @('Alias', 'Function', 'Cmdlet')
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Module')) {
            $getCommandSplat['Module'] = $Module
        } else {
            $getCommandSplat.Add('Module', $Module)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Module
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}

<#
    Get-Script
#>
function Get-Script {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.FunctionInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [switch]
        $ListImported,

        [switch]
        $UseAbbreviationExpansion,

        [switch]
        $UseFuzzyMatch
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $getCommandSplat = @{
            All = $All.IsPresent
            CommandType = 'ExternalScript'
            ListImported = $ListImported.IsPresent
            UseAbbreviationExpansion = $UseAbbreviationExpansion.IsPresent
            UseFuzzyMatch = $UseFuzzyMatch.IsPresent
        }
    }

    PROCESS {
        if ($getCommandSplat.ContainsKey('Name')) {
            $getCommandSplat['Name'] = $Name
        } else {
            $getCommandSplat.Add('Name', $Name)
        }

        Get-Command @getCommandSplat | Write-Output
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER All
        .PARAMETER ListImported
        .PARAMETER UseAbbreviationExpansion
        .PARAMETER UseFuzzyMatch
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
        .LINK
        about_CommonParameters
        .LINK
        about_Functions_Advanced
        .LINK
        Get-Command
        .LINK
        Set-StrictMode
        .LINK
        Set-Variable
    #>
}
