# Requirements for Zsh Script "Audit Inception Commit"
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/requirements/REQUIREMENTS-audit_inception_commit-POC.md`_
> - _github: [core/src/requirements/REQUIREMENTS-audit_inception_commit-POC.md](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-audit_inception_commit-POC.md)
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

This requirements document applies to the Open Integrity Project's **Proof-of-Concept** script `audit_inception_commit-POC.sh`, **version 0.1.05 (2025-03-04)**, and associated files, which are available at the following sources:

> **Origin:**
> - [Requirements: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-audit_inception_commit-POC.md`_](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-audit_inception_commit-POC.md)
> - [Script: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/audit_inception_commit-POC.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/audit_inception_commit-POC.sh)
> - [Regression Test: _github: `https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-audit_inception_commit.sh`_](https://github.com/OpenIntegrityProject/core/blob/main/src/tests/TEST-audit_inception_commit.sh)


## General Requirements

This script must adhere to all principles defined in:
- [REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md) - For general Zsh scripting practices
- [REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md) - For framework-specific implementation details (as this script exceeds the size limitations for snippet scripts)

As a framework script, this implements multiple phases of the Progressive Trust lifecycle for Git repositories, focusing on inception commit validation and cryptographic trust establishment.

## Core Functionality

The script must provide a comprehensive audit tool for Git repository inception commits with these capabilities:

### Progressive Trust Phases Implementation

- **Phase 2 (Wholeness):** *(Required)*
  - Locate and validate the repository's inception commit structure
  - Verify the inception commit is empty (contains no files)
  - Validate the commit message format meets Open Integrity requirements

- **Phase 3 (Proofs):** *(Required)*
  - Verify SSH signature with appropriate Git configuration (gpg.ssh.allowedSignersFile)
  - Support multiple Git configuration scenarios:
    - Inception-only repositories (using global configuration)
    - Multi-commit repositories (checking local configuration first)
    - Legacy configurations with appropriate migration guidance

- **Phase 4 (References):** *(Required)*
  - Verify committer identity matches key fingerprint
  - Establish trust references between cryptographic identities and human-readable ones

- **Phase 5 (Requirements):** *(Required)*
  - Verify compliance with GitHub-specific standards
  - Enable interactive verification with web browser support

### Progressive Trust Phases Implementation

- **Phase 2 (Wholeness):** *(Required)*
  - Structure: "Locate" inception commit, "found"
  - Content: "Assess" empty commit, "commit is empty as required"
  - Format: "Assess" message format, "meets requirements"
  - Additional actions: "Extract" key details, "Match" patterns, "Check" requirements

- **Phase 3 (Proofs):** *(Required)*
  - "Authenticate" SSH signature, "verified"
  - Support multiple Git configuration scenarios including:
    - Inception-only repositories
    - Multi-commit repositories 
    - Legacy configurations

- **Phase 4 (References):** *(Required)*
  - "Affirm" identity references
  - "Committer matches key fingerprint"

- **Phase 5 (Requirements):** *(Required)*
  - "Comply with" GitHub standards
  - Enable community standards compliance check

### Output Controls

- **Multiple Verbosity Levels:** *(Required)*
  - Standard output with minimal details
  - Verbose mode with detailed progress information
  - Debug mode with in-depth troubleshooting data

- **Interactive vs Non-Interactive:** *(Required)*
  - Support both interactive use with prompts
  - Support non-interactive execution for automation

- **Output Formatting:** *(Required)*
  - Structured, multi-phase report
  - Emoji-enhanced status indicators
  - Color support (with fallback for terminals without color)

## Command-Line Arguments and Options

- **Must support standard options:** *(Required)*
  - `-v, --verbose` - Enable verbose output
  - `-q, --quiet` - Suppress non-critical output
  - `-d, --debug` - Enable debug output
  - `-h, --help` - Show help message
  - `-n, --no-color` - Disable color output
  - `-c, --color` - Force color output
  - `-p, --no-prompt` - Run non-interactively
  - `-i, --interactive` - Force interactive mode
  - `-C, --chdir <path>` - Change to specified directory before execution

- **Robust Argument Parsing:** *(Required)*
  - Handle invalid arguments gracefully
  - Process argument combinations correctly
  - Detect and adapt to terminal capabilities

## Exit Codes & Error Handling
- Use exit codes for different error types *(Required)*
- Use the standardized exit codes defined in [Zsh Core Scripting Requirements and Best Practices § Error Handling Requirements](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#zsh-snippet-scripting---error-handling-requirements) *(Required)*
- Follow the error propagation flow defined in the Core Requirements *(Required)*
- The script currently returns exit code 1 for successful audits when GitHub integration is unavailable *(Current behavior)*
  - This is consistent with treating GitHub checks as part of the full verification
  - For test automation and CI/CD integration, this behavior should be noted (and is an Open Issue in ISSUES-audit_inception_commit-POC.md)
- Error messages must be directed to stderr using `z_Output error` or if that is not possible `print -u2` *(Required)*
- For successful operations, display clear success messages with a checkmark emoji (✅)
- For failures, display error messages with appropriate emoji (❌)

## Naming Conventions

### Function Naming Requirements

- **Framework Utility Functions:** *(Required)*
  - Prefix with `z_` (for general Zsh utilities)
  - Follow `verb_Object_Descriptor` pattern with lowercase first word and capitalized subsequent words
  - Examples: `z_setup_Environment`, `z_check_Requirements`, `z_cleanup`

- **Domain-Specific Functions:** *(Required)*
  - Prefix with `oi_` (for Open Integrity specific functions)
  - Follow same `verb_Object_Descriptor` pattern with lowercase first word and capitalized subsequent words
  - Examples: `oi_audit_Local_Inception_Commit`, `oi_locate_Inception_Commit`, `oi_authenticate_SSH_Signature`

- **Special-Purpose Functions:** *(Required)*
  - `main` - Entry point function (no prefix, single lowercase word)
  - `show_Usage` - Help function (lowercase first word, capitalized subsequent words)
  - `parse_Arguments` - Argument handling (lowercase first word, capitalized subsequent words)

### Variable Naming Requirements

- **Global Variables:** *(Required - avoid if possible)*
  - Use `UPPER_SNAKE_CASE` for any global constants

- **Script-Scoped Variables:** *(Required)*
  - Use `Mixed_Snake_Case` for script-scoped variables
  - Examples: `Script_FileName`, `Output_Debug_Mode`, `Inception_Commit_Repo_Id`

- **Local Function Variables:** *(Required)*
  - Use `CamelCase` for local variables, with at least two words
  - For array or map variables, use descriptive names conveying content type
  - Examples: `CommitHash`, `KeyInfo`, `AllowedSigners` (not `hash`, `info`, `signers`)

- **Boolean Flags:** *(Required)*
  - Define and use constants `TRUE=1` and `FALSE=0` for boolean logic
  - Use script-scoped boolean flags like `Output_Verbose_Mode=$FALSE`

## Documentation and Comment Structure Requirements

### Script Header Documentation

- **Script Header Block:** *(Required)*
  - Must use the multi-line comment format with `##` for header lines
  - Must include the script name, description, and version
  - Must include SCRIPT INFO section with VERSION and DESCRIPTION
  - Must include FEATURES list highlighting key functionality
  - Must include LIMITATIONS section detailing current constraints
  - Must include USAGE and OPTIONS sections
  - Must include REQUIREMENTS section listing dependencies
  - Must include LICENSE, COPYRIGHT, and attribution information
  - Must include PORTIONS section if code is borrowed from other sources
  - Must include PART OF section showing project affiliation

Example format:
```zsh
########################################################################
##                         SCRIPT INFO
##
## audit_inception_commit-POC.sh
## - Open Integrity Audit of a Git Repository Inception Commit
##
## VERSION:     0.1.00
##              (Last Updated: 2024-01-29)
##
## DESCRIPTION:
## This script performs a multi-part review of a Git repository's inception
## commit, auditing compliance with Open Integrity specifications across
## multiple Progressive Trust phases:
## - Wholeness: Assessing structural integrity and format
## - Proofs: Cryptographic SSH signature authentication
## - References: Affirming committer identity via references
## - Requirements: Auditing Open Integrity and GitHub community compliance
##
## The script is a part of a Proof-of-Concept (POC) for using 
## Git repositories as cryptographic roots of trust, leveraging empty, 
## SSH-signed inception commits for a secure identifier that can 
## be independently authenticated across distributed platforms.
##
## FEATURES:
## - Local audit of Inception Commit (Progressive Trust phases 2-5)
## - Empty inception commit assessed for SHA-1 trust mitigation
## - SSH-based commit signing for cryptographic integrity
## - Independent authentication of platform-agnostic signatures
## - Affirming signer identity via key fingerprint
## - Checking compliance against GitHub authentication standards
##
## For more on the progressive trust life cycle, see:
##    https://developer.blockchaincommons.com/progressive-trust/
##
## LIMITATIONS:
## - Currently only supports testing the Inception Commit (commit 0) of a
##   local git repository 
## - Script must be executed from within the repository being audited 
##   (a CLI parameter option for repository path is a work-in-progress)
## - GitHub standards compliance checks are very basic
##
## USAGE: audit_inception_commit-POC.sh [options]
## 
## OPTIONS:
## --help            Show this help message
## --verbose         Enable detailed output
## --quiet           Suppress non-critical output
## --debug           Show debugging information
## --no-prompt       Run non-interactively
## --no-color        Disable colored output
## --color           Force colored output
##
## REQUIREMENTS:
## - Zsh 5.8 or later
## - Git 2.34 or later
## - GitHub CLI (gh) 2.65.0 or later, authenticated with GitHub
## - OpenSSH 8.2+ for signature verification
##
## LICENSE:
## (c) 2025 By Blockchain Commons LLC
## https://www.BlockchainCommons.com
## Licensed under BSD-2-Clause Plus Patent License
## https://spdx.org/licenses/BSD-2-Clause-Patent.html
##
## PORTIONS:
## z_Output function:     
## Z_Utils - ZSH Utility Scripts 
## - <https://github.com/ChristopherA/Z_Utils>
## - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
## (c) 2025 Christopher Allen    
## Licensed under BSD-2-Clause Plus Patent License
## 
## PART OF:      
## Open Integrity Project of Blockchain Commons LLC.
## - Open Integrity Git Inception POCs
##   - <https://github.com/BlockchainCommons/open_integrity-git_inception_pocs>
##   - <did:repo:a3306efcb768baa6f414409b6b3575914986c8a6>
##
## CONTRIBUTING:
## This script is a work-in-progress and welcomes community contributions.
## - GitHub: https://github.com/BlockchainCommons/Open-Integrity
##
## SUPPORT BLOCKCHAIN COMMONS LLC:
## If you appreciate our tools, writing, digital rights advocacy, and 
## unique perspective, we invite you to sponsor our work.
##
## At Blockchain Commons, we champion open, interoperable, secure, and 
## compassionate digital infrastructure to empower individuals to control 
## their digital destiny while preserving their dignity online. 
## We convene stakeholders to collaboratively design decentralized 
## solutions where **everyone wins**, fostering a neutral, 
## vendor- and platform-independent ecosystem.
##
## Sponsoring us means joining a **network that prioritizes the voices of 
## independent developers** over corporate interests. We advocate for 
## smaller developers in a vendor-neutral, platform-neutral way, 
## ensuring we can all build and work together more effectively.
##
## You can become a monthly patron on our GitHub Sponsor Page:  
## 👉 https://github.com/sponsors/BlockchainCommons  
## Sponsorships start at just **$20/month**, and one-time donations are
## also welcome.
##
## But this isn't just a transaction—it's an opportunity to **shape the  
## future of the open web, digital civil liberties, and human rights**. 
## Sponsoring us means **plugging into our mission, our projects, and our 
## community**—-and hopefully finding a way to contribute to the 
## **digital commons** yourself. 
##
## Let's collaborate and build a better digital future together!
##
## -- Christopher Allen <ChristopherA@LifeWithAlacrity.com>
##    Github: [@ChristopherA](https://github.com/ChristopherA)
##    Twitter: [@ChristopherA](https://twitter.com/ChristopherA)
##    Bluesky: [@ChristopherA](https://bsky.app/profile/christophera.bsky.social)
#######################################################################```

### Change Log Section

- **Change Log Block:** *(Required)*
  - Must appear immediately after script header
  - Must use clear version numbering (e.g., 0.1.0, 1.0.0)
  - Must include release dates for each version
  - Must use bulleted lists with indentation to show feature hierarchies
  - Must document all significant changes, additions, or fixes

Example format:
```zsh
#######################################################################
## CHANGE LOG
#######################################################################
## 0.1.0    - Initial Release (2024-01-29)
##          - Core audit functionality for inception commits
##          - Support for Progressive Trust phases 2-5:
##            * Phase 2: Wholeness (structural integrity, format)
##            * Phase 3: Proofs (cryptographic signatures)
##            * Phase 4: References (identity authentication)
##            * Phase 5: GitHub community standards
##          - Interactive and non-interactive operation modes
##          - Colored output with configurable options
##          - Comprehensive help and usage information
##           - Verbose and debug output modes
##           - Initial support for GitHub standards compliance
##          - Basic error handling and reporting
##          - Script must currently be run from within repository
#######################################################################
```

### Section Header Documentation

- **Major Section Headers:** *(Required)*
  - Must use a specific multi-line comment format with descriptive title
  - Must include a detailed description of section purpose
  - Must document key components and functionality
  - Must document any dependencies or requirements
  - Must list functions contained in the section

Example format:
```zsh
#######################################################################
## Section: ZSH Configuration and Environment Initialization
##--------------------------------------------------------------------##
## Description:
## - Configures the Zsh environment to ensure robust error handling and
##   predictable execution behavior.
## - Implements safe Zsh options to prevent silent script failures,
##   unintentional global variables, or accidental file overwrites.
## - Declares script-scoped variables, constants, and execution flags
## - Early functions for setting up the script environment and assuring
##   requirements.
##
## Declarations:
## - Safe ZSH Environment Options: Strict error-handling and behavior flags.
## - Script-Scoped Variables:
##   - Boolean Constants: TRUE and FALSE for boolean logic.
##   - Execution Flags: Control script behavior and modes.
##   - Script Constants: Immutable variables for script metadata and 
##   runtime context.
##   - Command-Line Arguments and Runtime Context: Processes arguments and
##   runtime details for improved usability and debugging.
##
## Functions:
## - setup_Environment: Initializes script settings and variables.
## - check_Requirements: Assures all prerequisites are met.
#######################################################################
```

### Group Comment Blocks

- **Subsection Headers:** *(Required)*
  - Must be used to group related variables or settings
  - Must include a descriptive title
  - Must include a concise description of the purpose and content
  - Must highlight any special considerations or dependencies

Example format:
```zsh
#----------------------------------------------------------------------#
# Script-Scoped Variables - Boolean Constants
#----------------------------------------------------------------------#
# - `TRUE` and `FALSE` are integer constants representing boolean values.
# - Declared as readonly to ensure immutability
#----------------------------------------------------------------------#
```

### Function Documentation

- **Function Header Blocks:** *(Required)*
  - Must use a standard comment format with separator bars
  - Must include function name in the header
  - Must include detailed description of purpose and operation
  - Must document all parameters with types and descriptions
  - Must document return values and possible exit codes
  - Must note any side effects or special considerations
  - For complex functions, should include usage examples

- **Extended Function Documentation:** *(Required for complex functions)*
  - For complex functions like `oi_authenticate_SSH_Signature`, include:
    - Git configuration requirements
    - Detailed description of different scenarios handled (inception-only vs. multi-commit)
    - Error handling details
    - Side effects documentation
    - Example usage

Example format:
```zsh
#----------------------------------------------------------------------#
# Function: oi_authenticate_SSH_Signature
#----------------------------------------------------------------------#
# Description:
#   Verifies the SSH signature on a Git commit following Git's configuration
#   hierarchy for allowed signers. Part of Progressive Trust Phase 3 (Proofs),
#   this function handles the cryptographic authentication of commit signatures.
#
# Parameters:
#   None, but uses global Inception_Commit_Repo_Id for the commit to verify
#
# Returns:
#   - 0 if signature verification succeeds
#   - 1 if signature verification fails or encounters errors
#
# Git Configuration Requirements:
#   Git configuration for allowed signers files:
#   - gpg.ssh.allowedSignersFile - Required configuration
#   Note: Legacy configurations (trusted.ssh.allowedSignersFile, gpg.allowedSignersFile)
#         are not supported. Script will error with instructions to update if found.
#
# Side Effects:
#   - Reads Git configuration (both local and global)
#   - Accesses filesystem to read allowed signers file
#   - Outputs debug and status messages via z_Output
#----------------------------------------------------------------------#
```

### Inline Comments

- **Meaningful Inline Comments:** *(Required)*
  - Must explain "why" not just "what" the code does
  - Must document non-obvious behaviors or edge cases
  - Must use consistent style and formatting
  - Must be kept up-to-date when code changes

Example format:
```zsh
# Check if repository has only one commit (inception commit only)
if (( commit_count == 1 )); then
    # For inception-only repos, check global config only
    allowed_signers_file=$(git config --global --get gpg.ssh.allowedSignersFile)
    allowed_signers_source="global configuration"
```

## Error Handling and Exit Codes

- **Standard Exit Codes:** *(Required)*
  - `Exit_Status_Success=0` - Successful execution
  - `Exit_Status_General=1` - General error
  - `Exit_Status_Usage=2` - Invalid usage or arguments
  - `Exit_Status_IO=3` - Input/output error
  - `Exit_Status_Git_Failure=5` - Git repository error
  - `Exit_Status_Config=6` - Configuration error
  - `Exit_Status_Dependency=127` - Missing dependency

- **Error Propagation:** *(Required)*
  - Functions should return appropriate error codes rather than calling `exit`
  - Only the main function should exit the script
  - Use the pattern `function_call || return $?` to propagate errors upward

- **User-Friendly Error Messages:** *(Required)*
  - Include actionable information to help users resolve issues
  - For configuration errors, provide example commands to fix the problem
  - Use appropriate format based on severity (warning vs. error)

## Dependencies and Requirements

- **External Tools:** *(Required)*
  - Git 2.34 or later (required for SSH signing)
  - Zsh 5.8 or later
  - GitHub CLI (gh) for GitHub standard compliance checks
  - OpenSSH 8.2+ for signature verification

- **Script Environment:** *(Required)*
  - Support for terminal color detection and fallback
  - Respect standard environment variables (NO_COLOR, FORCE_COLOR, etc.)
  - Must function in both interactive and non-interactive environments

## Security Best Practices

- **Non-Destructive Operation:** *(Required)*
  - Script must NEVER modify repositories or Git configuration
  - All operations must be read-only and verification-focused

- **Input Validation:** *(Required)*
  - Validate all user inputs, especially paths and arguments
  - Never execute user-supplied commands or arguments directly
  - Use proper quoting for all variable expansions

- **Security Notices:** *(Required)*
  - Include warnings about SHA-1 limitations for cryptographic purposes
  - Provide guidance about securing SSH keys and allowed signers files

- **Credential Handling:** *(Required)*
  - Never expose private key information or sensitive data
  - Respect ownership and permission restrictions

## Performance and Resource Management

- **Efficient Git Operations:** *(Required)*
  - Minimize the number of Git commands executed
  - Batch operations where possible
  - Cache results when the same data is needed multiple times

- **Resource Cleanup:** *(Required)*
  - Use proper trap handlers for cleanup
  - Remove any temporary files on exit
  - Prevent recursive script execution

## Testing Requirements

- **Test Coverage:** *(Required)*
  - Test basic functionality with standard arguments
  - Test various repository states (inception-only, multi-commit)
  - Test error conditions and edge cases
  - Test in both interactive and non-interactive modes

- **Test Environment:** *(Required)*
  - Test with different terminal configurations
  - Test with various Git configurations
  - Test across supported platforms (macOS, Linux)

## Extension Points

- **Future Compatibility:** *(Optional)*
  - Consider support for additional Git hosting platforms
  - Allow for extension to other Progressive Trust phases
  - Enable integration with other Open Integrity tools

## Example Usage

The script should support the following usage patterns:

```bash
# Basic usage (current directory)
audit_inception_commit.sh

# Verbose mode with specified directory
audit_inception_commit.sh --verbose -C /path/to/repository

# Non-interactive mode for automation
audit_inception_commit.sh --no-prompt --quiet -C /path/to/repository

# Help display
audit_inception_commit.sh --help
```

## Limitations and Future Improvements

- **Current Limitations:**
  - Only supports testing the inception commit of a local Git repository
  - Limited GitHub standards compliance checks
  - No support for cross-repository verification

- **Future Improvements:**
  - Enhanced platform integration beyond GitHub
  - Support for additional Progressive Trust phases
  - Cross-repository verification features
  - Integration with decentralized identifiers (DIDs)

---

This requirements document will be updated as the script evolves. All changes should be tracked in the script's version history and reflected in this document.