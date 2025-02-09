# Contributing to PSInstallCom

This repository contains PowerShell cmdlets for developers and administrators to develop, deploy,
administer, and manage U.S. Office of Personnel Management Azure resources.

## Basics

If you would like to become a contributor to this project (or any other open source U.S. Office of Personnel Management
project), see how to [Get Involved](https://opensource.microsoft.com/collaborate/).

## Before Starting

### Onboarding

All users must sign the
[U.S. Office of Personnel Management Contributor License Agreement (CLA)](https://cla.opensource.microsoft.com/) before making any code contributions.

### Code of Conduct

This project has adopted the
[Microsoft Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more
information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or
comments.

### GitHub Basics

#### GitHub Workflow

The following guides provide basic knowledge for understanding Git command usage and the workflow of
GitHub.

- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

#### Forking the Azure/azure-powershell repository

Unless you are working with multiple contributors on the same file, we ask that you fork the
repository and submit your pull request from there. The following guide explains how to fork a
GitHub repo.

- [Contributing to GitHub projects](https://guides.github.com/activities/forking/).

## Filing Issues

## Submitting Changes

### Pull Requests

When creating a pull request, keep the following in mind:

- Verify you are pointing to the fork and branch that your changes were made in.
- Choose the correct branch you want your pull request to be merged into.
  - The **main** branch is for active development; changes in this branch will be in the next Azure
    PowerShell release.  However, it is not a proper target for pull requests.
  - The **Development** branch is for active development during a release and is an appropriate target for pull requests.
- The pull request template that is provided **must be filled out**. Do not delete or ignore it when
  the pull request is created.
  - **_IMPORTANT:_** Deleting or ignoring the pull request template will delay the PR review process.
- The SLA for reviewing pull requests is **two business days**.

### Pull Request Guidelines

A pull request template will automatically be included as a part of your PR. Please fill out the
checklist as specified. Pull requests **will not be reviewed** unless they include a properly
completed checklist.

The following set of guidelines must be adhered to when opening pull requests in the Azure
PowerShell repository.

#### Target Release Types

#### General guidelines

The following guidelines must be followed for **every** pull request that is opened.

- Title of the pull request is clear and informative.
- The appropriate `ChangeLog.md` file(s) has been updated:
  - For any service, the `ChangeLog.md` file can be found at
    `src/{{SERVICE}}/{{SERVICE}}/ChangeLog.md`.
  - A snippet outlining the change(s) made in the PR should be written under the
    `## Upcoming Release` header -- no new version header should be added.
- There are a small number of commits in your PR and each commit has an informative commit message.
- All files shipped with a module should contain a proper John Merryweather Cooper license header.

#### Testing guidelines

The following guidelines must be followed in **every** pull request that is opened.

- Changes made have corresponding test coverage.
- Tests should not include any hardcoded values, such as location, resource id, etc.
- Tests should have proper setup of resources to ensure any user can re-record the test if necessary.
- No existing tests should be skipped.

#### Cmdlet guidelines

#### Parameter guidelines

#### Piping guidelines

#### Module guidelines
