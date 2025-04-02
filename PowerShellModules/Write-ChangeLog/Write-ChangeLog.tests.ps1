<#
 =============================================================================
<copyright file="Write-ChangeLog.tests.ps1" company="John Merryweather Cooper
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
<date>Created:  2024-9-12</date>
<summary>
This file "Write-ChangeLog.tests.ps1" is part of "Write-ChangeLog".
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
#requires -Module GitModule
#requires -Module PowerShellModule

BeforeAll {
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '.\Write-ChangeLog.ps1'
    . $ScriptPath
    Initialize-PSTest -Name 'Write-ChangeLog.ps1' -Path $ScriptPath
}

AfterAll {
}

Describe -Name 'Write-ChangeLog.ps1' -Tag 'Script', 'Under', 'Test' {
    Context -Name 'Script Manifest' -Tag 'Manifest', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ScriptManifest = Test-ScriptFileInfo -Path $ScriptPath

            # Assert
            $ScriptManifest | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Version greater than or equal to 1.0.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ScriptVersion = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ScriptVersion | Should -BeGreaterOrEqual '1.0.0'
        }

        It -Name 'should have a GUID of 0FDC4220-823B-42F6-B059-30F9607A09D5' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Guid'

            # Assert
            $Guid | Should -Be '0FDC4220-823B-42F6-B059-30F9607A09D5'
        }

        It -Name 'should have an Author of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Author = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It -Name 'should have a CompanyName of John Merryweather Cooper' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $CompanyName = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be $COMPANY_NAME_STRING
        }

        It -Name 'should have a Copyright of Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Copyright = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be $COPYRIGHT_STRING
        }

        It -Name 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Description'

            # Act
            $Length = $Description | Measure-Object -Character | Select-Object -ExpandProperty Characters

            # Assert
            $Length | Should -BeGreaterThan $MINIMUM_DESCIPTION_LENGTH
        }

        It -Name 'should have a Description of The `Write-ChangeLog.ps1` script writes a change log to a file path.  The change log is written in markdown format and echoed to standard output..' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Out-String | Should -Contain 'The `Write-ChangeLog.ps1` script writes a change log to a file path.  The change log is written in markdown format and echoed to standard output.'
        }
    }

    Context -Name 'Write-ChangeLog' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-ChangeLog'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-ChangeLog'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-ChangeLog' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange
            $Description = Get-Help -Name 'Write-ChangeLog' -Full | Select-Object -ExpandProperty Description

            # Act
            $Length = $Description | Measure-Object -Character | Select-Object -ExpandProperty Characters

            # Assert
            $Length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should output a NewLine for null input' -Tag 'Unit', 'Test' {
            # Arrange
            Set-Variable -Name 'Actual' -Value $null -Scope 'Script'
            $Expected = [Environment]::NewLine

            # Act
            $null | Write-ChangeLog -Variable 'Actual'

            # Assert
            $Actual | Should -Be $Expected
        }

        It -Name 'should output the same text string' -Tag 'Unit', 'Test' {
            # Arrange
            Set-Variable -Name 'Actual' -Value $null -Scope 'Script'
            $Expected = 'Hello, World!'

            # Act
            $Expected | Write-ChangeLog -Variable 'Actual'

            # Assert
            $Actual | Should -Be $Expected
        }
    }

    Context -Name 'Write-ChangeLogHeader' -Tag 'Cmdlet', 'Function', 'Under', 'Test' {
        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-ChangeLogHeader'

            # Assert
            $Command | Should -Not -BeNull
        }

        It -Name 'should be a cmdlet or function' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Command = Get-Command -Name 'Write-ChangeLogHeader'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It -Name 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Write-ChangeLogHeader' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It -Name 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' -Tag 'Unit', 'Test' {
            # Arrange
            $Description = Get-Help -Name 'Write-ChangeLogHeader' -Full | Select-Object -ExpandProperty Description

            #Act
            $Length = $Description | Measure-Object -Character | Select-Object -ExpandProperty Characters

            # Assert
            $Length | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It -Name 'should output a Level 1 markdown header' -Tag 'Unit', 'Test' {
            # Arrange
            $Value = 'Hello, World!'
            $Expected = '# Hello, World!'
            Set-Variable -Name 'Actual' -Value $null -Scope 'Script'

            # Act
            $Value | Write-ChangeLogHeader -Variable 'Actual'

            # Assert
            $Actual | Should -Be $Expected
        }
    }
}
