<#
 =============================================================================
<copyright file="VersionModule.tests.ps1" company="U.S. Office of Personnel
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
This file "VersionModule.tests.ps1" is part of "VersionModule".
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
#requires -Module UtcModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\VersionModule.psd1'
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'VersionModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'VersionModule' | Remove-Module -Verbose -Force
}

Describe -Name 'VersionModule' {
    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It 'should have a RootModule of VersionModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'VersionModule.psm1'
        }

        It 'should have a ModuleVersion greater than  1.3.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.3.0'
        }

        It 'should have a GUID of 08636B39-72BD-48E3-8CEF-084EFA5AD3D7' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '08636B39-72BD-48E3-8CEF-084EFA5AD3D7'
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
            $Copyright | Should -Be 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'
        }

        It 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a Description of PowerShell Module of Cmdlets/Functions that generates and modifies versions for files.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'PowerShell Module of Cmdlets/Functions that generates and modifies versions for files.'
        }

        It 'should have a PowerShellVersion of 5.1' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }

        It 'should have ExportedCmdlets count should equal ExportedFunctions count' {
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

        It 'should have ExportedCmdlets equal to ExportedFunctions' {
            # Arrange
            $exportedCmdlets = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedCmdlets' |
                    Sort-Object -Unique
            $exportedFunctions = Test-ModuleManifest -Path $ModulePath |
                Select-Object -ExpandProperty 'ExportedFunctions' |
                    Sort-Object -Unique

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

    Context -Name 'Compare-PerlVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-PerlVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-PerlVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Compare-PerlVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Compare-PerlVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Compare-PerlVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Compare-PythonVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-PythonVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-PythonVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Compare-PythonVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Compare-PythonVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Compare-PythonVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Compare-StringVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-StringVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-StringVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Compare-StringVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Compare-StringVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Compare-StringVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Compare-WindowsVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-WindowsVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Compare-WindowsVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Compare-WindowsVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Compare-WindowsVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Compare-WindowsVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'ConvertFrom-PerlVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-PerlVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-PerlVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertFrom-PerlVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertFrom-PerlVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertFrom-PerlVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'ConvertFrom-PythonVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-PythonVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-PythonVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertFrom-PythonVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertFrom-PythonVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertFrom-PythonVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'ConvertFrom-SemanticVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-SemanticVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-SemanticVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertFrom-SemanticVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertFrom-SemanticVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertFrom-SemanticVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'ConvertFrom-StringVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-StringVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-StringVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertFrom-StringVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertFrom-StringVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertFrom-StringVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'ConvertFrom-WindowsVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-WindowsVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'ConvertFrom-WindowsVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'ConvertFrom-WindowsVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'ConvertFrom-WindowsVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'ConvertFrom-WindowsVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Get-AssemblyVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-AssemblyVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-AssemblyVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-AssemblyVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-AssemblyVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-AssemblyVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Get-FileVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-FileVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-FileVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-FileVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-FileVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-FileVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Get-FileVersionInfo' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-FileVersionInfo'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-FileVersionInfo'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-FileVersionInfo' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-FileVersionInfo' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-FileVersionInfo' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Get-InformationalVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-InformationalVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-InformationalVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-InformationalVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-InformationalVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-InformationalVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Get-ModuleVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-ModuleVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-ModuleVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-ModuleVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-ModuleVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-ModuleVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'module version greater than 1.0.0.0' -Tag 'Test' {
            # Arrange
            $modulePath = '.\VersionModule.psd1'

            # Act
            $actual = Get-ModuleVersion -ModuleManifest $modulePath

            # Assert
            $actual | Should -BeGreaterThan '1.0.0.0'
        }
    }

    Context -Name 'Initialize-Version' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Initialize-Version'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Initialize-Version'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Initialize-Version' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Initialize-Version' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Initialize-Version' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-AssemblyVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-AssemblyVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-AssemblyVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-AssemblyVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-AssemblyVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-AssemblyVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type System.Version' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10

            # Act
            $result = New-AssemblyVersion -Major $major -Minor $minor

            # Assert
            $result | Should -BeOfType 'System.Version'
        }

        It -Name 'new assembly version should be greater than Major.Minor.0.0' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-AssemblyVersion -Major $major -Minor $minor

            # Assert
            $expected | Should -BeLessThan $actual
        }

        It -Name 'new assembly version should have Major same as Major input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-AssemblyVersion -Major $major -Minor $minor

            # Assert
            $expected.Major | Should -Be $actual.Major
        }

        It -Name 'new assembly version should Minor same as Minor input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-FileVersion -Major $major -Minor $minor

            # Assert
            $expected.Minor | Should -Be $actual.Minor
        }

        It -Name 'new assembly version should have a Revision of 0' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = 0

            # Act
            $actual = New-AssemblyVersion -Major $major -Minor $minor

            # Assert
            $actual.Revision | Should -Be $expected
        }
    }

    Context -Name 'New-BuildNumber' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-BuildNumber'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-BuildNumber'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-BuildNumber' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-BuildNumber' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-BuildNumber' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type int' -Tag 'Test' {
            # Arrange and Act
            $result = New-BuildNumber

            # Assert
            $result | Should -BeOfType 'int'
        }

        It 'build number should be stable' {
            # Arrange and Act
            $expected = New-BuildNumber
            $actual = New-BuildNumber

            # Assert
            $expected | Should -BeLessOrEqual $actual
        }

        It 'build number should less than or equal to 65534' {
            # Arrange and Act
            $expected = 65534
            $actual = New-BuildNumber

            # Assert
            $expected | Should -BeGreaterOrEqual $actual
        }
    }

    Context -Name 'New-CalendarVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-CalendarVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-CalendarVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-CalendarVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-CalendarVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-CalendarVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-FileVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-AssemblyVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-FileVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-FileVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-FileVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-FileVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type System.Version' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10

            # Act
            $result = New-FileVersion -Major $major -Minor $minor

            # Assert
            $result | Should -BeOfType 'System.Version'
        }

        It -Name 'new file version should be greater than Major.Minor.0.0' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-FileVersion -Major $major -Minor $minor

            # Assert
            $expected | Should -BeLessThan $actual
        }

        It -Name 'new file version should have Major same as Major input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-FileVersion -Major $major -Minor $minor

            # Assert
            $expected.Major | Should -Be $actual.Major
        }

        It -Name 'new file version should Minor same as Minor input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-FileVersion -Major $major -Minor $minor

            # Assert
            $expected.Minor | Should -Be $actual.Minor
        }
    }

    Context -Name 'New-InformationalVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-InformationalVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-InformationalVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-InformationalVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-InformationalVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-InformationalVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type string' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10

            # Act
            $result = New-AssemblyVersion -Major $major -Minor $minor

            # Assert
            $result | Should -BeOfType 'string'
        }

        It -Name 'new informational version should be greater than Major.Minor.0.0' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-InformationalVersion -Major $major -Minor $minor

            # Assert
            $expected | Should -BeLessThan $actual
        }

        It -Name 'new informational version should have Major same as Major input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-InformationalVersion -Major $major -Minor $minor

            # Assert
            $expected.Major | Should -Be $actual.Major
        }

        It -Name 'new informational version should Minor same as Minor input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-InformationalVersion -Major $major -Minor $minor

            # Assert
            $expected.Minor | Should -Be $actual.Minor
        }
    }

    Context -Name 'New-JsonVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-JsonVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-JsonVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-JsonVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-JsonVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-JsonVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-PatchNumber' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PatchNumber'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PatchNumber'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-PatchNumber' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-PatchNumber' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-PatchNumber' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type int' -Tag 'Test' {
            # Arrange and Act
            $result = New-PatchNumber

            # Assert
            $result | Should -BeOfType 'int'
        }

        It -Name 'new patch number should be less than or equal to max int' -Tag 'Test' {
            # Arrange and Act
            $result = New-PatchNumber

            # Assert
            $result | Should -BeLessOrEqual [int]::MaxValue
        }

        It -Name 'new patch number build part should equal build number' -Tag 'Test' {
            # Arrange
            $expected = New-BuildNumber

            # Act
            $actual = [int][Math]::Floor((New-PatchNumber) / 100000.0)

            # Assert
            $actual | Should -Be $expected
        }
    }

    Context -Name 'New-PerlVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PerlVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PerlVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-PerlVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-PerlVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-PerlVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-PythonVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PythonVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-PythonVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-PythonVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-PythonVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-PythonVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-RevisionNumber' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-RevisionNumber'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-RevisionNumber'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-RevisionNumber' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-RevisionNumber' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-RevisionNumber' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-SemanticVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-SemanticVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-SemanticVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-SemanticVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-SemanticVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-SemanticVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }

        It -Name 'return value should be of type System.Management.Automation.SemanticVersion' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10

            # Act
            $result = New-SemanticVersion -Major $major -Minor $minor

            # Assert
            $result | Should -BeOfType 'System.Management.Automation.SemanticVersion'
        }

        It -Name 'new semantic version should be greater than Major.Minor.0' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0)

            # Act
            $actual = New-SemanticVersion -Major $major -Minor $minor

            # Assert
            $expected | Should -BeLessThan $actual
        }

        It -Name 'new semantic version should have Major same as Major input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-SemanticVersion -Major $major -Minor $minor

            # Assert
            $expected.Major | Should -Be $actual.Major
        }

        It -Name 'new semantic version should Minor same as Minor input' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = [System.Version]::new($major, $minor, 0, 0)

            # Act
            $actual = New-SemanticVersion -Major $major -Minor $minor

            # Assert
            $expected.Minor | Should -Be $actual.Minor
        }

        It -Name 'new semantic version Patch should be greater than or equal to New-PatchNumber' -Tag 'Test' {
            # Arrange
            $major = 1940
            $minor = 10
            $expected = New-PatchNumber

            # Act
            $actual = New-SemanticVersion -Major $major -Minor $minor

            # Assert
            $expected | Should -BeLessOrEqual $actual.Patch
        }
    }

    Context -Name 'New-WindowsVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-WindowsVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-WindowsVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-WindowsVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-WindowsVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-WindowsVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'New-XmlVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-XmlVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-XmlVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-XmlVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-XmlVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-XmlVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Test-CPreRelease' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-CPreRelease'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-CPreRelease'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-CPreRelease' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-CPreRelease' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-CPreRelease' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Test-PreRelease' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-PreRelease'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-PreRelease'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-PreRelease' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-PreRelease' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-PreRelease' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-AssemblyVersionToAssemblyInfo' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyVersionToAssemblyInfo'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyVersionToAssemblyInfo'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-AssemblyVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-AssemblyVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-AssemblyVersionToAssemblyInfo' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-AssemblyFileVersionToAssemblyInfo' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyFileVersionToAssemblyInfo'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyFileVersionToAssemblyInfo'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-AssemblyFileVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-AssemblyFileVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-AssemblyFileVersionToAssemblyInfo' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-AssemblyInformationalVersionToAssemblyInfo' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyInformationalVersionToAssemblyInfo'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-AssemblyInformationalVersionToAssemblyInfo'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-AssemblyInformationalVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-AssemblyInformationalVersionToAssemblyInfo' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-AssemblyInformationalVersionToAssemblyInfo' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-FileVersionToSdkProj' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-FileVersionToSdkProj'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-FileVersionToSdkProj'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-FileVersionToSdkProj' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-FileVersionToSdkProj' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-FileVersionToSdkProj' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-InformationalVersionToSdkProj' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-InformationalVersionToSdkProj'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-InformationalVersionToSdkProj'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-InformationalVersionToSdkProj' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-InformationalVersionToSdkProj' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-InformationalVersionToSdkProj' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-VersionToSdkProj' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-VersionToSdkProj'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-VersionToSdkProj'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-VersionToSdkProj' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-VersionToSdkProj' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-VersionToSdkProj' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }

    Context -Name 'Write-XPathVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-XPathVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-XPathVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-XPathVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Write-XPathVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of VersionModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Write-XPathVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'VersionModule'
        }
    }
}
