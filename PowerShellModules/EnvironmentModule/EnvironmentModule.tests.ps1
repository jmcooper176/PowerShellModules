<#
 =============================================================================
<copyright file="EnvironmentModule.tests.ps1" company="U.S. Office of Personnel
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
This file "EnvironmentModule.tests.ps1" is part of "EnvironmentModule".
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
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\EnvironmentModule.psd1'
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'EnvironmentModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'EnvironmentModule' | Remove-Module -Verbose -Force
}

Describe -Name 'EnvironmentModule' {
    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It 'should have a RootModule of EnvironmentModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'EnvironmentModule.psm1'
        }

        It 'should have a ModuleVersion greater than  1.3.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.3.0'
        }

        It 'should have a GUID of 073AE309-6F89-42BC-BD92-306B4BB57D82' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '073AE309-6F89-42BC-BD92-306B4BB57D82'
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

    Context -Name 'Add-EnvironmentValue' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-EnvironmentValue'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-EnvironmentValue'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-EnvironmentValue' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-EnvironmentValue' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-EnvironmentValue' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Copy-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Copy-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Copy-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Copy-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Copy-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Copy-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Get-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Get-EnvironmentHashtable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-EnvironmentHashtable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-EnvironmentHashtable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-EnvironmentHashtable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-EnvironmentHashtable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-EnvironmentHashtable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Join-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Join-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Join-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Join-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Join-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Join-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'New-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'New-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'New-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            Write-Information -MessageData "Synopsis: $Synopsis" -InformationAction Continue
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'New-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'New-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Remove-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Remove-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Remove-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Remove-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Out-ArrayList' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Out-ArrayList'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Out-ArrayList'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Out-ArrayList' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Out-ArrayList' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Out-ArrayList' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Out-Hashtable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Out-Hashtable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Out-Hashtable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Out-Hashtable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Out-Hashtable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Out-Hashtable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Rename-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Rename-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Rename-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Rename-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Rename-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Rename-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Set-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Set-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Set-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Set-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Set-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }

    Context -Name 'Test-EnvironmentVariable' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-EnvironmentVariable'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-EnvironmentVariable'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-EnvironmentVariable' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-EnvironmentVariable' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of EnvironmentModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-EnvironmentVariable' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'EnvironmentModule'
        }
    }
}
