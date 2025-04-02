# Security Policy

## Supported Versions

PowerShell modules, scripts, and targets  status.

NOTE:  PowerShell modules ready for use have been uploaded to SkyOps-PowerShell.

| Supported Version | PowerShell Modules                       | Supported          |
|-------------------|------------------------------------------|--------------------|
|                   | AntModule                                | :x:                |
|                   | BuildScripts                             | :x:                |
|                   | ContainersModule                         | :x:                |
|                   | ConvertModule                            | :x:                |
|                   | COutModule                               | :x:                |
|                   | EnumModule                               | :x:                |
| 1.3.9168.58670    | EnvironmentModule                        | :white_check_mark: |
| 1.8.9169.53687    | ErrorRecordModule                        | :white_check_mark: |
| 1.6.9190.62881    | GitHubModule                             | :white_check_mark: |
| 1.8.9192.36765    | GitModule                                | :white_check_mark: |
|                   | HelperModule                             | :x:                |
|                   | LinqModule                               | :x:                |
|                   | LocalAccountModule                       | :x:                |
|                   | LogModule                                | :x:                |
| 1.3.9158.48011    | MessageModule                            | :white_check_mark: |
| 1.2.9127.52003    | MiscModule                               | :white_check_mark: |
|                   | ModulePublisher                          | :x:                |
|                   | NuGetModule                              | :x:                |
|                   | PathModule                               | :x:                |
| 1.4.9159.38683    | PowerShellModule                         | :white_check_mark: |
|                   | ProcessLauncherModule                    | :x:                |
|                   | ProcessModule                            | :x:                |
|                   | PublishModule                            | :x:                |
|                   | RandomModule                             | :x:                |
|                   | Repo-Tasks                               | :x:                |
|                   | ServiceAccountModule                     | :x:                |
| 1.5.9160.44796    | StringBuilderModule                      | :white_check_mark: |
| 1.0.9166.49496    | TypeAcceleratorModule                    | :white_check_mark: |
|                   | UpdateModule                             | :x:                |
| 1.2.9157.13441    | UriModule                                | :white_check_mark: |
| 1.4.9160.42789    | UtcModule                                | :white_check_mark: |
| 1.10.9190.63045   | VersionModule                            | :white_check_mark: |
|                   | ZipModule                                | :x:                |

| Supported Version | Scripts                                  | Supported          |
|-------------------|------------------------------------------|--------------------|
| 1.0.0.0           | ApplyVersiontoAssemblies.ps1             | :white_check_mark: |
|                   | ConvertTo-JWE.ps1                        | :x:                |
|                   | Generate-CmdletDesignMarkdown.ps1        | :x:                |
|                   | Generate-ExternalContributors.ps1        | :x:                |
|                   | Generate-Help.ps1                        | :x:                |
|                   | New-Mappings.ps1                         | :x:                |
| 1.0.0.0           | New-Package.ps1                          | :white_check_mark: |
| 1.0.0.0           | Push-Package.ps1                         | :white_check_mark: |
| 1.0.0.0           | Write-ChangeLog.ps1                      | :white_check_mark: |

| Supported Version | PowerShell Packing Scripts               | Supported          |
|-------------------|------------------------------------------|--------------------|
| 1.0.0.0           | Publish-LocalPSRepository.ps1            | :white_check_mark: |
| 1.0.0.0           | Register-LocalPSRepository.ps1           | :white_check_mark: |
| 1.0.0.0           | Save-PSToLocalRepository.ps1             | :white_check_mark: |
| 1.0.0.0           | Update-ModuleManifestVersion.ps1         | :white_check_mark: |

| Supported Version | Integration Scripts                      | Supported          |
|-------------------|------------------------------------------|--------------------|
|                   | Move-DevelopmentToFeature.ps1            | :x:                |
|                   | Move-DevelopmentToFeature-COM.ps1        | :x:                |
|                   | Move-DevelopmentToFeature-PowerShell.ps1 | :x:                |
|                   | Move-Feature-COMToDevelopment.ps1        | :x:                |
|                   | Move-MainToStaging.ps1                   | :x:                |
|                   | Move-StagingToDevelopment.ps1            | :x:                |
|                   | Move-StagingToMain.ps1                   | :x:                |

| Supported Version | MSBuild Targets                          | Supported          |
|-------------------|------------------------------------------|--------------------|
| N/A               | PowerShell.targets                       | :white_check_mark: |


## Reporting a Vulnerability

### Status

PowerShell scanning reveals none.  PowerShell scanning is performed every commit and at least daily.

### Reporting Policy

Should you discover a vulnerability, please contact me directly at <jmcooper8654@gmail.com> and report.

I will let you know I have received your report within 48 hours.

With a complete report as defined above, I will typically respond within
48 hours with whether I `accept` or `decline` the vulnerability.

If `accepted`, I will report back with my fix for your testing.

I will let you know if I `reject` a report (very unlikely).

I will then create a `work item`, which I will report back to you.

You can track the status from there.

### Reporting Information Required

#### Who

`Who` is reporting the vulnerability with a reachable OPM email address.

#### What

`What`, concisely stated, is the vulnerability.

#### When

`When` the vulnerability was first detected.

#### Where
`Where`, on what build, etc., with a link to the build or a full raw and
detailed log.

#### Why
`Why` this is a critical, high, moderate, low, or minor vulnerability.
If there is a CVE, please attach a link.

#### How
`How`, concisely state, the vulnerability was detected, including the
reproduce-able sequence of steps to demonstrate the vulnerability.

For sure, `please` include:

* the affected script or module;
* the expected behavior;
* the actual behavior;
* any stack trace, if present; AND
* any CVE, if it has been assigned
