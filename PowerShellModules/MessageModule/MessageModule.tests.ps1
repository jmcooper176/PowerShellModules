<#
 =============================================================================
<copyright file="MessageModule.tests.ps1" company="John Merryweather Cooper">
    Copyright © 2022-2025, John Merryweather Cooper.
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
<date>Created:  2025-1-9</date>
<summary>
This file "MessageModule.tests.ps1" is part of "MessageModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module Pester
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\MessageModule.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'MessageModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'MessageModule' | Remove-Module -Verbose -Force
}

Describe -Name 'MessageModule' -Tag 'Module', 'Under', 'Test' {
    Context -Name 'Module Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath $ModulePath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModulePath, $ModuleName)
                $newErrorRecordSplat = @{
                    Exception    = [System.Management.Automation.ParseException]::new($message)
                    Category     = 'ParseError'
                    ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                    TargetObject = $_
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
            }

            # Assert
            $success | Should -BeTrue
        }

        It -Name 'should have a RootModule of MessageModule.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'MessageModule.psm1'
        }

        It -Name 'should have a ModuleVersion greater than  1.3.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.3.0'
        }

        It -Name 'should have a GUID of 70f1f86a-28b1-48a2-8f3e-34c5c8363091' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '70f1f86a-28b1-48a2-8f3e-34c5c8363091'
        }

        It -Name 'should have an Author of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Author = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It -Name 'should have a CompanyName of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $CompanyName = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be $COMPANY_NAME_STRING
        }

        It -Name 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be $COPYRIGHT_STRING
        }

        It -Name 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a Description of Cmdlets/functions to format and write messages loosely following the Microsoft compiler message format.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Cmdlets/functions to format and write messages loosely following the Microsoft compiler message format.'
        }

        It -Name 'should have a PowerShellVersion of 5.1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }

        It -Name 'should have ExportedCmdlets count should equal ExportedFunctions count' -Tag 'Unit', 'Test' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                    Sort-Object -Unique
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                    Sort-Object -Unique

            # Act And Assert
            $exportedCmdlets.Count | Should -Be $exportedFunctions.Count
        }

        It -Name 'should have ExportedCmdlets equal to ExportedFunctions' -Tag 'Unit', 'Test' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                    Sort-Object -Unique -Descending
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                    Sort-Object -Unique -Descending

            # Act
            for ($i = 0; $i -lt $exportedCmdlets.Count; $i++) {
                $result = $exportedCmdlets[$i] -eq $exportedFunctions[$i]

                if (-not $result) {
                    break
                }
            }

            # Assert
            $result | Should -BeTrue
        }
    }

    Context -Name 'Add-SeparatorIfNotNullOrEmpty' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-SeparatorIfNotNullOrEmpty'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-SeparatorIfNotNullOrEmpty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-SeparatorIfNotNullOrEmpty' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-SeparatorIfNotNullOrEmpty' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-SeparatorIfNotNullOrEmpty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }
    }

    Context -Name 'Format-Debug' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Debug'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Debug'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Debug' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Debug' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Debug' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should emit formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Debug -InvocationInfo $MyInvocation -Content $Message

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Debug -InvocationInfo $MyInvocation

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }
    }

    Context -Name 'Format-Error' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Error'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Error'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Error' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Error' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Error' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should emit formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $message = 'This is a message.'
            $errorId = Format-ErrorId -Caller $MyInvocation -Name 'Exception' -Position $MyInvocation.ScriptLineNumber
            $newErrorRecordSplat = @{
                Exception = [System.Exception]::new($message)
                Category = 'NotSpecified'
                ErrorId = $errorId
                TargetObject = $message
                TargetName = 'message'
            }

            $errorRecord = New-ErrorRecord @newErrorRecordSplat

            # Act
            $FormattedMessage = Format-Error -ErrorRecord $errorRecord -InvocationInfo $MyInvocation -Content $Message -Metadata @($errorId, 'Exception', 0)

            # Assert
            $FormattedMessage.Contains($message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $message = 'This is a message.'
            $errorId = Format-ErrorId -Caller $MyInvocation -Name 'Exception' -Position $MyInvocation.ScriptLineNumber
            $newErrorRecordSplat = @{
                Exception = [System.Exception]::new($message)
                Category = 'NotSpecified'
                ErrorId = $errorId
                TargetObject = $message
                TargetName = 'message'
            }

            $errorRecord = New-ErrorRecord @newErrorRecordSplat

            # Act
            $FormattedMessage = $errorRecord | Format-Error -InvocationInfo $MyInvocation -Content $Message -Metadata @($errorId, 'Exception', 0)

            # Assert
            $FormattedMessage.Contains($message) | Should -BeTrue
        }
    }

    Context -Name 'Format-Information' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Information'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Information'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Information' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Information' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Information' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should emit formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Information -InvocationInfo $MyInvocation -Content $Message -Tag ('Info', 'Test', 'Message')

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $message | Format-Information -InvocationInfo $MyInvocation -Tag ('Info', 'Test', 'Message')

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }
    }

    Context -Name 'Format-Message' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Message'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Message'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Message' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Message' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Message' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should emit formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2')

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit metadata in message' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message

            # Assert
            $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with metadata' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2')

            # Assert
            $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit formatted message with valid origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message valid origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2')

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit metadata in message valid origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with metadata valid origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2')

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit formatted message with valid caller origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -UseCaller

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message valid caller origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -UseCaller

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit metadata in message valid caller origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -UseCaller

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with metadata valid caller origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -UseCaller

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit formatted message with valid file name origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -UseGccBrief

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message valid file name origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -UseGccBrief

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit metadata in message valid file name origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -UseGccBrief

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with metadata valid file name origin' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'
            $Message = 'This is a message.'
            $Metadata = 'Value1 Value2'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -UseGccBrief

            # Assert
            $FormattedMessage.Contains($Expected) -and $FormattedMessage.Contains($Metadata) | Should -BeTrue
        }

        It -Name 'should emit formatted message with timestamp' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -Timestamp

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with timestamp' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Timestamp

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit formatted message with local timestamp' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Content $Message -Timestamp -AsLocal

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }

        It -Name 'should emit piped formatted message with local timestamp' -Tag 'Unit', 'Test' {
            # Arrange
            $Message = 'This is a message.'

            # Act
            $FormattedMessage = $Message | Format-Message -InvocationInfo $MyInvocation -Metadata @('Value1', 'Value2') -Timestamp -AsLocal

            # Assert
            $FormattedMessage.Contains($Message) | Should -BeTrue
        }
    }

    Context -Name 'Format-Metadata' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Metadata'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Metadata'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Metadata' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Metadata' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Metadata' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should emit formatted metadata' -Tag 'Unit', 'Test' {
            # Arrange
            $Metadata = @(
                'Value1',
                'Value2'
            )

            # Act
            $FormattedMetadata = Format-Metadata -Metadata $Metadata

            #Assert
            $FormattedMetadata | Should -Be 'Value1 Value2'
        }
    }

    Context -Name 'Format-Origin' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Origin'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Origin'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Origin' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Origin' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Origin' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should return the path origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the caller origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseCaller

            # Assert
            $Origin.StartsWith($Expected) | Should -BeTrue
        }

        It -Name 'should return the file name origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseGccBrief

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the timestamp with path origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -Timestamp

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the timestamp with caller origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseCaller -Timestamp

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the timestamp with file name origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseGccBrief -Timestamp

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the local timestamp with path origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -Timestamp -AsLocal

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the local timestamp with caller origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseCaller -Timestamp -AsLocal

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }

        It -Name 'should return the local timestamp with file name origin of the message' -Tag 'Unit', 'Test' {
            # Arrange
            $Expected = 'Pester.psm1'

            # Act
            $Origin = Format-Origin -InvocationInfo $MyInvocation -UseGccBrief -Timestamp -AsLocal

            # Assert
            $Origin.Contains($Expected) | Should -BeTrue
        }
    }

    Context -Name 'Format-Verbose' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Verbose'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Verbose'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Verbose' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Verbose' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Verbose' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }
    }

    Context -Name 'Format-Warning' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Warning'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Format-Warning'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Format-Warning' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Format-Warning' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Format-Warning' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }
    }

    Context -Name 'Test-Debug' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-Debug'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-Debug'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-Debug' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            Write-Information -MessageData "Synopsis: $Synopsis" -InformationAction Continue
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-Debug' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-Debug' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should be false without -Debug' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Verbose = Test-Debug -InvocationInfo $MyInvocation

            # Assert
            $Verbose | Should -Be $false
        }
    }

    Context -Name 'Test-Verbose' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-Verbose'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-Verbose'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-Verbose' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-Verbose' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-Verbose' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should be false without -Verbose' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Verbose = Test-Verbose -InvocationInfo $MyInvocation

            # Assert
            $Verbose | Should -Be $false
        }
    }

    Context -Name 'Write-DebugIf' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-DebugIf'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-DebugIf'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-DebugIf' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-DebugIf' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of MessageModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-DebugIf' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'MessageModule'
        }

        It -Name 'should write to the debug stream with Condition True' -Tag 'Unit', 'Test' {
            # Arrange
            $DebugPreference = 'Continue'

            # Act
            Write-DebugIf -InvocationInfo $MyInvocation -Condition $True -Message 'Debug message' -Verbose | Tee-Object -Variable DebugText

            # Assert
            $DebugText.EndsWith('Debug message') | Should -BeTrue
        }

        It -Name 'should write to the debug stream with ScriptBlock evaluating to True' -Tag 'Unit', 'Test' {
            # Arrange
            $DebugPreference = 'Continue'

            # Act
            Write-DebugIf -InvocationInfo $MyInvocation -ScriptBlock { $True } -Message 'Debug message' -Verbose | Tee-Object -Variable DebugText

            # Assert
            $DebugText.EndsWith('Debug message') | Should -BeTrue
        }
    }
}
