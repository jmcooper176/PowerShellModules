<#
 =============================================================================
<copyright file="GitHubModule.tests.ps1" company="John Merryweather Cooper">
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
<date>Created:  2024-9-12</date>
<summary>
This file "GitHubModule.tests.ps1" is part of "GitHubModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from https://go.microsoft.com/fwlink/?LinkID=534084
#

#requires -Module Pester
#requires -Module EnvironmentModule
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule
#requires -Module StringBuilderModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\GitHubModule.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'GitHubModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'GitHubModule' | Remove-Module -Verbose -Force
}

Describe -Name 'GitHubModule' -Tag 'Module', 'Under', 'Test' {
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

        It -Name 'should have a RootModule of GitHubModule.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'GitHubModule.psm1'
        }

        It -Name 'should have a ModuleVersion greater than  1.5.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.5.0'
        }

        It -Name 'should have a GUID of 883f9316-52b6-4604-ad9a-b48f5c7b75d0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '883f9316-52b6-4604-ad9a-b48f5c7b75d0'
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

        It -Name 'should have a Description of Utility Module that provides functionality useful with GitHub steps.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Utility Module that provides functionality useful with GitHub steps.'
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

    Context -Name 'Add-MultilineStepSummary' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-MultilineStepSummary'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Add-MultilineStepSummary') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Add-MultilineStepSummary')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-MultilineStepSummary'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-MultilineStepSummary' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-MultilineStepSummary' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-MultilineStepSummary' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Add-StepSummary' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-StepSummary'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Add-StepSummary') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Add-StepSummary')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-StepSummary'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-StepSummary' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-StepSummary' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-StepSummary' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Add-SystemPath' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-SystemPath'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Add-SystemPath') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Add-SystemPath')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-SystemPath'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-SystemPath' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-SystemPath' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-SystemPath' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'ConvertTo-Tuple' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertTo-Tuple'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'ConvertTo-Tuple') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'ConvertTo-Tuple')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertTo-Tuple'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertTo-Tuple' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertTo-Tuple' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertTo-Tuple' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }

        It -Name 'should return a tuple object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'GITHUB_OUTPUT, 1.2.3.4'

            # Act
            $result = ConvertTo-Tuple -Value $value

            # Assert
            $result | Should -BeOfType [object]
        }

        It -Name 'should return a tuple where Item1 is string' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'GITHUB_OUTPUT, 1.2.3.4'

            # Act
            $result = ConvertTo-Tuple -Value $value

            # Assert
            $result.Item1 | Should -BeOfType [string]
        }

        It -Name 'should return a tuple where Item2 is string' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'GITHUB_OUTPUT, 1.2.3.4'

            # Act
            $result = ConvertTo-Tuple -Value $value

            # Assert
            $result.Item2 | Should -BeOfType [string]
        }

        It -Name 'should return a tuple with Item1 equal to EnvironmentFile' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'GITHUB_OUTPUT, 1.2.3.4'
            $expected = 'GITHUB_OUTPUT'

            # Act
            $result = ConvertTo-Tuple -Value $value

            # Assert
            $result.Item1 | Should -Be $expected
        }

        It -Name 'should return a tuple with Item2 equal to Content' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'GITHUB_OUTPUT, 1.2.3.4'
            $expected = '1.2.3.4'

            # Act
            $result = ConvertTo-Tuple -Value $value

            # Assert
            $result.Item2 | Should -Be $expected
        }
    }

    Context -Name 'Export-EnvironmentVariableFile' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        BeforeEach {
            'env.txt', 'output.txt', 'path.txt', 'save.txt', 'step_summary.txt' | ForEach-Object -Process {
                $removePath = Join-Path -Path $env:TEMP -ChildPath $_
                Remove-Item -LiteralPath $removePath -Force -ErrorAction SilentlyContinue
            }
        }

        AfterEach {
            'GITHUB_ENV', 'GITHUB_OUTPUT', 'GITHUB_PATH', 'GITHUB_SAVE', 'GITHUB_STEP_SUMMARY' | ForEach-Object -Process {
                Remove-Item -LiteralPath env:$_ -ErrorAction SilentlyContinue
            }

            'env.txt', 'output.txt', 'path.txt', 'save.txt', 'step_summary.txt' | ForEach-Object -Process {
                $removePath = Join-Path -Path $env:TEMP -ChildPath $_
                Remove-Item -LiteralPath $removePath -Force -ErrorAction SilentlyContinue
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Export-EnvironmentVariableFile'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Export-EnvironmentVariableFile') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Export-EnvironmentVariableFile')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Export-EnvironmentVariableFile'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Export-EnvironmentVariableFile' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Export-EnvironmentVariableFile' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Export-EnvironmentVariableFile' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }

        It -Name 'should set file pointed to by GITHUB_ENV' -Tag 'Unit', 'Test' {
            # Arrange
            $envPath = Join-Path -Path $env:TEMP -ChildPath 'env.txt'
            $env:GITHUB_ENV = $envPath
            $expected = 'Hello, World!'

            # Act
            Export-EnvironmentVariableFile -EnvironmentFile GITHUB_ENV -Content $expected -Echo
            $fileContent = Get-Content -LiteralPath $envPath

            # Assert
            $fileContent | Should -Be $expected
        }

        It -Name 'should set file pointed to by GITHUB_OUTPUT' -Tag 'Unit', 'Test' {
            # Arrange
            $outputPath = Join-Path -Path $env:TEMP -ChildPath 'output.txt'
            $env:GITHUB_OUTPUT = $outputPath
            $expected = 'Hello, World!'

            # Act
            Export-EnvironmentVariableFile -EnvironmentFile GITHUB_OUTPUT -Content $expected -Echo
            $fileContent = Get-Content -LiteralPath $outputPath

            # Assert
            $fileContent | Should -Be $expected
        }

        It -Name 'should set file pointed to by GITHUB_PATH' -Tag 'Unit', 'Test' {
            # Arrange
            $pathPath = Join-Path -Path $env:TEMP -ChildPath 'path.txt'
            $env:GITHUB_PATH = $pathPath
            $expected = 'Hello, World!'

            # Act
            Export-EnvironmentVariableFile -EnvironmentFile GITHUB_PATH -Content $expected -Echo
            $fileContent = Get-Content -LiteralPath $pathPath

            # Assert
            $fileContent | Should -Be $expected
        }

        It -Name 'should set file pointed to by GITHUB_SAVE' -Tag 'Unit', 'Test' {
            # Arrange
            $savePath = Join-Path -Path $env:TEMP -ChildPath 'save.txt'
            $env:GITHUB_SAVE = $savePath
            $expected = 'Hello, World!'

            # Act
            Export-EnvironmentVariableFile -EnvironmentFile GITHUB_SAVE -Content $expected -Echo
            $fileContent = Get-Content -LiteralPath $savePath

            # Assert
            $fileContent | Should -Be $expected
        }

        It -Name 'should set file pointed to by GITHUB_STEP_SUMMARY' -Tag 'Unit', 'Test' {
            # Arrange
            $stepSummaryPath = Join-Path -Path $env:TEMP -ChildPath 'step_summary.txt'
            $env:GITHUB_STEP_SUMMARY = $stepSummaryPath
            $expected = 'Hello, World!'

            # Act
            Export-EnvironmentVariableFile -EnvironmentFile GITHUB_STEP_SUMMARY -Content $expected -Echo
            $fileContent = Get-Content -LiteralPath $stepSummaryPath

            # Assert
            $fileContent | Should -Be $expected
        }
    }

    Context -Name 'Get-GitHubEnvironmentVariable' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitHubEnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Get-GitHubEnvironmentVariable') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Get-GitHubEnvironmentVariable')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitHubEnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitHubEnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitHubEnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitHubEnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Remove-StepSummary' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-StepSummary'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Remove-StepSummary') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Remove-StepSummary')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-StepSummary'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Remove-StepSummary' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Remove-StepSummary' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Remove-StepSummary' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Set-GitHubEnvironmentVariable' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-GitHubEnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Set-GitHubEnvironmentVariable') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Set-GitHubEnvironmentVariable')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-GitHubEnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Set-GitHubEnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Set-GitHubEnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Set-GitHubEnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Set-MultilineEnvironmentVariable' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-MultilineEnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Set-MultilineEnvironmentVariable') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Set-MultilineEnvironmentVariable')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-MultilineEnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Set-MultilineEnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Set-MultilineEnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Set-MultilineEnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Set-MultilineStepSummary' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-MultilineStepSummary'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Set-MultilineStepSummary') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Set-MultilineStepSummary')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-MultilineStepSummary'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Set-MultilineStepSummary' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Set-MultilineStepSummary' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Set-MultilineStepSummary' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }
    }

    Context -Name 'Set-OutputParameter' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        BeforeEach {
            'setOutputParameter.txt' | ForEach-Object -Process {
                $removePath = Join-Path -Path $env:TEMP -ChildPath $_
                Remove-Item -LiteralPath $removePath -Force -ErrorAction SilentlyContinue
            }
        }

        AfterEach {
            'GITHUB_OUTPUT' | ForEach-Object -Process {
                Remove-Item -LiteralPath env:$_ -ErrorAction SilentlyContinue
            }

            'setOutputParameter.txt' | ForEach-Object -Process {
                $removePath = Join-Path -Path $env:TEMP -ChildPath $_
                Remove-Item -LiteralPath $removePath -Force -ErrorAction SilentlyContinue
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-OutputParameter'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should parse' -Tag 'Unit', 'Test' {
            # Arrange
            $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath 'Set-OutputParameter') -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)
            $success = $true

            # Act
            $errors.Value | ForEach-Object -Process {
                $success = $false
                $message = ('{0}@{1} : Parse error generating abstract syntax tree' -f $ModuleName, 'Set-OutputParameter')
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

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-OutputParameter'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Set-OutputParameter' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Get-Help -Name 'Set-OutputParameter' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should have a module name of GitHubModule' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Set-OutputParameter' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitHubModule'
        }

        It -Name 'should set file pointed to by GITHUB_OUTPUT to version' -Tag 'Unit', 'Test' {
            # Arrange
            $outputPath = Join-Path -Path $env:TEMP -ChildPath 'setOutputParameter.txt'
            $env:GITHUB_OUTPUT = $outputPath
            $expected = 'FileVersion=1.2.3.4'

            # Act
            Set-OutputParameter -Name FileVersion -Value '1.2.3.4' -Echo
            $fileContent = Get-Content -LiteralPath $outputPath

            # Assert
            $fileContent | Should -Be $expected
        }

        It -Name 'should set file pointed to by GITHUB_OUTPUT to path' -Tag 'Unit', 'Test' {
            # Arrange
            $outputPath = Join-Path -Path $env:TEMP -ChildPath 'setOutputParameter.txt'
            $env:GITHUB_OUTPUT = $outputPath
            $expected = ('FilePath={0}' -f $outputPath)

            # Act
            Set-OutputParameter -Name FilePath -Value $outputPath -Echo
            $fileContent = Get-Content -LiteralPath $outputPath

            # Assert
            $fileContent | Should -Be $expected
        }
    }
}
