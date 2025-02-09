<#
 =============================================================================
<copyright file="pre-build.tests.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-1-31</date>
<summary>
This file "pre-build.tests.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module Pester
#requires -Module PowerShellModule

BeforeAll {
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '.\pre-build.ps1'
    . $ScriptPath -ClaimType 'Test' -ClaimValue 'Mine' -Server 'https://octopus.opm.gov'
    Initialize-PSTest -Name 'pre-build.ps1' -Path $ScriptPath
}

AfterAll {
}

Describe -Name 'pre-build.ps1' {
    Context -Name 'Script Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ScriptManifest = Test-ScriptFileInfo -Path $ScriptPath

            # Assert
            $ScriptManifest | Should -Not -BeNullOrEmpty
        }

        It 'should have a Version greater than or equal to 1.0.0' {
            # Arrange and Act
            $ScriptVersion = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ScriptVersion | Should -BeGreaterOrEqual '1.0.0'
        }

        It 'should have a GUID of C704773C-ECA9-42F1-8AA9-88F9659CCDCC' {
            # Arrange and Act
            $Guid = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Guid'

            # Assert
            $Guid | Should -Be 'C704773C-ECA9-42F1-8AA9-88F9659CCDCC'
        }

        It 'should have an Author of John Merryweather Cooper' {
            # Arrange and Act
            $Author = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Author'

            # Assert
            $Author | Should -Be 'John Merryweather Cooper'
        }

        It 'should have a CompanyName of John Merryweather Cooper' {
            # Arrange and Act
            $CompanyName = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'CompanyName'

            # Assert
            $CompanyName | Should -Be $COMPANY_NAME_STRING
        }

        It 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' {
            # Arrange and Act
            $Copyright = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be $COPYRIGHT_STRING
        }

        It 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Description'

            # Act
            $Length = $Description | Measure-Object -Character | Select-Object -ExpandProperty Characters

            # Assert
            $Length | Should -BeGreaterThan $MINIMUM_DESCIPTION_LENGTH
        }

        It 'should have a Description containing `Convert a ClaimsIdentity to a JSON Web Encryption (JWE) token.' {
            # Arrange and Act
            $Description = Test-ScriptFileInfo -Path $ScriptPath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Contain 'Convert a ClaimsIdentity to a JSON Web Encryption (JWE) token.'
        }
    }
}