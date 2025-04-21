// ---------------------------------------------------------------------------
// <copyright file="Client.cs" company="John Merryweather Cooper">
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
// This file "Client.cs" is part of "Octopus.Client.Cmdlet".
// </summary>
// <remarks>
// description
// </remarks>
// ---------------------------------------------------------------------------

namespace Octopus.Client.Cmdlet.Common
{
    using System;
    using System.Management.Automation;

    [Cmdlet(VerbsCommon.Close, "Client")]
    [OutputType(typeof(void))]
    [CmdletBinding(SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.Low)]
    public class CloseClient : PSCmdlet, IDisposable
    {
        #region Public Properties

        [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        public OctopusClient? Client { get; set; }

        public SwitchParameter Force { get; set; }

        #endregion Public Properties

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
            if (Force.IsPresent)
            {
                this.SessionState.PSVariable.Set("ConfirmPreference", ConfirmImpact.None);
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    Client?.Dispose();
                }

                Client = null;
                disposedValue = true;
            }
        }

        protected override void ProcessRecord()
        {
            if (this.ShouldProcess(nameof(Client), nameof(CloseClient)))
            {
                Dispose();
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(CloseClient), 0);
        }

        #endregion Protected Methods

        #region Private Fields

        private bool disposedValue;

        #endregion Private Fields
    }

    [Cmdlet(VerbsCommon.New, "Client")]
    [OutputType(typeof(OctopusClient))]
    [CmdletBinding(SupportsShouldProcess = true, ConfirmImpact = ConfirmImpact.Low)]
    public class NewClient : PSCmdlet, IDisposable
    {
        #region Private Fields

        private OctopusClient? client;

        private bool disposedValue;

        #endregion Private Fields

        #region Public Properties

        public SwitchParameter Force { get; set; }

        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty()]
        public string OctopusApiKey { get; set; }

        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty()]
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
            if (Force.IsPresent)
            {
                this.SessionState.PSVariable.Set("ConfirmPreference", ConfirmImpact.None);
            }
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

        protected override void ProcessRecord()
        {
            // Create repository object
            if (this.ShouldProcess(OctopusUrl, nameof(NewClient)) {
                var endpoint = new OctopusServerEndpoint(OctopusUrl, OctopusApiKey);
                client = new OctopusClient(endpoint);
                this.WriteObject(client);
            }
        }

        protected override void StopProcessing()
        {
            Dispose();
            this.WriteFatal(new PipelineStoppedException(), ErrorCategory.OperationStopped, this, nameof(NewClient), 0);
        }

        #endregion Protected Methods
    }
}
