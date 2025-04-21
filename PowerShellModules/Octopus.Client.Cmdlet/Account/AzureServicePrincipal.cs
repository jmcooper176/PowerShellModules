// ---------------------------------------------------------------------------
// <copyright file="AzureServicePrincipal.cs" company="John Merryweather Cooper">
//     Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper. All Rights Reserved.
//
//     Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following
//     conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials provided with the distribution.
//
//     3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
//     BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
//     EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//     PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
//     TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//     POSSIBILITY OF SUCH DAMAGE.
// </copyright>
// <author>
// John Merryweather Cooper
// </author>
// <date>
// Created:  2025-4-7
// </date>
// <summary>
// This file "AzureServicePrincipal.cs" is part of "Octopus.Client.Cmdlet".
// </summary>
// <remarks>
// description
// </remarks>
// ---------------------------------------------------------------------------

namespace Octopus.Client.Cmdlet.Account
{
    using System.Management.Automation;
    using System.Security;
    using System.Xml.Linq;

    using Octopus.Client;
    using Octopus.Client.Cmdlet.Common;
    using Octopus.Client.Editors;
    using Octopus.Client.Model;

    [Cmdlet(VerbsCommon.New, "AzureServicePrincipal")]
    public class NewAzureServicePrincipal : PSCmdlet, IDisposable
    {
        #region Public Properties

        /// <summary>
        /// Gets or sets a value indicating the Azure Client Id.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string AzureClientId { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Azure secret.
        /// </summary>
        [Parameter(Mandatory = true)]
        public SensitiveValue AzureSecret { get; set; }

        // Azure specific details
        /// <summary>
        /// Gets or sets a value indicating the Azure Subscription Number.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string AzureSubscriptionNumber { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Azure Tenant Id.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string AzureTenantId { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Octopus Account Description.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string OctopusAccountDescription { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Octopus Account Environment Ids.
        /// </summary>
        public ReferenceCollection OctopusAccountEnvironmentIds { get; set; } = null;

        // Octopus Account details
        /// <summary>
        /// Gets or sets a value indicating the Octopus Deploy Account Name.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string OctopusAccountName { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Octopus Account Tenant Ids.
        /// </summary>
        public ReferenceCollection OctopusAccountTenantIds { get; set; } = null;

        /// <summary>
        /// Gets or sets a value indicating the Octopus Account Tenant Participation.
        /// </summary>
        public TenantedDeploymentMode OctopusAccountTenantParticipation { get; set; } = TenantedDeploymentMode.Untenanted;

        /// <summary>
        /// Gets or sets a value indicating the Octopus Account Tenant Tags.
        /// </summary>
        public ReferenceCollection OctopusAccountTenantTags { get; set; } = null;

        /// <summary>
        /// Gets or sets a value indicating the Octopus Deploy Server API Key.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string OctopusApiKey { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Octopus Deploy Server URL.
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string OctopusUrl { get; set; }

        /// <summary>
        /// Gets or sets a value indicating the Octopus Deploy space.
        /// </summary>
        public string SpaceName { get; set; } = "default";

        #endregion Public Properties

        #region Protected Methods

        protected override void BeginProcessing()
        {
            endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
            repository = new OctopusRepository(endpoint);
            client = new OctopusClient(endpoint);
            space = repository.Spaces.FindByName(SpaceName);
        }

        protected override void ProcessRecord()
        {
            try
            {
                // Get a repository for a given space resource
                var repositoryForSpace = client.ForSpace(space);

                // Fill in account details
                azureAccount = new Model.Accounts.AzureServicePrincipalAccountResource
                {
                    ClientId = AzureClientId,
                    TenantId = AzureTenantId,
                    SubscriptionNumber = AzureSubscriptionNumber,
                    Password = AzureSecret,
                    Name = OctopusAccountName,
                    Description = OctopusAccountDescription,
                    TenantedDeploymentParticipation = OctopusAccountTenantParticipation,
                    TenantTags = OctopusAccountTenantTags,
                    TenantIds = OctopusAccountTenantIds,
                    EnvironmentIds = OctopusAccountEnvironmentIds
                };

                // Create account
                WriteObject(repositoryForSpace.Accounts.Create(azureAccount));
            }
            catch (Exception ex)
            {
                var er = new ErrorRecord(ex, Common.FormatErrorId(nameof(NewAzureServicePrincipal), ex, 0), ErrorCategory.InvalidOperation, azureAccount);
                WriteError(er);
            }
        }

        #endregion Protected Methods

        #region Private Fields

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    client?.Dispose();
                }

                client = null;
                disposedValue = true;
            }
        }

        private Model.Accounts.AzureServicePrincipalAccountResource azureAccount;

        private OctopusClient? client;

        private bool disposedValue;

        private OctopusServerEndpoint? endpoint;

        private OctopusRepository? repository;

        private SpaceResource? space;

        #endregion Private Fields
    }
}
