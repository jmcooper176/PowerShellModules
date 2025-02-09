<#
 =============================================================================
<copyright file="GitModule.tests.ps1" company="U.S. Office of Personnel
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
This file "GitModule.tests.ps1" is part of "GitModule".
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
#requires -Module PowerShellModule

BeforeAll {
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '.\GitModule.psd1'
    Import-Module -Name $ModulePath -Verbose
    Initialize-PSTest -Name 'GitModule' -Path $ModulePath
}

AfterAll {
    Get-Module -Name 'GitModule' | Remove-Module -Verbose -Force
}

Describe -Name 'GitModule' {
    BeforeEach {
        $RepositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve
        Push-Location -Path $RepositoryRoot
    }

    AfterEach {
        Pop-Location
    }

    Context -Name 'Module Manifest' {
        It 'should exist' {
            # Arrange and Act
            $ModuleManifest = Test-ModuleManifest -Path $ModulePath

            # Assert
            $ModuleManifest | Should -Not -BeNullOrEmpty
        }

        It 'should have a RootModule of GitModule.psm1' {
            # Arrange and Act
            $RootModule = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'RootModule'

            # Assert
            $RootModule | Should -Be 'GitModule.psm1'
        }

        It 'should have a ModuleVersion greater than  1.5.0' {
            # Arrange and Act
            $ModuleVersion = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Version'

            # Assert
            $ModuleVersion | Should -BeGreaterThan '1.5.0'
        }

        It 'should have a GUID of 55DE9FBD-3050-485E-9670-003CFA391BC3' {
            # Arrange and Act
            $Guid = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'GUID'

            # Assert
            $Guid | Should -Be '55DE9FBD-3050-485E-9670-003CFA391BC3'
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

        It 'should have a Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.' {
            # Arrange and Act
            $Copyright = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Copyright'

            # Assert
            $Copyright | Should -Be 'Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.'
        }

        It 'should have a Description length greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a Description of Collection of Cmdlets/Functions to scrape data from git.' {
            # Arrange and Act
            $Description = Test-ModuleManifest -Path $ModulePath | Select-Object -ExpandProperty 'Description'

            # Assert
            $Description | Should -Be 'Collection of Cmdlets/Functions to scrape data from git.'
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

    Context -Name 'Get-GitAuthorHead' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitAuthorHead'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitAuthorHead'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitAuthorHead' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitAuthorHead' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitAuthorHead' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitAuthorHead

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitAuthorDateHead' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitAuthorDateHead'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitAuthorDateHead'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitAuthorDateHead' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitAuthorDateHead' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitAuthorDateHead' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitAuthorDateHead
            Write-Information -MessageData $result -InformationAction Continue

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitBranch' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitBranch'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitBranch'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitBranch' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitBranch' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitBranch' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitBranch

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitCommitMetadata' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitMetadata'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitMetadata'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitCommitMetadata' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitCommitMetadata' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitCommitMetadata' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitCommitMetadata

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitCommitterHead' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitterHead'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitterHead'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitCommitterHead' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitCommitterHead' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitCommitterHead' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitCommitterHead

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitCommitterDateHead' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitterDateHead'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitCommitterDateHead'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitCommitterDateHead' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitCommitterDateHead' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitCommitterDateHead' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitCommitterDateHead

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitFormattedLog' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitFormattedLog'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitFormattedLog'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitFormattedLog' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitFormattedLog' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitFormattedLog' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitFormattedLog

            # Assert
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitLongId' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitLongId'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitLongId'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitLongId' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitLongId' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitLongId' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitLongId

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitLongRef' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitLongRef'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitLongRef'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitLongRef' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitLongRef' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitLongRef' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitLongRef

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitRef' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRef'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRef'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitRef' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitRef' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitRef' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitRef

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitRepositoryMetadata' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryMetadata'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryMetadata'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitRepositoryMetadata' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitRepositoryMetadata' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitRepositoryMetadata' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitRepositoryMetadata

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitRepositoryName' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryName'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryName'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitRepositoryName' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitRepositoryName' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitRepositoryName' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitRepositoryName

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitRepositoryPath' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryPath'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryPath'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitRepositoryPath' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitRepositoryPath' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitRepositoryPath' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitRepositoryPath

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitRepositoryUrl' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryUrl'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitRepositoryUrl'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitRepositoryUrl' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitRepositoryUrl' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitRepositoryUrl' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitRepositoryUrl

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitShortId' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitShortId'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitShortId'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitShortId' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitShortId' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitShortId' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitShortId

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitTag' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitTag'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitTag'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitTag' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitTag' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitTag' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitTag

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Get-GitVersion' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitVersion'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Get-GitVersion'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Get-GitVersion' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Get-GitVersion' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Get-GitVersion' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should not be null or empty' {
            # Arrange and Act
            $result = Get-GitVersion

            # Assert
            $Command | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Invoke-ToolCommandLine' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Invoke-ToolCommandLine'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Invoke-ToolCommandLine'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Invoke-ToolCommandLine' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Invoke-ToolCommandLine' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Invoke-ToolCommandLine' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }
    }

    Context -Name 'Test-GitRepository' {
        It 'should exist' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-GitRepository'

            # Assert
            $Command | Should -Not -BeNull
        }

        It 'should be a cmdlet or function' {
            # Arrange and Act
            $Command = Get-Command -Name 'Test-GitRepository'

            # Assert
            $Command.CommandType | Should -BeIn 'Cmdlet', 'Function'
        }

        It 'should have a synopsis greater than MINIMUM_SYNOPSIS_LENGTH' {
            # Arrange and Act
            $Synopsis = Get-Help -Name 'Test-GitRepository' -Full | Select-Object -ExpandProperty Synopsis

            # Assert
            $Synopsis.Length | Should -BeGreaterThan $MINIMUM_SYNOPSIS_LENGTH
        }

        It 'should have a description greater than MINIMUM_DESCRIPTION_LENGTH' {
            # Arrange and Act
            $Description = Get-Help -Name 'Test-GitRepository' -Full | Select-Object -ExpandProperty Description

            # Assert
            $Description | Out-String | Should -BeGreaterThan $MINIMUM_DESCRIPTION_LENGTH
        }

        It 'should have a module name of GitModule' {
            # Arrange and Act
            $ModuleName = Get-Command -Name 'Test-GitRepository' | Select-Object -ExpandProperty ModuleName

            # Assert
            $ModuleName | Should -Be 'GitModule'
        }

        It 'should be true for root of source control' {
            # Arrange and Act
            $result = Test-GitRepository

            # Assert
            $result | Should -Be $true
        }
    }
}