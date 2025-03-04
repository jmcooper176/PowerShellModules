<#
 =============================================================================
<copyright file="StringBuilder.tests.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-2-3</date>
<summary>
This file "StringBuilder.tests.ps1" is part of "StringBuilderModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

using module .\StringBuilder.psm1

#requires -Module Pester
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\StringBuilder.psd1'
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Initialize-PSTest -Name 'StringBuilder' -Path $ModulePath
}

AfterAll {
    Write-Warning -Message "Must restart a new session to unload class"
}

Describe -Name 'StringBuilder' {
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

        It 'should have a RootModule of StringBuilder.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'StringBuilder.psm1'
        }

        It 'should have a ModuleVersion greater than  1.0.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.0.0'
        }

        It 'should have a GUID of 5C2E948D-0C90-4FE6-A454-AD6BB5463590' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '5C2E948D-0C90-4FE6-A454-AD6BB5463590'
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

        It 'should have a Description of Implements StringBuilder for PowerShell.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Implements StringBuilder for PowerShell.'
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

    Context 'StringBuilder Class' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should register a TypeAccelerator' {
            # Arrange, Act and Assert
            [StringBuilder]::new()
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

            #Act
            $Accelerators = $TypeAcceleratorsClass::Get

            # Assert
            $Accelerators.Values | Where-Object -Property Name -EQ 'StringBuilder' | Should -BeTrue
        }

        It 'should have a ClassName property' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It 'should have a MaxCapacity property' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It 'should have a PSCapacity script property' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name PSCapacity -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It 'should have a PSLength script property' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name PSLength -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It 'should have an Append method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Append -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an AppendFormat method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendFormat -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an AppendJoin method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendJoin -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an AppendLine method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendLine -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Clear method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Clear -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Contains method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Contains -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a CopyTo method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name CopyTo -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an ElementAt method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an EndsWith method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name EndsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an EnsureCapacity method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name EnsureCapacity -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an Equals method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Equals -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an IndexOf method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have an Insert method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Insert -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a LastIndexOf method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name LastIndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Prepend method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Prepend -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Remove method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Remove -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Replace method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Replace -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ReplaceLineEndings method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ReplaceLineEndings -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a SetElementAt method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name SetElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Slice method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Slice -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Split method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Split -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a StartsWith method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name StartsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToCharArray method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToCharArray -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToLower method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToLower -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToLowerInvariant method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToLowerInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToString method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToString -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToUpper method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToUpper -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a ToUpperInvariant method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToUpperInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a Trim method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Trim -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a TrimEnd method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name TrimEnd -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a TrimStart method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name TrimStart -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It 'should have a static ComputeImpliedCount method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ComputeImpliedCount -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static CountIsOutOfRange method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name CountIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static IndexIsOutOfRange method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static IsEmpty method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static IsNull method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNull -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static IsNullOrEmpty method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNullOrEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static IsNullOrWhiteSpace method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNullOrWhiteSpace -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static LengthIsOutOfRange method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name LengthIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It 'should have a static StartIndexIsOutOfRange method' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name StartIndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Constructor Default by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Default by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange and Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange and Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Default by New-StringBuilder' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange and Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange and Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Capacity by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 100' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = [StringBuilder]::new($expected)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Capacity by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 100' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Capacity by New-StringBuilder' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should not have a value' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It 'PSCapacity should be 100' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 0' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = [StringBuilder]::new($expected)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value by New-StringBuilder' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = New-StringBuilder -Value $expected

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 16' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value and Capacity by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = [StringBuilder]::new($value, $capacity)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = [StringBuilder]::new($expected, $capacity)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Arrange and Act
            $StringBuilder = [StringBuilder]::new($value, $expected)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $capacity = 200
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = [StringBuilder]::new($value, $capacity)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value and Capacity by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected, $capacity

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $capacity = 200
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value, StartIndex, Length, and Capacity by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200

            # Act
            $StringBuilder = [StringBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = 'Hello, World'

            # Act
            $StringBuilder = [StringBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $expected = 200

            # Act
            $StringBuilder = [StringBuilder]::new($value, $startIndex, $count, $expected)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 12' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = $value.Substring($startIndex, $count).Length

            # Act
            $StringBuilder = [StringBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor Value, StartIndex, Length, and Capacity by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = 'Hello, World'

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $expected = 200

            # Arrange and Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $startIndex, $count, $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 12' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = $value.Substring($startIndex, $count).Length

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor HashTable by TypeAccelerator' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = 200
            }

            # Act
            $StringBuilder = [StringBuilder]::new($HashTable)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            $HashTable = @{
                Value = $expected
                Length = 13
                Capacity = 200
            }

            # Act
            $StringBuilder = [StringBuilder]::new($HashTable)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $expected = 200

            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = $expected
            }

            # Act
            $StringBuilder = [StringBuilder]::new($HashTable)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $expected = 13

            $HashTable = @{
                Value = 'Hello, World!'
                Length = $excepted
                Capacity = 200
            }

            # Act
            $StringBuilder = [StringBuilder]::new($HashTable)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor HashTable by New-Object' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = 200
            }

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $HashTable

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            $HashTable = @{
                Value = $expected
                Length = 13
                Capacity = 200
            }

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $HashTable

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $expected = 200

            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = $expected
            }

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $HashTable

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            $HashTable = @{
                Value = $value
                Length = $expected
                Capacity = 200
            }

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $HashTable

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Constructor HashTable by New-StringBuilder' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should return a [StringBuilder] object' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 12
                Capacity = 200
            }

            # Act
            $StringBuilder = New-StringBuilder -Properties $HashTable

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It 'should have a value' {
            # Arrange
            $expected = 'Hello, World!'

            $HashTable = @{
                Value = $expected
                Length = 13
                Capacity = 200
            }

            # Act
            $StringBuilder = New-StringBuilder -Properties $HashTable

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It 'PSCapacity should be 200' {
            # Arrange
            $expected = 200

            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = $expected
            }

            # Act
            $StringBuilder = New-StringBuilder -Properties $HashTable

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It 'PSLength should be 13' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            $HashTable = @{
                Value = $value
                Length = $excepted
                Capacity = 200
            }

            # Act
            $StringBuilder = New-StringBuilder -Properties $HashTable

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context 'Property ClassName' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should exist' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It 'should be a string' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ClassName | Should -BeOfType 'string'
        }

        It 'should equal StringBuilder' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ClassName | Should -Be 'StringBuilder'
        }
    }

    Context 'Property MaxCapacity' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should exist' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It 'should be an int' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.MaxCapacity | Should -BeOfType 'int'
        }

        It 'should equal 2147483647' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.MaxCapacity | Should -Be 2147483647
        }
    }

    Context 'Method Append' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It 'should exist' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Append  -MemberType Method | Should -Not -BeNullOrEmpty
        }
    }
}
