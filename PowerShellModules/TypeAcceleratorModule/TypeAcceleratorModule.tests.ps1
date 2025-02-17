<#
 =============================================================================
<copyright file="TypeAcceleratoModuler.tests.ps1" company="U.S. Office of Personnel
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
This file "TypeAcceleratoModuler.tests.ps1" is part of "TypeAcceleratorModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module Pester
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'TypeAcceleratorModule.psd1'
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'TypeAcceleratorModule' -Path $ModulePath

    $TestData = @(
        @{Accelerator = [Alias];                          FullName = 'System.Management.Automation.AliasAttribute';},
        @{Accelerator = [AllowEmptyCollection];           FullName = 'System.Management.Automation.AllowEmptyCollectionAttribute';},
        @{Accelerator = [AllowEmptyString];               FullName = 'System.Management.Automation.AllowEmptyStringAttribute';},
        @{Accelerator = [AllowNull];                      FullName = 'System.Management.Automation.AllowNullAttribute';},
        @{Accelerator = [ArgumentCompleter];              FullName = 'System.Management.Automation.ArgumentCompleterAttribute';},
    #   @{Accelerator = [ArgumentCompletions];            FullName = 'System.Management.Automation.ArgumentCompletionsAttribute';},
        @{Accelerator = [array];                          FullName = 'System.Array';},
        @{Accelerator = [bool];                           FullName = 'System.Boolean';},
        @{Accelerator = [byte];                           FullName = 'System.Byte';},
        @{Accelerator = [char];                           FullName = 'System.Char';},
        @{Accelerator = [CmdletBinding];                  FullName = 'System.Management.Automation.CmdletBindingAttribute';},
        @{Accelerator = [datetime];                       FullName = 'System.DateTime';},
        @{Accelerator = [decimal];                        FullName = 'System.Decimal';},
        @{Accelerator = [double];                         FullName = 'System.Double';},
        @{Accelerator = [DscResource];                    FullName = 'System.Management.Automation.DscResourceAttribute';},
    #   @{Accelerator = [ExperimentAction];               FullName = 'System.Management.Automation.ExperimentAction';},
    #   @{Accelerator = [Experimental];                   FullName = 'System.Management.Automation.ExperimentalAttribute';},
    #   @{Accelerator = [ExperimentalFeature];            FullName = 'System.Management.Automation.ExperimentalFeature';},
        @{Accelerator = [float];                          FullName = 'System.Single';},
        @{Accelerator = [single];                         FullName = 'System.Single';},
        @{Accelerator = [guid];                           FullName = 'System.Guid';},
        @{Accelerator = [hashtable];                      FullName = 'System.Collections.Hashtable';},
        @{Accelerator = [int];                            FullName = 'System.Int32';},
        @{Accelerator = [int32];                          FullName = 'System.Int32';},
    #   @{Accelerator = [short];                          FullName = 'System.Int16';},
        @{Accelerator = [int16];                          FullName = 'System.Int16';},
        @{Accelerator = [long];                           FullName = 'System.Int64';},
        @{Accelerator = [int64];                          FullName = 'System.Int64';},
        @{Accelerator = [ciminstance];                    FullName = 'Microsoft.Management.Infrastructure.CimInstance';},
        @{Accelerator = [cimclass];                       FullName = 'Microsoft.Management.Infrastructure.CimClass';},
        @{Accelerator = [cimtype];                        FullName = 'Microsoft.Management.Infrastructure.CimType';},
        @{Accelerator = [cimconverter];                   FullName = 'Microsoft.Management.Infrastructure.CimConverter';},
        @{Accelerator = [IPEndpoint];                     FullName = 'System.Net.IPEndPoint';},
    #   @{Accelerator = [NoRunspaceAffinity];             FullName = 'System.Management.Automation.Language.NoRunspaceAffinityAttribute';},
        @{Accelerator = [NullString];                     FullName = 'System.Management.Automation.Language.NullString';},
        @{Accelerator = [OutputType];                     FullName = 'System.Management.Automation.OutputTypeAttribute';},
        @{Accelerator = [ObjectSecurity];                 FullName = 'System.Security.AccessControl.ObjectSecurity';},
    #   @{Accelerator = [ordered];                        FullName = 'System.Collections.Specialized.OrderedDictionary';},
        @{Accelerator = [Parameter];                      FullName = 'System.Management.Automation.ParameterAttribute';},
        @{Accelerator = [PhysicalAddress];                FullName = 'System.Net.NetworkInformation.PhysicalAddress';},
        @{Accelerator = [pscredential];                   FullName = 'System.Management.Automation.PSCredential';},
        @{Accelerator = [PSDefaultValue];                 FullName = 'System.Management.Automation.PSDefaultValueAttribute';},
        @{Accelerator = [pslistmodifier];                 FullName = 'System.Management.Automation.PSListModifier';},
        @{Accelerator = [psobject];                       FullName = 'System.Management.Automation.PSObject';},
        @{Accelerator = [pscustomobject];                 FullName = 'System.Management.Automation.PSObject';},
        @{Accelerator = [psprimitivedictionary];          FullName = 'System.Management.Automation.PSPrimitiveDictionary';},
        @{Accelerator = [ref];                            FullName = 'System.Management.Automation.PSReference';},
        @{Accelerator = [PSTypeNameAttribute];            FullName = 'System.Management.Automation.PSTypeNameAttribute';},
        @{Accelerator = [regex];                          FullName = 'System.Text.RegularExpressions.Regex';},
        @{Accelerator = [DscProperty];                    FullName = 'System.Management.Automation.DscPropertyAttribute';},
        @{Accelerator = [sbyte];                          FullName = 'System.SByte';},
        @{Accelerator = [string];                         FullName = 'System.String';},
        @{Accelerator = [SupportsWildcards];              FullName = 'System.Management.Automation.SupportsWildcardsAttribute';},
        @{Accelerator = [switch];                         FullName = 'System.Management.Automation.SwitchParameter';},
        @{Accelerator = [cultureinfo];                    FullName = 'System.Globalization.CultureInfo';},
        @{Accelerator = [bigint];                         FullName = 'System.Numerics.BigInteger';},
        @{Accelerator = [securestring];                   FullName = 'System.Security.SecureString';},
        @{Accelerator = [timespan];                       FullName = 'System.TimeSpan';},
    #   @{Accelerator = [ushort];                         FullName = 'System.UInt16';},
        @{Accelerator = [uint16];                         FullName = 'System.UInt16';},
    #   @{Accelerator = [uint];                           FullName = 'System.UInt32';},
        @{Accelerator = [uint32];                         FullName = 'System.UInt32';},
    #   @{Accelerator = [ulong];                          FullName = 'System.UInt64';},
        @{Accelerator = [uint64];                         FullName = 'System.UInt64';},
        @{Accelerator = [uri];                            FullName = 'System.Uri';},
        @{Accelerator = [ValidateCount];                  FullName = 'System.Management.Automation.ValidateCountAttribute';},
        @{Accelerator = [ValidateDrive];                  FullName = 'System.Management.Automation.ValidateDriveAttribute';},
        @{Accelerator = [ValidateLength];                 FullName = 'System.Management.Automation.ValidateLengthAttribute';},
        @{Accelerator = [ValidateNotNull];                FullName = 'System.Management.Automation.ValidateNotNullAttribute';},
        @{Accelerator = [ValidateNotNullOrEmpty];         FullName = 'System.Management.Automation.ValidateNotNullOrEmptyAttribute';},
    #   @{Accelerator = [ValidateNotNullOrWhiteSpace];    FullName = 'System.Management.Automation.ValidateNotNullOrWhiteSpaceAttribute';},
        @{Accelerator = [ValidatePattern];                FullName = 'System.Management.Automation.ValidatePatternAttribute';},
        @{Accelerator = [ValidateRange];                  FullName = 'System.Management.Automation.ValidateRangeAttribute';},
        @{Accelerator = [ValidateScript];                 FullName = 'System.Management.Automation.ValidateScriptAttribute';},
        @{Accelerator = [ValidateSet];                    FullName = 'System.Management.Automation.ValidateSetAttribute';},
        @{Accelerator = [ValidateTrustedData];            FullName = 'System.Management.Automation.ValidateTrustedDataAttribute';},
        @{Accelerator = [ValidateUserDrive];              FullName = 'System.Management.Automation.ValidateUserDriveAttribute';},
        @{Accelerator = [version];                        FullName = 'System.Version';},
        @{Accelerator = [void];                           FullName = 'System.Void';},
        @{Accelerator = [ipaddress];                      FullName = 'System.Net.IPAddress';},
        @{Accelerator = [DscLocalConfigurationManager];   FullName = 'System.Management.Automation.DscLocalConfigurationManagerAttribute';},
        @{Accelerator = [WildcardPattern];                FullName = 'System.Management.Automation.WildcardPattern';},
        @{Accelerator = [X509Certificate];                FullName = 'System.Security.Cryptography.X509Certificates.X509Certificate';},
        @{Accelerator = [X500DistinguishedName];          FullName = 'System.Security.Cryptography.X509Certificates.X500DistinguishedName';},
        @{Accelerator = [xml];                            FullName = 'System.Xml.XmlDocument';},
        @{Accelerator = [CimSession];                     FullName = 'Microsoft.Management.Infrastructure.CimSession';},
        @{Accelerator = [mailaddress];                    FullName = 'System.Net.Mail.MailAddress';},
    #   @{Accelerator = [semver];                         FullName = 'System.Management.Automation.SemanticVersion';},
        @{Accelerator = [adsi];                           FullName = 'System.DirectoryServices.DirectoryEntry';},
        @{Accelerator = [adsisearcher];                   FullName = 'System.DirectoryServices.DirectorySearcher';},
        @{Accelerator = [wmiclass];                       FullName = 'System.Management.ManagementClass';},
        @{Accelerator = [wmi];                            FullName = 'System.Management.ManagementObject';},
        @{Accelerator = [wmisearcher];                    FullName = 'System.Management.ManagementObjectSearcher';},
        @{Accelerator = [scriptblock];                    FullName = 'System.Management.Automation.ScriptBlock';},
    #   @{Accelerator = [pspropertyexpression];           FullName = 'Microsoft.PowerShell.Commands.PSPropertyExpression';},
        @{Accelerator = [psvariable];                     FullName = 'System.Management.Automation.PSVariable';},
        @{Accelerator = [type];                           FullName = 'System.Type';},
        @{Accelerator = [psmoduleinfo];                   FullName = 'System.Management.Automation.PSModuleInfo';},
        @{Accelerator = [powershell];                     FullName = 'System.Management.Automation.PowerShell';},
        @{Accelerator = [runspacefactory];                FullName = 'System.Management.Automation.Runspaces.RunspaceFactory';},
        @{Accelerator = [runspace];                       FullName = 'System.Management.Automation.Runspaces.Runspace';},
        @{Accelerator = [initialsessionstate];            FullName = 'System.Management.Automation.Runspaces.InitialSessionState';},
        @{Accelerator = [psscriptmethod];                 FullName = 'System.Management.Automation.PSScriptMethod';},
        @{Accelerator = [psscriptproperty];               FullName = 'System.Management.Automation.PSScriptProperty';},
        @{Accelerator = [psnoteproperty];                 FullName = 'System.Management.Automation.PSNoteProperty';},
        @{Accelerator = [psaliasproperty];                FullName = 'System.Management.Automation.PSAliasProperty';},
        @{Accelerator = [psvariableproperty];             FullName = 'System.Management.Automation.PSVariableProperty';}
    )

    <#
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $TestData.Add(@{Accelerator = [ArgumentCompletions]; FullName = 'System.Management.Automation.ArgumentCompletionsAttribute'})
        $TestData.Add(@{Accelerator = [ExperimentalAction]; FullName = 'System.Management.Automation.ExperimentalAction'})
        $TestData.Add(@{Accelerator = [Experimental]; FullName = 'System.Management.Automation.ExperimentalAttribute'})
        $TestData.Add(@{Accelerator = [ExperimentalFeature]; FullName = 'System.Management.Automation.ExperimentalFeature'})
        $TestData.Add(@{Accelerator = [short]; FullName = 'System.Int16'})
        $TestData.Add(@{Accelerator = [NoRunspaceAffinity]; FullName = 'System.Management.Automation.Language.NoRunspaceAffinityAttribute'})
        $TestData.Add(@{Accelerator = [ordered]; FullName = 'System.Collections.Specialized.OrderedDictionary'})
        $TestData.Add(@{Accelerator = [ushort]; FullName = 'System.UInt16'})
        $TestData.Add(@{Accelerator = [uint]; FullName = 'System.UInt32'})
        $TestData.Add(@{Accelerator = [ulong]; FullName = 'System.UInt64'})
        $TestData.Add(@{Accelerator = [ValidateNotNullOrWhiteSpace]; FullName = 'System.Management.Automation.ValidateNotNullOrWhiteSpaceAttribute'})
        $TestData.Add(@{Accelerator = [semver]; FullName = 'System.Management.Automation.SemanticVersion'})
        $TestData.Add(@{Accelerator = [pspropertyexpression]; FullName = 'Microsoft.PowerShell.Commands.PSPropertyExpression'})
    }
    #>
}

AfterAll {
    Get-Module -Name 'TypeAcceleratorModule' | Remove-Module -Verbose -Force
}

Describe -Name 'TypeAcceleratorModule' {
    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It 'should have a RootModule of TypeAcceleratorModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'TypeAcceleratorModule.psm1'
        }

        It 'should have a ModuleVersion greater than  1.0.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.0.0'
        }

        It 'should have a GUID of DE36732E-2C9C-4832-8FDD-779EBBAAE157' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be 'DE36732E-2C9C-4832-8FDD-779EBBAAE157'
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

        It 'should have a Description of Library of cmdlets/functions to register/un-register type accelerators.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Library of cmdlets/functions to register/un-register type accelerators.'
        }

        It 'should have a PowerShellVersion of 5.1' {
            # Arrange and Act
            $PowerShellVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'PowerShellVersion'

            # Assert
            $PowerShellVersion | Should -Be '5.1'
        }
    }

    Context -Name 'Add-TypeAccelerator' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-TypeAccelerator'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Add-TypeAccelerator'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Add-TypeAccelerator' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Add-TypeAccelerator' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Add-TypeAccelerator' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Mock Add-TypeAccelerator and prove invoked' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            Mock -CommandName 'Add-TypeAccelerator' -ModuleName 'TypeAccelerator' -MockWith {
                Write-Information -MessageData "Mocked Add-TypeAccelerator -ExportableType '[$($FullName)]' -InvocationInfo <MyInvocationInfo>" -InformationAction Continue
                $ExportableTypeState['ExportableType'] = $FullName
                $ExportableTypeState['InvocationInfo'] = $MyInvocation
            }

            # Act
            Add-TypeAccelerator -ExportableType $Accelerator -InvocationInfo $MyInvocation

            # Assert
            Should -Invoke 'Add-TypeAccelerator' -Exactly 1
        }

        It -Name 'Mock Add-TypeAccelerato and global state should match' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            Mock -CommandName 'Add-TypeAccelerator' -ModuleName 'TypeAccelerator' -MockWith {
                Write-Information -MessageData "Mocked Add-TypeAccelerator -ExportableType '[$($FullName)]' -InvocationInfo <MyInvocationInfo>" -InformationAction Continue
                $ExportableTypeState['ExportableTypeName'] = $FullName
                $ExportableTypeState['InvocationInfo'] = $MyInvocation
            }

            # Act
            Add-TypeAccelerator -ExportableType $Accelerator -InvocationInfo $MyInvocation

            # Assert
            $ExportableTypeState['ExportableTypeName'] | Should -Be $FullName
        }
    }

    Context -Name 'Get-TypeAccelerator' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-TypeAccelerator'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-TypeAccelerator'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-TypeAccelerator' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-TypeAccelerator' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-TypeAccelerator' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Get-TypeAccelerator -ListAvailable gets count TypeAccelerators' -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = 107

            # Act
            $Actual = Get-TypeAccelerator -ListAvailable | Select-Object -ExpandProperty Count

            # Assert
            $Actual | Should -Be $Expected
        }

        It -Name 'Get-TypeAccelerator -ListAvailable gets all TypeAccelerators Accelerators' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = ($Accelerator -as [type])

            # Act
            $Actual = Get-TypeAccelerator -ListAvailable | Where-Object -Property Key -EQ $Accelerator

            # Assert
            $Actual | Should -Be $Expected
        }

        It -Name 'Get-TypeAccelerator -ListAvailable gets all TypeAccelerators FullNames' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = $FullName

            $Actual = Get-TypeAccelerator -ListAvailable | Where-Object -Property Value -EQ $FullName

            # Assert
            $Actual | Should -Be $Expected
        }
    }

    Context -Name 'Get-TypeAcceleratorClass' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-TypeAcceleratorClass'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-TypeAcceleratorClass'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-TypeAcceleratorClass' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-TypeAcceleratorClass' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-TypeAcceleratorClass' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Get-TypeAcceleratorClass should not be null' -Tag @('Unit', 'Test') {
            # Arrange and Act
            $result = Get-TypeAcceleratorClass

            # Assert
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Register-TypeAccelerator' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Register-TypeAccelerator'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Register-TypeAccelerator'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Register-TypeAccelerator' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Register-TypeAccelerator' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Register-TypeAccelerator' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Mock Register-TypeAccelerator' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            Mock -CommandName 'Register-TypeAccelerator' -ModuleName 'TypeAccelerator' -MockWith {
                Write-Information -MessageData "Mocked Register-TypeAccelerator -ExportableType '[$($_.Name)]'" -InformationAction Continue
            }

            # Act
            Register-TypeAccelerator -ExportableType $Accelerator

            # Assert
            Should -Invoke 'Register-TypeAccelerator' -Exactly 1
        }
    }

    Context -Name 'Remove-TypeAccelerator' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-TypeAccelerator'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Remove-TypeAccelerator'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Remove-TypeAccelerator' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Remove-TypeAccelerator' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Remove-TypeAccelerator' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Mock Remove-TypeAccelerator' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            Mock -CommandName 'Remove-TypeAccelerator' -ModuleName 'TypeAccelerator' -MockWith {
                Write-Information -MessageData "Mocked Remove-TypeAccelerator -ExportableType '[$($_.Name)]'" -InformationAction Continue
            }

            # Act
            Remove-TypeAccelerator -ExportableType $Accelerator

            # Assert
            Should -Invoke 'Remove-TypeAccelerator' -Exactly 1
        }
    }

    Context -Name 'Test-TypeAcceleratorRegistered' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-TypeAcceleratorRegistered'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-TypeAcceleratorRegistered'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-TypeAcceleratorRegistered' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-TypeAcceleratorRegistered' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of TypeAcceleratorModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-TypeAcceleratorRegistered' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'TypeAcceleratorModule'
        }

        It -Name 'Test-TypeAcceleratorRegistered against TestData' -ForEach $TestData -Tag @('Unit', 'Test') {
            # Arrange
            $Expected = $TestData.Length

            # Act
            $Actual = Get-TypeAccelerator -ListAvailable | Select-Object -ExpandProperty Count

            # Assert
            Test-TypeAcceleratorRegistered -ExportableType $Accelerator | Should -BeTrue
        }
    }
}
