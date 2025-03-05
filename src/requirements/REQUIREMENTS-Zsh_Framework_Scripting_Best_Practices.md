# Zsh Framework Scripting Requirements and Best Practices
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md`_
> - _github: [`core/src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com> Github/Twitter/Bluesky: @ChristopherA_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## Code Version and Source

This requirements document applies to the the initial Open Integrity Project's **Proof-of-Concept** scripts, versioned **0.1.\***, which are available at the following source:

> **Origin:** [_github: `https://github.com/OpenIntegrityProject/scripts/`_](https://github.com/OpenIntegrityProject/scripts/)

Any updates or modifications to these scripts should reference this requirements document to ensure consistency with the outlined requirements.

## Introduction

Zsh Framework scripts are comprehensive, structured scripts designed for complex operations requiring robust architecture, extensive error handling, and sophisticated workflows. Framework scripts differ from Snippet scripts in scope, complexity, and architectural design, providing a foundation for building sophisticated tools while maintaining reliability and maintainability.

These requirements build upon the core principles defined in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`, which establishes the fundamental baseline for all Zsh scripts. Framework scripts implement these core principles with greater depth and sophistication, accommodating larger codebases and more complex operations.

While Snippet scripts focus on single-purpose utilities under 200 lines, Framework scripts support:
- Multi-phase operations with interdependent components
- Comprehensive error handling and recovery
- Layered architectural design
- Sophisticated user interfaces with multiple output modes
- Complex state management and workflow orchestration

The requirements outlined in this document provide guidance for creating, maintaining, and extending Framework scripts that balance robustness with maintainability.

## Zsh Framework Scripting - General Principles

### Framework-Specific Design Principles
- **Layered Architecture**: Organize code into distinct architectural layers with clear responsibilities and dependencies.
- **Separation of Concerns**: Maintain clear boundaries between framework infrastructure, domain logic, and orchestration.
- **Progressive Enhancement**: Support basic functionality with minimal dependencies while enabling advanced features when available.
- **Controlled State Management**: Implement explicit state tracking with validation and consistent access patterns.
- **Graceful Degradation**: Provide fallbacks for missing dependencies or capabilities.
- **Comprehensive Testing**: Include thorough test coverage for complex interactions and edge cases.

### Architectural Layers
Framework scripts should implement a layered architecture with clear separation between:

1. **Foundation Layer**: Environment setup, constants, initial variables, and terminal configuration
2. **Utility Layer**: Reusable functions for common operations independent of domain logic
3. **Domain Layer**: Domain-specific implementation of core functionality
4. **Orchestration Layer**: Workflow sequencing, phase management, and process coordination
5. **Controller Layer**: Entry points, initialization, cleanup, and high-level error handling

Each layer should have well-defined responsibilities and dependencies, with higher layers depending on lower layers but not vice versa.

## Zsh Framework Scripting - Safety and Predictability

Framework scripts must implement the safety principles from the Zsh Core Requirements document with additional safeguards for complex operations:

- **Use all required options from Core Requirements**:
  ```zsh
  emulate -LR zsh
  setopt errexit nounset pipefail localoptions warncreateglobal
  ```

- **Additional recommended safety options for Framework scripts**:
  ```zsh
  setopt noclobber          # Prevent accidental file overwrites
  setopt no_unset           # Treat undefined parameters as errors
  setopt no_nomatch         # Prevent glob pattern failures
  setopt no_list_ambiguous  # Disable ambiguous completion
  ```

- **Implement robust signal handling**:
  - Register traps for at least INT, TERM, and EXIT signals
  - Ensure cleanup routines run on all exit paths
  - Handle interrupted operations gracefully

- **Resource tracking and cleanup**:
  - Track created resources (files, directories, processes) explicitly
  - Implement comprehensive cleanup functions
  - Use EXIT traps to ensure cleanup runs even on errors

## Zsh Framework Scripting - Script Structure and Organization

### Required Section Organization
Framework scripts must be organized into clearly defined sections with comprehensive documentation:

1. **Header**: Detailed script information (name, version, description, etc.)
2. **Change Log**: Version history with dated entries 
3. **Foundation Layer**: Environment setup, constants, and initial variables
4. **Utility Layer**: Framework-level utility functions
5. **Domain Layer**: Domain-specific functionality
6. **Orchestration Layer**: Workflow control and parameter processing
7. **Controller Layer**: Entry point and high-level orchestration
8. **Execution Gateway**: Script execution control

Each section must include a section header block with:
- Clear title and description
- Purpose and responsibilities
- Dependencies and relationships to other sections
- Architectural role in the overall script

## Framework Script Execution Flow

The standard execution flow for framework scripts follows a structured pattern with two-stage argument processing and dedicated handler functions:

```
Script Invocation
├── Environment Initialization
│   └── Constants, variables, and options setup
│
├── Execution Gateway Check
│   └── Direct execution check (${(%):-%N} == $0)
│       ├── Signal trap setup
│       ├── main() execution
│       └── Exit with propagated status
│
└── main()
    ├── Environment validation (z_Setup_Environment)
    │   └── Check dependencies, requirements, and environment
    │
    ├── Two-Phase Argument Processing:
    │   ├── Phase 1: z_Parse_Initial_Arguments
    │   │   ├── Process framework arguments (--verbose, --debug, etc.)
    │   │   └── Set global execution flags
    │   │
    │   └── Phase 2: parse_Remaining_Arguments
    │       ├── Process domain-specific arguments
    │       ├── Call handle_* functions for complex arguments
    │       │   ├── handle_Change_Directory for -C/--chdir
    │       │   ├── handle_Process_Config for config options
    │       │   └── Other specialized handlers as needed
    │       └── Validate argument combinations
    │
    └── core_Logic()
        ├── High-level workflow orchestration
        │   ├── Phase initialization and sequencing
        │   ├── Workflow state management
        │   └── Result collection and processing
        │
        ├── execute_*_Phases()
        │   ├── Phase-specific orchestration
        │   ├── State tracking across operations
        │   └── Domain function coordination
        │
        └── Domain Functions
            ├── oi_* functions (Open Integrity specific)
            │   ├── Focused, single-responsibility implementations
            │   ├── Domain-specific business logic
            │   └── Domain state management
            │
            └── z_* functions (Zsh Utility library)
                ├── Output and error reporting (z_Output, z_Report_Error)
                ├── Path and resource management
                ├── Environment and dependency handling
                └── Common utility operations
```

### Error Propagation Flow

In Framework scripts, errors are handled in a structured manner with proper propagation through the call stack:

```
Domain Function Error
├── Error Detection at Source
│   ├── Input validation failure
│   ├── Operation failure
│   └── Environment condition failure
│
├── Local Error Handling
│   ├── Context enrichment
│   │   └── Add domain-specific details to error
│   ├── Error logging via z_Report_Error
│   └── Return appropriate exit status
│
├── Orchestration Layer Handling
│   ├── Detect error via return code
│   │   └── if ! domain_function; then...
│   ├── Add workflow context to error
│   ├── Decide error severity
│   │   ├── Continue with degraded functionality
│   │   └── OR abort current phase
│   └── Return error status to controller
│
├── Controller Layer (core_Logic)
│   ├── Phase failure detection
│   ├── Error aggregation
│   ├── Result generation with error context
│   └── Return error status to main()
│
└── Entry Point (main)
    ├── Final error handling
    ├── Cleanup operations via trap
    └── Exit with appropriate status code
```

This error flow ensures errors are detected as close to their source as possible, properly contextualized as they propagate up the call stack, and appropriately handled at each level, with the final error status returned to the calling environment.

### Two-Phase Argument Processing

Framework scripts must implement a two-phase argument processing approach:

1. **Framework Argument Phase**:
   - Process framework-level arguments first (verbose, debug, etc.)
   - Must use a dedicated function such as `z_Parse_Initial_Arguments`
   - Sets global execution flags that affect script behavior

2. **Domain Argument Phase**:
   - Process domain-specific arguments after framework setup
   - Must use a separate function such as `parse_Remaining_Arguments`
   - Applies domain logic to specialized parameters

### Controller Function Responsibilities

Framework scripts must clearly delineate responsibilities between controller functions:

- **main()**: Script entry point that:
  - Sets up signal handlers and traps
  - Initializes the environment
  - Processes command-line arguments (via two-phase approach)
  - Delegates to `core_Logic` for main workflow
  - Ensures proper cleanup and exit status propagation
  - Must be the only function that directly exits the script

- **core_Logic()**: Main workflow orchestrator that:
  - Manages the execution sequence
  - Coordinates phase transitions
  - Controls workflow branching
  - Presents results and summaries
  - Returns status codes rather than exiting directly

- **execute_*_Phases()**: Phase-specific orchestrators that:
  - Manage the execution of domain-specific functions
  - Track phase completion and status
  - Report phase-specific results
  - Return appropriate status codes

### Phase-Based Execution
Organize complex operations into distinct phases:

1. **Phase Definition**:
   - Clear entry and exit criteria
   - Well-defined dependencies between phases
   - Explicit success/failure conditions

2. **Phase Management**:
   - Dedicated orchestration functions for each phase
   - State tracking across phase boundaries
   - Skip or conditional execution logic

## Zsh Framework Scripting - Naming and Documentation Requirements

Follow the "Naming and Documentation Requirements" in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`, with these additional framework-specific conventions:

### Function Naming Conventions

- **Framework Infrastructure**:
  - Prefix with `z_` (for general Zsh utilities)
  - Examples: `z_Output`, `z_Parse_Initial_Arguments`, `z_Setup_Environment`

- **Domain-Specific Functions**:
  - Prefix with domain identifier (e.g., `oi_` for Open Integrity)
  - Examples: `oi_Verify_Commit_Signature`, `oi_Locate_Inception_Commit`

- **Orchestration Functions**:
  - No prefix for workflow orchestration
  - Examples: `execute_Audit_Phases`, `process_Repository_Structure`

- **Handler Functions**:
  - Prefix with `handle_` for dedicated argument handlers
  - Examples: `handle_Change_Directory`, `handle_Process_Config`

- **Controller Functions**:
  - Standardized names without prefix
  - Examples: `main`, `core_Logic`

### Comprehensive Function Documentation

Function documentation blocks must be more comprehensive for Framework scripts, including:

```zsh
#----------------------------------------------------------------------#
# Function: function_Name
#----------------------------------------------------------------------#
# Description:
#   Detailed explanation of the function's purpose and operation.
#   For complex functions, include algorithm overview and key behaviors.
#
# Parameters:
#   $1 - Parameter description with type and constraints
#   $2 - Parameter description with type and constraints
#   [...additional parameters as needed]
#
# Returns:
#   Exit_Status_Success (0) when successful with detailed condition
#   Exit_Status_Code (N) under specific failure conditions
#   [Additional return cases as needed]
#
# Required Script Variables:
#   Script_Variable_1 - How the variable is used or modified
#   Script_Variable_2 - How the variable is used or modified
#
# Side Effects:
#   - Any global state changes
#   - File system operations
#   - Environment modifications
#
# Dependencies:
#   - External commands or libraries
#   - Other functions called by this function
#
# Usage Example:
#   function_Name "parameter1" "parameter2"
#   if ! function_Name "parameter1"; then
#     handle_error
#   fi
#----------------------------------------------------------------------#
```

### Script Header Documentation

The script header must be even more detailed for Framework scripts, including:
- Complete script description with version, author, license
- Detailed feature list and significant limitations
- Security considerations and implementation notes
- Visual ASCII dividers for clear section separation

Example:
```zsh
########################################################################
##                         SCRIPT INFO
########################################################################
## script_name.sh
## - Comprehensive description of script purpose and functionality
##
## VERSION:      1.0.0 (YYYY-MM-DD)
##
## DESCRIPTION:
##   Detailed explanation of what the script does, its approach, and
##   key capabilities. This should be multiple paragraphs for complex
##   Framework scripts.
##
## DESIGN PHILOSOPHY:
##   - Key architectural principle 1
##   - Key architectural principle 2
##   - Additional principles as needed
##
## FEATURES:
##   - Major feature category 1:
##     * Specific capability 1
##     * Specific capability 2
##   - Major feature category 2:
##     * Specific capability 1
##     * Specific capability 2
##
## LIMITATIONS:
##   - Current limitation 1
##   - Current limitation 2
##
## SECURITY CONSIDERATIONS:
##   - Security aspect 1
##   - Security aspect 2
##
## USAGE: script_name.sh [options]
## 
## OPTIONS:
##   -o, --option          Description of option
##   -p, --param <value>   Description of parameterized option
##
## EXAMPLES:
##   # Example 1 description:
##   script_name.sh --option value
##
##   # Example 2 description:
##   script_name.sh --advanced-option
##
## REQUIREMENTS:
##   - Requirement 1 (version)
##   - Requirement 2 (version)
##
## LICENSE:
##   (c) YYYY By Organization
##   License details
########################################################################
```

## Zsh Framework Scripting - Error Handling Requirements

Framework scripts require more sophisticated error handling than Snippet scripts, following the principles in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` with these extensions:

### Layered Error Handling
Implement a layered approach to error handling that differentiates between:

1. **Low-Level Errors**: Detected and handled by utility functions
2. **Domain-Level Errors**: Specific to business logic failures
3. **Workflow-Level Errors**: Affecting process orchestration
4. **System-Level Errors**: External or environment failures

Each layer should handle errors appropriate to its scope and propagate others upward.

### Error Context Enrichment
Implement context enrichment as errors propagate upward:

```zsh
domain_Function() {
    if ! utility_Function "$param"; then
        # Add domain context to the error
        z_Report_Error "Domain operation failed: $param" $Exit_Status_Domain_Failure
        return $Exit_Status_Domain_Failure
    fi
}

orchestration_Function() {
    if ! domain_Function "$param"; then
        # Add workflow context to the error
        z_Report_Error "Workflow step failed: $operation" $Exit_Status_Workflow_Failure
        return $Exit_Status_Workflow_Failure
    fi
}
```

### Comprehensive Error Reporting
Implement a central error reporting function that:

- Provides consistent formatting
- Supports different severity levels
- Includes context information
- Optionally supports error codes
- Handles both user-facing and debug output

### Exit Code Hierarchy
Implement a hierarchical exit code structure:

```zsh
# Success codes
typeset -r Exit_Status_Success=0            # Operation successful

# General errors (1-9)
typeset -r Exit_Status_General=1            # General failure
typeset -r Exit_Status_Usage=2              # Command-line usage error
typeset -r Exit_Status_IO=3                 # Input/output error

# Domain-specific errors (10-19)
typeset -r Exit_Status_Domain_Failure=10    # Domain operation failed
typeset -r Exit_Status_Validation=11        # Validation error

# Workflow errors (20-29)
typeset -r Exit_Status_Workflow_Failure=20  # Workflow orchestration failed
typeset -r Exit_Status_Phase_Failure=21     # Specific phase failed

# System and environment errors (100+)
typeset -r Exit_Status_Dependency=127       # Missing dependency
```

## Zsh Framework Scripting - Parameter Handling

Framework scripts require more sophisticated parameter handling than the smaller Snippet scripts:

### Parameter Processing Patterns

1. **Two-Phase Argument Processing**: As described in the Script Structure section
2. **Dedicated Handler Functions**: Implement handler functions for complex parameters
3. **Parameter Validation Hierarchy**:
   - Basic syntax validation
   - Type checking
   - Range/constraint validation
   - Cross-parameter dependency validation
   - Domain-specific semantic validation

Example dedicated handler:
```zsh
function handle_Process_Config_Path() {
    typeset ConfigPath="$1"
    
    # Basic existence check
    if [[ -z "$ConfigPath" ]]; then
        z_Report_Error "Config path cannot be empty" $Exit_Status_Usage
        return $Exit_Status_Usage
    fi
    
    # Access validation
    if [[ ! -r "$ConfigPath" ]]; then
        z_Report_Error "Config path not readable: $ConfigPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi
    
    # Set the validated path in script state
    Config_Path="$ConfigPath"
    return $Exit_Status_Success
}
```

### Default Management
Implement a structured approach to defaults:

1. **Layered Default Resolution**:
   - Hardcoded script defaults (lowest priority)
   - Environment variables
   - Configuration files
   - Command-line parameters (highest priority)

2. **Default Documentation**:
   - Document all defaults in help text
   - Log applied defaults in verbose mode
   - Indicate source of each configuration value in debug output

## Zsh Framework Scripting - Using Zsh Features Effectively

Framework scripts should leverage Zsh's powerful features for more robust implementations:

### Advanced Array and Associative Array Usage
- Use associative arrays for complex state tracking
- Implement robust array handling for data manipulation
- Leverage parameter expansion flags for array operations

Example:
```zsh
# Associative array for state tracking
typeset -A Trust_Assessment_Status=(
    "structure" $FALSE
    "content" $FALSE
    "format" $FALSE
    "signature" $FALSE
    "identity" $FALSE
    "standards" $FALSE
)

# Parameter expansion for status checking
if (( ${Trust_Assessment_Status[structure]:-0} == TRUE && 
      ${Trust_Assessment_Status[content]:-0} == TRUE && 
      ${Trust_Assessment_Status[format]:-0} == TRUE )); then
    z_Output success "Wholeness phase passed"
fi
```

### Advanced Pattern Matching
- Use `=~` for regex pattern matching with explicit array handling
- Implement robust text parsing using Zsh pattern matching
- Handle complex string manipulations with parameter expansion

Example:
```zsh
# Regex pattern matching with capture groups
typeset -a match mbegin mend  # Special arrays for regex captures

if [[ "$string" =~ '^([a-z]+)=(.*)$' ]]; then
  key="${match[1]}"      # First capture group
  value="${match[2]}"    # Second capture group
fi

# Multi-line output processing
typeset -a OutputLines
OutputLines=("${(@f)$(command_output)}")  # Split by newlines into array
```

### Zsh-Specific Optimizations
- Use native Zsh path manipulation instead of external commands
- Leverage Zsh modifiers for efficient string manipulation
- Implement optimal globbing techniques for file operations

Example:
```zsh
# Path manipulation without external commands
typeset directory="${filepath:h}"  # Like dirname
typeset filename="${filepath:t}"   # Like basename
typeset extension="${filename:e}"  # Extract extension
typeset basename="${filename:r}"   # Remove extension

# Array joining with custom separator
joined_string="${(j:,:)array}"  # Join array with commas
```

## Zsh Framework Scripting - Output and User Interface

Framework scripts require sophisticated output handling beyond basic printing:

### Multi-Level Output System
Implement a comprehensive output system with:

1. **Multiple Output Modes**:
   - Standard (default)
   - Verbose (detailed progress)
   - Debug (troubleshooting)
   - Quiet (minimal/silent)

2. **Message Categories**:
   - Informational
   - Success
   - Warning
   - Error
   - Progress
   - Debug

3. **Formatting Controls**:
   - Color (with detection and fallbacks)
   - Indentation hierarchy
   - Emojis or symbols (with fallbacks)
   - Wrapping for long text

Example multi-level output function (abridged):
```zsh
function z_Output() {
    typeset MessageType="${1:-print}"
    shift
    
    # Output suppression logic based on verbosity settings
    case "$MessageType" in
        verbose)
            (( Output_Verbose_Mode != TRUE )) && return 0
            ;;
        debug)
            (( Output_Debug_Mode != TRUE )) && return 0
            ;;
        # Other message types...
    esac
    
    # Format and output the message with appropriate styling
    # ...
}
```

### Interactive vs Non-Interactive Modes
Support both interactive and non-interactive execution:

1. **Interaction Detection**:
   - Check for terminal capabilities
   - Respect environment variables (CI, NO_PROMPT)
   - Honor explicit flags (--no-prompt, --interactive)

2. **Fallback Mechanisms**:
   - Provide default values for prompts in non-interactive mode
   - Document all interactive decisions in help text
   - Ensure critical operations have non-interactive pathways

Example interaction handling:
```zsh
function get_User_Confirmation() {
    typeset Prompt="$1"
    typeset Default="${2:-N}"
    
    # Non-interactive mode: use default
    if (( Output_Prompt_Enabled != TRUE )); then
        z_Output debug "Non-interactive mode: using default '$Default' for prompt: $Prompt"
        [[ "$Default" =~ ^[Yy] ]] && return 0 || return 1
    fi
    
    # Interactive mode: prompt user
    typeset Response
    Response=$(z_Output prompt "$Prompt [y/N]:" Default="$Default")
    
    [[ "$Response" =~ ^[Yy] ]] && return 0 || return 1
}
```

### CLI Output Formatting
- Ensure consistent column widths for tabular data
- Document field widths in comments for maintainability
- Handle variable-length data gracefully
- Implement proper line wrapping for long text

## Zsh Framework Scripting - System Requirements

Framework scripts must implement comprehensive system requirements validation:

### Dependency Checking
- Validate all required external commands with version checks
- Provide clear, actionable guidance for missing dependencies
- Support optional dependencies with graceful degradation
- Check for platform-specific dependencies (macOS vs. Linux)

Example dependency checking:
```zsh
function check_External_Dependency() {
    typeset DependencyName="$1"
    typeset MinVersion="${2:-}"
    typeset Required="${3:-$TRUE}"
    
    # Check if dependency exists
    if ! command -v "$DependencyName" >/dev/null 2>&1; then
        if (( Required == TRUE )); then
            z_Output error "Required dependency not found: $DependencyName"
            z_Output error "Please install $DependencyName and try again"
            return $Exit_Status_Dependency
        else
            z_Output warn "Optional dependency not found: $DependencyName"
            z_Output warn "Some features may be unavailable"
            return $Exit_Status_Success
        fi
    fi
    
    # Version checking logic...
    return $Exit_Status_Success
}
```

### Environment Validation
- Verify Zsh version compatibility (minimum version 5.8)
- Check for required environment variables
- Validate filesystem access and permissions
- Detect terminal capabilities for output formatting

### Platform-Specific Adaptations
- Handle differences between macOS and Linux tools
- Implement platform detection with appropriate fallbacks
- Document platform-specific limitations or requirements
- Use portable command syntax where possible

## Zsh Framework Scripting - Testing and Debugging

Framework scripts must implement comprehensive testing and debugging capabilities:

### Debugging Features
- Implement verbose and debug output modes
- Provide explicit debugging functions for complex operations
- Support environment variable-based debug activation
- Include state dumps for troubleshooting

Example debugging function:
```zsh
function dump_Script_State() {
    [[ Output_Debug_Mode != TRUE ]] && return 0
    
    z_Output debug "=== Script State Dump ==="
    z_Output debug "Working Directory: $PWD"
    z_Output debug "Verbose Mode: $Output_Verbose_Mode"
    z_Output debug "Debug Mode: $Output_Debug_Mode"
    z_Output debug "Quiet Mode: $Output_Quiet_Mode"
    
    # Dump other relevant state
    z_Output debug "Trust Assessment Status:"
    for Phase in "${(@k)Trust_Assessment_Status}"; do
        z_Output debug "  $Phase: ${Trust_Assessment_Status[$Phase]}"
    done
}
```

### Regression Testing Requirements
Every Framework script must have a companion regression test script that adheres to `REQUIREMENTS-Regression_Test_Scripts.md`: *(Required)*

1. **Test Script Naming Convention**: *(Required)*
   - Use naming pattern: `TEST-[SCRIPT_NAME].sh`
   - Example: `TEST-audit_inception_commit-POC.sh` for `audit_inception_commit-POC.sh`

2. **Test Coverage Requirements**: *(Required)*
   - Test basic functionality with standard arguments
   - Test all command-line options and combinations
   - Include error condition testing
   - Verify all critical functionality paths

3. **Test Structure Requirements**: *(Required)*
   - Implement a dedicated test harness
   - Include setup and teardown procedures
   - Create isolated test environments
   - Provide clear test result reporting

4. **Test Output Requirements**: *(Required)*
   - Use standardized success/failure indicators
   - Include verbose mode for detailed diagnostics
   - Support non-interactive execution
   - Provide a test summary with pass/fail counts

Example test harness structure:
```zsh
function run_All_Tests() {
    typeset -a TestFunctions
    typeset -i TotalTests=0
    typeset -i PassedTests=0
    typeset -i FailedTests=0
    
    # Discover test functions
    TestFunctions=($(typeset +f | grep -E '^test_'))
    TotalTests=${#TestFunctions}
    
    print "Running $TotalTests tests..."
    
    # Execute each test
    for TestFunction in $TestFunctions; do
        print "\nTest: $TestFunction"
        if $TestFunction; then
            PassedTests=$((PassedTests + 1))
        else
            FailedTests=$((FailedTests + 1))
        fi
    done
    
    # Report results
    print "\n===== Test Results ====="
    print "Total: $TotalTests"
    print "Passed: $PassedTests"
    print "Failed: $FailedTests"
    
    (( FailedTests == 0 ))
}
```

### Test-Friendly Design Considerations
Framework scripts should be designed with testability in mind from the beginning. This improves reliability, maintainability, and integration capabilities.

#### Feature Flagging Variables
- Implement explicit feature detection flags:
  ```zsh
  typeset -i Feature_Available=$FALSE
  typeset -i External_Tool_Authenticated=$FALSE
  ```
- Set these flags early based on availability checks
- Use flags to control execution paths consistently
- Document flag meanings and default states

#### Exit Code Consistency
- Define clear exit code semantics for all execution paths:
  - Success with all features (e.g., 0)
  - Success with optional features unavailable (e.g., 0 with warnings)
  - Critical feature failures (e.g., non-zero codes)
- Document the meaning of each exit code and when it occurs
- Consider adding a `--strict` mode that fails on any limitation
- Ensure CI/CD integration notes explain exit code interpretations
- For backward compatibility, document any cases where exit codes diverge from standards

#### Testing Mode Support
- Consider implementing a dedicated `--testing` flag that:
  - Disables interactive prompts automatically
  - Produces deterministic output (standardized paths, predictable IDs)
  - Skips resource-intensive or external operations
  - Uses predetermined values for normally random elements
  - Provides structured, machine-parsable output
- Document testing mode behaviors and limitations
- Include examples of test invocations in script documentation

#### Operation Determinism
- Provide mechanisms to ensure predictable execution:
  - Allow seeding of random values
  - Support timestamp overrides for reproducible output
  - Implement path normalization for consistent display
  - Add modes that mask or replace variable elements in output
- Balance determinism with security (avoid exposing sensitive data)


### State Tracing
- Implement comprehensive state tracing for complex operations
- Track function call sequences for debugging
- Monitor variable state changes during execution
- Log critical decision points in the workflow

## Zsh Framework Scripting - Utility Functions

### z_Utils Integration Requirements
Framework scripts must leverage and contribute to the shared utility function library as defined in `REQUIREMENTS-z_Utils_Functions.md`:

1. **Use Existing z_Utils Functions**: *(Required)*
   - Leverage existing `z_Output` for consistent output formatting
   - Use `z_Report_Error` for centralized error reporting
   - Implement `z_Check_Dependencies` for dependency validation
   - Utilize `z_Convert_Path_To_Relative` for improved path display

2. **Consistent Implementation**: *(Required)*
   - Follow the implementation patterns established in z_Utils
   - Maintain consistent parameter ordering and naming
   - Adhere to documented function interfaces
   - Ensure backward compatibility when enhancing functions

3. **Contribution Requirements**: *(Required)*
   - Identify reusable functionality for potential z_Utils inclusion
   - Document new utility functions following z_Utils standards
   - Test utility functions independently before integration
   - Update documentation when enhancing existing z_Utils functions

4. **Versioning and Attribution**: *(Required)*
   - Document the z_Utils version being used or referenced
   - Provide attribution for borrowed or adapted functions
   - Track deviations from standard z_Utils implementations
   - Support migration to newer z_Utils versions

Example z_Utils attribution:
```zsh
########################################################################
## PORTIONS:
## z_Output, z_Report_Error functions:     
## Z_Utils - ZSH Utility Scripts 
## - <https://github.com/ChristopherA/Z_Utils>
## - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
## Version: 1.0.0 (2025-02-27)
## (c) 2025 Christopher Allen    
## Licensed under BSD-2-Clause Plus Patent License
########################################################################
```

## Zsh Framework Scripting - Example Files

The project includes several reference implementations that demonstrate Framework scripting principles:

### Reference Implementations

1. **`audit_inception_commit-POC.sh`**: Comprehensive example implementing:
   - Layered architecture with clear separation of concerns
   - Two-phase argument processing
   - Sophisticated output handling with multiple modes
   - Progressive Trust-based verification workflow
   - Rich documentation and error handling

2. **`z_frame.sh`**: Template framework with:
   - Comprehensive utility functions
   - Modular architecture
   - Rich output capabilities
   - Advanced error handling

3. **`z_min_frame.sh`**: Minimal framework template focusing on:
   - Essential framework capabilities
   - Core architectural patterns
   - Basic workflow orchestration

These implementations demonstrate the practical application of Framework scripting principles at different levels of complexity.

### Example Usage Patterns

Key patterns to study in these reference implementations include:

1. **Layered Architecture Implementation**:
   - Clear section organization
   - Explicit function dependencies
   - Consistent naming conventions

2. **Error Handling Patterns**:
   - Error propagation through return codes
   - Context-aware error reporting
   - Comprehensive cleanup on failure

3. **State Management Approaches**:
   - Explicit variable declaration and typing
   - State validation at boundaries
   - Clear state transitions

4. **Output Formatting Techniques**:
   - Multi-level output system
   - Consistent emoji and color usage
   - Structured progress reporting

## Conclusion

Framework scripts provide a robust foundation for complex operations while maintaining reliability and maintainability. By following these requirements, you can create sophisticated Zsh scripts that balance power with readability and extensibility.

The requirements outlined in this document complement those in `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` and build upon them to address the challenges of larger, more complex scripts. Additionally, integration with reusable utility functions from z_Utils and implementation of comprehensive regression testing ensures both code quality and long-term maintainability.

Through proper architecture, consistent implementation patterns, and comprehensive testing, Framework scripts can provide reliable, maintainable solutions for complex automation needs.