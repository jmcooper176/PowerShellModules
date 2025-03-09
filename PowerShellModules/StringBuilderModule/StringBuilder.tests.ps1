<#
 =============================================================================
<copyright file="StringBuilder.tests.ps1" company="John Merryweather Cooper">
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
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Initialize-PSTest -Name 'StringBuilder' -Path $ModulePath
}

AfterAll {
    Write-Warning -Message "Must restart a new session to unload class"
}

Describe -Name 'StringBuilder' -Tag 'Module', 'Under', 'Test' {
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

        It -Name 'should have a RootModule of StringBuilder.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'StringBuilder.psm1'
        }

        It -Name 'should have a ModuleVersion greater than  1.0.0' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.0.0'
        }

        It -Name 'should have a GUID of 258b2258-ae15-4550-a767-1946aefd4fe1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '258b2258-ae15-4550-a767-1946aefd4fe1'
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

        It -Name 'should have a Description of Implements StringBuilder for PowerShell.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Implements StringBuilder for PowerShell.'
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

    Context -Name 'StringBuilder Class' -Tag 'Class', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should register a TypeAccelerator' -Tag 'Unit', 'Test' {
            # Arrange, Act and Assert
            [StringBuilder]::new()
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

            #Act
            $Accelerators = $TypeAcceleratorsClass::Get

            # Assert
            $Accelerators.Values | Where-Object -Property Name -EQ 'StringBuilder' | Should -BeTrue
        }

        It -Name 'should have a ClassName property' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a MaxCapacity property' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a PSCapacity script property' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name PSCapacity -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a PSLength script property' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name PSLength -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Append method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Append -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendFormat method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendFormat -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendJoin method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendJoin -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendLine method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name AppendLine -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Clear method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Clear -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Contains method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Contains -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a CopyTo method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name CopyTo -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an ElementAt method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an EndsWith method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name EndsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an EnsureCapacity method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name EnsureCapacity -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Equals method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Equals -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an IndexOf method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Insert method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Insert -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a LastIndexOf method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name LastIndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Prepend method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Prepend -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Remove method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Remove -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Replace method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Replace -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ReplaceLineEndings method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ReplaceLineEndings -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a SetElementAt method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name SetElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Slice method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Slice -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Split method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Split -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a StartsWith method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name StartsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToCharArray method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToCharArray -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToLower method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToLower -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToLowerInvariant method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToLowerInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToString method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToString -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToUpper method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToUpper -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToUpperInvariant method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ToUpperInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Trim method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Trim -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a TrimEnd method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name TrimEnd -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a TrimStart method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name TrimStart -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static ComputeImpliedCount method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ComputeImpliedCount -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static CountIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name CountIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IndexIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsEmpty method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNull method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNull -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNullOrEmpty method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNullOrEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNullOrWhiteSpace method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name IsNullOrWhiteSpace -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static LengthIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name LengthIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static StartIndexIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name StartIndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Constructor Default by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Default by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Default by New-StringBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
            $StringBuilder = New-StringBuilder -Default

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = [StringBuilder]::new($expected)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = [StringBuilder]::new($capacity)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by New-StringBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
            $StringBuilder = New-StringBuilder -Capacity $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
            $StringBuilder = New-StringBuilder -Capacity $capacity

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = [StringBuilder]::new($expected)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = [StringBuilder]::new($value)

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by New-StringBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
            $StringBuilder = New-StringBuilder -Value $expected

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
            $StringBuilder = New-StringBuilder -Value $value

            # Assert
            $StringBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value and Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = [StringBuilder]::new($value, $capacity)

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = [StringBuilder]::new($expected, $capacity)

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Arrange and Act
            $StringBuilder = [StringBuilder]::new($value, $expected)

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor Value and Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $capacity

            # Assert
            $StringBuilder | Should -BeOfType '[StringBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $expected, $capacity

            # Assert
            $StringBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Act
            $StringBuilder = New-Object -TypeName StringBuilder -ArgumentList $value, $expected

            # Assert
            $StringBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor Value, StartIndex, Length, and Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
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

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
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

        It -Name 'PSLength should be 12' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor Value, StartIndex, Length, and Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
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

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
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

        It -Name 'PSLength should be 12' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor HashTable by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
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

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
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

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor HashTable by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
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

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
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

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
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

    Context -Name 'Constructor HashTable by New-StringBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'StringBuilderModule' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [StringBuilder] object' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
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

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
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

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
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

    Context -Name 'Property ClassName' -Tag 'Property', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should be a string' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ClassName | Should -BeOfType 'string'
        }

        It -Name 'should equal StringBuilder' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.ClassName | Should -Be 'StringBuilder'
        }
    }

    Context -Name 'Property MaxCapacity' -Tag 'Property', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should be an int' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.MaxCapacity | Should -BeOfType 'int'
        }

        It -Name 'should equal 2147483647' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder.MaxCapacity | Should -Be 2147483647
        }
    }

    Context -Name 'Method Append' -Tag 'Method', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'StringBuilder' | ForEach-Object -Process {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $StringBuilder = [StringBuilder]::new()

            # Assert
            $StringBuilder | Get-Member -Name Append  -MemberType Method | Should -Not -BeNullOrEmpty
        }
    }
}
