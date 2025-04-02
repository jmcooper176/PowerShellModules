namespace Octopus.Client.Cmdlet
{
    using System.Management.Automation;
    using System.Security;
    using System.Xml.Linq;

    using Octopus.Client;
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
                WriteWarning(ex.Message);
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
