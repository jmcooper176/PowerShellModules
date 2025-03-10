<#
 =============================================================================
<copyright file="PowerShellModule.tests.ps1" company="John Merryweather Cooper">
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
<date>Created:  2025-1-27</date>
<summary>
This file "PowerShellModule.tests.ps1" is part of "PowerShellModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from https://go.microsoft.com/fwlink/?LinkID=534084
#

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\PowerShellModule.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'PathModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'PowerShellModule' | Remove-Module -Verbose -Force
}

Describe -Name 'PowerShellModule' -Tag 'Module', 'Under', 'Test' {
    Context -Name 'PowerShellModule Module Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'Exists' -Tag 'Unit', 'Test' {
            # Act and Assert
            Test-Path -LiteralPath $ModulePath -PathType Leaf | Should -BeTrue
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

        It -Name 'Has Content' -Tag 'Unit', 'Test' {
            # Act and Assert
            Get-ItemProperty -LiteralPath $ModulePath -Name Length | Should -BeGreaterThan 0
        }

        It -Name 'Is Not Null Or Empty' -Tag 'Unit', 'Test' {
            # Act and Assert
            Test-ModuleManifest -Path $ModulePath | Should -Not -BeNullOrEmpty
        }

        It -Name 'Is Valid Return Type' -Tag 'Unit', 'Test' {
            # Act and Assert
            Test-ModuleManifest -Path $ModulePath | Should -BeOfType [System.Management.Automation.PSModuleInfo]
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace RootModule' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath
            $expected = 'PowerShellModule.psm1'

            # Act
            $actual = $moduleInfo.RootModule

            # Assert
            $actual | Should -BeExactly $expected
        }

        It -Name 'Has Not Null ModuleVersion' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Version

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'Has ModuleVersion Greater Than 0.0.0' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath
            $expected = [System.Version]::new(0, 0, 0)

            # Act
            $actual = $moduleInfo.Version

            # Assert
            $actual | Should -BeGreaterThan $expected
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace Guid' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Guid.ToString()

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace Author' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Author

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace CompanyName' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.CompanyName

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'CompanyName is COMPANY_NAME_STRING' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.CompanyName

            # Assert
            $actual | Should -BeExactly $COMPANY_NAME_STRING
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace Copyright' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Copyright

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'Copyright is COPYRIGHT_STRING' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Copyright

            # Assert
            $actual | Should -BeExactly $COPYRIGHT_STRING
        }

        It -Name 'Has Not Null, Empty, or WhiteSpace Description' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Description

            # Assert
            $actual | Should -Not -BeNullOrEmpty
        }

        It -Name 'Description Length is Greater Than or Equal to MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange
            $moduleInfo = Test-ModuleManifest -Path $ModulePath

            # Act
            $actual = $moduleInfo.Description.Length

            # Assert
            $actual | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
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

    Context -Name 'Add-PSEntry' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Add-PSEntry'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName) -Raw

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $moduleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Add-PSParameter' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Add-PSParameter'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Enter-PSBlock' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Enter-PSBlock'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Get-PSBuildVersion' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Get-PSBuildVersion'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Get-PSMajorVersion' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Get-PSMajorVersion'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Get-PSMinorVerison' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Get-PSMinorVersion'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Get-PSParameter' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Get-PSParameter'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Get-PSVersion' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Get-PSVersion'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Initialize-PSClass' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Initialize-PSClass'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Initialize-PSCmdlet' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Initialize-PSCmdlet'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Initialize-PSFunction' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Initialize-PSFunction'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Initialize-PSTest' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Initialize-PSTest'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Initialize-PSScript' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Initialize-PSScript'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Measure-PSString' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Measure-PSString'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Test-PSParameter' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Test-PSParameter'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Test-PSVersion' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Test-PSVersion'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }

        Context -Name 'Update-PSVariable' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
            BeforeEach {
                # Arrange
                $cmdletName = 'Update-PSVariable'
                $inputSource = Get-Content -LiteralPath (Join-Path -Path Function: -ChildPath $cmdletName)

                [ref] $tokens = @()
                [ref] $errors = @()
                $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $RootModule, $tokens, $errors)

                $errors.Value | ForEach-Object -Process {
                    $writeErrorHash = @{
                        Exception    = [System.Management.Automation.ParseException]::new($_)
                        Message      = ('{0}/{1}:  Parse error generating abstract syntax tree' -f $ModuleName, $cmdletName)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-L{1}' -f $cmdletName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorHash -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }

                $Help = Get-Help -Name $cmdletName -Full
            }

            It -Name 'Has Synopsis'  -Tag 'Unit', 'Test' {
                $Help.Synopsis.Length | Should -BeGreaterOrEqual $MINIMUM_SYNOPSIS_LENGTH
            }

            It -Name 'Has Description'  -Tag 'Unit', 'Test' {
                $Help.description.Text | Measure-PSString | Should -BeGreaterOrEqual $MINIMUM_DESCRIPTION_LENGTH
            }

            It -Name 'Parameters are Present'  -Tag 'Unit', 'Test' {
                $Help.Parameters.Parameter | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterOrEqual $AST.ParamBlock.Parameters.Count
            }

            It -Name 'Has Example'  -Tag 'Unit', 'Test' {
                $Help.Examples.Count | Should -BeGreaterThan 0
            }

            It -Name 'Copyright is Present'  -Tag 'Unit', 'Test' {
                # Arrange
                $expected = $COPYRIGHT_STRING

                # Act
                $Notes = ($Help.alertSet.alert.text -split [Environment]::NewLine)

                # Assert
                $actual = $Notes[0].Trim()
                $actual | Should -Be $expected
            }

            It -Name 'Has Links'  -Tag 'Unit', 'Test' {
                $Help.RelatedLinks | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -BeGreaterThan 0
            }
        }
}
