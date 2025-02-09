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

        It 'should have a module name of HelperModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-EnvironmentValue' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'HelperModule'
        }
    }
}

BeforeAll {
    # Arrange
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'HelperModule.psd1' -Resolve
    $ConvertModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\ConvertModule\ConvertModule.psd1' -Resolve
    $TypeAcceleratorPath = Join-Path -Path $PSScriptRoot -ChildPath '..\TypeAccelerator\TypeAccelerator.psd1' -Resolve

    # Act
    Import-Module -Name $ModulePath -Force -Verbose
    Import-Module -Name $TypeAcceleratorPath -Force -Verbose

    # Assert
    Get-Module -Name 'HelperModule' | Should -Not -BeNull
    Get-Module -Name 'TypeAccelerator' | Should -Not -BeNull
}

AfterAll {
    # Act
    Get-Module -Name 'HelperModule' | Remove-Module -Verbose
    Get-Module -Name 'TypeAccelerator' | Remove-Module -Verbose

    # Assert
    Get-Module -Name 'HelperModule' | Should -BeNull
    Get-Module -Name 'TypeAccelerator' | Should -BeNull
}

Describe -Name 'HelperModule' {
    It 'should have a RootModule of HelperModule.psm1' {
        # Arrange and Act
        $RootModule = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'RootModule'

        # Assert
        $RootModule | Should -Be 'HelperModule.psm1'
    }

    It 'should have a ModuleVersion of 1.1.0' {
        # Arrange and Act
        $ModuleVersion = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Version'

        # Assert
        $ModuleVersion | Should -Be '1.1.0'
    }

    It 'should have an Author of John Merryweather Cooper' {
        # Arrange and Act
        $Author = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Author'

        # Assert
        $Author | Should -Be 'John Merryweather Cooper'
    }

    It 'should have a CompanyName of Ram Tuned Mega Code' {
        # Arrange and Act
        $CompanyName = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'CompanyName'

        # Assert
        $CompanyName | Should -Be 'Ram Tuned Mega Code'
    }

    It 'should have a Copyright of Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.' {
        # Arrange and Act
        $Copyright = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Copyright'

        # Assert
        $Copyright | Should -Be 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'
    }

    It 'should have a Description of Unit test helper functions for PowerShell.' {
        # Arrange and Act
        $Description = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'Description'

        # Assert
        $Description | Should -Be 'Unit test helper functions for PowerShell.'
    }

    It 'should have a PowerShellVersion of 5.1' {
        # Arrange and Act
        $PowerShellVersion = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'PowerShellVersion'

        # Assert
        $PowerShellVersion | Should -Be '5.1'
    }

    It 'should have a NestedModule of ConvertModule' {
        # Arrange and Act
        $NestedModules = Test-ModuleManifest -Path '.\HelperModule.psd1' | Select-Object -ExpandProperty 'NestedModules'

        # Assert
        $NestedModules | Should -Be 'ConvertModule'
    }
}

Describe -Name 'Select-ModuleByFilter' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Select-ModuleByFilter'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context -Name 'When the Module parameter exists and the Filter parameter is $true' {
        It -Name 'Should return the the same module' -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = $ModulePath

            # Act
            $Module = Select-ModuleByFilter -Path $Expected -Filter { $true }

            # Assert
            $Module | Select-Object -ExpandProperty Path | Should -Be $Expected
        }
    }
}

Describe -Name 'Select-ModuleByProperty' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Select-ModuleByProperty'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context -Name 'When the Module parameter exists and the Property parameter is "Path"' {
        It -Name 'Should return the the same module' -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = $ModulePath

            # Act
            $Module = Select-ModuleByProperty -Path $Expected -Property 'Path' -Value $Expected

            # Assert
            $Module | Select-Object -ExpandProperty Path | Should -Be $Expected
        }
    }
}

Describe 'Test-HasMember' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Test-HasMember'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context 'When the Object parameter is null' {
        It -Name 'Should throw a ArgumentNullException' -Tag @('Unit', 'Test') {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMember -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }
    }

    Context 'When the Object parameter is not null and Property Name exists' {
        It -Name 'Should return $true' -Tag @('Unit', 'Test') {
            # Arrange
            $Object = Get-Item -LiteralPath $env:ComSpec

            # Act and Assert
            'FullName' | Test-HasMember -Object $Object -Strict | Should -BeTrue
        }
    }
}

Describe 'Test-HasMethod' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Test-HasMethod'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context 'When the Object parameter is null' {
        It -Name 'Should throw a ArgumentNullException' -Tag @('Unit', 'Test') {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMethod -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }
    }

    Context 'When the Object parameter is not null and Property Name exists' {
        It -Name 'Should return $true' -Tag @('Unit', 'Test') {
            # Arrange
            $Object = Get-Item -LiteralPath $env:COMSPEC

            # Act and Assert
            'GetType' | Test-HasMethod -Object $Object -Strict | Should -BeTrue
        }
    }
}

Describe 'Test-HasProperty' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Test-HasMethod'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context 'When the Object parameter is null' {
        It -Name 'Should throw a ArgumentNullException' -Tag @('Unit', 'Test') {
            # Arrange, Act, and Assert
            { 'Name' | Test-HasMethod -Object $null -Strict } | Should -Throw '*ArgumentNullException*'
        }
    }

    Context 'When the Object parameter is not null and Property Name exists' {
        It -Name 'Should return $true' -Tag @('Unit', 'Test') {
            # Arrange
            $Object = [PSCustomObject]@{
                Name = 'John'
            }

            # Act and Assert
            $Object | Test-HasProperty -Object $Object -Strict | Should -BeTrue
        }
    }
}

Describe 'Test-ModuleProperty' {
    Context -Name 'Exists' {
        It -Name 'Should exist' -Tag @('Unit', 'Test') {
            # Arrange
            $testPathSplat = @{
                Path = 'Function:\Test-ModuleProperty'
                PathType = 'Leaf'
            }

            # Act and Assert
            Test-Path @testPathSplat | Should -BeTrue
        }
    }

    Context 'When the Module parameter exists and Property Name exists' {
        It -Name 'Should return $true' -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = 'Path'

            # Act and Assert
            $ModulePath | Test-ModuleProperty -Property $Expected | Should -BeTrue
        }
    }
}