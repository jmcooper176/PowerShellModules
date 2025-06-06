-- ---------------------------------------------------------------------------
-- <copyright file="Octopus.InvokeOctopusRunbook_Powershell.sql" company="U.S. Office of Personnel
-- Management">
--     Copyright © 2025, U.S. Office of Personnel Management.
--     All Rights Reserved.
--
--     Redistribution and use in source and binary forms, with or without
--     modification, are permitted provided that the following conditions
--     are met:
--
--        1. Redistributions of source code must retain the above
--           copyright notice, this list of conditions and the following
--           disclaimer.
--
--        2. Redistributions in binary form must reproduce the above
--           copyright notice, this list of conditions and the following
--           disclaimer in the documentation and/or other materials
--           provided with the distribution.
--
--        3. Neither the name of the copyright holder nor the names of
--           its contributors may be used to endorse or promote products
--           derived from this software without specific prior written
--           permission.
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
-- </copyright>
-- <author>John Merryweather Cooper</author>
-- <date>Created:  2025-2-19</date>
-- <summary>
-- This file "Octopus.InvokeOctopusRunbook_Powershell.sql" is part of "InvokeOctopusRunbook".
-- </summary>
-- <remarks>description</remarks>
-- ---------------------------------------------------------------------------

USE PDS_LIVE
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'[Octopus].[InvokeOctopusRunbook_Powershell]') AND type in (N'U'))
	BEGIN
	CREATE TABLE Octopus.InvokeOctopusRunbook_Powershell
	(
		ScriptFileContent nvarchar(MAX) NOT NULL,
		LastUpdated datetimeoffset(7) NOT NULL
	)
	INSERT INTO Octopus.InvokeOctopusRunbook_Powershell
		(ScriptFileContent, LastUpdated)
	VALUES
		(@ScriptFileContent, SYSDATETIMEOFFSET())
END
ELSE
	UPDATE Octopus.InvokeOctopusRunbook_Powershell
	SET ScriptFileContent = @ScriptFileContent, LastUpdated = SYSDATETIMEOFFSET()

GO
