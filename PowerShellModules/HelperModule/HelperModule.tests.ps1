<#
 =============================================================================
<copyright file="HelperModule.tests.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-1-27</date>
<summary>
This file "HelperModule.tests.ps1" is part of "HelperModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module Pester
#requires -Module ConvertModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\HelperModule.psd1'
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'HelperModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'HelperModule' | Remove-Module -Verbose -Force
}

Describe -Name 'HelperModule' {
    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It 'should parse' {
            $inputSource = Get-Content -LiteralPath $ModulePath -Raw

            [ref] $tokens = @()
            [ref] $errors = @()
            $AST = [System.Management.Automation.Language.Parser]::ParseInput($inputSource, $ModuleFileName, $tokens, $errors)

            $errors.Value | ForEach-Object -Process {
                $message = ('{0} at {1}:  Parse error generating abstract syntax tree' -f $ModuleName, $ModulePath)
                $writeErrorSplat = @{
                        Exception    = [System.Management.Automation.ParseException]::new($message)
                        Category     = 'ParseError'
                        ErrorId      = ('{0}-ParseException-{1}' -f $ModuleName, $MyInvocation.ScriptLineNumber)
                        TargetObject = $_
                        ErrorAction  = 'Continue'
                    }

                    Write-Error @writeErrorSplat -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($writeErrorHash)
                }
        }

        It 'should have a RootModule of HelperModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'HelperModule.psm1'
        }

        It 'should have a ModuleVersion greater than  1.3.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.3.0'
        }

        It 'should have a GUID of 6FB469B2-EF92-423D-8D82-F495128AD32F' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '6FB469B2-EF92-423D-8D82-F495128AD32F'
        }

        It 'should have an Author of John Merryweather Cooper' {
            # Arrange and Act
            $Author = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It 'should have a CompanyName of John Merryweather Cooper' {
            # Arrange and Act
            $CompanyName = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be $COMPANY_NAME_STRING
        }

        It 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be $COPYRIGHT_STRING
        }

        It 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a Description of Enhanced interface to Process Environment Variables.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Enhanced interface to Process Environment Variables.'
        }

        It 'should have a PowerShellVersion of 5.1' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }
    }

    Context -Name 'Get-HelpModule' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-HelpPropery'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-HelpProperty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Get-HelpProperty -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Get-HelpProperty -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-HelpProperty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }

        It 'ForEach-Object Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name ForEach-Object -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Get-ChildItem Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Get-ChildItem -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Get-Help Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Get-Help -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Get-Item Description should be not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Get-Item -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Measure-Object Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Measure-Object -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Select-Object Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Select-Object -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Sort-Object Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Sort-Object -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }

        It 'Where-Object Description should not be null or empty' {
            # Arrange and Act
            $value = Get-HelpPropertyLength -Name Where-Object -Property Description

            # Assert
            $value | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-HelpModuleLength' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-HelpProperyLength'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-HelpPropertyLength'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Get-HelpPropertyLength -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Get-HelpPropertyLength -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-HelpPropertyLength' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }

        It 'ForEach-Object Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name ForEach-Object -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Get-ChildItem Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Get-ChildItem -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Get-Help Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Get-Help -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Get-Item Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Get-Item -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Measure-Object Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Measure-Object -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Select-Object Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Select-Object -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Sort-Object Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Sort-Object -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'Where-Object Description should be greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $length = Get-HelpPropertyLength -Name Where-Object -Property Description

            # Assert
            $length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }
    }

    Context -Name 'Get-ModuleProperty' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-ModulePropery'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-ModuleProperty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Get-ModuleProperty -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Get-ModuleProperty -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-ModuleProperty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }

        It 'Module Name Pester should return property Name equals Pester' {
            # Arrange and Act
            $name = Get-ModuleProperty -Name 'Pester' -Property Name

            # Assert
            $name | Should -Be 'Pester'
        }

        It 'Module Name Pester  return property Path that exists and is a leaf' {
            # Arrange and Act
            $path = Get-ModuleProperty -Name 'Pester' -Property Path

            # Assert
            $path | Test-Path -PathType Leaf | Should -Be $true
        }

        It 'Module Name Pester  return property Description that is not null or empty' {
            # Arrange and Act
            $description = Get-ModuleProperty -Name 'Pester' -Property Description

            # Assert
            $description | Should -Not -BeNullOrEmpty
        }

        It 'Module Name Pester return property ModuleType of Script' {
            # Arrange and Act
            $moduleType = Get-ModuleProperty -Name 'Pester' -Property ModuleType

            # Assert
            $moduleType | Should -Be 'Script'
        }

        It 'Module Name Pester return property Name equals Pester' {
            # Arrange and Act
            $name = Get-ModuleProperty -Name 'Pester' -Property Name

            # Assert
            $name | Should -Be 'Pester'
        }

        It 'Module Name Pester return property Path that exists and is a leaf' {
            # Arrange and Act
            $path = Get-ModuleProperty -Name 'Pester' -Property Path

            # Assert
            $path | Test-Path -PathType Leaf | Should -BeTrue
        }

        It "LiteralPath '.\HelperModule.psd1' should return property Description that is not null or empty" {
            # Arrange and Act
            $description = Get-ModuleProperty -LiteralPath '.\HelperModule.psd1' -Property Description

            # Assert
            $description | Should -Not -BeNullOrEmpty
        }

        It "LiteralPath '.\HelperModule.psd1' should return property ModuleType of Script" {
            # Arrange and Act
            $moduleType = Get-ModuleProperty -LiteralPath '.\HelperModule.psd1' -Property ModuleType

            # Assert
            $moduleType | Should -Be 'Script'
        }

        It "LiteralPath '.\HelperModule.psd1' should return property Path that exists and is a leaf" {
            # Arrange and Act
            $path = Get-ModuleProperty -LiteralPath '.\HelperModule.psd1' -Property Path

            # Assert
            $path | Test-Path -PathType Leaf | Should -BeTrue
        }

        It "Path '.\HelperModul*.psd?' should return property Description that is not null or empty" {
            # Arrange and Act
            $description = Get-ModuleProperty -Path '.\HelperModul*.psd?' -Property Description

            # Assert
            $description | Should -Not -BeNullOrEmpty
        }

        It "Path '.\HelperModul*.psd?' should return property ModuleType of Script" {
            # Arrange and Act
            $moduleType = Get-ModuleProperty -Path '.\HelperModul*.psd?' -Property ModuleType

            # Assert
            $moduleType | Should -Be 'Script'
        }

        It "Path '.\HelperModul*.psd?' should return property Path that exists and is a leaf" {
            # Arrange and Act
            $path = Get-ModuleProperty -Path '.\HelperModul*.psd?' -Property Path

            # Assert
            $path | Test-Path -PathType Leaf | Should -BeTrue
        }
    }

    Context -Name 'Select-ModuleByFilter' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Select-ModuleByFilter'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Select-ModuleByFilter'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Select-ModuleByFilter -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Select-ModuleByFilter -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Select-ModuleByFilter' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }

    Context -Name 'Select-ModuleByProperty' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Select-ModuleByProperty'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Select-ModuleByProperty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Select-ModuleByProperty -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Select-ModuleByProperty -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Select-ModuleByProperty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }

    Context -Name 'Test-HasMember' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasMember'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasMember'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Test-HasMember -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Test-HasMember -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-HasMember' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }

    Context -Name 'Test-HasMethod' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasMethod'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasMethod'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Test-HasMethod -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Test-HasMethod -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-HasMethod' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }

    Context -Name 'Test-HasProperty' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasProperty'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-HasProperty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Test-HasProperty -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Test-HasProperty -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-HasProperty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }

    Context -Name 'Test-ModuleProperty' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-ModuleProperty'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-ModuleProperty'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-HelpProperty -Name Test-ModuleProperty -Property Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-HelpProperty -Name Test-ModuleProperty -Property Description

            # Assert
            $Description.Length Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-ModuleProperty' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }
}
