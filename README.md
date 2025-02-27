# Open Integrity Project: Scripts - `README.md`
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/README.md`_
> - _github: `https://github.com/OpenIntegrityProject/scripts/blob/main/README.md`_
> - _updated: 2025-02-26 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

_**Cryptographic Roots of Trust for Open Source Development**_

## Overview

This repository contains the script implementations for the [Open Integrity Project](https://github.com/OpenIntegrityProject/docs), focusing on establishing cryptographic roots of trust in Git repositories. These scripts enable developers to create, verify, and maintain trust in their repositories through SSH-based signing and structured verification processes.

⚠️ **IMPORTANT**: All of these current implementations are **proof-of-concept** scripts designed to validate the Open Integrity approach and explore implementation challenges. These scripts are intended for proof-of-concept evaluation only and **should not** be used in production environments without further endorsement. While they demonstrate the viability of using Git repositories as cryptographic roots of trust, they currently have significant limitations: they largely work only against local repositories, have only basic Git platform integration (currently only GitHub), and only partial implementation of Progressive Trust capabilities. Their primary value is in proving core concepts and informing the development of future production-ready tools.

For the full project context, architecture details, and broader documentation, please visit the [Open Integrity Documentation Hub](https://github.com/OpenIntegrityProject/docs).

## Available Scripts

### Primary Scripts

None at this time. The development of primary Open Integrity scripts is currently in progress. These will include comprehensive audit tools for assessing, verifying, and affirming the cryptographic trust of inception commits and repository integrity.

### Utility Scripts (Snippets)

Snippet scripts providing focused utility functions for specific Open Integrity operations.

- `get_repo_did.sh` - Retrieves a repository's DID based on its inception commit
- `create_inception_commit.sh` - Creates a repository with a properly signed inception commit
- `snippet_template.sh` - Template for creating new snippet scripts

## Repository Organization and Structure

This repository is organized to separate different types of scripts and documentation:

### Main Directory Structure

- **Root directory**: Contains this `README.md` and will eventually house more complex scripts
  - Will contain larger scripts that don't fit the snippet classification

- **/requirements/**: Houses core requirements documents that apply across the project
  - `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` - Core Zsh scripting standards
  - `REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md` - Standards for snippet scripts

- **/issues/**: Tracks known issues and planned improvements
  - `ISSUES-Open_Integrity_Scripting_Infrastructure.md` - System-wide infrastructure issues
  - `ISSUES-Zsh_Core_Scripting_Best_Practices.md` - Issues related to core scripting standards

- **/snippets/**: Contains small utility scripts (< 200 lines of code) and their related files
  - `create_inception_commit.sh` - Creates repositories with signed inception commits
  - `get_repo_did.sh` - Retrieves a repository's DID based on inception commit
  - `snippet_template.sh` - Template for creating new snippet scripts
  - **/snippets/requirements/**: Contains requirements specific to individual snippet scripts
    - `REQUIREMENTS-check_git_config_for_oi_signing.md` - Requirements for Git config checking
    - `REQUIREMENTS-create_inception_commit.md` - Requirements for inception commit creation
    - `REQUIREMENTS-get_repo_did.md` - Requirements for repository DID retrieval
  - **/snippets/tests/**: Contains regression test scripts for validating snippet functionality
    - `TEST-create_inception_commit.sh` - Tests for the create_inception_commit.sh script

- **/tests/**: Reserved for regression test scripts that test complex scripts and broader project functionality

### Purpose of Each Directory

- **Root**: The main repository level will eventually contain larger, complex scripts and framework templates that provide the foundation for the project's functionality, including proof-of-concept implementations and reusable script templates.

- **/requirements/**: This directory holds the foundational documentation that establishes coding standards, best practices, and requirements that apply across the entire project, as well as requirement documentation for the more complex scripts.

- **/issues/**: Tracks known issues, planned improvements, and implementation challenges across the codebase, providing a centralized location for development planning.

- **/snippets/**: This directory is dedicated to small, focused utility scripts that perform specific tasks. Each snippet should be self-contained, under 200 lines of code (excluding comments and declarations), and follow the specific requirements for snippet scripts.
  - **/snippets/requirements/**: Contains detailed requirement specifications for each snippet script, defining their purpose, functionality, parameters, and expected behavior.
  - **/snippets/tests/**: Contains scripts that test snippet functionality against their requirements, ensuring they work as expected and maintain compliance with project standards.

- **/tests/**: Reserved for more comprehensive testing that may involve multiple scripts or broader project functionality, including regression test harnesses for framework scripts.

This structure maintains a clear separation between global requirements, larger project components, and small utility scripts, making it easier to navigate and maintain the Open Integrity codebase.

```console
.
├── .gitignore
├── README.md
├── issues
│   ├── ISSUES-Open_Integrity_Scripting_Infrastructure.md
│   └── ISSUES-Zsh_Core_Scripting_Best_Practices.md
├── requirements
│   ├── REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md
│   └── REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md
├── snippets
│   ├── create_inception_commit.sh
│   ├── get_repo_did.sh
│   ├── requirements
│   │   ├── REQUIREMENTS-check_git_config_for_oi_signing.md
│   │   ├── REQUIREMENTS-create_inception_commit.md
│   │   └── REQUIREMENTS-get_repo_did.md
│   ├── snippet_template.sh
│   └── tests
│       └── TEST-create_inception_commit.sh
└── tests
```

## Getting Started

To use these scripts, clone this repository and make sure you have the necessary dependencies:

```bash
# Clone the repository
git clone https://github.com/OpenIntegrityProject/scripts.git
cd scripts

# Make scripts executable if needed
chmod +x *.sh
chmod +x snippets/*.sh

# Example: Create a new repository with a signed inception commit
./snippets/create_inception_commit.sh -r my_new_repo

# Example: Get the DID for a repository
./snippets/get_repo_did.sh -C /path/to/repo
```

For detailed instructions on each script, refer to their individual requirements documents in the `snippets/requirements/` directory.

## Development

All script development follows strict guidelines defined in our requirements documents:

- [Zsh Core Scripting Best Practices](requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
- [Zsh Snippet Script Best Practices](requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)

### Testing

Each script includes regression tests that can be run to verify functionality. For example:

```bash
# Run tests for create_inception_commit.sh
./snippets/tests/TEST-create_inception_commit.sh
```

## Contributing

Contributions are welcome! Please read the [Contributing Guidelines](https://github.com/OpenIntegrityProject/scripts/blob/main/CONTRIBUTING.md) before submitting changes.

## License

This project is licensed under the BSD 2-Clause Plus Patent License - see the [LICENSE](https://github.com/OpenIntegrityProject/scripts/blob/main/LICENSE) for details.

## More Information

For more information about the Open Integrity Project, including architecture details, problem statements, and broader documentation, please visit the [Open Integrity Documentation Hub](https://github.com/OpenIntegrityProject/docs).
