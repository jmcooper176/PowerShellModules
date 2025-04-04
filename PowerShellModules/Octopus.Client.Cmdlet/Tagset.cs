using System;

// ---------------------------------------------------------------------------
// <copyright file="Tagset.cs" company="John Merryweather Cooper">
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
// Created:  2025-4-2
// </date>
// <summary>
// This file "Tagset.cs" is part of "Octopus.Client.Cmdlet".
// </summary>
// <remarks>
// description
// </remarks>
// ---------------------------------------------------------------------------

namespace Octopus.Client.Cmdlet
{
    using Octopus.Client;
    using Octopus.Client.Model;

    using System;
    using System.Collections.Generic;
    using System.Management.Automation;

    [Cmdlet(VerbsCommon.Get, "Tagset")]
    [OutputType(typeof(List<TagsetResource>), ParameterSetName = ["UsingFindAll", "UsingFindMany"])]
    [OutputType(typeof(TagsetResource), ParameterSetName = ["UsingFindOne"])]
    public class GetTagset : PSCmdlet, IDisposable
    {
        #region Public Properties

        [Parameter(Mandatory = true, ParameterSetName = "UsingFindAll")]
        public SwitchParameter All { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = "UsingFindOne")]
        public SwitchParameter First { get; set; }

        [Parameter(Mandatory = true, ParameterSetName = "UsingFindMany")]
        public SwitchParameter Many { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusApiKey { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusUrl { get; set; }

        public Predicate<TagsetResource> Selector { get; set; } = (a => a != null);

        [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public string SpaceName { get; set; }

        #endregion Public Properties

        #region Private Fields

        private OctopusClient? client;

        private bool disposedValue;

        private IOctopusRepository? repository;

        #endregion Private Fields

        #region Public Methods

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        #endregion Public Methods

        #region Protected Methods

        protected override void BeginProcessing()
        {
            // Create repository object
            var endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
            repository = new OctopusRepository(endpoint);
            client = new OctopusClient(endpoint);
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
                repository = null;
                disposedValue = true;
            }
        }

        protected override void EndProcessing()
        {
            Dispose();
        }

        protected override void ProcessRecord()
        {
            try
            {
                // Get space
                var space = repository.Spaces.FindByName(SpaceName);
                var repositoryForSpace = client.ForSpace(space);

                if (this.ParameterSetName == "UsingFindAll")
                {
                    WriteObject(repository.Tagsets.FindAll());
                }
                else if (this.ParameterSetName == "UsingFindOne")
                {
                    WriteObject(repository.Tagsets.FindOne(a => Selector.Invoke(a)));
                }
                else
                {
                    WriteObject(repository.Tagsets.FindMany(a => Selector.Invoke(a)));
                }
            }
            catch (Exception ex)
            {
                this.WriteError(ex, ErrorCategory.InvalidResult, repository?.Tagsets, nameof(GetTagset), 0);
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(GetTagset), 0);
        }

        #endregion Protected Methods
    }

    [Cmdlet(VerbsCommon.New, "Tagset")]
    [CmdletBinding(SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.Low)]
    [OutputType(typeof(TagsetResource))]
    public class NewTagset : PSCmdlet, IDisposable
    {
        #region Private Fields

        private OctopusClient? client;

        private bool disposedValue;

        private IOctopusRepository? repository;

        #endregion Private Fields

        #region Public Properties

        public SwitchParameter Force { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusApiKey { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusUrl { get; set; }

        #endregion Public Properties

        #region Protected Methods

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        protected override void BeginProcessing()
        {
            if (Force.IsPresent && !this.MyInvocation.BoundParameters.ContainsKey("Confirm"))
            {
                this.SessionState.PSVariable.Set("ConfirmPreference", ConfirmImpact.None);
            }

            // Create repository object
            var endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
            repository = new OctopusRepository(endpoint);
            client = new OctopusClient(endpoint);
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
                repository = null;
                disposedValue = true;
            }
        }

        protected override void EndProcessing()
        {
            Dispose();
        }

        protected override void ProcessRecord()
        {
            if (this.ShouldProcess("Tagset", "UpdateTagset"))
            {
                base.ProcessRecord();
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(NewTagset), 0);
        }

        #endregion Protected Methods
    }

    [Cmdlet(VerbsCommon.Remove, "Tagset")]
    [CmdletBinding(SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.Low)]
    [OutputType(typeof(void))]
    public class RemoveTagset : PSCmdlet, IDisposable
    {
        #region Public Properties\

        public SwitchParameter Force { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusApiKey { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusUrl { get; set; }

        #endregion Public Properties\

        #region Public Methods

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        #endregion Public Methods

        #region Protected Methods

        protected override void BeginProcessing()
        {
            if (Force.IsPresent && !this.MyInvocation.BoundParameters.ContainsKey("Confirm"))
            {
                this.SessionState.PSVariable.Set("ConfirmPreference", ConfirmImpact.None);
            }

            // Create repository object
            var endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
            repository = new OctopusRepository(endpoint);
            client = new OctopusClient(endpoint);
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
                repository = null;
                disposedValue = true;
            }
        }

        protected override void EndProcessing()
        {
            Dispose();
        }

        protected override void ProcessRecord()
        {
            if (this.ShouldProcess("Tagset", "RemoveTagset"))
            {
                base.ProcessRecord();
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(RemoveTagset), 0);
        }

        #endregion Protected Methods

        #region Private Fields

        private OctopusClient? client;

        private bool disposedValue;

        private IOctopusRepository? repository;

        #endregion Private Fields
    }

    [Cmdlet(VerbsData.Update, "Tagset")]
    [CmdletBinding(SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.Low)]
    [OutputType(typeof(TagsetResource))]
    public class UpdateTagset : PSCmdlet, IDisposable
    {
        #region Private Fields

        private OctopusClient? client;

        private bool disposedValue;

        private IOctopusRepository? repository;

        #endregion Private Fields

        #region Public Properties

        public SwitchParameter Force { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusApiKey { get; set; }

        [Parameter(Mandatory = true)]
        public string OctopusUrl { get; set; }

        #endregion Public Properties

        #region Protected Methods

        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        protected override void BeginProcessing()
        {
            if (Force.IsPresent && !this.MyInvocation.BoundParameters.ContainsKey("Confirm"))
            {
                this.SessionState.PSVariable.Set("ConfirmPreference", ConfirmImpact.None);
            }

            // Create repository object
            var endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
            repository = new OctopusRepository(endpoint);
            client = new OctopusClient(endpoint);
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
                repository = null;
                disposedValue = true;
            }
        }

        protected override void EndProcessing()
        {
            Dispose();
        }

        protected override void ProcessRecord()
        {
            if (this.ShouldProcess("Tagset", "UpdateTagset"))
            {
                base.ProcessRecord();
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(UpdateTagset), 0);
        }

        #endregion Protected Methods
    }
}
