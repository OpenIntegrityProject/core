# **Enforcing Signed Commits and Pull Request Requirements in GitHub**
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Enforcing_Signed_Commits_And_PRs_GitHub.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Enforcing_Signed_Commits_And_PRs_GitHub.md`_
> - _updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

## **Goal & Rationale**

### **Goal**

The objective of this guide is to ensure all commits to a protected branch (e.g., `main`) are verified and signed, while enforcing structured pull request workflows to maintain security, accountability, and commit integrity.

### **Rationale for GitHub Options**

Each GitHub option helps support this goal by:

- **Requiring Pull Requests Before Merging**: Ensures that all changes undergo a review process before merging, preventing unauthorized modifications.
- **Requiring Signed Commits**: Guarantees that commit authorship is verified and prevents bad actors from injecting unverified commits.
- **Enforcing Merge Strategies**: Restricts the use of rebase and squash merges to maintain signed commit integrity and traceable history.
- **Preventing Direct Pushes**: Blocks unauthorized changes directly into protected branches, reinforcing the need for PR reviews.
- **Enforcing Required Status Checks**: Ensures workflows such as signed commit verification pass before a PR is merged.
- **Preventing Force Pushes & Branch Deletions**: Protects repository integrity by preserving commit history and preventing accidental deletions.

## **Configuring Repository Settings via GitHub CLI**

GitHub CLI (`gh`) allows you to configure repository settings without using API calls.

### **Enforce Pull Requests Before Merging**

```sh
gh repo edit <OWNER>/<REPO> --enable-pull-requests
```

Ensures that all changes go through a pull request before merging.

### **Set Merge Strategy (Only Allow Merge Commits, No Squash or Rebase)**

```sh
gh repo edit <OWNER>/<REPO> --allow-merge-commit --disable-rebase-merge --disable-squash-merge
```

Prevents squash merges (which strip commit signatures) and rebase merges (which rewrite history).

### **Prevent Direct Pushes to Main**

```sh
gh repo edit <OWNER>/<REPO> --enable-pull-requests
```

Blocks direct pushes to `main`, requiring pull requests.

### **List Current Branch Protection Rules**

```sh
gh repo view <OWNER>/<REPO> --json defaultBranchRef
```

Shows the current default branch and basic protection settings.

### **Enforce Required GitHub Actions (e.g., Signed Commits Check)**

```sh
gh workflow list --repo <OWNER>/<REPO>
gh workflow enable "Enforce Signed Commits" --repo <OWNER>/<REPO>
```

Ensures that the "Enforce Signed Commits" workflow runs before merging.

### **Use Git Native Plugins for Commit Signing Enforcement**

Git provides built-in support for GPG commit signing. To ensure all local commits are signed before pushing, configure Git globally:

```sh
git config --global commit.gpgsign true
git config --global user.signingkey <YOUR_GPG_KEY>
```

Ensures all commits are signed before being pushed.

To verify that a commit is signed:

```sh
git log --show-signature
```

Displays commit signatures, ensuring authorship verification.

## **Enforcing Advanced Protection Using GitHub API**

For stricter enforcement (e.g., signed commits, force push prevention, required status checks), use the GitHub API via `gh api`.

### **Require Signed Commits**

```sh
gh api --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/<OWNER>/<REPO>/branches/main/protection \
  -f required_signatures='{"enabled": true}'
```

Blocks unsigned commits from being merged.

### **Prevent Force Pushes & Branch Deletion**

```sh
gh api --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/<OWNER>/<REPO>/branches/main/protection \
  -f enforce_admins='true' \
  -f allow_force_pushes='false' \
  -f allow_deletions='false'
```

Ensures commit history integrity by blocking force pushes and deletion of protected branches.

## **Using GitHub Actions for Automated Enforcement**

### **Enforce Signed Commits in Pull Requests**

Create a workflow file `.github/workflows/enforce-signed-commits.yml`:

```yaml
name: Enforce Signed Commits

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  verify-signed-commits:
    name: Verify Signed Commits
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Verify Commit Signatures
        run: |
          for commit in $(git rev-list --format=%H ${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }} | grep -v '^commit'); do
            echo "Checking commit: $commit"
            if ! git verify-commit $commit; then
              echo "❌ Commit $commit is NOT signed!"
              exit 1
            fi
          done
```

This workflow blocks unsigned commits before merging a pull request.

## **Next Steps & Automation**

### **Automating with Scripts**

For multiple repositories, create a Bash script to apply protection rules automatically:

```sh
#!/bin/bash
OWNER="<OWNER>"
REPO="<REPO>"

echo "Enforcing GitHub Branch Protections..."

gh repo edit $OWNER/$REPO --enable-pull-requests
gh repo edit $OWNER/$REPO --allow-merge-commit --disable-rebase-merge --disable-squash-merge
gh api --method PUT -H "Accept: application/vnd.github+json" \
  /repos/$OWNER/$REPO/branches/main/protection \
  -f required_signatures='{"enabled": true}'

echo "Protection Rules Applied!"
```

Run this script to enforce protection policies across repositories.

### **Troubleshooting GitHub CLI Commands**

If `gh` commands fail due to permissions, ensure that you:

- Have the necessary repository admin or write access.
- Are authenticated with `gh auth login`.
- Check if branch protection rules conflict with the applied settings.

## **Using GitHub Actions for Automated Enforcement**

### **Handling Exceptions in Enforcement**

Some organizations may need to allow exceptions for trusted users or specific repositories. This can be done by implementing rules in GitHub Actions to exclude designated maintainers from enforcement.

Example exclusion:

```yaml
if: github.actor != 'trusted-user'
```

This ensures that trusted users can bypass enforcement where necessary.

## **Auditing Repository Settings Over Time**

To maintain long-term compliance, organizations should periodically audit repository settings to ensure they adhere to policies.

A GitHub Action can be set up to run daily or weekly and check repository protections:

```yaml
name: Audit Branch Protections

on:
  schedule:
    - cron: "0 0 * * *" # Runs daily

jobs:
  audit-protections:
    runs-on: ubuntu-latest
    steps:
      - name: Check Protection Settings
        run: |
          gh api /repos/${{ github.repository }}/branches/main/protection || exit 1
```

This ensures that protection rules remain enforced over time and alerts administrators if configurations drift.

## **Conclusion**

This document provides a step-by-step guide to enforcing signed commits and PR-based merges using:

- GitHub CLI (`gh`) for basic protection.
- GitHub API (`gh api`) for advanced enforcement.
- GitHub Actions for automation.
- Git native signing for local commit verification.

By following these steps, organizations can maintain a secure and traceable commit history while preventing unauthorized changes.
