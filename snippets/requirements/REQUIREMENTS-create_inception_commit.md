_file: `REQUIREMENTS-create_inception_commit.md`_

# Zsh Snippet `create_inception_commit.sh` Requirements
_(Last updated: 2025-02-25, Christopher Allen <ChristopherA@LifeWithAlacrity.com>)_

## General Requirements

This script must adhere to all principles defined in:
- `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` - For general Zsh scripting practices
- `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md` - For Snippet-specific implementation details

As a Zsh Snippet, this script must remain under 100 lines of code (excluding comments and variable declarations) and follow the execution flow, error handling, parameter processing, and documentation standards defined in those documents.

## Functionality
- Create a new Git repository with a properly signed empty inception commit following Open Integrity Project standards
- Verify Git configuration includes required signing settings
- Create the directory structure for the repository if it doesn't exist
- Create an empty initial commit that provides a cryptographic root of trust
- Ensure the commit is properly signed with SSH key using Git's native signing capabilities
- Verify the signature after creation to confirm trust integrity
- Display the repository's DID in the format "did:repo:<hash>"
- Provide appropriate error messages for missing requirements or failed operations
- Support both relative and absolute paths for repository creation

### Repository Creation Process
The script must follow these steps to create a compliant inception commit:
- Create and initialize the specified Git repository
- Create an empty commit with the standardized Open Integrity initialization message
- Sign the commit using the author's SSH key
- Set the committer name to the SSH key fingerprint
- Verify the signature to ensure trust integrity
- Display the repository's DID based on the inception commit hash

## Output Handling
- Use `print` for all output for better Zsh compatibility. *(Required)*
- All error messages must be directed to stderr using `print -u2`. *(Required)*
- For successful operations, display clear success messages with a checkmark emoji (✅)
- For failures, display error messages with appropriate emoji (❌)
- Include the full path of the created repository in the output
- Display both the inception commit hash and the resulting DID

## Arguments & Options
- **`-r | --repo <directory>`** (optional)
  - Specify the directory where the repository should be created
  - If not provided, use a default name "new_open_integrity_repo" in the current directory
- **`-h | --help`** (optional)
  - Display help message with usage and examples

## Exit Codes & Error Handling
- Use standardized exit codes defined in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`. *(Required)*
- Follow the error propagation flow defined in the Core Requirements. *(Required)*
- Use specific exit codes for different error types:
  - `Exit_Status_Success` (0) - Repository created successfully
  - `Exit_Status_General` (1) - General error
  - `Exit_Status_Usage` (2) - Invalid arguments
  - `Exit_Status_IO` (3) - Repository path/directory issues
  - `Exit_Status_Git_Failure` (5) - Git repository operations failed
  - `Exit_Status_Config` (6) - Git configuration is invalid
  - `Exit_Status_Dependency` (127) - Missing executables

## Function Documentation

All functions must be documented with a consistent, structured comment block that includes: *(Required)*
- Function name in the header
- Description of purpose
- Parameters with types and constraints
- Return values and exit codes
- Dependencies on external commands or functions
- Any side effects or special considerations

### Function Naming Standards
Function names must follow the pattern specified in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`: *(Required)*
- **General utilities**: `z_Verb_Object()` (e.g., `z_Check_Dependencies()`)
- **Open Integrity specific**: `oi_Verb_Object()` (e.g., `oi_Create_Inception_Commit()`)

### Required Functions
The script must include the following functions:
- **`z_Check_Dependencies()`** - Verifies required external commands are available
- **`z_Ensure_Parent_Path_Exists()`** - Validates and creates parent directories if needed
- **`oi_Verify_Git_Config()`** - Verifies Git configuration includes required signing settings
- **`oi_Create_Inception_Commit()`** - Creates a new repository with a properly signed inception commit
- **`oi_Assure_Functional_Git_Repo()`** - Verifies a path is a functional Git repository
- **`oi_Get_First_Commit_Hash()`** - Retrieves the hash of the first commit from a Git repository
- **`oi_Verify_Commit_Signature()`** - Verifies that a commit is properly signed with SSH key
- **`oi_Get_Repo_DID()`** - Gets the DID for a repository based on its inception commit

## Script Documentation

### Script Header Comment Block Requirements
Must include the following elements: *(Required)*
- **Script name and version**
- **Origin** (link to repository)
- **Description** of purpose and functionality
- **License** (BSD-3-Clause)
- **Copyright** and attribution
- **Usage** with all command-line options
- **Examples** showing typical invocation patterns
- **Security** notes about the inception commit's role in establishing trust

## Testing Requirements

The following test cases must be used to verify compliance:

1. **Parameter Handling**
   - Test the script with the default repository name (no arguments)
   - Test with `-r | --repo` parameter for relative paths
   - Test with `-r | --repo` parameter for absolute paths
   - Test with `-r | --repo` parameter for nested paths
   - Test with `-h | --help` parameter for help display

2. **Error Handling**
   - Test with invalid options and verify appropriate error message
   - Test with a path that already contains a repository
   - Test with path that cannot be created (permissions)
   - Test with Git configuration missing required settings

3. **Path Handling**
   - Test with existing directories
   - Test with non-existent directories that need creation
   - Test with nested directories requiring recursive creation
   - Test with relative and absolute paths

4. **Inception Commit Creation**
   - Verify that the commit is empty
   - Verify that the commit message follows the Open Integrity standard
   - Verify that the committer name is set to the SSH key fingerprint
   - Verify that the signature can be verified

5. **Output Validation**
   - Verify that successful operations display the repository path
   - Verify that the inception commit hash is displayed
   - Verify that the DID is correctly formatted as "did:repo:<hash>"

## Security Requirements

- Ensure the commit is properly signed using SSH keys
- Verify Git is correctly configured for SSH-based commit signing
- Check that SSH keys are accessible and have appropriate permissions
- Include security notices about the importance of verifying signatures

## Compatibility Requirements

- The script must work with Git 2.34 or later (required for SSH signing support)
- The script must be compatible with OpenSSH 8.0 or later 
- The script must work on both macOS and Linux systems

## Versioning and Lifecycle

Version history and future plans for this script:

- **0.1.00** (2025-02-25): Initial release version
  - Base functionality to create inception commits
  - Support for relative and absolute paths
  - DID generation based on inception commit

Future versions may include:
- Support for custom commit messages while maintaining compliance
- Integration with other Open Integrity tools
- Support for automated allowed signers configuration
- Repository configuration for enhanced security

This requirements document will be updated as the script evolves, with version numbers matching the script's version numbers.