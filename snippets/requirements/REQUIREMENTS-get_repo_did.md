_file: `REQUIREMENTS-get_repo_did.md`_

# Zsh Snippet `get_repo_did.sh` Requirements
_(Last updated: 2025-02-25, Christopher Allen <ChristopherA@LifeWithAlacrity.com>)_

## General Requirements

This script must adhere to all principles defined in:
- `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` - For general Zsh scripting practices
- `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md` - For Snippet-specific implementation details

As a Zsh Snippet, this script must remain under 100 lines of code (excluding comments and variable declarations) and follow the execution flow, error handling, parameter processing, and documentation standards defined in those documents.

## Functionality
- Retrieve the **first commit (Inception Commit)** of a Git repository.
- Format and output the **Decentralized Identifier (DID)** to stdout in the form:
```
did:repo:<commit-hash>
```
- If the `-C | --chdir <path>` option is provided, change to that directory **before** executing Git commands.
- If no directory is specified, **use the current working directory (`pwd`)**.

## Output Handling
- Use `print` for all output for better Zsh compatibility. *(Required)*
- Handle unexpected blank lines in external command output appropriately. *(Required)*
- All error messages must be directed to stderr using `print -u2`. *(Required)*

## Exit Codes & Error Handling
- All snippets must use the standardized exit codes defined in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`. *(Required)*
- Follow the error propagation flow defined in the Core Requirements. *(Required)*
- Use specific exit codes for different error types:
  - `$Exit_Status_Usage` (2) - Invalid arguments
  - `$Exit_Status_IO` (3) - Path/directory issues
  - `$Exit_Status_Git_Failure` (5) - Git repository errors
  - `$Exit_Status_Dependency` (127) - Missing executables

## Arguments & Options
- **`-C | --chdir <path>`** (optional)  
  - If provided, switch to the specified directory before execution, otherwise $PWD

## Documentation Requirements

### Script Header Documentation
- The script header must include all elements specified in Snippet requirements. *(Required)*
- Must include a **Security** notice about SHA-1 weaknesses with specific mention that the DID should only be trusted when verified by a full Open Integrity inception commit audit. *(Required)*

### Function Documentation
- Each function must have a documentation block conforming to the Snippet requirements. *(Required)*
- The `get_First_Commit_Hash` function documentation must explicitly note its Git dependency.
- Error propagation paths must be documented for each function.

## Failure Conditions & Handling
- For path validation:
  - Ensure the path exists and is a readable and writable directory (`-d`, `-r`, and `-w`).
  - Exit with `$Exit_Status_IO` if validation fails
- For Git operations:
  - Verify repository validity with `rev-parse --is-inside-work-tree`
  - Check for commits with `rev-list --max-count=1`
  - Exit with `$Exit_Status_Git_Failure` for any Git-related failures
  - Include Git's error output in failure messages

Script must handle and properly report:
- Non-existent repository: "Error: Invalid or unreadable directory '$dir'"
- Non-git directory: "Error: Not a Git repository"
- Empty repository: "Error: No initial commit found (repository may be empty)"

## Performance Considerations
- Repository validation should balance thoroughness with speed
- Basic repository checks should complete quickly
  - Heavy operations like fsck should be optional or configurable

## Testing Requirements

The following test cases must be used to verify compliance:

1. **Basic functionality**
   - Test against a valid Git repository
   - Verify output is in the correct format: `did:repo:<valid-commit-hash>`

2. **Directory option**
   - Test `-C` option with valid directory path
   - Test `--chdir` option with valid directory path
   - Verify both work identically

3. **Error handling**
   - Test with non-existent directory (verify `$Exit_Status_IO` exit code)
   - Test with non-Git directory (verify `$Exit_Status_Git_Failure` exit code)
   - Test with empty Git repository (verify `$Exit_Status_Git_Failure` exit code)
   - Verify error messages match requirements

4. **Edge cases**
   - Test with repository containing unusual characters in path
   - Test with repository having multiple root commits (should return earliest)
   - Test script behavior when invoked via source vs. direct execution

## Security Requirements

The script must include a security notice about the limitations of SHA-1 for cryptographic purposes, specifically:
- SHA-1 has known cryptographic weaknesses
- The DID should only be trusted when verified by a full Open Integrity inception commit audit
- The script itself should make no claims of cryptographic security

## Versioning and Lifecycle

Version history and future plans for this script:

- **0.1.00** (2025-02-25): Initial release version
  - Base functionality to retrieve inception commit hash and format as DID
  - Support for `-C|--chdir` option
  - Error handling for path validation and Git operations

Future versions may include:
- Enhanced validation of Git repositories
- Support for additional DID methods beyond `did:repo`
- Integration with inception commit auditing tools
- Performance optimizations for large repositories

This requirements document will be updated as the script evolves, with version numbers matching the script's version numbers.
