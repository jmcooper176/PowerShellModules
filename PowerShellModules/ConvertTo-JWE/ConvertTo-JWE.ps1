<#
 =============================================================================
<copyright file="ConvertTo-JWE.ps1" company="John Merryweather Cooper">
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
This file "ConvertTo-JWE.ps1" is part of "ConvertTo-JWE".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID FCC89B76-BE32-48E3-A393-0ABD5781C0A6

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/ConvertTo-JWE

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module PowerShellModule

<#
    .DESCRIPTION
    Convert a ClaimsIdentity to a JSON Web Encryption (JWE) token.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [Alias('Type')]
    [string]
    $ClaimType,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [Alias('Value')]
    [string]
    $ClaimValue,

    [Parameter(Mandatory)]
    [ValidateNotNullOrWhiteSpace()]
    [Alias('OctopusUrl')]
    [string]
    $Server
)

<#
    Functions
#>

<#
    New-CLaimIdentity
#>
function New-ClaimIdentity {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Security.Claims.ClaimsIdentity])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Type')]
        [string]
        $ClaimType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Value')]
        [string]
        $ClaimValue
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $claims = New-Object -TypeName System.Security.Claims.ClaimsIdentity
    $claims.AddClaim([System.Security.Claims.Claim]::new($ClaimType, $ClaimValue)) | Out-Null
    $claims | Write-Output
}

<#
    New-JwtSecurityToken
#>
function New-JwtSecurityToken {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IdentityModel.Tokens.JwtSecurityToken])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Descriptor')]
        [hashtable]
        $Descriptor,

        [Parameter(Mandatory)]
        [System.IdentityModel.Tokens.JwtSecurityTokenHandler]
        $JwtHandler
    )
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $jwt = $jwtHandler.CreateToken($Descriptor) | Write-Output
}

<#
    New-SecurityTokenDescriptor
#>
function New-SecurityTokenDescriptor {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Type')]
        [string]
        $ClaimType,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Value')]
        [string]
        $ClaimValue,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('AppliesToAddress')]
        [string]
        $AppliesToAddress,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('TokenIssuerName')]
        [string]
        $TokenIssuerName
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $descriptor = @{
        Subject            = New-ClaimIdentity -ClaimType $ClaimType -ClaimValue $ClaimValue
        AppliesToAddress   = $AppliesToAddress
        SigningCredentials = New-Object -TypeName System.IdentityModel.Tokens.X509SigningCredentials
        TokenIssuerName    = $TokenIssuerName
        Lifetime           = [System.IdentityModel.Protocols.WSTrust.Lifetime]::new([DateTime]::UtcNow, [DateTime]::UtcNow.AddMinutes(360))  # default max build timeout
    } | Write-Output
}

<#
    Write-JsonToken
#>
function Write-JsonToken {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [System.IdentityModel.Tokens.JwtSecurityTokenHandler]
        $JwtHandler,

        [Parameter(Mandatory)]
        [System.IdentityModel.Tokens.JwtSecurityToken]
        $Jwt
    )

    $CmletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $JwtHandler.WriteToken($Jwt) | Write-Output
}

<#
    Script
#>

$ScriptName = Initialize-PSScript -MyInvocation $MyInvocation

if ($MyInvocation.InvocationName -ne '.') {
    $descriptor = New-SecurityTokenDescriptor -ClaimType $ClaimType -ClaimValue $ClaimValue -AppliesToAddress $Server -TokenIssuerName $Sever
    $jwtHandler = New-Object -TypeName System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler
    $jwt = New-SecurityTokenDescriptor -Descriptor $descriptor -JwtHandler $jwtHandler
    Write-JsonToken -JwtHandler $jwtHandler -Jwt $jwt | Write-Output
}
else {
    Write-Warning -Message "$($criptName) : This script has been dot-sourced, and should only be under test."
}
