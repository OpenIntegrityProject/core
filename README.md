- _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/README.md`_
- _github: `https://github.com/OpenIntegrityProject/scripts/blob/main/README.md`_

# Open Integrity Scripts
_(Last updated: 2025-02-25, Christopher Allen <ChristopherA@LifeWithAlacrity.com>)_

## Script Repository Organization and Purpose

### Main Directory Structure

This repository is organized to separate different types of scripts and documentation:

- **Root directory**: Will contain more complex scripts (none yet implemented) and this `README.md`
- **/requirements/**: Houses core requirements documents that apply across the project
- **/snippets/**: Contains small utility scripts (< 200 lines of code) and their related files
  - **/snippets/requirements/**: Contains requirements specific to individual snippet scripts
  - **/snippets/tests/**: Contains regression test scripts for validating snippet functionality
- **/tests/**: Reserved for regression test scripts that test the complex scripts, as well as any broader project-level tests beyond individual tests.

### Purpose of Each Directory

- **Root**: The main repository level will eventually contain larger, more complex scripts and documentation that don't fit the "snippet" classification. These may also include framework template starte scripts.

- **/requirements/**: This directory holds the foundational documentation that establishes coding standards, best practices, and requirements that apply across the entire project, as well as requirement documentation for the more complex scripts.

- **/snippets/**: This directory is dedicated to small, focused utility scripts that perform specific tasks. Each snippet should be self-contained, under 200 lines of code (excluding comments and declarations), and follow the specific requirements for snippet scripts.
  - **/snippets/requirements/**: Contains detailed requirement specifications for each snippet script, defining their purpose, functionality, parameters, and expected behavior.
  - **/snippets/tests/**: Contains scripts that test snippet functionality against their requirements, ensuring they work as expected and maintain compliance with project standards.

- **/tests/**: Reserved for more comprehensive testing that may involve multiple scripts or broader project functionality.

This structure maintains a clear separation between global requirements, larger project components, and small utility scripts, making it easier to navigate and maintain the Open Integrity codebase.

```console
% tree -a -I ".git|.DS_Store"
.
├── .gitignore
├── requirements
│   ├── REQUIREMENTS-Zsh_Core_Scripting_Best Practices.md
│   └── REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md
├── snippets
│   ├── create_inception_commit.sh
│   ├── get_repo_did.sh
│   ├── requirements
│   │   ├── REQUIREMENTS-check_git_config_for_oi_signing.md
│   │   ├── REQUIREMENTS-create_inception_commit.md
│   │   └── REQUIREMENTS-get_repo_did.md
│   ├── snippet_template.sh
│   └── tests
│       └── TEST-create_inception_commit.sh
└── tests

6 directories, 10 files
```
