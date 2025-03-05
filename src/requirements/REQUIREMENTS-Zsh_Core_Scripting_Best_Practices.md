# Zsh Core Scripting Requirements and Best Practices
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`_
> - _github: [`scripts/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)_
> - _Updated: 2025-03-01 by Christopher Allen <ChristopherA@LifeWithAlacrity.com> Github/Twitter/Bluesky: @ChristopherA_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## Code Version and Source

This requirements document applies to the the initial Open Integrity Project's **Proof-of-Concept** scripts, versioned **0.1.\***, which are available at the following source:

> **Origin:** [_github: `https://github.com/OpenIntegrityProject/scripts/`_](https://github.com/OpenIntegrityProject/scripts/)

Any updates or modifications to these scripts should reference this requirements document to ensure consistency with the outlined requirements.

## Introduction
Zsh scripting requires a methodical approach that prioritizes safety, readability, and predictability. This document outlines the core principles and foundational practices for creating robust Zsh scripts, establishing the fundamental requirements that serve as the baseline for all script development in the project.

The Zsh scripting architecture consists of three tiers of requirements:
1. **Core Requirements:** Universal principles and standards applicable to all Zsh scripts (this document).
2. **Snippet Script Requirements:** Specific guidance for small (under 200 lines), single-purpose scripts (at `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md`).
3. **Framework Script Requirements** - Extended requirements for complex, multi-component scripts (at `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md`).

These comprehensive requirements are designed to ensure scripts are not just functional, but maintainable, secure, and aligned with best practices in shell scripting. They focus on safety, predictability, proper error handling, and clear documentation, with implementation specifics detailed in either the Snippet or Framework requirements documents based on script scope and complexity.

## Zsh Core Scripting - General Principles

### Foundational Design Principles
- **Safety First:** Scripts should fail safely, predictably, and early when errors occur, with robust error handling and comprehensive input validation.
- **Explicit Over Implicit:** Make script behavior, dependencies, and side effects explicit and predictable across different environments.
- **Clarity Over Complexity:** Prioritize readability and maintainability, avoiding terse or "clever" code in favor of clear, understandable implementations.

### Code Quality Principles
- **Meaningful Documentation:** Design scripts to be self-documenting through clear naming, structure, and comprehensive documentation that explains purpose, requirements, usage, and expected behavior.
- **Defensive Coding:** Validate inputs, check dependencies, handle edge cases, and implement graceful failure mechanisms that provide meaningful error information.
- **Error Transparency:** Provide clear, actionable error messages that help solve problems.
- **Performance Balance:** Balance performance optimization with code maintainability.

### Architectural Principles
- **Single Responsibility:** Create functions with a well-defined, focused purpose that are self-contained and reusable.
- **Clear Interfaces:** Provide clear interfaces for function inputs and outputs.
- **Minimal Dependencies:** Prefer built-in Zsh utilities and minimize external command usage.
- **State Management:** Minimize global state and side effects.
- **Workflow Integration:** Design scripts to be easily integrated into larger automation workflows.

These principles apply across all script types and sizes, though their specific implementation may vary based on script complexity.

## Zsh Core Scripting - Safety and Predictability

- **Use `#!/usr/bin/env zsh`** as the shebang to ensure portability across systems.
- **Ensure a predictable execution environment**
  - `emulate -LR zsh` resets inherited shell settings and maintains localized options within functions. *(Required)*
- **Enable strict error handling**
  - `setopt errexit` makes the script exit immediately on any command failure. *(Required)*
  - `setopt nounset` treats uninitialized variables as errors. *(Required)*
  - `setopt pipefail` ensures a pipeline fails if any command within it fails. *(Required)*
- **Prevent unintended global variables**
  - `setopt warncreateglobal` warns when creating global variables unintentionally. *(Required)*
- **Encourage safer variable and file handling**
  - `setopt localoptions` restores option settings upon function return. *(Required)*
  - `setopt noclobber` prevents overwriting existing files unless explicitly allowed with `>|`. *(Optional)*

Example:
```zsh
# Reset environment to avoid inherited settings
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal
```

## Zsh Core Scripting - Naming and Documentation Requirements

### Naming Conventions
- **Scripts:** Use `lower_snake_case.sh` (not `.zsh`) in `verb_preposition_object.sh` order (e.g., `create_inception_commit.sh`).
- **Functions:** Use `lowerfirst_Pascal_Snake_Case` in `verb_Preposition_Object` order (e.g., `verify_Commit_Signature()`).
  - To prevent potential conflicts with Zsh built-ins and plugins, check for existing function names using `typeset -f function_name` during testing.
- **Variables:**
  - **Avoid globals:** Use script-scoped variables instead.
  - **Globals:** If you must use a global, it should be `UPPER_SNAKE_CASE` (e.g., `GIT_COMMITTER_NAME`) unless it is inherited by or passed to another script with different requirements.
  - **Script-Scoped:** Use `Mixed_Snake_Case` in `Adjective_Object` order (e.g., `Repo_Dir_Path`).
  - **Local variables:** Use `CamelCase` in `AdjectiveObject` order, with at least two words (e.g., `CommitHash`, `SigningKey`). Never use single-word names like `Dir`, `Repo`, `List`, `Path`, or `File` - these fail to convey purpose or content.
  - **Loop variables:** Use single-letter (`i, j`) only if a trivial loop; otherwise, use meaningful two-word names.
  - **Explain exceptions** Add comments about exceptions to variable naming rules, for instance Zsh-specific variables (e.g. `$result`) or inherited by or passed to another script with different requirements (e.g., `GIT_COMMITTER_NAME` required by `git`, or `$HOST` from the shell).
  - **Use `typeset`** to declare variables explicitly:
```zsh
typeset -g GLOBAL_VARIABLE  # Global scope (avoid if possible)
typeset localVar  # Local variable (camelCase, at least two words)
```
  - **Specify variable types:**
  ```zsh
typeset -i integerVar   # Integer local variable
typeset -a arrayVar     # Array local variable
typeset -A assocArray   # Associative array local variable
```
- **Use `readonly`** for constants and values that should not change:**
```zsh
typeset -r SCRIPT_VERSION="1.0.0"
```

### Function Naming Examples
Good - Clear verb_Object pattern with purpose:
```zsh
calculate_File_Hash()     # Calculates hash of a file
verify_Git_Repo()        # Verifies Git repository status
parse_Command_Options()   # Parses command line options
validate_Input_Path()     # Validates an input path exists
```

Bad - Unclear purpose or missing verb:
```zsh
do_hash()          # Unclear what is being hashed
repo_check()       # Missing verb, unclear action
args()            # Too generic, unclear purpose
validate()         # Missing object being validated
```

## Zsh Core Scripting - Execution Flow and Structure

### Fundamental Execution Principles

Scripts—whether **Snippets** or **Framework-based**—should follow a structured, predictable execution flow to ensure clarity, maintainability, and error resilience. The key principles are:

- Maintain a **clear separation of concerns** between initialization, core logic, and cleanup.
- **Minimize global state modifications** and rely on explicit parameter passing.
- Establish **clear entry (`main()`) and exit points** with well-defined error propagation.
- Handle errors **at their source** while ensuring critical issues propagate back to `main()`.
- Implement structured **resource cleanup** on all exit paths.
- Ensure **functions are listed in reverse dependency order** to prevent forward references.
- Organize sections in a consistent manner for maintainability.

### Core Execution Pattern

A well-structured script typically follows this execution flow:

1. **Script Header**
   - Metadata, license, author, and usage instructions.
2. **Environment Setup**
   - Initialize environment variables and dependencies.
   - Declare constants, script-scoped variables, utility functions, and core functions.
3. **Main Function (`main()`) Purpose**
   - The `main()` function serves as the script's entry point and controls execution flow.
   - It calls `core_Logic()` to orchestrate the script’s primary workflow.
   - `main()` should **not** contain detailed logic or inline processing; instead, it should delegate tasks to well-defined functions.
   - `main()` should capture and handle return codes from `core_Logic()` to determine the final exit status.
4. **Script Execution**
   - Ensuring the script runs only if executed directly (`[[ "${(%):-%N}" == "$0" ]]`).
   - Establish the script entry point, which calls `main()`.
5. **CLI Argument Processing**
   - In **Snippets**, handled by `main()` in the simplest scripts, or by `parse_Arguments()`.
   - In **Framework-based scripts**, argument processing begins with the standardized `z_parse_Initial_Arguments()` function, followed by the script-specific `parse_Remaining_Arguments()` and various `handle_*` functions. This process ensures a well-defined execution environment, validates inputs, sets up logging, determines runtime modes, applies default configurations, and integrates structured error handling.
6. **Dependency and Input Validation**
   - Verify required binaries, permissions, and runtime dependencies.
   - Validate function input parameters early to prevent cascading failures.
7. **Core Logic Execution (`core_Logic()`)**
   - `core_Logic()` is the **orchestrator**, responsible for sequencing, workflow control, and delegation to specialized helper functions.
   - It should ensure **proper error handling**, propagate failures, and maintain structured execution.
   - Errors encountered within `core_Logic()` should propagate back to `main()` for centralized handling.
8. **Cleanup and Resource Management**
   - Ensure proper cleanup of temporary files, background processes, and acquired resources.
   - Implement structured teardown routines for safe script termination.
   - Errors or success codes must propagate back to `main()` to determine the final exit status of the script.

## Zsh Core Scripting - Execution Flow and Structure

### Function Design Guidelines

- Each function should have a **single, well-defined purpose**.
- Minimize side effects and **avoid modifying global state**.
- Return meaningful status codes rather than relying on implicit behavior.
- Explicitly pass parameters instead of depending on global variables.
- Consistently **handle and propagate errors**, ensuring failures do not cause silent script termination.
- **Avoid circular dependencies** by carefully analyzing function relationships.
- **When adding new functions**, analyze their dependencies and place them in the correct order.
- **Test function ordering** during development by checking for undefined function errors.

### Function Ordering Requirements

- **Dependency-Based Ordering (Required):** Functions must be ordered from least dependent to most dependent. This means:
  - A function must be defined before any function that calls it
  - Base functions with no dependencies on other script functions come first
  - Functions that depend on those base functions come next
  - Higher-level functions that call multiple lower-level functions come after
  - The `main()` function typically comes last as it calls many other functions

- **Resolving Same-Level Dependencies (Required):** When multiple functions have the same dependency level:
  - Order them by reverse execution sequence (functions called earlier in the script's flow appear later in the definition)
  - Consider execution paths through different script options and arguments
  - Document the rationale for the chosen order in section comments

- **Section Organization (Required):**
  - Group related functions within marked sections
  - Within each section, maintain the dependency-based ordering principle
  - Document dependencies between sections in section headers
  - The general order of sections should follow: utilities → domain-specific → orchestration → control

- **Documentation for Function Dependencies (Required):**
  - Each function's documentation block must list all script functions it depends on
  - Section headers must document dependencies on other sections

### Function Ordering Example

```zsh
# Level 1: Base utility with no dependencies on other script functions
function format_output() {
   # Implementation with no calls to other script functions
}

# Level 1: Another base utility (same dependency level as format_output)
function validate_input() {
   # Implementation with no calls to other script functions
}

# Level 2: Function that depends on validate_input
function process_data() {
   # First validates input, then processes
   validate_input "$1" || return $?
   # Processing logic
}

# Level 3: Function that depends on both format_output and process_data
function main() {
   # Setup
   process_data "$input" || {
      format_output "error" "Processing failed"
      return 1
   }
   format_output "success" "Processing complete"
}
```

### Script Execution Control

- Scripts should support both **direct execution and sourcing**.
- Provide mechanisms to **prevent recursive execution** when applicable.
- Support different runtime modes (interactive, non-interactive, batch processing).

By following this structured approach, script readability and maintainability are significantly improved, reducing the risk of unintended side effects and making future modifications easier.

## Zsh Core Scripting - Error Handling Requirements

### Error Handling Principles

Robust error handling is fundamental to creating reliable Zsh scripts. The core principles ensure consistent, transparent, and informative error management:

- **Localized Error Detection:** Identify and handle errors at their source
- **Controlled Error Propagation:** 
  - Functions return error status codes instead of calling `exit` directly
  - Only the main entry point (`main()`) should terminate the script
- **Contextual Error Reporting:**
  - Print error messages at the point of failure
  - Include relevant state information
  - Use descriptive variable names
- **Clear Error Paths:**
  - Distinguish between normal and error execution paths
  - Handle all potential error scenarios explicitly

### Error Handling Implementation Approaches

Different script types implement these error handling principles according to their complexity:

- **Snippet Scripts** typically use direct stderr redirection (`print -u2`) for error messages
- **Framework Scripts** employ dedicated error handling functions (e.g., `z_Print error` or `z_Output error`) that handle formatting and redirection consistently

See the specific implementation details in the respective requirements documents and template examples.

```markdown
### Error Handling and Propagation

- **Local Error Handling:** Detect and resolve errors at their origin when possible to prevent unnecessary failure propagation.
- **Critical Error Escalation:** Ensure non-recoverable issues escalate to `main()` with meaningful exit codes.
- **Consistent Exit Codes:**  
  - Use `$Exit_Status_Success` (which is defined as `0`) to indicate success.
  - Use non-zero codes to specify different error types.
- **Actionable Error Messages:** Provide concise, informative failure descriptions.
- **Guaranteed Cleanup:** Execute cleanup routines regardless of script outcome.

#### **Grouping Commands for Localized Error Handling**
To ensure predictable error handling within grouped operations, use `{}` blocks to contain failures while preventing unintended side effects:

- **Use `{}` blocks to encapsulate related commands**, ensuring they execute in a controlled scope:
```zsh
{
    setopt localoptions KSH_TYPESET
    git fetch origin
    git merge origin/main
} || {
    print -u2 "Error: Failed to update repository"
    return $Exit_Status_Git_Failure
}
```
  - If any command within the block fails, execution moves to the `||` handler.

- **Use `&&` for sequential execution** when each step must succeed before proceeding:
```zsh
{
    validate_Input "$filePath" && process_File "$filePath" && archive_File "$filePath"
} || {
    print -u2 "Error: One or more steps in file processing failed"
    return $Exit_Status_Process_Failure
}
```
  - If `validate_Input` fails, `process_File` and `archive_File` will not execute.

- **Use `return` inside blocks instead of `exit`** to prevent premature script termination:
```zsh
{
    cd "$repoPath" || return $Exit_Status_Invalid_Path
    git pull || return $Exit_Status_Git_Failure
}
  ```

- **Group cleanup tasks in `{}` blocks** to ensure consistent resource deallocation:
```zsh
{
    rm -f "$tempFile"
    rm -rf "$tempDir"
} || {
    print -u2 "Warning: Failed to remove temporary files"
}
```

By applying `{}` blocks in these scenarios, scripts can maintain **localized error handling**, ensuring that failures do not cascade unexpectedly while improving maintainability and debugging clarity.

### Error Context Preservation

Effective error context preservation becomes increasingly critical as script complexity grows. Key strategies include:

- Capture and retain relevant state information at the point of failure
- Use explicit, descriptive variable names that convey error context
- Avoid passing raw error messages up the call chain
- Return early from functions with clear, specific error indicators
- Ensure each error path is handled with appropriate granularity

### Exit Code Standards
```zsh
# Exit Status Codes
typeset -r Exit_Status_Success=0            # Successful execution
typeset -r Exit_Status_General=1            # General error (unspecified)
typeset -r Exit_Status_Usage=2              # Invalid usage or arguments (e.g., missing required script argument)
typeset -r Exit_Status_IO=3                 # Input/output error (e.g., missing or unreadable file)
typeset -r Exit_Status_Git_Failure=5        # Local Git repository functional error (e.g., not a Git repo)
typeset -r Exit_Status_Config=6             # Missing configuration or non-executable dependency (e.g., missing `git`)
typeset -r Exit_Status_Dependency=127       # Missing executable (e.g., gh CLI not found)
```

Standardized exit codes are essential for script interoperability and automated testing. They provide a consistent interface for understanding script failure modes.

### Exit Code Usage Guidelines
- Use most specific error code available
- Exit codes must be checked in logical order:
  1. Usage errors (invalid parameters) -- `exit $Exit_Status_Usage`
  2. Dependencies (missing commands) -- `exit $Exit_Status_Dependency`
  3. IO errors (file access) -- `exit $Exit_Status_IO`
  4. General errors (when no other code fits) -- `exit $Exit_Status_General`

### Specific Error Handling Examples

For detailed, practical examples of error handling implementation, refer to the "Error Handling" sections in the Zsh Snippet Scripting (at `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md`) or Zsh Framework Scripting requirements (at `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md`). These sections provide concrete code demonstrations of applying these core error handling principles in different script contexts.

## Zsh Core Scripting - Parameter Handling

### Core Parameter Principles
- Functions should receive explicit parameters
- Avoid relying on global/script-scoped variables
- Return values via `print` for capture
- Use command substitution to capture returns
- Check exit status when capturing output
- Store command output in descriptively named variables
- Don't mix output capture and condition testing
- Avoid rerunning commands for error messages

These principles apply to all scripts, though the specific implementation patterns will vary based on script complexity.

### Parameter Validation Requirements
- Validate parameters as early as possible
- Use default values explicitly
- Check dependencies between parameters
- Check for mutually exclusive options
- Verify all required parameters are present
- Validate environment requirements early

Parameter validation becomes increasingly important as script complexity grows. More complex scripts may use more sophisticated validation patterns, but these core principles remain applicable.

### Parameter Handling Examples

#### Default Parameter Assignment
```zsh
# Provide sensible defaults using parameter expansion
typeset InputPath="${1:-$PWD}"     # Default to current directory
typeset Algorithm="${2:-sha256}"   # Default to sha256
```

#### Function Parameter Example (Good)
```zsh
process_File() {
    typeset filePath="$1"  # Accept file path as parameter
    if [[ ! -f "$filePath" ]]; then
        print -u2 "Error: File '$filePath' not found."
        return $Exit_Status_IO
    fi
    print "The file '$filePath' has $(wc -l < "$filePath") lines."
}
```

#### Anti-Pattern: External State Dependency (Bad)
```zsh
process_File() {
    if [[ ! -f "$File_Path" ]]; then  # ❌ BAD: Uses script-scoped variable or global
        print -u2 "Error: File '$Global_File_Path' not found."
        return $Exit_Status_IO
    fi
    print "The file '$Global_File_Path' has $(wc -l < "$File_Path") lines."
}
```

### Parameter Validation Examples
```zsh
# Required parameter checking
[[ -z "$InputPath" ]] && {
    print -u2 "Error: Input path is required"
    return $Exit_Status_Usage
}

# Validation with default assignment
typeset OptionValue="${1:-$DEFAULT}"
validate_Option_Value "$OptionValue" || return $?

# Mutually exclusive options
[[ -n "$OptA" && -n "$OptB" ]] && {
    print -u2 "Error: Cannot use --opt-a and --opt-b together"
    return $Exit_Status_Usage
}

# Environment validation
command -v openssl >/dev/null || {
    print -u2 "Error: Required command 'openssl' not found"
    return $Exit_Status_Dependency
}

# Range checking example
(( InputValue >= MIN && InputValue <= MAX )) || {
    print -u2 "Error: Value $InputValue outside range $MIN-$MAX"
    return $Exit_Status_Usage
}
```

## Zsh Core Scripting - Using Zsh Features Effectively

### Native Zsh Capabilities
- **Prefer Zsh Native Capabilities**
  - Use `print` over `echo` or `printf` for output (better compatibility and escape handling)
  - Use parameter expansion (`${var:A}`) over `readlink` for path resolution
  - Use `[[ ... ]]` over `[ ... ]` or `test` for conditions
  - Use `${(f)var}` over `while read` for line splitting
  - Use `${var##*/}` over `basename` for path manipulation
  - Use native modifiers (`:h`, `:t`, `:r`, `:e`) over `dirname`/`basename` for path components
  - Use `${(@f)command_output}` to split command output into an array by newlines
  - Use `${(j:\n:)array}` to join array elements with newlines

### Array and Associative Array Handling

#### Array Declaration and Access
- **Declare arrays explicitly**:
```zsh
typeset -a SimpleArray          # Regular indexed array
typeset -A AssociativeArray     # Key-value associative array
```

- **Initialize arrays properly**:
```zsh
SimpleArray=("item1" "item2" "item3")
AssociativeArray=(
  "key1" "value1"
  "key2" "value2"
)
```

- **Access arrays without quotes around keys**:
```zsh
# CORRECT - Without quotes
value="${SimpleArray[1]}"           # Access by index
value="${AssociativeArray[keyname]}" # Access by key

# INCORRECT - Quotes around keys can cause issues
value="${AssociativeArray["keyname"]}"
```

- **Iterate arrays safely**:
```zsh
# Always use typeset for loop variables
typeset item
for item in $SimpleArray; do
  # ...process the item
done

typeset key
for key in ${(k)AssociativeArray}; do
  typeset value="${AssociativeArray[$key]}"
  # ...process the key-value pair
done
```

- **Use parameter expansion flags for array operations**:
```zsh
# Join array elements with a separator
joined_string="${(j:,:)SimpleArray}"  # Joins with commas

# Split a string into an array
typeset -a words
words=(${(s: :)some_string})         # Splits on spaces

# Get array keys
keys=(${(k)AssociativeArray})

# Get array values
values=(${(v)AssociativeArray})
```

#### Scope Considerations

- **Arrays in functions**: When modifying array elements in functions, be explicit about scope:
```zsh
# CORRECT - Explicitly modify the array element
functionName() {
  # Properly scoped modification
  MyArray[index]="new value"      # Modify element directly
}

# AVOID - Returning and reassigning array
functionName() {
  typeset -a localArray=("$@")
  # ...modify localArray
  print -r -- "${localArray[@]}"   # Must be captured and parsed by caller
}
```

- **Always scope loop variables**:
```zsh
# CORRECT
typeset key
for key in ${(k)AssociativeArray}; do
  # ...
done

# INCORRECT - Can create global variables
for key in ${(k)AssociativeArray}; do
  # key might become global
done
```

### Pattern Matching and Command Substitution

- **Use `=~` for regex pattern matching with explicit array handling**:
```zsh
typeset -a match mbegin mend  # Special arrays for regex captures

if [[ "$string" =~ '^([a-z]+)=(.*)$' ]]; then
  key="${match[1]}"      # First capture group
  value="${match[2]}"    # Second capture group
fi
```

- **Handle command substitution safely**:
```zsh
# Capture output with proper quoting
result="$(some_command)"

# Capture multi-line output into an array
typeset -a lines
lines=("${(@f)$(some_command)}")
```

- **Process output with parameter expansion**:
```zsh
# Remove trailing newlines
content="${$(< filename)%$'\n'}"

# Split and rejoin output (useful for formatting)
typeset -a lines
lines=("${(@f)$(command)}")
formatted="${(j:\n  :)lines}"  # Join with newline+indent
```

### Safe `eval` usage for Associative Arrays

While `eval` should be used with caution, it can be necessary for dynamically accessing or modifying associative arrays when variable names are stored indirectly. Follow these guidelines to ensure safety:

- **Use `typeset -A` to define associative arrays explicitly** before using `eval`:
```zsh
typeset -A commitData
commitData[abc123]="Signed"
```

- **Use `eval` only when necessary**, and always sanitize input:
```zsh
eval "signatureStatus=\${commitData[$commitHash]:-Unsigned}"
```

- **Avoid unnecessary `eval` by leveraging namerefs (`typeset -n`)** where possible:
```zsh
typeset -n commitRef="commitData[$commitHash]"
print "Commit Status: $commitRef"
```

- **Use `print -r --` to safely output evaluated values without unintended expansion**:
```zsh
eval "print -r -- \"Commit: ${commitData[$commitHash]}\""
```

### Debugging Array Values

When working with arrays, especially associative arrays, include debugging techniques to verify content:

```zsh
# Debug function for associative arrays
function debug_AssociativeArray() {
  typeset arrayName="$1"
  typeset key
  
  print "=== Contents of $arrayName ==="
  for key in ${(k)${(P)arrayName}}; do
    print "  $key = ${${(P)arrayName}[$key]}"
  done
  print "=== End of $arrayName ==="
}

# Usage
debug_AssociativeArray "MyAssociativeArray"
```

These Zsh-specific features and techniques enable more efficient and robust scripting, leveraging the full power of Zsh while avoiding common pitfalls.

## Zsh Core Scripting - CLI Output

### Structured CLI Output Formatting

Consistently formatted CLI output improves readability, usability, and script interoperability. While `print` is generally preferred over `echo` or `printf` due to better escape handling and compatibility, `printf` is still useful for structured output where precise formatting is required, in particular for tables and reports.

This section provides best practices for producing structured, human-readable output, ensuring alignment, truncation, and proper handling of variable-length fields.

- **Use `print --` to safely output values without unintended expansion**:
```zsh
print -- "$variableContainingUserInput"
```
- **Use `printf` instead of `echo` or `print`** for structured output control:
```zsh
printf "%-10s %-15s\n" "Column1" "Column2"
printf "%-10s %-15s\n" "Value1" "Value2"
```
- **Ensure consistent column widths** for human-readable CLI output.
- **Document field widths in comments** when output formatting is critical:
```zsh
# %-7s  - Commit hash (left aligned, 7 chars)
# %-8s  - Status (left aligned, 8 chars)
printf "%-7s %-8s %-20s\n" "$commitHash" "$status" "$email"
```
- **Truncate fields explicitly** to avoid misalignment due to variable-length data:
```zsh
typeset -L10 shortCommitHash="$commitHash"  # Ensure commit hash is exactly 10 characters
printf "%-10s %-20s\n" "$shortCommitHash" "$authorName"
```
- **Use tab or space separation for machine-readable output when needed:**
```zsh
printf "%s\t%s\t%s\n" "$commitHash" "$status" "$authorName"
```

## Zsh Core Scripting - Documentation Requirements

### Documentation Principles
- Documentation should be proportional to script complexity
- Function documentation should clearly state purpose, parameters, and return values
- Script documentation should include usage, examples, and any security considerations
- Comments should explain *why*, not just *what* the code does
- Maintain consistent documentation formats across all scripts

Documentation requirements scale with script complexity:

- **Snippet Scripts** require minimal but comprehensive header blocks and function documentation (see `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md` for details)
- **Framework Scripts** require more extensive documentation including header blocks, function documentation, and section comment blocks (see upcoming `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` and examples in `z_min_frame.sh` and `z_frame.sh`)

While the core principles remain the same, the implementation becomes more comprehensive as script complexity increases.

The specifics of documentation implementation will vary between snippet and framework scripts, but these core principles apply universally.

## Zsh Core Scripting - System Requirements

### Dependency Checks
- Any non-standard dependencies, especially those not included in recent macOS or Debian Linux distributions, must be explicitly checked for and validated.
- Some utilities behave differently between macOS and Linux. Ensure that commands used in the script exist and function as expected across platforms.
- Special attention should be given to macOS-specific external utilities (awk, sed, etc.), as they may differ from their GNU counterparts; scripts must account for these differences to ensure cross-platform compatibility.
- If the script depends on external commands, check for their existence using `command -v <cmd>` before execution.
- Exit with `127` (`$Exit_Status_Dependency`) if a required command is missing.

## Zsh Core Scripting - Testing & Debugging

### Core Testing Principles

### Fundamental Test Requirements
- Verify script syntax
- Test core function behavior
- Validate error handling
- Check parameter processing
- Ensure exit code accuracy

### Basic Test Validation
- Confirm script runs without syntax errors
- Test each function's primary workflow
- Check error condition handling
- Check input parameter processing
- Verify exit codes match expected outcomes
- Create a regression test procedure or script for all CLI options

### Syntax & Execution Testing
- Some external commands (in particular `git`) sometimes return empty lines. Use Zsh-native string handling to remove any unexpected empty lines:
  ```zsh
  # Remove empty lines from git output using Zsh-native parameter expansion
  commitList=("${(@f)$(git log --format="%H")}")  # Read output into an array, splitting on newlines
  
  # Print non-empty commit hashes
  for commit in "${commitList[@]}"; do
      [[ -n "$commit" ]] && print "$commit"
  done
  ```
- Ensure that the entire script does not contain Windows-style line endings (`\r`), which may cause execution issues.
- Check for syntax errors before execution:
```zsh
zsh -n script.sh  # Syntax check
```
- Debug execution step by step:
```zsh
zsh -x script.sh  # Debug execution
```

### Block Redirections and Output Containment
- **Use `{}` blocks to encapsulate command sequences**, ensuring related commands execute within a controlled scope and preventing unintended side effects:
```zsh
{
    setopt localoptions KSH_TYPESET
    git fetch origin
    git merge origin/main
} || {
    print -u2 "Error: Failed to update repository"
    return 1
}
```
- **Redirect command output explicitly** to avoid unintentional leakage:
```zsh
{
    some_command >output.log 2>&1
} || print -u2 "Error: Command execution failed"
```
- **Suppress unwanted output when necessary** to avoid cluttering logs:
```zsh
some_command >/dev/null 2>&1
```

### Debugging Tools and Structured Trace Mode
- **Use `typeset -p` to inspect variable values and structures**:
```zsh
typeset -p variableName
```
  This prints the current state of a variable, including its type and scope.
- **Enable structured debugging output using `setopt XTRACE`**:
```zsh
setopt XTRACE  # Enable debugging mode
```
  This prints each command before execution, making it easier to trace script behavior.
- **Use conditional tracing to debug specific sections without overwhelming output**:
```zsh
if [[ "$Output_Debug_Mode" == $TRUE && "$Output_Verbose_Mode" == $TRUE ]]; then
    setopt XTRACE
    # Debugging code here
    unsetopt XTRACE  # Disable debugging after execution
fi
```
- **Redirect trace output to a log file** to prevent cluttering standard output:
```zsh
exec 2>debug.log
setopt XTRACE
```
This ensures all debug output is captured for later analysis.

### Testing for Conflicts and Issues
- During testing, check for conflicts with built-ins and plugins using `typeset -f`.
- Verify that custom functions do not override existing shell built-ins or commands.
- Use project-specific prefixes to avoid naming collisions (e.g., `oi_` for Open Integrity, `z_` for shared Zsh utilities).
- Check for unintended variable scope conflicts by verifying global versus local declarations with `typeset -p`.

## Example Implementation Files

The project includes several example files that demonstrate the application of these requirements across different script complexity levels:

### Snippet Examples
- `snippet_template.sh` - A basic template for small, focused utility scripts
- `get_repo_did.sh` - A fully functional example of a Zsh Snippet script

### Framework Examples (In Development)
- `z_min_frame.sh` - A minimal framework template with essential structure and error handling
- `z_frame.sh` - A comprehensive framework template with advanced features

These templates share common utility functions (particularly the versatile `z_Output` function) and demonstrate how the core principles scale from simple to complex implementations.

## Conclusion
These core requirements establish the foundation for Zsh scripting within the project. They focus on universal principles that apply regardless of script size or complexity. They ensure that all scripts, from simple snippets to complex frameworks, maintain a consistent level of quality, security, and maintainability.

For specific implementation guidance, refer to:
- `REQUIREMENTS-Zsh_Snippet_Scripting_Best_Practices.md` for small, single-purpose scripts
- `REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` for complex, multi-component frameworks

By following these core principles and the relevant specific requirements, you can create robust, maintainable, and secure Zsh scripts that adhere to project standards.
