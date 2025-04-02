<#
 =============================================================================
<copyright file="CommandLine.Module.tests.ps1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2025 U.S. Office of Personnel Management.
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
<date>Created:  2024-9-17</date>
<summary>
This file "CommandLine.Module.tests.ps1" is part of "CommandLineModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

using module CommandLine

AfterAll {
    Pop-Location
}

BeforeAll {
    Push-Location -LiteralPath $PSScriptRoot

    $psModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerShellModule.psd1'

    if (Test-Path -LiteralPath $psModulePath -PathType Leaf) {
        Import-Module -Name $psModulePath -Force
    }

    Initialize-PSTest -Name 'PowerShellModule' -Path $PSCommandPath

    if (Test-Path -LiteralPath $SourceToTestPath -PathType Leaf) {
        Write-Information -MessageData "$($ScriptName):  Dot Sourcing -> '$($SourceToTestPath)'" -InformationAction Continue -Tags @('dot', 'source', 'test', 'path')
        . $SourceToTestPath
    }
    else {
        Write-Information -MessageData "$($ModuleName):  Importing Module -> '$($ModulePath)'" -InformationAction Continue -Tags @('import', 'module', 'path')
        Import-Module -Name $ModulePath -Force
    }
}

Describe "Commandline Class" {
    Context "Constructors" {
        It -Name 'Constructor Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }
    }

    Context "Public Methods" {
        It -Name 'Initializer Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendFileNameIfNotNull Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendFileNamesIfNotNull Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendSpaceIfNotEmpty Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendSwitch Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendSwitchIfNotNull Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendSwitchUnquotedIfNotNull Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendTextUnquoted Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'AppendTextWithQuoting Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'ToString Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }
    }

    Context "Logic Public Methods" {
        It -Name 'IsQuotingRequired Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'IsEscapingRequired Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'IsSpecialCharacter Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }
    }

    Context "Static Public Methods" {
        It -Name 'AppendQuotedTextToBuffer Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'Escape Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'VerifyThrowNoEmbeddedDoubleQuotes Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }

        It -Name 'Update Scenario Expected Result' -Tag 'Test' {
            # Arrange

            # Act

            # Assert
        }
    }
}
