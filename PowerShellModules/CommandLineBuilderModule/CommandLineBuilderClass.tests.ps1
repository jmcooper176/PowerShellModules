<#
 =============================================================================
<copyright file="CommandLineBuilderClass.tests.ps1" company="John Merryweather Cooper
">
    Copyright © 2025, John Merryweather Cooper.
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
<date>Created:  2025-3-18</date>
<summary>
This file "CommandLineBuilderClass.tests.ps1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

using module .\CommandLineBuilderClass.psm1

#requires -Module Pester
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule
#requires -Module TypeAcceleratorModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\CommandLineBuilderClass.psd1'
    $RootModule = ($ModulePath -replace '.psd1', '.psm1') | Get-ItemProperty -Name Name
    $ModuleName = $ModulePath | Get-ItemProperty -Name BaseName
    Initialize-PSTest -Name 'CommandLineBuilderClass' -Path $ModulePath
}

AfterAll {
    Write-Warning -Message "Must restart a new session to unload class"
}

Describe -Name 'CommandLineBuilderClass' -Tag 'Module', 'Under', 'Test' {
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

        It -Name 'should have a RootModule of CommandLineBuilderClass.psm1' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'CommandLineBuilderClass.psm1'
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

        It -Name 'should have a Copyright of Copyright © 2024-2025, John Merryweather Cooper.  All Rights Reserved.' -Tag 'Unit', 'Test' {
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

        It -Name 'should have a Description of Implements CommandLineBuilder for PowerShell.' -Tag 'Unit', 'Test' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Implements CommandLineBuilder for PowerShell.'
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

    Context -Name 'CommandLineBuilderClass Class' -Tag 'Class', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilderClass' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should register a TypeAccelerator' -Tag 'Unit', 'Test' {
            # Arrange, Act and Assert
            [CommandLineBuilder]::new()
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

            #Act
            $Accelerators = $TypeAcceleratorsClass::Get

            # Assert
            $Accelerators.Values | Where-Object -Property Name -EQ 'CommandLineBuilder' | Should -BeTrue
        }

        It -Name 'should have a ClassName property' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a MaxCapacity property' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a PSCapacity script property' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name PSCapacity -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a PSLength script property' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name PSLength -MemberType ScriptProperty | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Append method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Append -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendFormat method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name AppendFormat -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendJoin method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name AppendJoin -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an AppendLine method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name AppendLine -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Clear method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Clear -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Contains method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Contains -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a CopyTo method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name CopyTo -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an ElementAt method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an EndsWith method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name EndsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an EnsureCapacity method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name EnsureCapacity -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Equals method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Equals -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an IndexOf method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have an Insert method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Insert -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a LastIndexOf method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name LastIndexOf -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Prepend method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Prepend -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Remove method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Remove -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Replace method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Replace -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ReplaceLineEndings method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ReplaceLineEndings -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a SetElementAt method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name SetElementAt -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Slice method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Slice -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Split method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Split -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a StartsWith method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name StartsWith -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToCharArray method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToCharArray -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToLower method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToLower -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToLowerInvariant method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToLowerInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToString method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToString -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToUpper method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToUpper -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a ToUpperInvariant method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ToUpperInvariant -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a Trim method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Trim -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a TrimEnd method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name TrimEnd -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a TrimStart method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name TrimStart -MemberType Method | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static ComputeImpliedCount method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ComputeImpliedCount -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static CountIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name CountIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IndexIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsEmpty method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IsEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNull method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IsNull -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNullOrEmpty method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IsNullOrEmpty -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static IsNullOrWhiteSpace method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name IsNullOrWhiteSpace -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static LengthIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name LengthIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }

        It -Name 'should have a static StartIndexIsOutOfRange method' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name StartIndexIsOutOfRange -MemberType Method -Static | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Constructor Default by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Default by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = New-Object -TypeName CommandLineBuilder

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = New-Object -TypeName CommandLineBuilder

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
             $instance = New-Object -TypeName CommandLineBuilder

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
             $instance = New-Object -TypeName CommandLineBuilder

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Default by New-CommandLineBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'CommandLineBuilder' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = New-CommandLineBuilder -Default

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = New-CommandLineBuilder -Default

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 16

            # Act
             $instance = New-CommandLineBuilder -Default

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 0

            # Act
             $instance = New-CommandLineBuilder -Default

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = [CommandLineBuilder]::new($capacity)

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = [CommandLineBuilder]::new($capacity)

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
             $instance = [CommandLineBuilder]::new($expected)

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
             $instance = [CommandLineBuilder]::new($capacity)

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $capacity

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $capacity

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $expected

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $capacity

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Capacity by New-CommandLineBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'CommandLineBuilder' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = New-CommandLineBuilder -Capacity $capacity

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should not have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100

            # Act
             $instance = New-CommandLineBuilder -Capacity $capacity

            # Assert
            $CommandLineBuilder.ToString() | Should -BeNullOrEmpty
        }

        It -Name 'PSCapacity should be 100' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 100

            # Act
             $instance = New-CommandLineBuilder -Capacity $expected

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 0' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 100
            $expected = 0

            # Act
             $instance = New-CommandLineBuilder -Capacity $capacity

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
             $instance = [CommandLineBuilder]::new($value)

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
             $instance = [CommandLineBuilder]::new($expected)

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
             $instance = [CommandLineBuilder]::new($value)

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
             $instance = [CommandLineBuilder]::new($value)

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $expected

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value by New-CommandLineBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'CommandLineBuilder' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'

            # Act
             $instance = New-CommandLineBuilder -Value $value

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'

            # Act
             $instance = New-CommandLineBuilder -Value $expected

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 16' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 16

            # Act
             $instance = New-CommandLineBuilder -Value $value

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
             $instance = New-CommandLineBuilder -Value $value

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value and Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
             $instance = [CommandLineBuilder]::new($value, $capacity)

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
             $instance = [CommandLineBuilder]::new($expected, $capacity)

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Arrange and Act
             $instance = [CommandLineBuilder]::new($value, $expected)

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 200
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
             $instance = [CommandLineBuilder]::new($value, $capacity)

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value and Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $capacity = 200

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $capacity

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $expected = 'Hello, World!'
            $capacity = 200

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $expected, $capacity

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $expected = 200

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $expected

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 13' -Tag 'Unit', 'Test' {
            # Arrange
            $capacity = 200
            $value = 'Hello, World!'
            $expected = $value.Length

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $capacity

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value, StartIndex, Length, and Capacity by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200

            # Act
             $instance = [CommandLineBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = 'Hello, World'

            # Act
             $instance = [CommandLineBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $expected = 200

            # Act
             $instance = [CommandLineBuilder]::new($value, $startIndex, $count, $expected)

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 12' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = $value.Substring($startIndex, $count).Length

            # Act
             $instance = [CommandLineBuilder]::new($value, $startIndex, $count, $capacity)

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor Value, StartIndex, Length, and Capacity by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
        }

        It -Name 'should have a value' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = 'Hello, World'

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
        }

        It -Name 'PSCapacity should be 200' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $expected = 200

            # Arrange and Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $startIndex, $count, $expected

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
        }

        It -Name 'PSLength should be 12' -Tag 'Unit', 'Test' {
            # Arrange
            $value = 'Hello, World!'
            $startIndex = 0
            $count = 12
            $capacity = 200
            $expected = $value.Substring($startIndex, $count).Length

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $value, $startIndex, $count, $capacity

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor HashTable by TypeAccelerator' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = 200
            }

            # Act
             $instance = [CommandLineBuilder]::new($HashTable)

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
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
             $instance = [CommandLineBuilder]::new($HashTable)

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
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
             $instance = [CommandLineBuilder]::new($HashTable)

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
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
             $instance = [CommandLineBuilder]::new($HashTable)

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor HashTable by New-Object' -Tag 'Constructor', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 13
                Capacity = 200
            }

            # Act
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $HashTable

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
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
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $HashTable

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
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
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $HashTable

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
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
             $instance = New-Object -TypeName CommandLineBuilder -ArgumentList $HashTable

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Constructor HashTable by New-CommandLineBuilder' -Tag 'Constructor', 'Under', 'Test' {
        BeforeAll {
            Import-Module -Name $ModulePath -Verbose
        }

        AfterAll {
            Get-Module -ListAvailable | Where-Object -Property Name -EQ 'CommandLineBuilder' | Remove-Module -Verbose
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should return a [CommandLineBuilder] object' -Tag 'Unit', 'Test' {
            # Arrange
            $HashTable = @{
                Value = 'Hello, World!'
                Length = 12
                Capacity = 200
            }

            # Act
             $instance = New-CommandLineBuilder -Properties $HashTable

            # Assert
            $instance | Should -BeOfType '[CommandLineBuilder]'
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
             $instance = New-CommandLineBuilder -Properties $HashTable

            # Assert
            $CommandLineBuilder.ToString() | Should -Be $expected
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
             $instance = New-CommandLineBuilder -Properties $HashTable

            # Assert
            $CommandLineBuilder.PSCapacity | Should -Be $expected
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
             $instance = New-CommandLineBuilder -Properties $HashTable

            # Assert
            $CommandLineBuilder.PSLength | Should -Be $expected
        }
    }

    Context -Name 'Property ClassName' -Tag 'Property', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name ClassName -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should be a string' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.ClassName | Should -BeOfType 'string'
        }

        It -Name 'should equal CommandLineBuilder' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.ClassName | Should -Be 'CommandLineBuilder'
        }
    }

    Context -Name 'Property MaxCapacity' -Tag 'Property', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name MaxCapacity -MemberType Properties | Should -Not -BeNullOrEmpty
        }

        It -Name 'should be an int' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.MaxCapacity | Should -BeOfType 'int'
        }

        It -Name 'should equal 2147483647' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $CommandLineBuilder.MaxCapacity | Should -Be 2147483647
        }
    }

    Context -Name 'Method Append' -Tag 'Method', 'Under', 'Test' {
        AfterAll {
            $TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
            $Accelerators = $TypeAcceleratorsClass::Get
            $Accelerators | Where-Object -Property Name -EQ 'CommandLineBuilder' | ForEach-Object {
                $TypeAcceleratorsClass::Remove($_.FullName)
            }
        }

        It -Name 'should exist' -Tag 'Unit', 'Test' {
            # Arrange and Act
             $instance = [CommandLineBuilder]::new()

            # Assert
            $instance | Get-Member -Name Append  -MemberType Method | Should -Not -BeNullOrEmpty
        }
    }
}
