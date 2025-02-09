#requires -version 7.4

using module CommandLine
using module ErrorResponseType
using module MessageType
using module TypeAccelerator

<#
    class : Metadata
#>
class Metadata {
    <#
        Public Properties
    #>
    [ValidateSet('Console', 'Debug', 'Error', 'Info', 'Trace', 'Verbose', 'Warning')]
    [MessageType]
    $MessageType

    [ValidatePattern('[A-Z]{4}\d{4}')]
    [string]
    $ResourceId

    [ValidatePattern('\w+Exception')]
    [string]
    $ExceptionName

    [int]
    $ErrorCode

    [int]
    $Length {
        get {
            return $this.ToString().Length
        };
    }

    Metadata($MessageType) {
        $this.MessageType = $MessageType
        $this.ErrorCode = 0
    }

    Metadata($MessageType, $ResourceId) {
        $this.MessageType = $MessageType
        $this.ResourceId = $ResourceId
        $this.ErrorCode = 0
    }

    Metadata($MessageType, $ResourceId, $ExceptionName) {
        $this.MessageType = $MessageType
        $this.ResourceId = $ResourceId
        $this.ExceptionName = $ExceptionName
        $this.ErrorCode = 1
    }

    Metadata($MessageType, $ResourceId, $ExceptionName, $ErrorCode) {
        $this.MessageType = $MessageType
        $this.ResourceId = $ResourceId
        $this.ExceptionName = $ExceptionName
        $this.ErrorCode = $ErrorCode
    }

    <#
        Public Methods
    #>
    [string]FormatErrorId([string]$Caller, [int]$Postion) {
        return "{0}-{1}-{2}" -f $Caller, $this.ExceptionName, $Postion
    }

    [string]ToString([switch]$Capitalize) {
        $buffer = New-Object -TypeName CommandLine

        if ($null -ne $TheMetadata.ResourceId) {
            $buffer.AddSpaceIfNotEmpty()

            if ($Capitalize.IsPresent) {
                $buffer.AddTextUnquoted($TheMetadata.ResourceId.ToUpper())
            }
            else {
                $buffer.AddTextUnquoted($TheMetadata.ResourceId)
            }
        }

        if ($null -ne $TheMetadata.ExceptionName) {
            $buffer.AddSpaceIfNotEmpty()
            $buffer.AddTextUnquoted($TheMetadata.ExceptionName)
        }

        if ($TheMetadata.ErrorCode -ne 0) {
            $buffer.AddSpaceIfNotEmpty()
            $errorString = '0x{0:X8}|{0}' -f $TheMetadata.ErrorCode
            $buffer.AddTextUnquoted($errorString)
        }
        else {
            $buffer.AddSpaceIfNotEmpty()
            $buffer.AddTextUnquoted('Error Success')
        }

        return $buffer.ToString()
    }
}

<#
    Import-Module supporting Constructor
#>
function New-Metadata {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Metadata])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Console', 'Debug', 'Error', 'Info', 'Trace', 'Verbose', 'Warning')]
        [MessageType]
        $MessageType
    )

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[Metadata] with one-argument constructor MessageType '$($MessageType)'", $CmdletName)) {
        [Metadata]::new($MessageType) | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([Metadata]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
