<#
 =============================================================================
<copyright file="ServiceAccountModule.psm1" company="U.S. Office of Personnel
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
This file "ServiceAccountModule.psm1" is part of "ServiceAccountModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

function Format-MessageFromModule {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [uint32[]]
        $LastError,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ModuleName)

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        foreach ($err in $LastError) {
            $result = $null

            if (! ($ret = [LogonCli.ServiceAccount]::FormatMessageFromModule($err, $ModuleName, [ref]$result))) {
                $result
            } else {
                Write-Error -Message "Cannot get message ID: $err. Error code: $ret" -Category 'InvalidResult'
            }
        }
    }

    <#
    #>
}

function Use-ServiceAccount {
    [CmdletBinding()]
    [OutputType([IntPtr])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Account,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateLength(8, 104)]
        [securestring]
        $Password,

        [Parameter(Mandatory)]
        [ValidateSet('Add', 'Query', 'Remove', 'Test')]
        [string]
        $Action,

        [switch]
        $Detailed,

        [switch]
        $ForceRemoveLocal,

        [switch]
        $PromptForPassword
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $DllImport =
@'

            // Service accounts

            [DllImport("logoncli.dll", CharSet = CharSet.Auto)]
            public static extern uint NetQueryServiceAccount(
                [In] string ServerName,
                [In] string AccountName,
                [In] uint InfoLevel,
                out IntPtr Buffer
            );

            [DllImport("logoncli.dll", CharSet = CharSet.Auto)]
            public static extern uint NetIsServiceAccount(
                string ServerName,
                string AccountName,
                ref bool IsService
            );

            [DllImport("logoncli.dll", CharSet = CharSet.Auto)]
            public static extern uint NetAddServiceAccount(
                string ServerName,
                string AccountName,
                string Reserved,
                int Flags
            );

            [DllImport("logoncli.dll", CharSet = CharSet.Auto)]
            public static extern uint NetRemoveServiceAccount(
                string ServerName,
                string AccountName,
                int Flags
            );

            [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
            public struct MSA_INFO
            {
                public MSA_INFO_STATE State;
            }

            [Flags]
            public enum MSA_INFO_STATE : uint
            {
                MsaInfoNotExist = 1u,
                MsaInfoNotService = 2u,
                MsaInfoCannotInstall = 3u,
                MsaInfoCanInstall = 4u,
                MsaInfoInstalled = 5u
            }

            // FormatMessage
            // https://github.com/PowerShell/PowerShell/blob/master/src/Microsoft.PowerShell.Commands.Diagnostics/CommonUtils.cs

            private const uint FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
            private const uint FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
            private const uint FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
            private const uint LOAD_LIBRARY_AS_DATAFILE = 0x00000002;
            private const uint FORMAT_MESSAGE_FROM_HMODULE = 0x00000800;

            [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
            private static extern uint FormatMessage(uint dwFlags, IntPtr lpSource,
                uint dwMessageId, uint dwLanguageId,
                [MarshalAs(UnmanagedType.LPWStr)]
                StringBuilder lpBuffer,
                uint nSize, IntPtr Arguments);

            [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
            private static extern IntPtr LoadLibraryEx(
                [MarshalAs(UnmanagedType.LPWStr)] string lpFileName,
                IntPtr hFile,
                uint dwFlags
                );

            [DllImport("kernel32.dll")]
            private static extern bool FreeLibrary(IntPtr hModule);

            public static uint FormatMessageFromModule(uint lastError, string moduleName, out String msg)
            {
                uint formatError = 0;
                msg = String.Empty;
                IntPtr moduleHandle = IntPtr.Zero;

                moduleHandle = LoadLibraryEx(moduleName, IntPtr.Zero, LOAD_LIBRARY_AS_DATAFILE);

                if (moduleHandle == IntPtr.Zero)
                {
                    return (uint)Marshal.GetLastWin32Error();
                }

                uint dwFormatFlags = FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_FROM_HMODULE;
                uint LANGID = (uint)System.Globalization.CultureInfo.CurrentUICulture.LCID;
                StringBuilder outStringBuilder = new StringBuilder(1024);

                try
                {
                    uint nChars = FormatMessage(dwFormatFlags,
                        moduleHandle,
                        lastError,
                        LANGID,
                        outStringBuilder,
                        (uint)outStringBuilder.Capacity,
                        IntPtr.Zero);

                    if (nChars == 0)
                    {
                        formatError = (uint)Marshal.GetLastWin32Error();
                    }
                    else
                    {
                        msg = outStringBuilder.ToString();

                        if (msg.EndsWith(Environment.NewLine, StringComparison.Ordinal))
                        {
                            msg = msg.Substring(0, msg.Length - 2);
                        }
                    }
                }
                finally
                {
                    FreeLibrary(moduleHandle);
                }

                return formatError;
            }
'@
        Add-Type -MemberDefinition $DllImport -Name ServiceAccount -Namespace LogonCli -ErrorAction Stop -UsingNamespace 'System.Text'
    }

    PROCESS {
        foreach ($userName in $Account) {
            Write-Verbose -Message "Using account: '$($userName)'"

            $result = [IntPtr]::Zero

            switch($Action) {
                'Add' {
                    Write-Verbose 'Installing account using NetAddServiceAccount'

                    if ($PromptForPassword.IsPresent) {
                        $Credential = Get-Credential -Message "Enter the password for the account '$($Account)'"
                        $Password = $Credential.Password
                    }

                    if (Test-PSParameter -Name 'Password' -Parameters $PSBoundParameters) {
                        $ret = [LogonCli.ServiceAccount]::NetAddServiceAccount( $null, $userName, (ConvertFrom-Encrypted -Password $Password), 2)
                    }
                    else {
                        # Use default credentials
                        $ret = [LogonCli.ServiceAccount]::NetAddServiceAccount($null, $userName, $null, 1)
                    }

                    break
                }

                'Query' {
                    Write-Verbose -Message 'Querying account detail using NetQueryServiceAccount'

                    if (!($ret = [LogonCli.ServiceAccount]::NetQueryServiceAccount($null, $userName, 0, [ref]$result))) {
                        $result = [System.Runtime.InteropServices.Marshal]::PtrToStructure($result, [System.Type][LogonCli.ServiceAccount+MSA_INFO])

                        if ($Detailed.IsPresent) {
                            Write-Verbose -Message 'Returning detailed result'
                            $result.State | Write-Output
                        }
                        else {
                            if ($result.State -eq [LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoInstalled) {
                                $result.State = [LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoInstalled
                            }
                            else {
                                switch ($result.State) {
                                    ([LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoNotExist) {
                                        Write-Warning -Message "Cannot find Managed Service Account '$($userName)' in the directory. Verify the Managed Service Account identity and call the cmdlet again."

                                        break
                                    }

                                    ([LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoNotService) {
                                        Write-Warning -Message "The '$($userName)' is not a Managed Service Account. Verify the identity and call the cmdlet again."

                                        break
                                    }

                                    ([LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoCannotInstall) {
                                        Write-Warning -Message "Test failed for Managed Service Account '$($userName)'. If standalone Managed Service Account, the account is linked to another computer object in the Active Directory. If group Managed Service Account, either this computer does not have permission to use the group MSA or this computer does not support all the Kerberos encryption types required for the gMSA. See the MSA operational log for more information."

                                        break
                                    }

                                    ([LogonCli.ServiceAccount+MSA_INFO_STATE]::MsaInfoCanInstall) {
                                        Write-Warning -Message "The Managed Service Account '$($userName)' is not linked with any computer object in the directory."

                                        break
                                    }
                                }

                                $result.State | Write-Output
                            }
                        }
                    }

                    break
                }

                'Remove' {
                    Write-Verbose -Message 'Uninstalling account using NetRemoveServiceAccount'

                    $ret = [LogonCli.ServiceAccount]::NetRemoveServiceAccount($null, $Account, 1)

                    # fom winnt.h
                    # define STATUS_NO_SUCH_DOMAIN 0xC00000DF
                    if ((0xC00000DF -eq $ret) -and ($ForceRemoveLocal.IsPresent)) {
                        Write-Verbose -Message 'Cannot contact domain, removing local account data'
                        $ret = [LogonCli.ServiceAccount]::NetRemoveServiceAccount($null, $Account, 2)
                    }

                    break
                }

                'Test' {
                    Write-Verbose -Message 'Testing account using NetIsServiceAccount'

                    if (!($ret = [LogonCli.ServiceAccount]::NetIsServiceAccount($null, $userName, [ref]$result))) {
                        $result
                    }

                    break
                }
            }

            if ($ret) {
                Write-Verbose "Returning user-friendly error message for status code: $ret"

                $ret | Format-MessageFromModule -ModuleName 'Ntdll.dll' | Write-Error
            }
        }
    }

    <#
        .SYNOPSIS
        Wrapper around Win32 API functions for managing (Group) Managed Service Accounts
        https://raw.githubusercontent.com/beatcracker/Powershell-Misc/master/Use-ServiceAccount.ps1

        .DESCRIPTION
        Wrapper around Win32 API functions for managing (Group) Managed Service Accounts.
        Allows to test/add/remove (G)MSAs without 'Active Directory' module.

        .PARAMETER Add
        Installs an existing Active Directory managed service account on the computer on which the cmdlet is run.

        .PARAMETER AccountPassword
        Specifies the account password as a secure string.
        This parameter enables you to specify the password of a standalone managed service account that you have provisioned and is ignored for group managed service accounts.
        This is required when you are installing a standalone managed service account on a server located on a segmented network (site) with read-only domain controllers (for example, a perimeter network or DMZ).
        In this case you should create the standalone managed service account, link it with the appropriate computer account, and assign a well-known password that must be passed when installing the standalone managed service account on the server on the read-only domain controller site with no access to writable domain controllers.

        .PARAMETER PromptForPassword
        Indicates that you can enter the password of a standalone managed
        service account that you have pre-provisioned and ignored for group
        managed service accounts.

        This is required when you are installing a standalone managed
        service account on a server located on a segmented network (site)
        with no access to writable domain controllers, but only read-only
        domain controllers (RODCs) (e.g. perimeter network or DMZ).

        In this case you should create the standalone managed service
        account, link it with the appropriate computer account, and assign
        a well-known password that must be passed when installing the
        standalone managed service account on the server on the RODC-only
        site.

        .PARAMETER Test
        Tests whether the specified standalone managed service account (sMSA)
        or group managed service account (gMSA) exists in the Netlogon
        store on the specified server.

        .PARAMETER Query
        Queries the specified service account from the local computer.

        The result indicates whether the account is ready for use, which means
        it can be authenticated and that it can access the domain using its
        current credentials.

        .PARAMETER Detailed
        Return MSA_INFO_STATE enumeration containing detailed information on
        (G)MSA state.

        See: https://msdn.microsoft.com/en-us/library/windows/desktop/dd894396.aspx

        .PARAMETER Remove
        Removes an Active Directory standalone managed service account (MSA)
        on the computer on which the cmdlet is run.

        For group MSAs, the cmdlet removes the group MSA from the cache.
        However, if a service is still using the group MSA and the host has
        permission to retrieve the password, then a new cache entry is
        created.

        The specified MSA must be installed on the computer.

        .PARAMETER ForceRemoveLocal
        Indicates that you can remove the account from the local security
        authority (LSA) if there is no access to a writable domain
        controller.

        This is required if you are uninstalling the MSA from a server that is
        placed in a segmented network such as a perimeter network with
        access only to a read-only domain controller.

        If you specify this parameter and the server has access to a writable
        domain controller, the account is also un-linked from the computer
        account in the directory.

        .PARAMETER AccountName
        Specifies the Active Directory MSA to uninstall.

        You can identify an MSA by its Security Account Manager (SAM) account
        name.

        .EXAMPLE
        PS>'GMSA_Acount' | Use-ServiceAccount -Add

        Install Group Managed Service Account with SAM account name
        'GMSA_Account' on the computer on which the cmdlet is run.

        .EXAMPLE
        PS> Use-ServiceAccount -AccountName 'GMSA_Acount' -Add

        Install Group Managed Service Account with SAM account name
        'GMSA_Account' on the computer on which the cmdlet is run.

        .EXAMPLE
        PS> 'GMSA_Acount' | Use-ServiceAccount -Test

        Test whether the specified standalone managed service account (sMSA)
        or group managed service account (gMSA) exists in the Netlogon
        store on the this server.

        .EXAMPLE
        PS> 'GMSA_Acount' | Use-ServiceAccount -Query

        Queries the specified service account from the local computer.

        .INPUTS
    #>
}

<#
    ConvertFrom-Encrypted
#>
function ConvertFrom-Encrypted {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [securestring]
        $Password
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $pointer = [IntPtr]::Zero
    }

    PROCESS {
        $pointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($pointer) | Write-Output
    }

    END {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }

    <#
        .SYNOPSIS
        Converts the input object to a string.

        .DESCRIPTION
        Converts the input object to a string.

        .PARAMETER Password
        Specifies the object to convert to a string.

        .INPUTS
        [System.Security.SecureString].  `ConvertFrom-Encrypted` accepts secure strings taken from the pipeline.

        .OUTPUTS
        [System.String].  `ConvertFrom-Encrypted` outputs clear text strings to the pipeline.
    #>
}

<#
    ConvertTo-Encrypted
#>
function ConvertTo-Encrypted {
    [CmdletBinding()]
    [OutputType([securestring])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $secureStringValue = [Sysetm.Security.SecureString]::new()

        $Value.ToCharArray() | ForEach-Object -Process {
            $secureStringValue.AppendChar($_)
        }

        $secureStringValue.MakeReadOnly() | Write-Output
    }

    <#
        .SYNOPSIS
        Converts the string value to a secure string.

        .DESCRIPTION
        Converts the string value to a secure string.

        .PARAMETER Value
        Specifies the object to convert to a secure string.

        .INPUTS
        [System.String].  `ConvertTo-Encrypted` accepts strings taken from the pipeline.

        .OUTPUTS
        [System.Security.SecureString].  `ConvertTo-Encrypted` outputs encrypted, read-only secure strings to the pipeline.
    #>
}
