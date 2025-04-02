<#
 =============================================================================
<copyright file="ProcessModule.tests.ps1" company="John Merryweather Cooper
">
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.
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
<date>Created:  2025-3-13</date>
<summary>
This file "ProcessModule.tests.ps1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\ProcessModule.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name $ModuleName -Path $ModulePath
}

AfterAll {
    Get-Module -Name $ModuleName | Remove-Module -Verbose -Force
}

Describe -Name $ModuleName -Tag 'Module', 'Under', 'Test' {
    Context -Name 'Module Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'exists' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It -Name 'parses' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath $ModulePath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
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

        It -Name "should have a RootModule of $RootModule" -Tag 'Unit', 'Test' {
            # Arrange and Act
            $actual = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $actual | Should -Be $RootModule
        }

        It -Name 'should have a ModuleVersion greater than or equal to  1.0.0.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterOrEqual '1.0.0.0'
        }

        It -Name 'should have a GUID of d4412982-d91f-42d7-a91e-e4885f9d5178' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be 'd4412982-d91f-42d7-a91e-e4885f9d5178'
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

        It -Name 'should have a Copyright of Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be 'Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.'
        }

        It -Name 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a Description of Cmdlets/Functions that invoke tools, start commands, and start shell execution.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Cmdlets/Functions that invoke tools, start commands, and start shell execution.'
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

    Context -Name 'Invoke-Tool' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        BeforeEach {
            $CmdletName = 'Invoke-Tool'
        }

        It -Name 'exists' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'parses' -Tag 'Unit', 'Test' {
            # Arrange
            $functionPath = (Join-Path -Path Function: -ChildPath $CmdletName)
            $inputSource = Get-Content -LiteralPath $functionPath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $HelpContent = $AST.GetHelpContent()
            $Component = $HelpContent.Component
            $Description = $HelpContent.Description
            $Examples = $HelpContent.Examples
            $Functionality = $HelpContent.Functionality
            $Inputs = $HelpContent.Inputs
            $Links = $HelpContent.Links
            $Notes = $HelpContent.Notes
            $Outputs = $HelpContent.Outputs
            $Parameters = $HelpContent.Parameters
            $Role = $HelpContent.Role
            $Synopsis = $HelpContent.Synopsis
            $Block = $HelpContent.GetCommentBlock()
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}/{1} : Parse error generating abstract syntax tree' -f $ModulePath, $ModuleName)
                $newErrorRecordSplat = @{
                    Exception    = [System.Management.Automation.ParseException]::new($message)
                    Category     = 'ParseError'
                    ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                    TargetObject = $errors
                    TargetName   = 'Errors'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
            }

            # Assert
            $success | Should -BeTrue
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have comment-based help' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Block | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description.Length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have examples that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Examples | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have inputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Inputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have notes that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Not -BeNullOrEmpty
        }

        It -Name 'notes should contain Copyright' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Contain 'Copyright'
        }

        It -Name 'should have outputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Outputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have parameters that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Parameters | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name "should have a module name of $ModuleName" -Tag 'Unit', 'Test' {
            # Arrange and Act
            $actual = Get-Command -Name $CmdletName | Select-Object -ExpandProperty ModuleName

            # Assert
            $actual | Should -Be $ModuleName
        }
    }

    Context -Name 'Start-Command' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        BeforeEach {
            $CmdletName = 'Start-Command'
        }

        It -Name 'exists' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'parses' -Tag 'Unit', 'Test' {
            # Arrange
            $functionPath = (Join-Path -Path Function: -ChildPath $CmdletName)
            $inputSource = Get-Content -LiteralPath $functionPath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $HelpContent = $AST.GetHelpContent()
            $Component = $HelpContent.Component
            $Description = $HelpContent.Description
            $Examples = $HelpContent.Examples
            $Functionality = $HelpContent.Functionality
            $Inputs = $HelpContent.Inputs
            $Links = $HelpContent.Links
            $Notes = $HelpContent.Notes
            $Outputs = $HelpContent.Outputs
            $Parameters = $HelpContent.Parameters
            $Role = $HelpContent.Role
            $Synopsis = $HelpContent.Synopsis
            $Block = $HelpContent.GetCommentBlock()
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}/{1} : Parse error generating abstract syntax tree' -f $ModulePath, $ModuleName)
                $newErrorRecordSplat = @{
                    Exception    = [System.Management.Automation.ParseException]::new($message)
                    Category     = 'ParseError'
                    ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                    TargetObject = $errors
                    TargetName   = 'Errors'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
            }

            # Assert
            $success | Should -BeTrue
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have comment-based help' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Block | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description.Length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have examples that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Examples | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have inputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Inputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have notes that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Not -BeNullOrEmpty
        }

        It -Name 'notes should contain Copyright' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Contain 'Copyright'
        }

        It -Name 'should have outputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Outputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have parameters that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Parameters | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name "should have a module name of $ModuleName" -Tag 'Unit', 'Test' {
            # Arrange and Act
            $actual = Get-Command -Name $CmdletName | Select-Object -ExpandProperty ModuleName

            # Assert
            $actual | Should -Be $ModuleName
        }
    }

    Context -Name 'Start-ShellExecution' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        BeforeEach {
            $CmdletName = 'Start-ShellExecution'
        }

        It -Name 'exists' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'parses' -Tag 'Unit', 'Test' {
            # Arrange
            $functionPath = (Join-Path -Path Function: -ChildPath $CmdletName)
            $inputSource = Get-Content -LiteralPath $functionPath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $HelpContent = $AST.GetHelpContent()
            $Component = $HelpContent.Component
            $Description = $HelpContent.Description
            $Examples = $HelpContent.Examples
            $Functionality = $HelpContent.Functionality
            $Inputs = $HelpContent.Inputs
            $Links = $HelpContent.Links
            $Notes = $HelpContent.Notes
            $Outputs = $HelpContent.Outputs
            $Parameters = $HelpContent.Parameters
            $Role = $HelpContent.Role
            $Synopsis = $HelpContent.Synopsis
            $Block = $HelpContent.GetCommentBlock()
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}/{1} : Parse error generating abstract syntax tree' -f $ModulePath, $ModuleName)
                $newErrorRecordSplat = @{
                    Exception    = [System.Management.Automation.ParseException]::new($message)
                    Category     = 'ParseError'
                    ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                    TargetObject = $errors
                    TargetName   = 'Errors'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
            }

            # Assert
            $success | Should -BeTrue
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name $CmdletName

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have comment-based help' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Block | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Description.Length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have examples that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Examples | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have inputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Inputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have notes that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Not -BeNullOrEmpty
        }

        It -Name 'notes should contain Copyright' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Notes | Should -Contain 'Copyright'
        }

        It -Name 'should have outputs that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Outputs | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have parameters that are not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Parameters | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis that is not null or empty' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange, Act, and Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name "should have a module name of $ModuleName" -Tag 'Unit', 'Test' {
            # Arrange and Act
            $actual = Get-Command -Name $CmdletName | Select-Object -ExpandProperty ModuleName

            # Assert
            $actual | Should -Be $ModuleName
        }
    }
}
