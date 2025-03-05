_file: `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md`_

# Zsh Snippet Scripting Requirements and Best Practices
_(last updated 2024-03-01, Christopher Allen <ChristopherA@LifeWithAlacrity.com> Github/Twitter/Bluesky: @ChristopherA)_

## Introduction
Zsh Snippet scripts are **small, self-contained, and executable**, typically **less than 75 lines** (excluding comment lines and variable declarations), but should remain **under 200 lines of code**. They should be **concise**, **modular**, and **follow best practices** while avoiding unnecessary complexity.

These requirements are **less stringent** than those for framework scripts, and define the **minimum necessary standards** for Zsh Snippet Scripts. If a script exceeds this scope—requiring extensive logic, multiple functions, or significant complexity—it should be refactored into a **full script framework** that adheres to the broader requirements in `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md`.

All Zsh Snippets must follow the **core principles** defined in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`. This document covers the **additional requirements specific to Zsh Snippet scripts**.

## Zsh Snippet Scripting - General Principles
- **Keep It Simple** – A Zsh Snippet should accomplish a well-defined task concisely.
- **Readability Over Cleverness** – Prefer clarity over obscure optimizations.
- **Single Responsibility** – Each Zsh Snippet should do **one thing well**.
- **Minimal Dependencies** – Use built-in Zsh utilities when possible.
- **Graceful Failure** – Implement basic error handling without excessive verbosity.
- **Security Best Practices** – Use proper quoting, avoid `eval`, and never expose sensitive data in plaintext.

While Zsh Snippets should be concise, never sacrifice:
- Proper error handling
- Security notices when relevant
- Essential input validation
- Clear error messages

### When NOT to Use a Script Snippet
If your script includes any of the following, use a framework script instead:
- **Exceeds ~100 lines of code** (excluding comments lines and variable declarations)
- **Multiple functions with complex logic**
- **Dependency checks beyond simple `command -v` verification**
- **Complex argument parsing (multiple options, positional parameters, etc.)**
- **Heavy user interaction requiring multiple prompts**
- **File system modifications with rollback logic**
- **File manipulation requiring cleanup**
  - Need for temporary file management
  - EXIT/INT/TERM trap handling
  - Complex cleanup requirements

If your script has these characteristics, follow the guidelines in `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` and use a script template framework like `z_min_frame.sh` or `z_frame.sh` instead.

## Zsh Snippet Scripting - Safety and Predictability

Implement the safety principles from the Core Requirements document with a minimal, focused approach. For Snippet scripts, this means:

- Always use `#!/usr/bin/env zsh` *(Required)*
- Reset the shell environment with `emulate -LR zsh` *(Required)*
- Apply strict error handling options: *(Required)*
```zsh
  setopt errexit nounset pipefail localoptions warncreateglobal
```

These configurations ensure predictable execution, prevent silent failures, and protect against unexpected script behavior. Prioritize simplicity while maintaining robust safety standards.

If your script requires more complex environment management, transition to a framework script.

## Zsh Snippet Scripting - Naming and Documentation Requirements

For naming conventions, variable scoping, and documentation standards, follow the "Naming and Documentation Requirements" in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`.

## Zsh Snippet Scripting - Execution Flow and Error Propagation

Zsh Snippet scripts follow a structured, modular approach to script execution, emphasizing:
- **Single Responsibility**: Each function does one thing well
- **Minimal Side Effects**: Functions depend on passed parameters, not global state
- **Clear Error Handling**: Errors propagate upward, stopping execution
- **Simple Structure**: Minimal execution paths with clear entry and exit points

Even for the simplest Zsh Snippet scripts, maintain a straightforward execution pattern:

### Examples of Execution Flow and Error Propagation

#### Simple Execution Flow (Success Path)

```
Script Start
├── Environment Setup
│   └── Reset shell environment and apply safe scripting options
│
├── Script Entry Point Check
│   └── If run directly "${(%):-%N}" == "$0"
│       └── Call main()
│
└── main()
    └── core_Logic()
        └── [Success] ──► stdout
```

#### Simple Error Propagation (Failure Path)

```
core_Logic()
└── return error (Exit_Status_Code)
    └── main()
        ├── exit (with status)
        └── [Error] ──► stderr
```

#### Simple Pseudocode Template

```zsh
#!/usr/bin/env zsh

# Reset shell environment and apply safe scripting options
emulate -LR zsh
setopt errexit nounset pipefail localoptions warncreateglobal

# Function for core logic
core_Logic() {
    # Primary functionality code
    # Return appropriate exit status
}

# Main execution block
main() {
    # Parameter and dependency checks
    core_Logic "$@"
}

# Execute only if run directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi
```

#### More Complex Execution Flow

For Zsh Snippets with parameter validation or dependency checks:

```
Script Start
├── Environment Setup
│   └── Reset shell environment and apply safe scripting options
│   └── Declare exit status constants and any script-scoped variables
│
├── Script Entry Point Check
│   └── If run directly "${(%):-%N}" == "$0"
│       └── Call main()
│
└── main()
    ├── parse_Parameters()
    │   └── validate input
    │
    ├── check_Dependencies() (optional)
    │   └── verify commands
    │
    └── core_Logic()
        └── [Success] ──► stdout
```

#### Corresponding Error Propagation

```
core_Logic()
└── return error (Exit_Status_Code)
    └── main()
        ├── exit (with status)
        └── [Error] ──► stderr

parse_Parameters()
└── show_Usage()
    └── main()
        ├── exit (Exit_Status_Usage)
        └── [Error] ──► stderr

check_Dependencies()
└── return error (Exit_Status_Dependency)
    └── main()
        ├── exit (with status)
        └── [Error] ──► stderr
```

#### Pseudocode for More Complex Snippets

```zsh
#!/usr/bin/env zsh

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Exit status constants
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
# Additional exit codes as needed

# Remaining script-scoped variables here

show_Usage() {
   # Prints usage instructions
}

# Additional functions with reusable, self-contained logic
other_Function() {
    # Function logic here
    # Return appropriate exit status on error
}

core_Logic() {
   # Primary script functionality
   # Call other functions as needed
   # Return appropriate exit status
}

check_Dependencies() {
   # Verify required commands exist
   # Return appropriate exit status on failure
}

parse_Parameters() {
   # Process and validate input parameters
   # Call show_Usage() for invalid input
   # Return validated parameters
}

main() {
   # Orchestrate execution flow
   # 1. Parse parameters
   # 2. Check dependencies (if needed)
   # 3. Execute core logic
}

# Execute only when run directly
if [[ "${(%):-%N}" == "$0" ]]; then
   main "$@"
fi
```
  
## Zsh Snippet Scripting - Error Handling Requirements

All error handling in Zsh Snippet scripts must adhere to the core principles outlined in the "Error Handling Requirements" section of `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`.

Zsh Snippets, being lightweight and focused scripts without comprehensive framework support, require careful, explicit error management. The following guidelines provide additional context and practical strategies for robust error handling in snippet-level scripts:

### Error Message Output

#### Using print (Preferred Method)
Error messages should be **concise** and use zsh-native `print -u2`:
```zsh
print -u2 "Error: File not writable."
return $Exit_Status_IO
```

#### Alternative Output Methods
When not using `print` (for instance, when you are required to use `echo` or `printf` for precise formatting, escape sequences, or POSIX compatibility), ensure the error output is **redirected to stderr**:

```zsh
# Using printf for precise formatting (e.g., fixed decimal places)
printf "Processed value: %.2f\n" 3.14159 >&2
return $Exit_Status_Invalid
```

### Command Output Error Handling
- Capture command output before testing status
  - Store output in descriptive variables
  - Capture both stdout and stderr when needed
  - Test exit status after capture

#### Git Command Error Handling
```zsh
git_output=$(git command 2>&1) || {
    print -u2 "Error: Operation failed. Git reported: $git_output"
    return $Exit_Status_Git_Failure
}
```

#### Pipeline Error Handling
```zsh
output=$(command1 | command2 2>&1) || {
    print -u2 "Error: Pipeline failed: $output"
    return $Exit_Status_Error
}
```

#### General Command Output Examples
```zsh
# Good: Descriptive variable names
GitCommitInfo=$(git log -1 --oneline 2>&1)
HashResult=$(openssl sha256 "$InputFile" 2>&1)

# Bad: Generic or unclear names
output=$(git log -1)
result=$(openssl sha256 "$f")

# Good: Local scope and clear purpose
calculate_Hash() {
    typeset HashCommand="openssl sha256"
    typeset HashOutput

    HashOutput=$($HashCommand "$1" 2>&1) || {
        print -u2 "Error: Hash calculation failed: $HashOutput"
        return $Exit_Status_General
    }
    print -- "$HashOutput"
}

# Good: Separate capture and testing
CommitInfo="$(git log -1)"  # Capture first
(( $? == 0 )) || {          # Test separately
    print -u2 "Error reading commit: $CommitInfo"
    return $Exit_Status_Git_Failure
}

# Capture multiline output properly
typeset -a OutputLines
OutputLines=("${(@f)$(command_that_outputs_lines)}") || {
    print -u2 "Error capturing output lines"
    return $Exit_Status_General
}
```

## Zsh Snippet Scripting - Parameter Handling

Follow the "Parameter Handling" section in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`.

## Zsh Snippet Scripting - Script Documentation

### Script Header Comment Block Requirements
Even though Zsh Snippets are brief, they must contain a **minimal metadata block** for tracking, attribution, and reuse.
- Text must have **at least 9 entries** to ensure comprehensive documentation *(Required)*
- Must include: *(Required)*
  - **Script name, Version, Description, and repository origin link**
  - **Use BSD-3-Clause license** (or specified project license)
  - **Attribution to original author(s)** 
  - **Usage** with syntax and parameters
  - **Examples** showing typical usage

- The first **Example** should demonstrate the typical usage pattern showing all available options.
- A second **Example** is optional but recommended to show an alternative or advanced use case.
- **Security** Comments should be included when script has security or trust implications:
  - Must be concise and specific
  - Should point to appropriate assurance mechanisms

**Good Example:**

```zsh
########################################################################
## Script:        get_repo_did.sh
## Version:       1.0 (2025-02-21)
## Origin:        https://github.com/BlockchainCommons/scripts/tree/main/snippets/get_repo_did.sh
## Description:   Retrieves the first commit (Inception Commit) hash of a Git 
##                repository and formats it as a W3C Decentralized Identifier (DID).
## License:       BSD-3-Clause (https://spdx.org/licenses/BSD-3-Clause.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
## Usage:         get_repo_did.sh [-C|--chdir <path>]
## Examples:      get_repo_did.sh -C /path/to/repo
##                touch "/path/to/repo/$(get_repo_did.sh -C /path/to/repo)"
## Security:      Git uses SHA-1 for commit identifiers, which has known  
##                cryptographic weaknesses. This DID should only be trusted 
##                when verified by a full Open Integrity inception commit audit.
########################################################################
```

### Function Comment Block Requirements
All functions must be documented with a consistent, structured comment block that includes: *(Required)*

```zsh
#----------------------------------------------------------------------#
# Function: function_Name
#----------------------------------------------------------------------#
# Description:
#   Brief explanation of function's purpose (one to two lines)
# Parameters:
#   $1 - Parameter description with type and constraints
#   $2 - Parameter description with type and constraints
# Returns:
#   Exit_Status_Success on success
#   Appropriate error codes on failure
#   Description of any output to stdout/stderr
# Dependencies: (if applicable)
#   Lists external commands or functions this depends on
#----------------------------------------------------------------------#
```

The comment block must: *(Required)*
- Be delimited by separator lines (`#----------------------------------------------------------------------#`) 
- Include the function name in the header
- Have clear section headings (Description, Parameters, Returns)
- Document all parameters by position and purpose
- Specify all return values and exit codes
- List dependencies when the function relies on external commands
- Include side effects if the function modifies global state

**Good Example:**

```zsh
#----------------------------------------------------------------------#
# Function: get_First_Commit_Hash
#----------------------------------------------------------------------#
# Description:
#   Retrieves the hash of the first commit (inception commit) from a Git repository
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Prints commit hash to stdout on success
#   Exit_Status_Success if hash is found
#   Exit_Status_Git_Failure if no commits exist or Git operation fails
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
get_First_Commit_Hash() {
  #...
}
```

## Zsh Snippet Scripting - System Requirements

For comprehensive system requirements, Zsh Snippet scripts must adhere to the guidelines outlined in the "System Requirements" section of `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`. Key principles include:

**System Requirements for Snippets:**

Given the lightweight nature of Snippet scripts, dependency checks should be:
- Minimal and focused
- Limited to simple `command -v` checks
- Provide clear, concise error messages

- **Dependency Verification:** Explicitly check for any non-standard dependencies
- **Cross-Platform Compatibility:** 
  - Ensure commands function correctly across macOS and Linux
  - Be aware of utility differences, especially for macOS-specific or BSD-based commands
- **Dependency Checks:** 
  - Use `command -v <cmd>` to verify external command existence
  - Exit with `127` (`$Exit_Status_Dependency`) if a required command is missing

If your script requires more extensive dependency management, consider transitioning to a framework script as outlined in the script complexity guidelines.

## Zsh Snippet Scripting - Testing & Debugging

Follow the testing and debugging guidelines in the "Testing & Debugging" section of `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`. 

**Testing Principles for Snippets:**
- Keep testing simple and focused
- Prioritize basic functionality checking
- Avoid over-complicating test procedures

**Syntax & Execution Testing:**
```zsh
# Syntax check
zsh -n snippet_script.sh

# Debug execution
zsh -x snippet_script.sh
```
**Function Name Conflict Testing:**
- During testing, check for conflicts with built-ins and plugins using `typeset -f`
- Use project-specific prefixes to avoid naming collisions (e.g., `oi_` for Open Integrity)

If your script requires more extensive testing or output management, consider using a full framework script.

### Regression Test Scripts for Zsh Snippets

Regression test scripts are not required for Zsh Snippets, but are recommended.

#### Fundamental Considerations
- The primary focus of a regression test script is testing of CLI parameter variations
- Regression test scripts for snippets are themselves Zsh snippet scripts
  - Thus must adhere to all Zsh Core and these Zsh snippet scripting requirements

#### CLI Parameter Testing
- Systematically test all defined command-line arguments and options
- Validate correct behavior for:
  - Each individual flag/option
  - Combinations of compatible flags
  - Error cases for invalid arguments
  - Help/usage output display

#### Test Environment Management
- Prioritize minimal, targeted test scenarios
- Create temporary test artifacts only when necessary
- Restore system state between individual tests, or after the regression test script is complete
- Ensure test script can be run repeatedly without side effects
- Clean up any temporary files, directories, or configuration changes

#### Key Testing Strategy
- Focus on parameter validation and error handling
- Verify script's response to various input scenarios
- Demonstrate script robustness without extensive sample data creation

#### What Regression Test Scripts Do Not Require
- Full comprehensive data generation of test cases
- Extensive mock environment setup
- Complex dependency simulation
- Detailed performance benchmarking
- Complete code coverage analysis
- Elaborate test fixture management
- Parallel test execution
- Persistent test state between runs
- Complex test result aggregation
- Integration with external testing frameworks

## Zsh Snippet Scripting - Example Files

The project includes several example files that illustrate best practices and core scripting requirements for Zsh Snippet Scripts. These serve as both educational resources and practical implementations.

### Example Templates and Implementations

- `snippet_template.sh` - A Zsh Snippet template providing an educational starting point for new scripts. It contains illustrative example code for reporting file status, designed primarily for learning rather than production use.

- `get_repo_did.sh` - A fully functional example of a Zsh Snippet script that retrieves the first commit (Inception Commit) hash of a Git repository and formats it as a W3C Decentralized Identifier (DID). This is the first in a series of utility Snippet scripts for creating, verifying, auditing, and debugging Open Integrity repositories.

### Snippet-Specific Requirements Documents

- `REQUIREMENTS-get_repo_did.md` - A reference document demonstrating how Zsh Snippet-specific requirements should be structured. This file provides a format for defining requirements before coding begins and updating them as the script evolves.

These example files serve as practical references for applying Zsh Snippet scripting best practices in real-world scenarios.

## Conclusion

Zsh Script Snippets should be **concise, readable, and self-contained**. By following these guidelines, you can create Zsh Snippets that are easy to use, maintain, and integrate into larger automation workflows.

For tasks that exceed the scope of a Zsh Snippet, use a full script framework like `z_frame.sh` or `z_min_frame.sh` instead. Refer to `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` for detailed guidance on more complex scripts.
