#reqires -version 7.4

using module ErrorResponseType
using module TypeAccelerator

<#
    class:  Origin
#>
class Origin {
    <#
        Public Properties
    #>
    [string]$ClassName

    [string]$Description

    [ValidateNotNullOrEmpty()]
    [string]$Name

    [System.IO.FileInfo]$Path

    [System.Type]$Type

    [ValidateRange(0, 2147483647)]
    [int]$Line

    [ValidateRange(0, 2147483647)]
    [int]$Column

    [ValidateRange(0, 2147483647)]
    [int]$LastLine

    [ValidateRange(0, 2147483647)]
    [int]$LastColumn

    [string]$Text

    <#
        Hidden Properties
    #>
    hidden [System.Management.Aurtomation.InvocationInfo]$TheInvocation

    <#
        Constructors
    #>
    Origin() {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $MyInvocation.MyCommand.Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $MyInvocation.DisplayScriptPosition.StartLineNumber
        $this.Column = $MyInvocation.DisplayScriptPosition.StartColumnNumber
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Name) {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $MyInvocation.DisplayScriptPosition.StartLineNumber
        $this.Column = $MyInvocation.DisplayScriptPosition.StartColumnNumber
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Name, $Line) {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $MyInvocation.DisplayScriptPosition.StartColumnNumber
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Name, $Line, $Column) {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Name, $Line, $Column, $LastColumn) {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $LastColumn
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Name, $Line, $Column, $LastLine, $LastColumn) {
        $this.ClassName = Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $LastLine
        $this.LastColumn = $LastColumn
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Type) {
        Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $this.Name = $Type.GetMembers() | Where-Object -FilterScript {
            $_.MemberType -eq 'Method' -or $_.MemberType -eq 'Constructor' -or $_.MemberType -eq 'Property' -or $_.MemberType -eq 'Field' } |
            Select-Object -First 1 -ExpandProperty Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $MyInvocation.DisplayScriptPosition.StartLineNumber
        $this.Column = $MyInvocation.DisplayScriptPosition.StartColumnNumber
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Type, $Line) {
        Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $this.Name = $Type.GetMembers() | Where-Object -FilterScript {
            $_.MemberType -eq 'Method' -or $_.MemberType -eq 'Constructor' -or $_.MemberType -eq 'Property' -or $_.MemberType -eq 'Field' } |
            Select-Object -First 1 -ExpandProperty Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $MyInvocation.DisplayScriptPosition.StartColumnNumber
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Type, $Line, $Column) {
        Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $this.Name = $Type.GetMembers() | Where-Object -FilterScript {
            $_.MemberType -eq 'Method' -or $_.MemberType -eq 'Constructor' -or $_.MemberType -eq 'Property' -or $_.MemberType -eq 'Field' } |
            Select-Object -First 1 -ExpandProperty Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $MyInvocation.DisplayScriptPosition.EndColumnNumber
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Type, $Line, $Column, $LastColumn) {
        Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $this.Name = $Type.GetMembers() | Where-Object -FilterScript {
            $_.MemberType -eq 'Method' -or $_.MemberType -eq 'Constructor' -or $_.MemberType -eq 'Property' -or $_.MemberType -eq 'Field' } |
            Select-Object -First 1 -ExpandProperty Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $MyInvocation.DisplayScriptPosition.EndLineNumber
        $this.LastColumn = $LastColumn
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    Origin($Type, $Line, $Column, $LastLine, $LastColumn) {
        Initialize-PSClass -Name [Origin].Name
        $this.TheInvocation = $MyInvocation

        $this.Name = $this.Name = $Type.GetMembers() | Where-Object -FilterScript {
            $_.MemberType -eq 'Method' -or $_.MemberType -eq 'Constructor' -or $_.MemberType -eq 'Property' -or $_.MemberType -eq 'Field' } |
            Select-Object -First 1 -ExpandProperty Name
        $this.Path = [System.IO.FileInfo]::new($MyInvocation.PSCommandPath)
        $this.Line = $Line
        $this.Column = $Column
        $this.LastLine = $LastLine
        $this.LastColumn = $LastColumn
        $this.Text = $MyInvocation.DisplayScriptPosition.Text

        foreach ($DefinitionSplat in [Origin]::PropertyDefinitions) {
            Update-TypeData -TypeName [Origin].Name @DefinitionSplat
        }
    }

    <#
        Public Script Property Definitions
    #>
    static [hashtable[]] $PropertyDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Definition'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.Definition
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'HelpFile'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.HelpFile
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'ModuleName'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.ModuleName
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Noun'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.Noun
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Source'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.Source
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Verb'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.Verb
                }
                else {
                    [string]::Empty
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Version'
            Value      = { if ($null -ne $this.TheInvocation) {
                    $this.TheInvocation.MyCommand.Version
                }
                else {
                    [System.Version]::new(0, 0, 0, 0)
                }
            }
        }
    )

    <#
        Public Methods
    #>
    [string]ToString() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $buffer = New-StringBuilder -Value $this.Name

        if ($this.Line -gt 0 -and $this.Column -gt 0 -and $this.LastColumn -gt 0 -and $this.LastLine -gt 0) {
            Add-End -Buffer $buffer -Value '('
            Add-End -Buffer $buffer -Integer $this.Line
            Add-End -Buffer $buffer -Value ','
            Add-End -Buffer $buffer -Integer $this.Column
            Add-End -Buffer $buffer -Value ','
            Add-End -Buffer $buffer -Integer $this.LastLine
            Add-End -Buffer $buffer -Value ','
            Add-End -Buffer $buffer -Integer $this.LastColumn
            Add-End -Buffer $buffer -Value ')'
        }
        elseif ($this.Line -gt 0 -and $this.Column -gt 0 -and $this.LastColumn -gt 0) {
            Add-End -Buffer $buffer -Value '('
            Add-End -Buffer $buffer -Integer $this.Line
            Add-End -Buffer $buffer -Value ','
            Add-End -Buffer $buffer -Integer $this.Column
            Add-End -Buffer $buffer -Value '-'
            Add-End -Buffer $buffer -Integer $this.LastColumn
            Add-End -Buffer $buffer -Value ')'
        }
        elseif ($this.Line -gt 0 -and $this.Column -gt 0) {
            Add-End -Buffer $buffer -Value '('
            Add-End -Buffer $buffer -Integer $this.Line
            Add-End -Buffer $buffer -Value ','
            Add-End -Buffer $buffer -Integer $this.Column
            Add-End -Buffer $buffer -Value ')'
        }
        elseif ($this.Line -gt 0) {
            Add-End -Buffer $buffer -Value '('
            Add-End -Buffer $buffer -Integer $this.Line
            Add-End -Buffer $buffer -Value ')'
        }
        else {
            Add-End -Buffer $buffer -Value '()'
        }

        return ConvertTo-String -Buffer $buffer
    }

    [string]ToString([int]$Postion) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $buffer = New-StringBuilder -Value $this.Name

        switch ($Postion) {
            0 {
                Add-End -Buffer $buffer -Value '()'
                break
            }

            1 {
                if ($this.Line -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ')'
                }
                else {
                    Add-End -Buffer $buffer -Value '()'
                }

                break
            }

            2 {
                if ($this.Line -gt 0 -and $this.Column -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ')'
                }
                else {
                    Add-End -Buffer $buffer -Value '()'
                }

                break
            }

            3 {
                if ($this.Line -gt 0 -and $this.Column -gt 0 -and $this.LastColumn -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value '-'
                    Add-End -Buffer $buffer -Integer $this.LastColumn
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0 -and $this.Column -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ')'
                }
                else {
                    Add-End -Buffer $buffer -Value '()'
                }

                break
            }

            4 {
                if ($this.Line -gt 0 -and $this.Column -gt 0 -and $this.LastColumn -gt 0 -and $this.LastLine -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.LastLine
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.LastColumn
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0 -and $this.Column -gt 0 -and $this.LastColumn -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value '-'
                    Add-End -Buffer $buffer -Integer $this.LastColumn
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0 -and $this.Column -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ','
                    Add-End -Buffer $buffer -Integer $this.Column
                    Add-End -Buffer $buffer -Value ')'
                }
                elseif ($this.Line -gt 0) {
                    Add-End -Buffer $buffer -Value '('
                    Add-End -Buffer $buffer -Integer $this.Line
                    Add-End -Buffer $buffer -Value ')'
                }
                else {
                    Add-End -Buffer $buffer -Value '()'
                }

                break
            }

            default {
                return $this.ToString()
            }
        }

        return ConvertTo-String -Buffer $buffer
    }
}

<#
    Import-Module supporting Constructor
#>
function New-Origin {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Origin])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[Origin] default constructor", $CmdletName)) {
        [Origin]::CmdletHost | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([Origin]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
