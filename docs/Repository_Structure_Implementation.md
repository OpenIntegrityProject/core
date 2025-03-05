# Open Integrity Project: Repository Structure Implementation
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Repository_Structure_Implementation.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Repository_Structure_Implementation.md`_
> - _updated: 2025-03-05 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

## Introduction

This document explains how to implement the Open Integrity Repository Structure in your project. The repository structure provides the foundation for cryptographic trust mechanisms in Git repositories, ensuring transparency, provenance, and immutability for software projects.

## Repository Structure

The Open Integrity Repository Structure implements a standardized directory layout within the `.repo` directory that contains configuration, scripts, and hooks for maintaining cryptographic integrity:

```
.repo/
│
├── hooks/               # Git hooks for enforcing signing policies
│   ├── pre-commit       # Enforces signing requirements
│   └── ...              # Other hooks
│
├── scripts/             # Utility scripts for repository management
│   ├── verify_signatures.sh  # Verifies signatures on all commits
│   └── ...              # Other utility scripts
│
├── config/              # Configuration files
│   ├── pipeline/        # CI/CD configuration templates
│   ├── environment/     # Environment-specific settings
│   └── verification/    # Verification-related files
│       └── allowed_commit_signers  # Authorized SSH keys
│
├── docs/                # Documentation specific to repository integrity
│   └── README.md        # Documentation index
│
└── monitoring/          # Scripts for monitoring repository integrity
```

## Implementation Steps

### 1. Create Repository Structure

Use the `create_repo_structure.sh` script to set up the standard directory structure in your repository:

```bash
# From the repository root directory
./path/to/open-integrity/src/create_repo_structure.sh

# Or specifying a repository path
./path/to/open-integrity/src/create_repo_structure.sh --repo /path/to/your/repo
```

This script will:
- Create the `.repo` directory structure
- Initialize configuration files
- Set up Git configuration for using the custom hooks directory
- Configure the allowed signers file path

### 2. Configure Signing Keys

To use Open Integrity, you need to configure Git to use SSH keys for signing:

```bash
# Set Git to use SSH for signatures
git config --local gpg.format ssh

# Set your SSH key for signing
git config --local user.signingkey ~/.ssh/your_key_file

# Enable commit signing
git config --local commit.gpgsign true
```

### 3. Manage Allowed Signers

Use the `manage_allowed_signers.sh` script to manage the list of SSH keys that are authorized to make signed commits:

```bash
# Add a signer
./path/to/open-integrity/src/manage_allowed_signers.sh add \
  --key ~/.ssh/id_ed25519.pub \
  --name "Alice"

# List all signers
./path/to/open-integrity/src/manage_allowed_signers.sh list

# Show details for a specific signer
./path/to/open-integrity/src/manage_allowed_signers.sh show --name "Alice"

# Remove a signer
./path/to/open-integrity/src/manage_allowed_signers.sh remove --name "Alice"
```

The allowed signers file will be automatically updated and committed with a signed commit to maintain the cryptographic chain of trust.

### 4. Create an Inception Commit

If you're starting a new repository, use the `create_inception_commit.sh` script to establish a cryptographic root of trust:

```bash
./path/to/open-integrity/src/create_inception_commit.sh --repo /path/to/new/repo
```

This creates an empty signed commit that serves as the immutable starting point for your repository's cryptographic trust chain.

### 5. Verify Repository Integrity

To verify the integrity of a repository:

```bash
# Audit the repository's inception commit
./path/to/open-integrity/src/audit_inception_commit-POC.sh -C /path/to/repo

# Get the repository's DID
./path/to/open-integrity/src/get_repo_did.sh -C /path/to/repo
```

## Git Hooks

The Open Integrity Repository Structure includes several Git hooks to enforce signing policies and maintain the cryptographic chain of trust:

### Pre-Commit Hook

The pre-commit hook (`src/hooks/pre-commit`) enforces:

1. SSH signing is properly configured
2. Commits are properly signed with a valid key
3. The signing key is in the allowed signers list
4. Commit messages meet basic requirements

To temporarily bypass the hooks (for debugging or special cases):

```bash
SKIP_OPEN_INTEGRITY_HOOKS=1 git commit -m "Commit message"
```

## Working with CI/CD Systems

For GitHub Actions, you can add the following workflow to verify signatures:

```yaml
name: Verify Signatures

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Install Open Integrity tools
        run: |
          git clone https://github.com/OpenIntegrityProject/core.git open-integrity
          
      - name: Verify repository integrity
        run: |
          ./open-integrity/src/audit_inception_commit-POC.sh -C .
```

## Additional Scripts and Tools

The Open Integrity implementation includes additional scripts for various tasks:

- `verify_signatures.sh`: Verifies signatures on all commits in a branch
- `audit_inception_commit-POC.sh`: Comprehensive audit of repository integrity
- `get_repo_did.sh`: Retrieves the repository's Decentralized Identifier (DID)

## Troubleshooting

If you encounter issues:

1. **SSH Key Issues**: Ensure your SSH key has appropriate permissions (typically 600)
2. **Signature Verification Failures**: Verify that your key is in the allowed signers file
3. **Configuration Issues**: Check Git configuration with `git config --list`
4. **Hook Bypass**: Use `SKIP_OPEN_INTEGRITY_HOOKS=1` for troubleshooting

## Security Considerations

- **SSH Key Security**: Always protect your SSH private keys with appropriate permissions and passphrases
- **Inception Commit**: The inception commit establishes the root of trust; verify its integrity before trusting a repository
- **Allowed Signers**: Only authorized keys should be added to the allowed signers file
- **Commit Verification**: Always verify commit signatures when auditing a repository

## Further Reading

- [Open Integrity Problem Statement](Open_Integrity_Problem_Statement.md)
- [Implementation Strategy](Implementation_Strategy.md)
- [Repository Directory Structure](Open_Integrity_Repo_Directory_Structure.md)
