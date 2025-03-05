# Requirements for Zsh Snippet "Create Inception Commit"
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/requirements/REQUIREMENTS-create_inception_commit.md`_
> - _github: [`core/src/requirements/REQUIREMENTS-create_inception_commit.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-create_inception_commit.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.02-blue.svg)](CHANGELOG.md)

## Code Version and Source

This requirements document applies to version **0.1.03 (2025-03-04)** of the code, which is available at the following source:

**Origin:** 
- [GitHub: `create_inception_commit.sh`](https://github.com/OpenIntegrityProject/core/blob/main/src/create_inception_commit.sh)
- [GitHub: `TEST-create_inception_commit.sh`](https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-create_inception_commit.sh)

Any updates or modifications to the code should reference this version to ensure consistency with the outlined requirements.

## General Requirements

This script must adhere to all the principles and requirements for Zsh scripts defined in:
- [Zsh Core Scripting Requirements and Best Practices](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md) - For general Zsh scripting practices
- [Zsh Snippet Scripting Requirements and Best Practices](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md) - For Snippet-specific implementation details

As a Zsh Snippet, this script must remain under 200 lines of code (excluding comments and variable declarations) and follow the execution flow, error handling, parameter processing, and documentation standards defined in those documents.

## Functionality
- Verify Git configuration includes required signing settings
- Support both relative and absolute paths for repository creation
- Create the directory structure for the repository if it doesn't exist
- Create an initial commit, following the Open Integrity Project standards, to provide a cryptographic root of trust
- Ensure the commit is properly signed with SSH key using Git's native signing capabilities
- Verify the signature after creation to confirm trust integrity
- Provide appropriate error messages for missing requirements or failed operations

### Repository Creation Process
The script must follow these steps to create a compliant inception commit:
- Create and initialize the specified Git repository
- Create an empty commit with the standardized Open Integrity initialization message
- Sign the commit using the author's SSH key
- Set the committer name to the SSH key fingerprint
- Display the repository's DID based on the inception commit hash, in the format "did:repo:<hash>"
- Display the relative path of the created repository in the output

## Output Handling
- Use `print` for all output for better Zsh compatibility *(Required)*
- All error messages must be directed to stderr using `print -u2` *(Required)*
- For successful operations, display clear success messages with a checkmark emoji (✅)
- For failures, display error messages with appropriate emoji (❌)
- Display the verified inception commit hash in `did:repo:<commithash>` form

## Arguments & Options
- **`-r | --repo <directory>`** (optional)
  - Specify the directory where the repository should be created
  - If not provided, use a default name "new_open_integrity_repo" in the current directory
- **`-h | --help`** (optional)
  - Display help message with usage and examples

## Exit Codes & Error Handling
- Use exit codes for different error types *(Required)*
- Use the standardized exit codes defined in [Zsh Core Scripting Requirements and Best Practices § Error Handling Requirements](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#zsh-snippet-scripting---error-handling-requirements) *(Required)*
- Follow the error propagation flow defined in the Core Requirements *(Required)*

## Script and Function Documentation
All functions must be documented with a consistent, structured comment block as per:
- [Script Header Comment Block Requirements](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#script-header-comment-block-requirements)
- [Function Comment Block Requirements](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#function-comment-block-requirements)

### Function Naming Standards
Function names must follow the pattern specified in Core Scripting Requirements:
- **General utility functions**: `z_Verb_Object()` (e.g., `z_Check_Dependencies()`)
- **Open Integrity specific utility functions**: `oi_Verb_Object()` (e.g., `oi_Create_Inception_Commit()`)

### Required Functions
The script must include the following functions:
- **`z_Report_Error()`** - Centralized error reporting with consistent formatting
- **`z_Convert_Path_To_Relative()`** - Converts absolute paths to relative paths for display
- **`z_Check_Dependencies()`** - Verifies required external commands are available
- **`z_Ensure_Parent_Path_Exists()`** - Validates and creates parent directories if needed
- **`oi_Extract_Ssh_Key_Fingerprint()`** - Extracts the SSH key fingerprint using Zsh-native parsing
- **`oi_Get_First_Commit_Hash()`** - Retrieves the hash of the first commit from a Git repository
- **`oi_Verify_Git_Config()`** - Verifies Git configuration includes required signing settings
- **`oi_Assure_Functional_Git_Repo()`** - Verifies a path is a functional Git repository
- **`oi_Get_Repo_DID()`** - Gets the DID for a repository based on its inception commit hash
- **`oi_Create_Inception_Commit()`** - Creates a new repository with a properly signed inception commit

## Test Harness Requirements

### Test Scenarios
The regression test script must:
- Verify script functionality across various input scenarios
- Test the script with:
  - Default repository name (no arguments)
  - Relative path repository creation
  - Absolute path repository creation
  - Nested path repository creation
  - Help flag display

### Test Coverage
The test script must validate:
- Successful repository creation
- Correct inception commit generation
- Proper SSH key signing
- Accurate repository DID generation
- Error handling for:
  - Invalid options
  - Existing repository paths
  - Permission-restricted paths
  - Incomplete Git configurations

### Test Output
- Provide clear, emoji-based test result reporting
- Generate a summary showing:
  - Total tests executed
  - Number of passed tests
  - Number of failed tests
- Support verbose mode for detailed test diagnostics

## Versioning and Lifecycle

Version history and future plans for this script:

- **0.1.02** (2025-02-28): Enhanced reliability and test coverage
  - Improved error handling
  - Expanded test scenarios
  - Enhanced path validation

- **0.1.01** (2025-02-25): Initial functional version
  - Base functionality to create inception commits
  - Support for relative and absolute paths
  - DID generation based on inception commit

Future versions may include:
- Support for custom commit messages while maintaining compliance
- Integration with other Open Integrity tools
- Support for automated allowed signers configuration
- Repository configuration for enhanced security

This requirements document will be updated as the script evolves, with version numbers matching the script's version numbers.
