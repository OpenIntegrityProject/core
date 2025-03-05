#!/usr/bin/env zsh

########################################################################
##                         SCRIPT INFO
########################################################################
## audit_inception_commit-POC.sh
## - Open Integrity Audit of a Git Repository Inception Commit
##
## VERSION:      0.1.05 (2025-03-04)
##
## DESCRIPTION:
##   This script performs a multi-part review of a Git repository's inception
##   commit, auditing compliance with Open Integrity specifications across
##   multiple Progressive Trust phases:
##   - Wholeness: Assessing structural integrity and format
##   - Proofs: Cryptographic SSH signature authentication
##   - References: Affirming committer identity via references
##   - Requirements: Auditing Open Integrity and GitHub community standards
##
##   The script is a part of a Proof-of-Concept (POC) for using 
##   Git repositories as cryptographic roots of trust, leveraging empty, 
##   SSH-signed inception commits for a secure identifier that can 
##   be independently authenticated across distributed platforms.
##
## DESIGN PHILOSOPHY:
##   - Progressive Trust Implementation - Follows a phased approach to building
##     trust in cryptographic identities.
##   - Separation of Concerns - Clear distinction between framework utilities, 
##     domain-specific functions, and controller logic.
##   - Non-Destructive Operation - All operations are read-only; the script never
##     modifies repositories or Git configuration.
##   - Two-Phase Argument Processing - Framework arguments are processed before
##     domain-specific ones for consistent behavior.
##   - Layered Architecture - Organized in foundation, utility, domain,
##     orchestration, and controller layers.
##
## FEATURES:
##   - Local Inception Commit Auditing:
##     * Empty commit validation for SHA-1 collision resistance
##     * Commit message format verification
##     * Repository structure assessment
##   - Cryptographic Verification:
##     * SSH signature validation with proper Git configuration
##     * Support for both global and local allowed signers files
##     * Key fingerprint and committer identity correlation
##   - Progressive Trust Implementation:
##     * Phase 2 (Wholeness): Structural integrity assessment
##     * Phase 3 (Proofs): Cryptographic signature verification
##     * Phase 4 (References): Identity authentication and linking
##     * Phase 5 (Requirements): GitHub standards compliance
##   - Flexible Execution Modes:
##     * Interactive and non-interactive operation
##     * Configurable verbosity (standard, verbose, debug)
##     * Color support with terminal capability detection
##     * Compatible with CI/CD environments
##
## For more on the progressive trust life cycle, see:
##    https://developer.blockchaincommons.com/progressive-trust/
##
## LIMITATIONS:
##   - Currently only supports testing the inception commit of a local Git repository
##   - Script must be executed within or near the repository being audited
##   - GitHub standards compliance checks are very basic
##
## SECURITY CONSIDERATIONS:
##   - SHA-1 used in Git commit identifiers has known cryptographic weaknesses
##   - SSH keys should be protected with appropriate permissions (600)
##   - Verification only confirms the inception commit is properly signed
##   - Trust models assume proper management of allowed_signers files
##   - This script performs read-only operations and never modifies repositories
##   - The script does not store or transmit any cryptographic keys
##
## USAGE: audit_inception_commit-POC.sh [options]
## 
## OPTIONS:
##   -C, --chdir <path>    Change to specified directory before execution
##   -v, --verbose         Enable detailed output
##   -q, --quiet           Suppress non-critical output
##   -d, --debug           Show debugging information
##   -p, --no-prompt       Run non-interactively
##   -i, --interactive     Force interactive prompts
##   -n, --no-color        Disable colored output
##   -c, --color           Force colored output
##   -h, --help            Show this help message
##
## EXAMPLES:
##   # Basic audit of current directory repository:
##   audit_inception_commit-POC.sh
##
##   # Audit a specific repository with detailed output:
##   audit_inception_commit-POC.sh -C /path/to/repo --verbose
##
##   # Non-interactive audit for CI/CD pipelines:
##   audit_inception_commit-POC.sh --no-prompt --quiet -C /path/to/repo
##
##   # Debugging output with all details:
##   audit_inception_commit-POC.sh -C /path/to/repo --verbose --debug
##
## REQUIREMENTS:
##   - Zsh 5.8 or later
##   - Git 2.34 or later (required for SSH signing support)
##   - GitHub CLI (gh) 2.65.0 or later, authenticated with GitHub (optional)
##   - OpenSSH 8.2+ for signature verification
##
## INTEGRATION:
##   This script can be integrated into CI/CD pipelines, pre-commit hooks,
##   or used as a standalone verification tool. It returns standard exit
##   codes that can be used for automated decision making:
##     0  - Local verification phases (1-3) passed successfully, even if
##          remote phases (4-5) have warnings
##     1  - General failure or local verification failure
##     2  - Invalid usage or arguments
##     5  - Git repository error (not a repo, commit issues)
##     6  - Configuration error
##     127 - Missing dependency
##
##   Note that only failures in local verification phases (1-3) will produce
##   non-zero exit codes. Issues with remote verification phases (4-5) are
##   reported as warnings but don't affect the exit code.
##
## LICENSE:
##   (c) 2025 By Blockchain Commons LLC
##   https://www.BlockchainCommons.com
##   Licensed under BSD-2-Clause Plus Patent License
##   https://spdx.org/licenses/BSD-2-Clause-Patent.html
##
## PORTIONS:
##   z_Output function:     
##   Z_Utils - ZSH Utility Scripts 
##   - <https://github.com/ChristopherA/Z_Utils>
##   - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
##   (c) 2025 Christopher Allen    
##   Licensed under BSD-2-Clause Plus Patent License
## 
## PART OF:      
##   Open Integrity Project of Blockchain Commons LLC.
##   - Open Integrity Core
##     - <https://github.com/OpenIntegrityProject/core>
##     - <did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6>
########################################################################

########################################################################
## CHANGE LOG
########################################################################
## 0.1.05   - Fixed Exit Code Behavior (2025-03-04)
##          - Implemented the architectural decision for exit codes:
##            * Non-zero exit codes now only returned for issues in phases 1-3
##            * Issues in phases 4-5 reported as warnings without affecting exit code
##            * Success (exit code 0) now returned for repositories that pass
##              local verification even if GitHub integration is unavailable
##          - Updated comments and documentation to reflect new behavior:
##            * Added tracking of phase numbers in Trust_Assessment_Status
##            * Improved error reporting with phase information
##          - Fixed exit code inconsistency by using explicit exit statements
##          - Improved output with clear warnings for non-critical issues
##          - Updated regression tests to match new exit code behavior
##
## 0.1.04   - GitHub Integration Test Fix (2025-03-04)
##          - Fixed GitHub integration testing issues:
##            * Updated test script to expect exit code 1 for GitHub repositories
##            * Ensured oi_Comply_With_GitHub_Standards returns Exit_Status_Success
##              for non-critical failures
##            * Added comprehensive documentation about exit code behavior
##          - Updated issue documentation:
##            * Added new issue for GitHub Integration Test Failures (resolved)
##            * Updated Inconsistent Exit Code Behavior issue (partially resolved)
##            * Documented architectural decision still needed for exit codes
##
## 0.1.03   - Major Architecture Update (2025-03-01)
##          - Implemented two-phase argument processing
##            * Added z_Parse_Initial_Arguments for framework arguments
##            * Added parse_Remaining_Arguments for domain arguments
##            * Added dedicated handler functions for complex parameters
##          - Reorganized functions into architectural layers:
##            * Foundation Layer: Error handling, environment setup
##            * Utility Layer: z_Utils functions
##            * Domain Layer: oi_Utils functions
##            * Orchestration Layer: Audit execution functions
##            * Controller Layer: main and core_Logic functions
##          - Clarified controller function responsibilities
##            * Refined main() to focus on initialization and orchestration
##            * Refactored core_Logic() for workflow sequencing
##            * Created execute_Audit_Phases() for phase management
##          - Enhanced documentation
##            * Standardized all function documentation blocks
##            * Improved section headers with architectural context
##            * Added security considerations section
##            * Extended script header with design philosophy
##          - Reordered functions by strict dependency relationships
##          - Refactored longer functions for better maintainability
##
## 0.1.02   - Updated version (2025-02-28)
##          - Enhanced function naming consistency
##          - Improved script structure and organization
##          - Added repository DID output in default mode
##          - Improved error handling with centralized reporting
##          - Enhanced function documentation
##          - Added detailed comments for complex logic
##          - Added condensed trust assessment results for default mode
##
## 0.1.01   - Updated version (2025-02-28)
##          - Enhanced security documentation and considerations
##          - Improved function documentation for clarity and completeness
##          - Enhanced error messaging with actionable guidance
##          - Improved Zsh feature utilization
##          - Added more detailed verification status tracking
##          - Improved compliance with Zsh scripting best practices:
##            * Standardized function documentation blocks
##            * Enhanced error handling and exit code usage
##            * Improved variable naming and scoping
##
## 0.1.00   - Initial Release (2025-02-27)
##          - Core audit functionality for inception commits
##          - Support for Progressive Trust phases 2-5:
##            * Phase 2: Wholeness (structural integrity, format)
##            * Phase 3: Proofs (cryptographic signatures)
##            * Phase 4: References (identity authentication)
##            * Phase 5: GitHub community standards
##          - Interactive and non-interactive operation modes
##          - Colored output with configurable options
##          - Comprehensive help and usage information
##          - Verbose and debug output modes
##          - Initial support for GitHub standards compliance
##          - Basic error handling and reporting
##          - Script must currently be run from within repository
########################################################################

########################################################################
## SECTION: Foundation Layer - Environment Configuration
##--------------------------------------------------------------------##
## Description:
##   This foundational layer configures the Zsh environment to ensure 
##   robust error handling and predictable execution behavior. It 
##   establishes the script's operational context through initialization 
##   of essential constants, variables, and execution flags.
##
## Architectural Role:
##   As the first layer in the script's architecture, the Foundation Layer
##   creates the secure, consistent base upon which all other layers depend.
##   It ensures predictable behavior across different systems and shell
##   configurations by explicitly setting shell options and initializing
##   the script's state.
##
## Design Philosophy:
##   - Explicit Environment Control: Reset and configure the shell environment
##     to ensure consistent behavior regardless of user shell settings.
##   - Safe Defaults: Enable strict error handling to prevent silent failures.
##   - Clear State Management: Initialize all script-scoped variables with
##     explicit typing and readability.
##   - Terminal Adaptation: Detect and configure color capabilities based on
##     the execution environment.
##
## Content:
##   - Shell Environment Reset: Standardize Zsh environment
##   - Safe Shell Options: Enforce strict error handling
##   - Boolean Constants: Define TRUE/FALSE values
##   - Exit Status Constants: Define standardized return codes
##   - Execution Flags: Control script behavior modes
##   - Script Information: Track execution context
##   - Audit-Specific Variables: Track verification state
##   - Terminal Configuration: Adapt to display capabilities
##
## Dependencies:
##   - Requires Zsh 5.8+ with support for advanced parameter handling
##   - May use tput for terminal capability detection (if available)
##
## Notes:
##   - This section contains initialization code only, no functions
##   - Variables are declared with appropriate typing (integer, array, etc.)
##   - Constants are properly declared as readonly (-r) to prevent modification
########################################################################

# Reset the shell environment to a default Zsh state for predictability
emulate -LR zsh   

# Setting safe options for robust error handling:
setopt errexit          # Exit the script when a command fails
setopt nounset          # Treat unset variables as an error
setopt pipefail         # Return the exit status of the last command that failed in a pipeline
setopt noclobber        # Prevents accidental overwriting of files
setopt localoptions     # Ensures script options remain local
setopt warncreateglobal # Warns if a global variable is created by mistake
setopt no_nomatch       # Prevents errors when a glob pattern does not match
setopt no_list_ambiguous # Disables ambiguous globbing behavior

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.05"

#----------------------------------------------------------------------#
# Script-Scoped Variables - Boolean Constants
#----------------------------------------------------------------------#
# - `TRUE` and `FALSE` are integer constants representing boolean values.
# - Declared as readonly to ensure immutability
#----------------------------------------------------------------------#
typeset -r -i TRUE=1  # Represents the "true" state or enabled mode
typeset -r -i FALSE=0 # Represents the "false" state or disabled mode

#----------------------------------------------------------------------#
# Script-Scoped Variables - Exit Status Codes
#----------------------------------------------------------------------#
# - Standard exit codes for script return values
# - All status codes are read-only integers
#----------------------------------------------------------------------#
typeset -r -i Exit_Status_Success=0      # Successful execution
typeset -r -i Exit_Status_General=1      # General error (unspecified)
typeset -r -i Exit_Status_Usage=2        # Invalid usage or arguments
typeset -r -i Exit_Status_IO=3           # Input/output error
typeset -r -i Exit_Status_Git_Failure=5  # Git operation failed
typeset -r -i Exit_Status_Config=6       # Configuration error
typeset -r -i Exit_Status_Dependency=127 # Missing dependency

#----------------------------------------------------------------------#
# Script-Scoped Variables - Execution Flags
#----------------------------------------------------------------------#
# - Script-scoped flags controlling various modes and behaviors
# - Declared as integers using `typeset -i` to ensure type safety
#----------------------------------------------------------------------#
typeset -i Script_Running=$FALSE         # Prevents recursive execution
typeset -i Output_Verbose_Mode=$FALSE    # Verbose mode
typeset -i Output_Quiet_Mode=$FALSE      # Quiet mode
typeset -i Output_Debug_Mode=$FALSE      # Debug mode
typeset -i Output_Color_Enabled=$TRUE    # Color output
typeset -i Output_Prompt_Enabled=$TRUE   # Interactive prompting

#----------------------------------------------------------------------#
# Script-Scoped Variables - Script Information
#----------------------------------------------------------------------#
# - Script name, path, and other context information
# - All path-related constants are readonly
#----------------------------------------------------------------------#
typeset -r Script_FileName="${0##*/}"                       # Script base name
typeset -r Script_BaseName=${${0:A:t}%.*}                   # Name without extension
typeset -r Script_FileExt=${0##*.}                          # File extension
typeset -r Script_RealFilePath=$(realpath "${0:A}")         # Absolute path
typeset -r Script_RealDirName=$(basename "$(realpath "${0:A:h}")") # Directory name
typeset -r Script_RealDirPath=$(realpath "${0:A:h}")        # Directory path
typeset -r Script_RealParentDir=$(realpath "${0:A:h:h}")    # Parent directory

#----------------------------------------------------------------------#
# Script-Scoped Variables - Command-Line Arguments
#----------------------------------------------------------------------#
# - Storage for original command-line arguments
# - Allows reference to original input throughout execution
#----------------------------------------------------------------------#
typeset -a Cmd_Args=("$@")                                  # All arguments
typeset -r Cmd_Args_Count="${#Cmd_Args[@]}"                 # Argument count
typeset -a Cmd_Positional_Args=("${(@)Cmd_Args:#--*}")      # Non-flag arguments
typeset -A Cmd_Parsed_Flags                                 # Parsed flag storage
typeset Cmd_Args_String="${*}"                              # Original args string
typeset -r Cmd_Invocation_Path=$(realpath "$0")             # Invocation path
typeset Working_Directory                                   # Working directory from -C/--chdir

#----------------------------------------------------------------------#
# Script-Scoped Variables - Environment Detection
#----------------------------------------------------------------------#
# - Environment variables used for detecting terminal capabilities
#   and script execution context
# - These can be overridden by command line flags
#----------------------------------------------------------------------#
typeset Script_No_Color="${NO_COLOR:-}"        # Industry standard for disabling color
typeset Script_Force_Color="${FORCE_COLOR:-}"  # Build system standard for forcing color
typeset Script_CI="${CI:-}"                    # Continuous Integration environment flag
typeset Script_PS1="${PS1:-}"                  # Shell prompt - indicates interactive shell
typeset Script_Term="${TERM:-}"                # Terminal type and capabilities

#----------------------------------------------------------------------#
# Terminal Color Configuration
#----------------------------------------------------------------------#
# Description:
# - Defines terminal colors and attributes for script output styling.
# - Includes basic colors, bright variations, and emphasis attributes.
# - Dynamically initialized based on terminal capabilities.
# - Read-only to ensure consistent and predictable usage.
#----------------------------------------------------------------------#
typeset -i Output_Has_Color=$FALSE
typeset -i Tput_Colors=0

# Safely retrieve the number of terminal colors
if command -v tput >/dev/null 2>&1; then
    Tput_Colors=$(tput colors 2>/dev/null || echo 0)  # Default to 0 if tput fails
    if (( Tput_Colors >= 8 )); then
        Output_Has_Color=$TRUE
    elif ! (( Output_Quiet_Mode )); then
        print "WARNING: Insufficient color support (${Tput_Colors} colors) - disabling color output."
    fi
else
    if ! (( Output_Quiet_Mode )); then
        print "WARNING: 'tput' command not found - disabling color output."
    fi
fi

# Initialize terminal color variables if supported and enabled
if (( Output_Has_Color && Output_Color_Enabled )); then
    # Basic Colors
    Term_Black=$(tput setaf 0)
    Term_Red=$(tput setaf 1)
    Term_Green=$(tput setaf 2)
    Term_Yellow=$(tput setaf 3)
    Term_Blue=$(tput setaf 4)
    Term_Magenta=$(tput setaf 5)
    Term_Cyan=$(tput setaf 6)
    Term_White=$(tput setaf 7)

    # Bright Colors
    Term_BrightBlack=$(tput bold; tput setaf 0)
    Term_BrightRed=$(tput bold; tput setaf 1)
    Term_BrightGreen=$(tput bold; tput setaf 2)
    Term_BrightYellow=$(tput bold; tput setaf 3)
    Term_BrightBlue=$(tput bold; tput setaf 4)
    Term_BrightMagenta=$(tput bold; tput setaf 5)
    Term_BrightCyan=$(tput bold; tput setaf 6)
    Term_BrightWhite=$(tput bold; tput setaf 7)

    # Emphasis Attributes
    Term_Bold=$(tput bold)
    Term_Underline=$(tput smul)
    Term_NoUnderline=$(tput rmul)
    Term_Standout=$(tput smso)
    Term_NoStandout=$(tput rmso)
    Term_Blink=$(tput blink)
    Term_Dim=$(tput dim)
    Term_Reverse=$(tput rev)
    Term_Invisible=$(tput invis)

    # Reset Attributes
    Term_Reset=$(tput sgr0)
else
    # Fallback to empty strings if color is unsupported or disabled
    Term_Black="" Term_Red="" Term_Green=""
    Term_Yellow="" Term_Blue="" Term_Magenta=""
    Term_Cyan="" Term_White=""
    Term_BrightBlack="" Term_BrightRed="" Term_BrightGreen=""
    Term_BrightYellow="" Term_BrightBlue="" Term_BrightMagenta=""
    Term_BrightCyan="" Term_BrightWhite=""
    Term_Bold="" Term_Underline="" Term_NoUnderline=""
    Term_Standout="" Term_NoStandout="" Term_Blink=""
    Term_Dim="" Term_Reverse="" Term_Invisible=""
    Term_Reset=""
fi

# Make all terminal color and attribute variables readonly
typeset -r Term_Black Term_Red Term_Green \
          Term_Yellow Term_Blue Term_Magenta \
          Term_Cyan Term_White Term_BrightBlack \
          Term_BrightRed Term_BrightGreen Term_BrightYellow \
          Term_BrightBlue Term_BrightMagenta Term_BrightCyan \
          Term_BrightWhite Term_Bold Term_Underline \
          Term_NoUnderline Term_Standout Term_NoStandout \
          Term_Blink Term_Dim Term_Reverse \
          Term_Invisible Term_Reset

#----------------------------------------------------------------------#
# Script-Scoped Variables - Audit Specific Variables
#----------------------------------------------------------------------#
# - Variables specifically for tracking audit state and results
# - Used throughout the script for storing commit information
#----------------------------------------------------------------------#
typeset Inception_Commit_Repo_Id       # Stores inception commit SHA-1
typeset Repo_DID                      # Stores the repository DID

# Associative array for tracking assessment status
typeset -A Trust_Assessment_Status
# Initialize with all assessments set to FALSE and their phase numbers
Trust_Assessment_Status=(
    # Assessment results
    "structure" $FALSE
    "content" $FALSE
    "format" $FALSE
    "signature" $FALSE
    "identity" $FALSE
    "standards" $FALSE
    
    # Phase numbers for each assessment (for exit code determination)
    "structure_phase" 2  # Wholeness - local
    "content_phase" 2    # Wholeness - local
    "format_phase" 2     # Wholeness - local
    "signature_phase" 3  # Cryptographic Proofs - local
    "identity_phase" 4   # Trust References - remote
    "standards_phase" 5  # Community Standards - remote
)

########################################################################
## SECTION: Utility Layer - z_Utils Functions
##--------------------------------------------------------------------##
## Description:
##   This layer contains reusable Zsh utility functions (z_Utils) that
##   provide general-purpose functionality for script infrastructure,
##   environment management, error handling, and output formatting.
##   These functions establish core capabilities needed by higher layers
##   but are not specific to Open Integrity auditing processes.
##
## Architectural Role:
##   The Utility Layer sits between the Foundation Layer and domain-specific
##   layers, providing standardized services and abstractions that
##   higher-level functions can rely on. These utilities encapsulate
##   common tasks to reduce code duplication and maintain consistency
##   throughout the script.
##
## Design Philosophy:
##   - Reusability: Functions designed to be used across multiple scripts
##   - Abstraction: Hide implementation details behind clean interfaces
##   - Consistency: Provide uniform behavior for common operations
##   - Robustness: Include comprehensive error handling
##
## Functions (in dependency order):
##   - z_Output: Advanced formatted output with multiple message types
##   - z_Report_Error: Centralized error reporting
##   - z_Convert_Path_To_Relative: Converts absolute paths to relative
##   - z_Check_Requirements: Verifies required tools and capabilities
##   - z_Setup_Environment: Initializes script environment
##   - z_Cleanup: Performs cleanup when script exits
##
## Naming Convention:
##   - All functions are prefixed with "z_" indicating general Zsh utilities
##   - Function names follow verb_Object pattern
##   - First word lowercase, subsequent words capitalized
##
## Dependencies:
##   - Foundation Layer environment variables and constants
##   - Some functions may require external commands (tput, command)
##
## Note:
##   This section implements general-purpose utilities that can be 
##   reused across multiple scripts in the z_Utils library. The code is 
##   maintained separately and imported into this script.
##
## Source:
##   Z_Utils - ZSH Utility Scripts 
##   - <https://github.com/ChristopherA/Z_Utils>
##   - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
##   (c) 2025 Christopher Allen
##   Licensed under BSD-2-Clause Plus Patent License
########################################################################

#----------------------------------------------------------------------#
# Function: z_Output
#----------------------------------------------------------------------#
# Description:
#   A utility function for formatted output in Zsh scripts. Supports
#   multiple message types, text formatting, emoji, indentation,
#   verbosity levels, and interactive prompts.
#
# Version: 1.0.00 (2025-02-27)
#
# Parameters:
#   $1 - Message type (string): Determines message behavior and visibility
#        Values: print, info, verbose, success, warn, error, debug,
#                vdebug, prompt
#   Remaining parameters - Either message text or Key=Value options
#
# Options (Key=Value):
#   - Color="<ANSI Code>" - Override default message color
#   - Emoji="🔹" - Set a custom emoji (default varies by type)
#   - Wrap=<int> - Maximum line width (default: terminal width)
#   - Indent=<int> - Left indentation (enables wrapping)
#   - Force=1 - Overrides quiet mode for all message types
#   - Default="value" - Pre-set response for non-interactive prompts
#
# Returns:
#   0 for standard messages
#   1 for errors
#   2 for invalid message types
#
# Required Script Variables:
#   - TRUE/FALSE - Boolean constants (1/0)
#   - Output_Verbose_Mode - Enables `verbose` messages
#   - Output_Quiet_Mode - Suppresses non-critical messages
#   - Output_Debug_Mode - Enables `debug` messages
#   - Output_Prompt_Enabled - Controls interactive prompting
#   - Various Term_* color variables
#
# Side Effects:
#   - Outputs formatted text to stdout
#   - May prompt for user input when type is "prompt"
#
# Dependencies:
#   - tput for color support and terminal detection
#
# Usage Examples:
#   z_Output print "Standard output message"
#   z_Output verbose "Details shown only in verbose mode"
#   z_Output error "Error message always shown"
#   z_Output debug "Debugging information"
#   z_Output prompt "Enter value:" Default="default"
#   z_Output info Indent=2 "Indented informational message"
#   z_Output warn Force=1 "Warning that shows even in quiet mode"
#----------------------------------------------------------------------#
function z_Output {
    # Required first parameter is message type with error on missing
    # ${1:?msg} is shared between zsh/bash but behavior differs on missing parameter
    typeset MessageType="${1:?Missing message type}"
    shift

    # Zsh arrays are 1-based and require explicit declaration of pattern matching arrays
    # match/mbegin/mend are special zsh arrays used for regex capture groups
    typeset -a match mbegin mend
    typeset -a MessageParts
    # -A creates associative array (like bash -A but with different scoping rules)
    typeset -A OptionsMap
    
    # In zsh, typeset creates local variables with explicit typing
    # Unlike bash where local/declare are interchangeable
    typeset MessageText IndentText WrapIndentText PrefixText
    typeset LineText WordText CurrentLine OutputText
    typeset KeyName Value
    
    # Zsh associative arrays persist declaration order unlike bash
    typeset -A ColorMap EmojiMap SuppressionMap
    
    ColorMap=(
        "print"   "$Term_Reset"
        "info"    "$Term_Cyan"
        "verbose" "$Term_Yellow"
        "success" "$Term_Green"
        "warn"    "$Term_Magenta"
        "error"   "$Term_Red"
        "debug"   "$Term_Blue"
        "vdebug"  "$Term_Blue"
        "prompt"  "$Term_Standout"
        "reset"   "$Term_Reset"
    )
    
    EmojiMap=(
        "print"   ""
        "info"    "💡"
        "verbose" "📘"
        "success" "✅"
        "warn"    "⚠️"
        "error"   "❌"
        "debug"   "🛠️"
        "vdebug"  "🔍"
        "prompt"  "❓"
    )
    
    SuppressionMap=(
        "print"   1
        "info"    1
        "verbose" 1
        "success" 1
        "warn"    1
        "error"   0
        "debug"   1
        "vdebug"  1
        "prompt"  0
    )

    # Zsh parameter expansion flags and word splitting differ from bash:
    # 1. =~ regex captures go to $match array (unlike bash's ${BASH_REMATCH})
    # 2. Options must be in the form 'Option=value' (no spaces)
    while (( $# > 0 )); do
        if [[ "$1" =~ '^([[:alnum:]_]+)=(.*)$' ]]; then
            KeyName="${match[1]}"
            Value="${match[2]}"
            OptionsMap[$KeyName]="$Value"
        else
            # Store as message content
            MessageParts+=( "$1" )
        fi
        shift
    done

    # ${(j: :)array} is zsh array joining with space separator
    # Equivalent to "${array[*]}" in bash but preserves multiple spaces
    MessageText="${(j: :)MessageParts}"

    # Explicit integer declaration required in zsh for arithmetic context
    typeset -i AllowMessage=$FALSE
    case "$MessageType" in
        "vdebug")
            # Zsh arithmetic expressions use (( )) like bash but with stricter typing
            (( AllowMessage = (Output_Debug_Mode == 1 && Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        "debug")
            (( AllowMessage = (Output_Debug_Mode == 1) ? TRUE : FALSE ))
            ;;
        "verbose")
            (( AllowMessage = (Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        *)
            (( AllowMessage = TRUE ))
            ;;
    esac

    if (( Output_Quiet_Mode == 1 && ${SuppressionMap[$MessageType]:-0} == 1 && ${OptionsMap[Force]:-0} != 1 )); then
        return 0
    fi

    if (( AllowMessage == 0 && ${OptionsMap[Force]:-0} != 1 )); then
        return 0
    fi

    if [[ "$MessageType" == "prompt" ]]; then
        typeset DefaultValue="${OptionsMap[Default]:-}"
        typeset EmptyDefault="$([[ -z "$DefaultValue" ]] && echo "(empty)" || echo "$DefaultValue")"
        typeset Prompt="${MessageText:-Enter value}"
        typeset PromptEmoji="${OptionsMap[Emoji]:-${EmojiMap[$MessageType]:-}}"
        typeset IndentText=""
        typeset PromptText
        
        # Handle indentation for prompts
        typeset -i IndentSize=${OptionsMap[Indent]:-0}
        (( IndentSize > 0 )) && IndentText="$(printf '%*s' $IndentSize '')"
        
        if [[ -n "$DefaultValue" ]]; then
            # :+ is parameter expansion shared with bash but more commonly used in zsh
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt} [${EmptyDefault}]"
        else
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt}"
        fi

        if (( Output_Prompt_Enabled == 0 )); then
            print -- "${DefaultValue}"
            return 0
        fi

        # Zsh read has -r flag like bash but variable=value? syntax for prompt
        # This syntax preserves exact spacing unlike bash's -p flag
        typeset UserInput
        read -r "UserInput?${PromptText}: "
        print -- "${UserInput:-$DefaultValue}"
        return 0
    fi

    typeset CurrentColor="${OptionsMap[Color]:-${ColorMap[$MessageType]:-}}"
    typeset ResetColor="${ColorMap[reset]}"
    typeset CurrentEmoji=""

    if [[ -n "$MessageText" && ("$MessageType" != "print" || ( -v "OptionsMap[Emoji]" )) ]]; then
        # Use :+ to check if Emoji is set (even if empty) before falling back to default
        if [[ -v "OptionsMap[Emoji]" ]]; then
            CurrentEmoji="${OptionsMap[Emoji]}"
        else
            CurrentEmoji="${EmojiMap[$MessageType]:-}"
        fi
        [[ -n "$CurrentEmoji" ]] && CurrentEmoji+=" "
    fi

    # Integer math in zsh requires explicit typing for reliable results
    typeset -i IndentSize=${OptionsMap[Indent]:-0}
    typeset -i BaseIndent=$IndentSize
    (( BaseIndent < 0 )) && BaseIndent=0

    IndentText=""
    [[ $BaseIndent -gt 0 ]] && IndentText="$(printf '%*s' $BaseIndent '')"
    
    WrapIndentText="$IndentText"
    [[ $BaseIndent -gt 0 ]] && WrapIndentText+="  "

    typeset -i TerminalWidth=$(tput cols)
    typeset -i RequestedWrap=${OptionsMap[Wrap]:-0}
    typeset -i WrapWidth

    if (( RequestedWrap == 0 && IndentSize == 0 )); then
        # print -- behaves differently than echo in zsh, more predictable for output
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return 0
    elif (( RequestedWrap > 0 )); then
        WrapWidth=$(( RequestedWrap <= TerminalWidth ? RequestedWrap : TerminalWidth ))
    elif (( IndentSize > 0 )); then
        WrapWidth=$TerminalWidth
    else
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return 0
    fi

    typeset -i WrapMargin=2
    typeset -i MinContentWidth=40
    typeset -i EffectiveWidth=$(( WrapWidth - BaseIndent - WrapMargin ))
    (( EffectiveWidth < MinContentWidth )) && EffectiveWidth=MinContentWidth

    OutputText=""
    CurrentLine="${IndentText}${CurrentEmoji}"
    typeset -i IsFirstLine=1

    # ${(ps:\n:)text} is zsh-specific splitting that preserves empty lines
    # Unlike bash IFS splitting which would collapse empty lines
    typeset -a Lines
    typeset Line
    Lines=("${(@f)MessageText}")

    typeset -i LineNum=1
    for Line in $Lines; do
        if (( LineNum > 1 )); then
            OutputText+="${CurrentLine}"$'\n'
            CurrentLine="${IndentText}"
            IsFirstLine=0
        fi
        
        # Split preserving exact whitespace patterns
        typeset -a Words
        Words=(${(ps: :)Line})
        
        for WordText in $Words; do
            # Tab expansion consistent between zsh/bash
            WordText=${WordText//$'\t'/    }
            
            # ${(%)string} is zsh-specific expansion that handles prompt escapes
            # Used for accurate Unicode width calculation, no bash equivalent
            typeset -i WordWidth=${#${(%)WordText}}
            typeset -i CurrentWidth=${#${(%)CurrentLine}}
            
            if (( CurrentWidth + WordWidth + 1 > WrapWidth - WrapMargin )); then
                if (( CurrentWidth > ${#IndentText} + (IsFirstLine ? ${#CurrentEmoji} : 0) )); then
                    OutputText+="${CurrentLine}"$'\n'
                    CurrentLine="${WrapIndentText}"
                    IsFirstLine=0
                fi
                
                # Handle words longer than the wrap width
                if (( WordWidth > EffectiveWidth )); then
                    # Process long words by breaking them into chunks
                    typeset ChunkSize=$EffectiveWidth
                    typeset RemainingWord="$WordText"
                    
                    while (( ${#RemainingWord} > ChunkSize )); do
                        typeset CurrentChunk="${RemainingWord:0:$ChunkSize}"
                        CurrentLine+="$CurrentChunk"
                        OutputText+="${CurrentLine}"$'\n'
                        RemainingWord="${RemainingWord:$ChunkSize}"
                        CurrentLine="${WrapIndentText}"
                        IsFirstLine=0
                    done
                    
                    # Add any remaining part of the word
                    WordText="$RemainingWord"
                fi
                
                CurrentLine+="$WordText"
            else
                if (( CurrentWidth == ${#IndentText} + (IsFirstLine ? ${#CurrentEmoji} : 0) )); then
                    CurrentLine+="$WordText"
                else
                    CurrentLine+=" $WordText"
                fi
            fi
        done
        (( LineNum++ ))
    done

    [[ -n "$CurrentLine" ]] && OutputText+="${CurrentLine}"

    print -- "${CurrentColor}${OutputText}${ResetColor}"
    return 0
}

#----------------------------------------------------------------------#
# Function: z_Report_Error
#----------------------------------------------------------------------#
# Description:
#   Centralized error reporting function for consistent error handling.
#   Formats error messages with appropriate styling and outputs them
#   to stderr. Uses z_Output if available, otherwise falls back to
#   direct stderr printing.
#
# Parameters:
#   $1 - Error message to display (string) - The text to show to the user
#   $2 - Optional exit code (integer) - Defaults to Exit_Status_General
#
# Returns:
#   Returns the specified error code or Exit_Status_General (1)
#
# Required Script Variables:
#   Exit_Status_General - Default error code to use if none specified
#
# Side Effects:
#   - Outputs error message to stderr
#   - May use terminal styling if color output is enabled
#
# Dependencies:
#   - May use z_Output if available, otherwise uses print -u2
#
# Usage Example:
#   z_Report_Error "Failed to access repository" $Exit_Status_IO
#----------------------------------------------------------------------#
function z_Report_Error() {
   typeset ErrorMessage="$1"
   typeset -i ErrorCode="${2:-$Exit_Status_General}"
   
   # Check if z_Output is available
   if typeset -f z_Output >/dev/null 2>&1; then
      z_Output error "$ErrorMessage"
   else
      print -u2 "❌ ERROR: $ErrorMessage"
   fi
   return $ErrorCode
}

#----------------------------------------------------------------------#
# Function: z_Convert_Path_To_Relative
#----------------------------------------------------------------------#
# Description:
#   Converts an absolute path into a relative one, based on the current
#   working directory (PWD). If the path is exactly the current directory,
#   it returns the directory name rather than "." for better readability.
#   This function improves user-facing path displays throughout the script.
#
# Parameters:
#   $1 - The absolute or partial path to convert (string) - Must be a valid path
#
# Returns:
#   Prints the relative path to stdout
#   Exit_Status_Success (0) on successful conversion
#
# Required Script Variables:
#   PWD - Current working directory (automatically provided by Zsh)
#   Exit_Status_Success - Standard success exit code
#
# Side Effects:
#   None - Pure calculation function with no state changes
#
# Dependencies:
#   None - Uses only Zsh built-in parameter expansion
#
# Usage Examples:
#   rel_path=$(z_Convert_Path_To_Relative "/etc/myconfig.conf")
#   # Returns "../../etc/myconfig.conf" if PWD is "/home/user"
#   
#   rel_path=$(z_Convert_Path_To_Relative "$PWD")
#   # Returns directory name (e.g., "scripts") instead of "."
#----------------------------------------------------------------------#
function z_Convert_Path_To_Relative() {
   typeset pathAbsolute="${1:A}"   # Canonical absolute path
   typeset pwdAbsolute="${PWD:A}"  # Canonical current directory
   
   # If it's exactly the current dir, return the basename instead of "."
   if [[ "$pathAbsolute" == "$pwdAbsolute" ]]; then
       print "$(basename "$pathAbsolute")"
       return $Exit_Status_Success
   fi

   # If it's a sub-path of the current dir, prefix with "./"
   if [[ "$pathAbsolute" == "$pwdAbsolute/"* ]]; then
       print "./${pathAbsolute#$pwdAbsolute/}"
       return $Exit_Status_Success
   fi
   
   # Otherwise, attempt to find a common ancestor
   typeset pathCommon="$pwdAbsolute"
   typeset pathResult=""
   
   # Step upwards until we find shared directory
   while ! [[ "$pathAbsolute" = ${pathCommon}* ]]; do
       pathResult="../$pathResult"
       pathCommon="${pathCommon:h}"
   done
   
   # If pathCommon is non-empty, remove that portion
   if [[ -n "$pathCommon" ]]; then
       typeset pathRelative="${pathAbsolute#$pathCommon/}"
       if [[ -n "$pathRelative" ]]; then
           print "${pathResult}${pathRelative}"
       else
           # If removing pathCommon leaves nothing, remove trailing slash
           print "${pathResult%/}"
       fi
   else
       # Fallback: no common ancestor => remain absolute
       print "$pathAbsolute"
   fi
   
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Check_Requirements
#----------------------------------------------------------------------#
# Description:
#   Verifies that all required external tools and capabilities are
#   available for script execution. Checks minimum version requirements
#   and validates the presence of essential command-line utilities.
#
# Parameters:
#   None
#
# Returns:
#   Exit_Status_Success (0) if all requirements are met
#   Exit_Status_Dependency (127) if any requirement is missing
#
# Required Script Variables:
#   Exit_Status_Success - Success exit code
#   Exit_Status_Dependency - Exit code for missing dependencies
#
# Side Effects:
#   - May output error messages on validation failure
#
# Dependencies:
#   - z_Report_Error for error reporting
#   - External commands being tested (zsh, git, etc.)
#
# Usage Example:
#   z_Check_Requirements || exit $?
#----------------------------------------------------------------------#
function z_Check_Requirements {
    typeset -i ErrorCount=0

    # Check Zsh version
    function check_Zsh_Version {
        typeset ZshOutput MinVer
        typeset -i Major=0 Minor=0

        ZshOutput="$(zsh --version)"
        if [[ -z "${ZshOutput}" ]]; then
            z_Report_Error "Failed to get Zsh version"
            return 1
        fi

        # Extract version numbers using parameter expansion
        MinVer="${ZshOutput#*zsh }"
        MinVer="${MinVer%% *}"
        Major="${MinVer%%.*}"
        Minor="${MinVer#*.}"

        if (( Major < 5 || (Major == 5 && Minor < 8) )); then
            z_Report_Error "Zsh version 5.8 or later required (found ${Major}.${Minor})"
            return 1
        fi
        return 0
    }

    # Check for required commands
    function check_Required_Commands {
        typeset -a RequiredCommands=(
            "printf"  # For formatted output
            "zsh"     # To check version
            "git"     # For repository operations
            "tput"    # For terminal capabilities
        )
        typeset Command
        typeset -i CmdIdx LocalErrorCount=0

        for (( CmdIdx=1; CmdIdx <= ${#RequiredCommands[@]}; CmdIdx++ )); do
            Command="${RequiredCommands[CmdIdx]}"
            if ! command -v "${Command}" >/dev/null 2>&1; then
                z_Report_Error "Required command not found: ${Command}"
                (( LocalErrorCount++ ))
            fi
        done
        return $LocalErrorCount
    }

    # Check Git version (requires 2.34+ for SSH signing)
    function check_Git_Version {
        typeset GitOutput MinVer
        typeset -i Major=0 Minor=0

        GitOutput="$(git --version)"
        if [[ -z "${GitOutput}" ]]; then
            z_Report_Error "Failed to get Git version"
            return 1
        fi

        # Extract version numbers using parameter expansion
        MinVer="${GitOutput#*version }"
        MinVer="${MinVer%% *}"
        Major="${MinVer%%.*}"
        Minor="${MinVer#*.}"
        Minor="${Minor%%.*}"  # Handle cases like 2.34.1

        if (( Major < 2 || (Major == 2 && Minor < 34) )); then
            z_Report_Error "Git version 2.34 or later required for SSH signing (found ${Major}.${Minor})"
            return 1
        fi
        return 0
    }

    # Execute each test
    check_Zsh_Version || (( ErrorCount++ ))
    check_Required_Commands || (( ErrorCount += $? ))
    check_Git_Version || (( ErrorCount++ ))

    # Return appropriate exit status
    if (( ErrorCount > 0 )); then
        return $Exit_Status_Dependency
    fi
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Setup_Environment
#----------------------------------------------------------------------#
# Description:
#   Initializes the script environment by verifying requirements
#   and performing any necessary setup operations. This function is called
#   during script startup to ensure a consistent execution environment.
#
# Parameters:
#   None
#
# Returns:
#   Exit_Status_Success (0) on successful setup
#   Exit_Status_Dependency (127) if setup requirements are not met
#
# Required Script Variables:
#   Exit_Status_Success - Success exit code
#   Exit_Status_Dependency - Exit code for missing dependencies
#
# Side Effects:
#   - May set additional environment variables
#   - May output diagnostic messages on validation failure
#
# Dependencies:
#   - z_Check_Requirements for dependency verification
#
# Usage Example:
#   z_Setup_Environment || exit $?
#----------------------------------------------------------------------#
function z_Setup_Environment {
    # Check requirements
    if ! z_Check_Requirements; then
        return $Exit_Status_Dependency
    fi

    # Additional setup steps can be added here
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Cleanup
#----------------------------------------------------------------------#
# Description:
#   Performs cleanup operations when the script exits, handling both
#   successful and error conditions. This function is registered via
#   a trap to ensure it runs even if the script exits abnormally.
#
# Parameters:
#   $1 - Success flag (boolean) - TRUE for normal exit, FALSE for error
#   $2 - Optional error message - Details about an error condition
#
# Returns:
#   Returns the same value as the success flag passed to it
#
# Required Script Variables:
#   Script_Running - Flag to track and prevent recursive script execution
#   TRUE/FALSE - Boolean constants
#
# Side Effects:
#   - Resets the Script_Running flag to FALSE
#   - Outputs completion or error status messages
#
# Dependencies:
#   - z_Output for message formatting
#
# Usage Example:
#   z_Cleanup $TRUE ""  # Normal successful completion
#   z_Cleanup $FALSE "Script terminated due to error"  # Error condition
#----------------------------------------------------------------------#
function z_Cleanup {
    typeset Success=$1
    typeset ErrorMsg="${2:-}"
    
    # Reset the script running flag
    Script_Running=$FALSE

    if (( Success == TRUE )); then
        # On success, report cleanup completion in debug mode
        z_Output debug "Cleanup completed successfully."
    else
        # On failure, use warning type which respects quiet mode
        z_Output warn Emoji="" ""
        z_Output warn "Script terminated with errors. Cleanup completed."
        if [[ -n "$ErrorMsg" ]]; then
            z_Output error "$ErrorMsg"
        fi
    fi
    
    return $Success
}

########################################################################
## SECTION: Domain Layer - oi_Utils Functions
##--------------------------------------------------------------------##
## Description:
##   This layer contains specialized functions for Open Integrity
##   repository auditing, implementing the core verification logic for
##   each Progressive Trust phase. These domain-specific functions handle
##   repository inspection, commit analysis, cryptographic signature
##   verification, and identity authentication.
##
## Architectural Role:
##   The Domain Layer sits between the general-purpose Utility Layer
##   and the Orchestration Layer. It provides the specialized operations
##   needed to implement Open Integrity's Progressive Trust phases,
##   leveraging the foundation established by lower layers.
##
## Design Philosophy:
##   - Progressive Trust Implementation: Each function corresponds to a 
##     specific phase of Progressive Trust verification.
##   - Non-Destructive Operations: All functions perform read-only
##     analysis; they never modify repositories or configurations.
##   - Detailed Feedback: Functions provide comprehensive output about
##     verification status and potential issues.
##   - Consistent Return Values: All functions return standardized
##     exit codes for reliable orchestration.
##
## Functions (in reverse dependency order):
##   - oi_Comply_With_GitHub_Standards: Phase 5 (Requirements) - GitHub compliance
##   - oi_Affirm_Committer_Signature: Phase 4 (References) - Identity verification
##   - oi_Authenticate_Ssh_Signature: Phase 3 (Proofs) - Signature verification
##   - oi_Assess_Commit_Message_Format: Phase 2 (Wholeness) - Message validation
##   - oi_Assess_Empty_Commit: Phase 2 (Wholeness) - Content validation
##   - oi_Locate_Inception_Commit: Phase 2 (Wholeness) - Struct. validation
##
## Naming Convention:
##   - All functions are prefixed with "oi_" indicating Open Integrity
##     specific operations
##   - Function names follow verb_Object pattern
##   - First word lowercase, subsequent words capitalized
##
## Dependencies:
##   - Foundation Layer environment variables and constants
##   - Utility Layer z_Utils functions
##   - Git command-line tools
##   - GitHub CLI (gh) for standards compliance (optional)
##
## Notes:
##   This section implements the core auditing functionality specific to
##   Open Integrity's inception commit verification requirements.
########################################################################

#----------------------------------------------------------------------#
# Function: oi_Locate_Inception_Commit
#----------------------------------------------------------------------#
# Description:
#   Locates the inception commit (first commit) in a Git repository,
#   which serves as the foundation for all Progressive Trust auditing.
#   This is the first step in Phase 2 (Wholeness) verification and
#   a prerequisite for all subsequent verification steps.
#
# Parameters:
#   None
#
# Returns:
#   Exit_Status_Success (0) if inception commit is found
#   Exit_Status_Git_Failure (5) if no inception commit can be located
#
# Required Script Variables:
#   Inception_Commit_Repo_Id - Set to the SHA-1 hash of the inception commit
#   Repo_DID - Set to the repository DID
#   Trust_Assessment_Status - Associative array updated with verification result
#
# Side Effects:
#   - Sets the Inception_Commit_Repo_Id script-scoped variable
#   - Sets the Repo_DID script-scoped variable
#   - Updates Trust_Assessment_Status["structure"] with result
#   - Outputs verification information via z_Output
#
# Dependencies:
#   - Git command-line tools (specifically git rev-list)
#   - z_Output for messaging
#
# Usage Example:
#   oi_Locate_Inception_Commit || return $?
#----------------------------------------------------------------------#
function oi_Locate_Inception_Commit {
    # Find the inception commit
    Inception_Commit_Repo_Id=$(git rev-list --max-parents=0 HEAD 2>/dev/null)
    
    # Validate we found a commit hash
    if [[ $? -eq 0 && -n "$Inception_Commit_Repo_Id" ]]; then
        # Set the repository DID value for later use
        Repo_DID="did:repo:${Inception_Commit_Repo_Id}"
        
        # Output verification information
        z_Output verbose Indent=4 "Found inception commit ${Inception_Commit_Repo_Id}"
        z_Output success Indent=2 "Repository Structure: Inception commit found"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[structure]=$TRUE
        
        return $Exit_Status_Success
    else
        # Error handling - no inception commit found
        z_Output verbose Indent=4 "No inception commit found"
        z_Output error Indent=4 "Repository Structure: No inception commit found"
        Inception_Commit_Repo_Id=""
        Repo_DID=""
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[structure]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: oi_Assess_Empty_Commit
#----------------------------------------------------------------------#
# Description:
#   Part of Progressive Trust Phase 2 (Wholeness). Verifies that the
#   inception commit is empty (contains no files), which is a security
#   requirement for mitigating SHA-1 collision risks in Git repositories.
#
# Parameters:
#   $1 - The commit hash to verify (string) - Must be a valid Git commit ID
#
# Returns:
#   Exit_Status_Success (0) if commit is empty (contains no files)
#   Exit_Status_Git_Failure (5) if commit is not empty or verification fails
#
# Required Script Variables:
#   Trust_Assessment_Status - Associative array updated with assessment result
#
# Side Effects:
#   - Updates Trust_Assessment_Status["content"] with result (TRUE/FALSE)
#   - Outputs verification information via z_Output
#
# Dependencies:
#   - Git command-line tools (git cat-file, git hash-object)
#   - z_Output for messaging
#
# Usage Example:
#   oi_Assess_Empty_Commit "$commit_hash" || return $?
#----------------------------------------------------------------------#
function oi_Assess_Empty_Commit {
    typeset CommitHash="$1"
    typeset TreeHash EmptyTreeHash
    
    # Parameter validation
    if [[ -z "$CommitHash" ]]; then
        z_Output error "Missing commit hash parameter for emptiness verification"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[content]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Get tree hash from commit object
    TreeHash=$(git cat-file -p "${CommitHash}" | awk '/^tree / {print $2}')
    
    # Get hash of empty tree for comparison
    EmptyTreeHash=$(git hash-object -t tree /dev/null)
    
    # Verify tree hash matches empty tree hash
    if [[ "${TreeHash}" == "${EmptyTreeHash}" ]]; then
        z_Output verbose Indent=4 "Tree hash matches empty commit requirements"
        z_Output success Indent=2 "Content Assessment: Commit is empty as required"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[content]=$TRUE
        
        return $Exit_Status_Success
    else
        z_Output verbose Indent=4 "Tree hash does not match empty commit requirements"
        z_Output error Indent=4 "Content Assessment: Commit is not empty"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[content]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: oi_Assess_Commit_Message_Format
#----------------------------------------------------------------------#
# Description:
#   Part of Progressive Trust Phase 2 (Wholeness). Verifies that the
#   inception commit message follows the required format defined in
#   Open Integrity specifications, including initialization message
#   and proper sign-off.
#
# Parameters:
#   $1 - The commit hash to verify (string) - Must be a valid Git commit ID
#
# Returns:
#   Exit_Status_Success (0) if commit message meets format requirements
#   Exit_Status_Git_Failure (5) if format verification fails or commit cannot be accessed
#
# Required Script Variables:
#   Trust_Assessment_Status - Associative array updated with assessment result
#
# Side Effects:
#   - Updates Trust_Assessment_Status["format"] with result (TRUE/FALSE)
#   - Outputs verification information via z_Output
#
# Dependencies:
#   - Git command-line tools (specifically git log)
#   - z_Output for message formatting
#
# Required Format Elements:
#   - Must contain "Initialize repository and establish a SHA-1 root of trust"
#   - Must include a "Signed-off-by:" line with author attribution
#   - Should follow Open Integrity message structure guidelines
#
# Usage Example:
#   oi_Assess_Commit_Message_Format "$commit_hash" || return $?
#----------------------------------------------------------------------#
function oi_Assess_Commit_Message_Format {
    typeset CommitHash="$1"
    
    # Parameter validation
    if [[ -z "$CommitHash" ]]; then
        z_Output error "Missing commit hash parameter for message format verification"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[format]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Verify commit exists and is accessible
    if ! git log "${CommitHash}" -1 --pretty=%B >/dev/null 2>&1; then
        z_Output error "Unable to retrieve commit message for ${CommitHash}"
        z_Output error "Verify that the commit exists and is accessible"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[format]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Get the commit message
    typeset CommitMessage
    CommitMessage=$(git log "${CommitHash}" -1 --pretty=%B)
    
    # Split message into lines for more structured analysis
    typeset -a MessageLines
    MessageLines=("${(@f)CommitMessage}")
    
    # Initialize verification flags
    typeset -i HasInitMessage=$FALSE
    typeset -i HasSignOff=$FALSE
    
    # Check required elements with Zsh pattern matching
    typeset CurrentLine
    for CurrentLine in $MessageLines; do
        if [[ "$CurrentLine" == "Initialize repository and establish a SHA-1 root of trust" ]]; then
            HasInitMessage=$TRUE
        elif [[ "$CurrentLine" =~ "^Signed-off-by: .+" ]]; then
            HasSignOff=$TRUE
        fi
    done
    
    # Evaluate verification result
    if (( HasInitMessage == TRUE && HasSignOff == TRUE )); then
        z_Output verbose Indent=4 "Found required initialization message and sign-off"
        z_Output success Indent=2 "Format Assessment: Commit message meets requirements"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[format]=$TRUE
        
        return $Exit_Status_Success
    else
        # Provide more detailed error feedback
        if (( HasInitMessage == FALSE )); then
            z_Output error Indent=4 "Missing required initialization message"
        fi
        if (( HasSignOff == FALSE )); then
            z_Output error Indent=4 "Missing required Signed-off-by line"
        fi
        z_Output error Indent=4 "Format Assessment: Commit message incomplete"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[format]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: oi_Authenticate_Ssh_Signature
#----------------------------------------------------------------------#
# Description:
#   Verifies the SSH signature on a Git commit following Git's configuration
#   hierarchy for allowed signers. Part of Progressive Trust Phase 3 (Proofs),
#   this function handles the cryptographic authentication of commit signatures.
#
# Parameters:
#   $1 - The commit hash to verify (string) - Must be a valid Git commit ID
#
# Returns:
#   Exit_Status_Success (0) if signature verification succeeds
#   Exit_Status_Git_Failure (5) if signature verification fails
#   Exit_Status_Config (6) if Git configuration issues are found
#
# Required Script Variables:
#   Trust_Assessment_Status - Associative array updated with assessment result
#
# Side Effects:
#   - Updates Trust_Assessment_Status["signature"] with result (TRUE/FALSE)
#   - Reads Git configuration (both local and global)
#   - Accesses filesystem to read allowed signers file
#   - Outputs verification information via z_Output
#
# Dependencies:
#   - Git command-line tools
#   - z_Output for messaging
#
# Git Configuration Requirements:
#   - gpg.ssh.allowedSignersFile must be configured
#   - Legacy configurations are not supported
#
# Verification Strategy:
#   For inception-only repositories (single commit):
#     - Uses global gpg.ssh.allowedSignersFile
#
#   For repositories with additional commits:
#     1. Local gpg.ssh.allowedSignersFile (if configured)
#     2. Default local allowed_signers file (./.repo/config/verification/allowed_commit_signers)
#     3. Falls back to global gpg.ssh.allowedSignersFile if no local config found
#
# Usage Example:
#   oi_Authenticate_Ssh_Signature "$commit_hash" || return $?
#----------------------------------------------------------------------#
function oi_Authenticate_Ssh_Signature {
    typeset CommitId="$1"
    typeset -a match mbegin mend
    
    # Parameter validation
    if [[ -z "$CommitId" ]]; then
        z_Output error "Missing commit ID parameter for signature verification"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    z_Output debug Indent=4 "oi_Authenticate_Ssh_Signature: Starting with commit $CommitId"
    
    z_Output verbose Indent=4 "Performing multi-step signature verification..."
    
    # Determine if this is an inception-only repository
    typeset -i CommitCount
    CommitCount=$(git rev-list --count HEAD)
    z_Output debug Indent=6 "Repository has $CommitCount commits"
    
    # Step 1: Check for signature presence and format
    z_Output verbose Indent=6 "Step 1: Checking signature format..."
    
    # Read commit object into an array, one line per element
    typeset -a CommitLines SigLines
    typeset Line
    typeset -i InSig=0
    z_Output debug Indent=8 "Reading commit object"
    CommitLines=("${(f)$(command git cat-file commit "$CommitId")}")
    
    # Extract signature block using zsh pattern matching
    z_Output debug Indent=8 "Extracting signature block"
    for Line in $CommitLines; do
        if [[ $Line =~ ^gpgsig ]]; then
            InSig=1
            SigLines+=("${Line#gpgsig }")
            continue
        elif (( InSig )); then
            if [[ $Line =~ ^[^[:space:]] ]]; then
                InSig=0
                continue
            fi
            SigLines+=("${Line# }")
        fi
    done
    
    # Join lines back together
    typeset SigInfo="${(j:\n:)SigLines}"
    z_Output debug Indent=8 "Signature extracted"
    
    if [[ -z "$SigInfo" ]]; then
        z_Output error Indent=4 "No signature found on commit"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    if [[ "$SigInfo" != *"BEGIN SSH SIGNATURE"* ]]; then
        z_Output error Indent=4 "Not an SSH signature"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    z_Output verbose Indent=8 "✓ Recognized SSH signature format found"
    
    # Step 2: Configure and check allowed_signers
    z_Output verbose Indent=6 "Step 2: Checking allowed_signers..."
    
    # Check for legacy configurations
    typeset LegacyFile
    
    # Get and display current configurations
    z_Output debug Indent=8 "Git configuration status:"
    z_Output debug Indent=10 "gpg.ssh.allowedSignersFile: $(git config --get gpg.ssh.allowedSignersFile)"
    
    # Check for legacy configurations that need migration
    LegacyFile=$(git config --get trusted.ssh.allowedSignersFile)
    if [[ -n "$LegacyFile" ]]; then
        z_Output error Indent=4 "Legacy configuration 'trusted.ssh.allowedSignersFile' found"
        z_Output error Indent=4 "Please update your Git configuration:"
        z_Output error Indent=6 "1. Unset legacy config:"
        z_Output error Indent=8 "git config --global --unset trusted.ssh.allowedSignersFile"
        z_Output error Indent=6 "2. Set required config:"
        z_Output error Indent=8 "git config --global gpg.ssh.allowedSignersFile $LegacyFile"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Config
    fi
    
    LegacyFile=$(git config --get gpg.allowedSignersFile)
    if [[ -n "$LegacyFile" ]]; then
        z_Output error Indent=4 "Legacy configuration 'gpg.allowedSignersFile' found"
        z_Output error Indent=4 "Please update your Git configuration:"
        z_Output error Indent=6 "1. Unset legacy config:"
        z_Output error Indent=8 "git config --global --unset gpg.allowedSignersFile"
        z_Output error Indent=6 "2. Set required config:"
        z_Output error Indent=8 "git config --global gpg.ssh.allowedSignersFile $LegacyFile"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Config
    fi
    
    # Check configuration based on repository type
    typeset AllowedSignersFile
    typeset AllowedSignersSource
    
    if (( CommitCount == 1 )); then
        z_Output verbose Indent=6 "Assessing inception-only repository (using global configuration)"
        # For inception-only repos, check global config
        AllowedSignersFile=$(git config --global --get gpg.ssh.allowedSignersFile)
        AllowedSignersSource="global configuration"
    else
        z_Output verbose Indent=6 "Assessing repository with additional commits (checking local configuration first)"
        # For repos with additional commits, check local config first
        AllowedSignersFile=$(git config --local --get gpg.ssh.allowedSignersFile)
        
        if [[ -n "$AllowedSignersFile" ]]; then
            # Local config exists - use it
            AllowedSignersSource="local configuration"
        else
            # Check for default local file
            if [[ -f "./.repo/config/verification/allowed_commit_signers" ]]; then
                z_Output error Indent=4 "Found local allowed_signers file but gpg.ssh.allowedSignersFile not configured"
                z_Output error Indent=4 "Please configure Git:"
                z_Output error Indent=6 "git config --local gpg.ssh.allowedSignersFile ./.repo/config/verification/allowed_commit_signers"
                
                # Update Trust_Assessment_Status
                Trust_Assessment_Status[signature]=$FALSE
                
                return $Exit_Status_Config
            fi
            # Fall back to global configuration
            AllowedSignersFile=$(git config --global --get gpg.ssh.allowedSignersFile)
            AllowedSignersSource="global configuration"
        fi
    fi

    # Display configuration details
    if [[ -f "$AllowedSignersFile" ]]; then
        z_Output debug Indent=8 "File: $AllowedSignersFile ($(stat -f %z "$AllowedSignersFile") bytes)"
        
        typeset FileContent
        FileContent="$(<"$AllowedSignersFile")"
        
        z_Output verbose Indent=8 "Using allowed signers from $AllowedSignersSource"
        z_Output verbose Indent=8 "Current configuration (at $AllowedSignersFile):"
        z_Output verbose Indent=10 "$FileContent"
        z_Output verbose Indent=8 "✓ allowed_signers file found and readable"
 
    else
        z_Output error Indent=4 "allowed_signers file not found at $AllowedSignersFile"
        z_Output error Indent=4 "To configure allowed signers:"
        z_Output error Indent=6 "1. Create the file with your public key:"
        z_Output error Indent=8 "mkdir -p $(dirname "$AllowedSignersFile")"
        z_Output error Indent=8 "echo '@username namespaces=\"git\" $(ssh-keygen -y -f ~/.ssh/id_ed25519)' > $AllowedSignersFile"
        z_Output error Indent=6 "2. Configure Git to use this file:"
        z_Output error Indent=8 "git config --global gpg.ssh.allowedSignersFile $AllowedSignersFile"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$FALSE
        
        return $Exit_Status_Config
    fi
    
    # Step 3: Perform cryptographic verification
    z_Output verbose Indent=6 "Step 3: Verifying signature..."
    typeset SigningKeyInfo
    z_Output debug Indent=8 "Running git verify-commit"
    SigningKeyInfo=$(command git verify-commit "$CommitId" 2>&1)
    z_Output debug Indent=8 "git verify-commit output: $SigningKeyInfo"
    
    if ! command git verify-commit "$CommitId" >/dev/null 2>&1; then
        case "$SigningKeyInfo" in
            *"key is not permitted for use in signature namespace"*)
                z_Output error Indent=4 "Key namespace configuration error"
                z_Output verbose Indent=6 "Check namespaces setting in allowed_signers"
                z_Output error Indent=6 "Ensure your allowed_signers file has 'namespaces=\"git\"' for each entry"
                z_Output error Indent=6 "Example format: @username namespaces=\"git\" ssh-ed25519 AAAAC3NzaC1..."
                
                # Update Trust_Assessment_Status
                Trust_Assessment_Status[signature]=$FALSE
                
                return $Exit_Status_Config
                ;;
            *"gpg.ssh.allowedSignersFile needs to be configured"*)
                z_Output error Indent=4 "Git SSH signature configuration error"
                z_Output error Indent=4 "gpg.ssh.allowedSignersFile must be configured"
                if [[ -n "$(git config --get trusted.ssh.allowedSignersFile)" ]]; then
                    z_Output error Indent=6 "Legacy configuration found. Please update your Git configuration:"
                    z_Output error Indent=8 "git config --global --unset trusted.ssh.allowedSignersFile"
                    z_Output error Indent=8 "git config --global gpg.ssh.allowedSignersFile $(git config --get trusted.ssh.allowedSignersFile)"
                fi
                
                # Update Trust_Assessment_Status
                Trust_Assessment_Status[signature]=$FALSE
                
                return $Exit_Status_Config
                ;;
            *)
                z_Output error Indent=4 "Signature verification failed"
                z_Output verbose Indent=6 "Error message: $SigningKeyInfo"
                z_Output error Indent=6 "Check that your SSH key is correctly configured and available"
                z_Output error Indent=6 "Ensure the key is in the allowed_signers file with correct namespace"
                
                # Update Trust_Assessment_Status
                Trust_Assessment_Status[signature]=$FALSE
                
                return $Exit_Status_Git_Failure
                ;;
        esac
    fi
    
    # Extract and display key details on success
    z_Output debug Indent=8 "Extracting key details"
    if [[ "$SigningKeyInfo" =~ "with ([[:alnum:]]+) key SHA256:([[:alnum:]+/]+)" ]]; then
        typeset KeyType="$match[1]"
        typeset KeyFingerprint="SHA256:$match[2]"
        z_Output verbose Indent=8 "✓ Signature cryptographically verified"
        z_Output verbose Indent=8 "✓ Using $KeyType key: $KeyFingerprint"
        z_Output success Indent=2 "SSH Signature: Verified"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[signature]=$TRUE
        
        return $Exit_Status_Success
    fi
    
    z_Output success Indent=2 "SSH Signature: Verified"
    
    # Update Trust_Assessment_Status
    Trust_Assessment_Status[signature]=$TRUE
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Affirm_Committer_Signature
#----------------------------------------------------------------------#
# Description:
#   Part of Progressive Trust Phase 4 (References). Affirms the identity
#   of the commit author by verifying that the committer name matches the
#   signing key fingerprint, establishing a cryptographic identity link.
#   This verification ensures that the commit attribution is cryptographically
#   tied to the key that signed it.
#
# Parameters:
#   $1 - The commit hash to verify (string) - Must be a valid Git commit ID
#
# Returns:
#   Exit_Status_Success (0) if committer name matches key fingerprint
#   Exit_Status_Git_Failure (5) if verification fails or Git operations fail
#
# Required Script Variables:
#   Trust_Assessment_Status - Associative array updated with verification result
#
# Side Effects:
#   - Updates Trust_Assessment_Status["identity"] with result (TRUE/FALSE)
#   - Outputs verification information via z_Output
#
# Dependencies:
#   - Git command-line tools (git log, git cat-file)
#   - z_Output for messaging
#
# Usage Example:
#   oi_Affirm_Committer_Signature "$commit_hash" || return $?
#----------------------------------------------------------------------#
function oi_Affirm_Committer_Signature {
    typeset CommitHash="$1"
    typeset SigningKeyFingerprint CommitterName
    
    # Parameter validation
    if [[ -z "$CommitHash" ]]; then
        z_Output error "Missing commit hash parameter for identity verification"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[identity]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Verify Git commands will succeed
    if ! git cat-file -e "$CommitHash" 2>/dev/null; then
        z_Output error "Invalid commit reference: $CommitHash"
        z_Output error "Unable to access commit object"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[identity]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Extract the key fingerprint from the signature
    z_Output verbose Indent=4 "Extracting key fingerprint..."
    
    # This command extracts the SHA256 fingerprint from the signature verification output
    SigningKeyFingerprint=$(git log "${CommitHash}" -1 --show-signature --pretty=format:'' | \
                            grep -o "SHA256:[^ ]*")
    
    # Verify we got a valid fingerprint
    if [[ -z "$SigningKeyFingerprint" ]]; then
        z_Output error "Failed to extract signing key fingerprint"
        z_Output error "Ensure the commit is signed with a valid SSH key"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[identity]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
    
    # Get the committer name from the commit
    CommitterName=$(git log "${CommitHash}" -1 --pretty=format:'%cn')
    
    # Compare committer name with fingerprint
    if [[ "${CommitterName}" == "${SigningKeyFingerprint}" ]]; then
        z_Output verbose Indent=4 "Matched committer name to fingerprint"
        z_Output success Indent=2 "Identity Check: Committer matches key fingerprint"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[identity]=$TRUE
        
        return $Exit_Status_Success
    else
        z_Output verbose Indent=4 "Committer name does not match fingerprint"
        z_Output verbose Indent=4 "Committer: $CommitterName"
        z_Output verbose Indent=4 "Fingerprint: $SigningKeyFingerprint"
        z_Output error Indent=4 "Identity Check: Committer does not match key fingerprint"
        z_Output error Indent=6 "For Open Integrity compliance, the committer name must be"
        z_Output error Indent=6 "set to the SSH key fingerprint during commit creation."
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[identity]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: oi_Comply_With_GitHub_Standards
#----------------------------------------------------------------------#
# Description:
#   Implements Phase 5 (Requirements/Community Standards) of Progressive 
#   Trust by checking compliance with GitHub's standards for signed
#   commits and repository initialization. This verification is optional
#   and only applicable for repositories hosted on GitHub.
#
# Parameters:
#   $1 - The SHA-1 hash of the inception commit to check (string)
#        Must be a valid Git commit SHA
#
# Returns:
#   Exit_Status_Success (0) if compliance check succeeds
#   Exit_Status_Git_Failure (5) if compliance check fails or GitHub access fails
#
# Required Script Variables:
#   Output_Prompt_Enabled - Controls interactive prompt behavior
#   Trust_Assessment_Status - Associative array updated with verification result
#
# Side Effects:
#   - Updates Trust_Assessment_Status["standards"] with result (TRUE/FALSE)
#   - May open a web browser if running interactively
#   - Outputs compliance information via z_Output
#
# Dependencies:
#   - gh CLI tool (GitHub CLI)
#   - Git command-line tools
#   - z_Output for messaging
#   - Web browser (when interactive confirmation is requested)
#
# Usage Example:
#   oi_Comply_With_GitHub_Standards "$commit_hash" || return $?
#----------------------------------------------------------------------#
function oi_Comply_With_GitHub_Standards {
    typeset CommitSha="$1"
    typeset GithubRepo GithubOrgId Response
    
    # Parameter validation
    if [[ -z "$CommitSha" ]]; then
        z_Output error Indent=4 "Missing commit SHA for GitHub standards compliance"
        
        # Update Trust_Assessment_Status
        Trust_Assessment_Status[standards]=$FALSE
        
        return $Exit_Status_Git_Failure
    fi

    # Check GitHub repository accessibility
    if ! command -v gh >/dev/null 2>&1; then
        z_Output warn "GitHub CLI (gh) not found - skipping GitHub standards check"
        z_Output warn "Install gh from https://cli.github.com/ for GitHub integration"
        
        # Standards is a non-critical assessment so we set it to TRUE and continue
        Trust_Assessment_Status[standards]=$TRUE
        
        # Return success since this is a non-critical check
        return $Exit_Status_Success
    fi

    # Verify we can access GitHub repo info
    if ! gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null >/dev/null; then
        z_Output warn "Repository not on GitHub or 'gh' CLI not authenticated."
        z_Output warn "Run 'gh auth login' to authenticate with GitHub."
        
        # Standards is a non-critical assessment so we set it to TRUE and continue
        Trust_Assessment_Status[standards]=$TRUE
        
        # Return success since this is a non-critical check
        return $Exit_Status_Success
    fi

    # Extract GitHub repository information from remote.origin.url
    if ! git config --get remote.origin.url >/dev/null 2>&1; then
        z_Output warn "No GitHub remote found - skipping GitHub standards check"
        z_Output warn "Add a GitHub remote with: git remote add origin https://github.com/owner/repo.git"
        
        # Standards is a non-critical assessment so we set it to TRUE and continue
        Trust_Assessment_Status[standards]=$TRUE
        
        # Return success since this is a non-critical check
        return $Exit_Status_Success
    fi
    
    # Extract repository owner and name from remote URL
    GithubRepo=$(basename "$(git config --get remote.origin.url)" .git)
    GithubOrgId=$(basename "$(dirname "$(git config --get remote.origin.url)")")
    typeset GithubUrl="https://github.com/${GithubOrgId}/${GithubRepo}/commit/${CommitSha}"
    
    # Phase 5 header and information
    z_Output info "Community Standards:"
    z_Output verbose Emoji="" "(Progressive Trust Phase 5)"
    z_Output info Indent=2 Emoji="🌐" "GitHub-specific compliance check available"

    # Handle interactive vs non-interactive mode
    if (( Output_Prompt_Enabled != TRUE )); then
        Response="N"
    else
        Response=$(z_Output prompt "Check compliance with GitHub standards (opens GitHub page)? [y/N]:" Default="N" Indent=4 )
    fi

    # Process response and provide compliance info
    case "${Response:-N}" in
        [Yy]*)
            z_Output verbose "Opening GitHub standards compliance page..."
            if command -v open >/dev/null 2>&1; then
                open "$GithubUrl"
            elif command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$GithubUrl"
            else
                z_Output warn "No browser open command found. Please visit manually:"
                z_Output warn "$GithubUrl"
            fi
            ;;
        *)
            z_Output verbose Indent=4 "GitHub standards compliance URL available for review:"
            z_Output verbose "${GithubUrl}" Emoji=""
            ;;
    esac

    # Update Trust_Assessment_Status
    Trust_Assessment_Status[standards]=$TRUE
    
    # If we get here, it means the repository is properly connected to GitHub
    # Set a global variable to track this for the parent function
    export Is_GitHub_Repository=$TRUE
    
    return $Exit_Status_Success
}

########################################################################
## SECTION: Orchestration Layer - Argument Processing and Execution Flow
##--------------------------------------------------------------------##
## Description:
##   This layer manages argument processing, parameter handling, and 
##   orchestrates the execution of audit phases. It contains functions 
##   for processing command-line arguments, displaying help, coordinating
##   verification phases, and managing execution flow.
##
## Architectural Role:
##   The Orchestration Layer sits between the Domain Layer and Controller
##   Layer, managing workflow sequencing and coordinating the execution
##   of domain-specific functions. It processes user input and orchestrates
##   the execution of the audit process.
##
## Design Philosophy:
##   - Two-Phase Argument Processing: Separate framework and domain arguments
##   - Clear Parameter Validation: Validate all inputs before execution
##   - Modular Execution Flow: Divide audit process into logical phases
##   - Progressive Trust Implementation: Execute verification phases in sequence
##   - User-Friendly Feedback: Provide clear outputs and status information
##
## Functions (in reverse dependency order):
##   - show_Usage: Displays help and usage information
##   - handler_Change_Directory: Handles directory change requests
##   - z_Parse_Initial_Arguments: First-phase argument processing (framework)
##   - parse_Remaining_Arguments: Second-phase argument processing (domain)
##   - execute_Audit_Phases: Coordinates execution of audit phases
##
## Naming Convention:
##   - Framework argument handlers prefixed with "z_"
##   - Domain-specific handlers have no prefix
##   - Handler functions prefixed with "handler_"
##
## Dependencies:
##   - Foundation Layer environment variables and constants
##   - Utility Layer z_Utils functions
##   - Domain Layer oi_Utils functions for audit execution
##
## Notes:
##   This section implements the orchestration logic that coordinates
##   the execution of specific Open Integrity verification phases.
########################################################################

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Displays usage information and help text for the script, including
#   available options, audit phases, and usage examples. This function
#   is called when the -h/--help flag is provided or when invalid
#   arguments are detected.
#
# Parameters:
#   None
#
# Returns:
#   Does not return - exits with Exit_Status_Success (0)
#
# Required Script Variables:
#   Script_Name - Script filename for display in usage text
#   Script_Version - Current version number for display
#   Script_FileName - Script filename for display in examples
#   Exit_Status_Success - Success exit code
#
# Side Effects:
#   - Outputs usage information to stdout
#   - Exits the script with Exit_Status_Success
#
# Dependencies:
#   None - Self-contained function
#
# Usage Example:
#   show_Usage  # Called directly when -h/--help is provided
#----------------------------------------------------------------------#
function show_Usage {
    cat <<EOF
$Script_Name v$Script_Version - Progressive Trust Audit for Git Repository Inception Commits

CURRENT LIMITATIONS:
  Requires external commands: Git 2.34+, OpenSSH 8.2+, gh CLI (optional)

USAGE:
  ${Script_FileName} [options]

OPTIONS:
  -C, --chdir <path>    Change to specified directory before execution
  -v, --verbose         Enable detailed progress messages
  -q, --quiet           Suppress non-essential output
  -d, --debug           Show debug information for troubleshooting
  -n, --no-color        Disable colored output
  -c, --color           Force colored output
  -p, --no-prompt       Run non-interactively
  -i, --interactive     Force interactive prompts
  -h, --help            Show this help message

AUDIT PHASES:
  Phase 2 (Wholeness)    Assesses structural integrity and message format
  Phase 3 (Proofs)       Verifies cryptographic SSH signatures
  Phase 4 (References)   Affirms committer identity against authorized keys
  Phase 5 (Requirements) Audits GitHub community standards compliance

EXAMPLES:
  Standard audit:
    ${Script_FileName} -C /path/to/repo
  Detailed output:
    ${Script_FileName} --verbose -C /path/to/repo
  Non-interactive mode:
    ${Script_FileName} --quiet --no-prompt -C /path/to/repo
EOF

    exit $Exit_Status_Success  # Exit directly instead of return to main script
}

#----------------------------------------------------------------------#
# Function: handler_Change_Directory
#----------------------------------------------------------------------#
# Description:
#   Handles the -C/--chdir argument by validating the specified directory
#   and changing to it if valid. This dedicated handler ensures proper
#   validation and error reporting for directory changes.
#
# Parameters:
#   $1 - Directory path to change to (string) - Must be a valid directory path
#
# Returns:
#   Exit_Status_Success (0) if directory change succeeds
#   Exit_Status_IO (3) if directory is invalid or cannot be accessed
#
# Required Script Variables:
#   Working_Directory - Updated with the validated directory path
#
# Side Effects:
#   - Changes the current working directory
#   - Updates Working_Directory with validated path
#   - May output error messages on validation failure
#
# Dependencies:
#   - z_Report_Error for error reporting
#
# Usage Example:
#   handler_Change_Directory "/path/to/repo" || return $?
#----------------------------------------------------------------------#
function handler_Change_Directory {
    typeset DirectoryPath="$1"
    
    # Validate directory exists
    if [[ ! -d "$DirectoryPath" ]]; then
        z_Report_Error "Invalid directory path: $DirectoryPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi
    
    # Validate directory is accessible
    if [[ ! -r "$DirectoryPath" ]]; then
        z_Report_Error "Directory not readable: $DirectoryPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi
    
    # Change to the specified directory
    if ! cd "$DirectoryPath"; then
        z_Report_Error "Failed to change to directory: $DirectoryPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi
    
    # Update Working_Directory with validated path
    Working_Directory="$DirectoryPath"
    z_Output debug "Changed working directory to: $DirectoryPath"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Parse_Initial_Arguments
#----------------------------------------------------------------------#
# Description:
#   First phase of argument processing that handles framework-level
#   arguments (verbose, debug, color, etc.). This function implements
#   the two-phase argument processing approach, focusing on arguments
#   that affect script behavior rather than domain-specific options.
#
# Parameters:
#   $@ - Command line arguments
#
# Returns:
#   Exit_Status_Success (0) if arguments are successfully parsed
#   Exit_Status_Usage (2) if argument parsing fails
#
# Required Script Variables:
#   Output_Verbose_Mode - Set based on -v/--verbose flag
#   Output_Quiet_Mode - Set based on -q/--quiet flag
#   Output_Debug_Mode - Set based on -d/--debug flag
#   Output_Color_Enabled - Set based on color-related flags
#   Output_Prompt_Enabled - Set based on interaction mode flags
#
# Side Effects:
#   - Sets script-scoped execution flags based on provided options
#   - May output debug messages for parsing status
#
# Dependencies:
#   - show_Usage for help display
#   - handler_Change_Directory for directory change handling
#
# Usage Example:
#   z_Parse_Initial_Arguments "$@" || exit $?
#----------------------------------------------------------------------#
function z_Parse_Initial_Arguments {
    # Store initial state for potential rollback
    typeset -i InitialVerbose=$Output_Verbose_Mode
    typeset -i InitialQuiet=$Output_Quiet_Mode
    typeset -i InitialDebug=$Output_Debug_Mode
    typeset -i InitialColor=$Output_Color_Enabled
    typeset -i InitialPrompt=$Output_Prompt_Enabled
    
    # Track if help was requested
    typeset -i HelpRequested=$FALSE
    
    # Process arguments one by one for maximum control
    while (( $# > 0 )); do
        case "$1" in
            # Output control options
            -v|--verbose)
                Output_Verbose_Mode=$TRUE
                shift
                ;;
            -q|--quiet)
                Output_Quiet_Mode=$TRUE
                shift
                ;;
            -d|--debug)
                Output_Debug_Mode=$TRUE
                shift
                ;;
                
            # Color control options
            -n|--no-color)
                Output_Color_Enabled=$FALSE
                shift
                ;;
            -c|--color)
                Output_Color_Enabled=$TRUE
                shift
                ;;
                
            # Interaction mode options
            -p|--no-prompt)
                Output_Prompt_Enabled=$FALSE
                shift
                ;;
            -i|--interactive)
                Output_Prompt_Enabled=$TRUE
                shift
                ;;
                
            # Directory change option (handled separately in phase 2)
            -C|--chdir)
                # Skip here, will be processed in parse_Remaining_Arguments
                shift 2
                ;;
                
            # Help option
            -h|--help)
                HelpRequested=$TRUE
                shift
                ;;
                
            # Unknown option or end of options
            -*)
                z_Report_Error "Unknown option: $1" $Exit_Status_Usage
                show_Usage
                ;;
            *)
                # Not a framework argument, leave for phase 2
                break
                ;;
        esac
    done
    
    # Handle help request immediately
    if (( HelpRequested )); then
        show_Usage
    fi
    
    # Environment variable overrides (if not explicitly set by flags)
    # NO_COLOR standard
    if [[ -n "$Script_No_Color" && $Output_Color_Enabled != $FALSE ]]; then
        Output_Color_Enabled=$FALSE
    fi
    
    # FORCE_COLOR standard
    if [[ -n "$Script_Force_Color" && $Output_Color_Enabled != $TRUE ]]; then
        Output_Color_Enabled=$TRUE
    fi
    
    # CI environment detection
    if [[ -n "$Script_CI" && $Output_Prompt_Enabled != $FALSE ]]; then
        Output_Prompt_Enabled=$FALSE
    fi
    
    # Terminal capability detection
    if [[ "$Script_Term" == "dumb" && $Output_Color_Enabled != $FALSE ]]; then
        Output_Color_Enabled=$FALSE
    fi
    
    # Log processed arguments if in debug mode
    if (( Output_Debug_Mode )); then
        z_Output debug "Framework argument processing:"
        z_Output debug "  Verbose Mode: $Output_Verbose_Mode"
        z_Output debug "  Debug Mode: $Output_Debug_Mode"
        z_Output debug "  Quiet Mode: $Output_Quiet_Mode"
        z_Output debug "  Color Enabled: $Output_Color_Enabled"
        z_Output debug "  Prompt Enabled: $Output_Prompt_Enabled"
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Remaining_Arguments
#----------------------------------------------------------------------#
# Description:
#   Second phase of argument processing that handles domain-specific
#   arguments (like repository path). This function is called after
#   z_Parse_Initial_Arguments to process the remaining arguments.
#
# Parameters:
#   $@ - Remaining command line arguments
#
# Returns:
#   Exit_Status_Success (0) if arguments are successfully parsed
#   Exit_Status_Usage (2) if argument parsing fails
#   Exit_Status_IO (3) if directory change fails
#
# Required Script Variables:
#   Working_Directory - Updated with repository path if -C/--chdir specified
#
# Side Effects:
#   - May change current working directory if -C/--chdir is specified
#   - May output error messages on validation failure
#
# Dependencies:
#   - handler_Change_Directory for directory change handling
#   - z_Report_Error for error reporting
#   - show_Usage for help display
#
# Usage Example:
#   parse_Remaining_Arguments "$@" || exit $?
#----------------------------------------------------------------------#
function parse_Remaining_Arguments {
    # Track directory change argument
    typeset DirectoryPath=""
    
    # Process arguments one by one
    while (( $# > 0 )); do
        case "$1" in
            # Directory change option
            -C|--chdir)
                if (( $# < 2 )); then
                    z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                    show_Usage
                fi
                DirectoryPath="$2"
                shift 2
                ;;
                
            # Framework arguments (already handled in phase 1)
            -v|--verbose|-q|--quiet|-d|--debug|-n|--no-color|-c|--color|-p|--no-prompt|-i|--interactive|-h|--help)
                # Skip these as they were already processed
                shift
                ;;
                
            # Unknown option
            -*)
                z_Report_Error "Unknown option: $1" $Exit_Status_Usage
                show_Usage
                ;;
                
            # Positional argument (not currently supported)
            *)
                z_Report_Error "Unexpected argument: $1" $Exit_Status_Usage
                show_Usage
                ;;
        esac
    done
    
    # Handle directory change if specified
    if [[ -n "$DirectoryPath" ]]; then
        if ! handler_Change_Directory "$DirectoryPath"; then
            return $Exit_Status_IO
        fi
    fi
    
    # Log processing completion in debug mode
    if (( Output_Debug_Mode )); then
        z_Output debug "Domain argument processing complete"
        if [[ -n "$Working_Directory" ]]; then
            z_Output debug "  Working Directory: $Working_Directory"
        fi
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: execute_Audit_Phases
#----------------------------------------------------------------------#
# Description:
#   Coordinates the execution of Progressive Trust audit phases for
#   inception commit assessment. This function orchestrates the
#   process by calling domain-specific functions in sequential order
#   and tracking results.
#
# Parameters:
#   None
#
# Returns:
#   Exit_Status_Success (0) if all local assessment phases (1-3) pass
#   Exit_Status_General (1) if any local assessment phase fails
#   Exit_Status_Git_Failure (5) if repository structure checks fail
#
# Required Script Variables:
#   Inception_Commit_Repo_Id - Set to inception commit hash for assessment
#   Repo_DID - Set to repository DID
#   Trust_Assessment_Status - Associative array tracking assessment results
#
# Side Effects:
#   - Updates Trust_Assessment_Status array with assessment results
#   - Produces assessment status output
#   - Updates Inception_Commit_Repo_Id and Repo_DID
#
# Dependencies:
#   - Domain Layer functions:
#     * oi_Locate_Inception_Commit
#     * oi_Assess_Empty_Commit
#     * oi_Assess_Commit_Message_Format
#     * oi_Authenticate_Ssh_Signature
#     * oi_Affirm_Committer_Signature
#     * oi_Comply_With_GitHub_Standards
#   - z_Output for status messaging
#
# Usage Example:
#   execute_Audit_Phases || return $?
#----------------------------------------------------------------------#
function execute_Audit_Phases {
    # Initialize audit state tracking for local phases (phases 1-3)
    typeset -i LocalAssessmentSuccess=$TRUE
    
    # Initialize audit state tracking for remote phases (phases 4-5)
    typeset -i RemoteAssessmentSuccess=$TRUE

    # Main audit header
    z_Output info "\nInception Commit Audit Report" Emoji=""
    z_Output verbose Emoji="" "Evaluating overall inception commit compliance with standards..."
    z_Output verbose Emoji="" ""

    #----------------------------------------------------------------------#
    # PHASE 2: WHOLENESS ASSESSMENT (LOCAL)
    #----------------------------------------------------------------------#
    z_Output info "Wholeness Assessment:"
    z_Output verbose Emoji="" "(Progressive Trust Phase 2)"
    
    # Track that these checks are part of phase 2 (local)
    Trust_Assessment_Status[structure_phase]=2
    Trust_Assessment_Status[content_phase]=2
    Trust_Assessment_Status[format_phase]=2
    
    # Assessment 1: Repository structure (phase 2)
    z_Output verbose Indent=2 Emoji="📌" "Assessing repository structure..."
    if ! oi_Locate_Inception_Commit; then
        return $Exit_Status_Git_Failure
    fi

    # Assessment 2: Commit content (phase 2)
    z_Output verbose Emoji="" ""
    z_Output verbose Indent=2 Emoji="📌" "Assessing commit content..."
    if ! oi_Assess_Empty_Commit "$Inception_Commit_Repo_Id"; then
        LocalAssessmentSuccess=$FALSE
    fi

    # Assessment 3: Message format (phase 2)
    z_Output verbose Emoji="" ""
    z_Output verbose Indent=2 Emoji="📌" "Assessing message format..."
    if ! oi_Assess_Commit_Message_Format "$Inception_Commit_Repo_Id"; then
        LocalAssessmentSuccess=$FALSE
    fi

    #----------------------------------------------------------------------#
    # PHASE 3: CRYPTOGRAPHIC PROOFS (LOCAL)
    #----------------------------------------------------------------------#
    z_Output verbose Emoji="" ""
    z_Output info "Cryptographic Proofs:"
    z_Output verbose Emoji="" "(Progressive Trust Phase 3)"
    
    # Track that this check is part of phase 3 (local)
    Trust_Assessment_Status[signature_phase]=3
    
    # Assessment 4: SSH signature verification (phase 3)
    z_Output verbose Indent=2 Emoji="📌" "Authenticating SSH signature..."
    if ! oi_Authenticate_Ssh_Signature "$Inception_Commit_Repo_Id"; then
        LocalAssessmentSuccess=$FALSE
    fi

    #----------------------------------------------------------------------#
    # PHASE 4: TRUST REFERENCES (REMOTE)
    #----------------------------------------------------------------------#
    z_Output verbose Emoji="" ""
    z_Output info "Trust References:"
    z_Output verbose Emoji="" "(Progressive Trust Phase 4)"
    
    # Track that this check is part of phase 4 (remote)
    Trust_Assessment_Status[identity_phase]=4
    
    # Assessment 5: Identity references (phase 4)
    z_Output verbose Indent=2 Emoji="📌" "Affirming identity references..."
    if ! oi_Affirm_Committer_Signature "$Inception_Commit_Repo_Id"; then
        # Remote assessment failure - don't affect exit code
        RemoteAssessmentSuccess=$FALSE
        z_Output warn Indent=2 "Identity reference issue (non-critical for local assessment)"
    fi

    # Reference to other useful local git commands with shortened SHA
    z_Output verbose Emoji="" ""
    z_Output verbose Indent=2 Emoji="" "Other useful local git commands (for reference):"
    z_Output verbose Indent=4 Emoji="" "View inception commit details:      git log ${Inception_Commit_Repo_Id:0:7} -1"
    z_Output verbose Indent=4 Emoji="" "View inception commit structure:    git cat-file -p ${Inception_Commit_Repo_Id:0:7}"
    z_Output verbose Indent=4 Emoji="" "Verify inception commit signature:  git verify-commit ${Inception_Commit_Repo_Id:0:7}"
    z_Output verbose Emoji="" ""
    
    #----------------------------------------------------------------------#
    # PHASE 5: STANDARDS COMPLIANCE (REMOTE)
    #----------------------------------------------------------------------#
    # Initialize GitHub repository flag
    typeset -i Is_GitHub_Repository=$FALSE
    
    # Track that this check is part of phase 5 (remote)
    Trust_Assessment_Status[standards_phase]=5

    # Standards Compliance (Phase 5) checks - non-critical
    if ! oi_Comply_With_GitHub_Standards "${Inception_Commit_Repo_Id}"; then
        # Non-critical failure, we continue without affecting overall result
        z_Output warn "GitHub compliance check skipped or failed (non-critical for local assessment)"
        RemoteAssessmentSuccess=$FALSE
        Is_GitHub_Repository=$FALSE
    else
        # GitHub standards check succeeded - repository is on GitHub
        Is_GitHub_Repository=$TRUE
    fi

    #----------------------------------------------------------------------#
    # DETERMINE EXIT STATUS
    #----------------------------------------------------------------------#
    # Return appropriate exit status based on local assessment success
    if (( LocalAssessmentSuccess == TRUE )); then
        # All local assessment phases passed (phases 1-3), return success
        # regardless of remote assessment status (phases 4-5)
        return $Exit_Status_Success
    else
        # One or more local assessment phases failed (phases 1-3)
        return $Exit_Status_General
    fi
}

########################################################################
## SECTION: Controller Layer - Main Execution Logic
##--------------------------------------------------------------------##
## Description:
##   This layer contains the highest-level functions that coordinate
##   the entire script execution. It manages the initialization,
##   entry point, and final result presentation, serving as the
##   top-level control for the entire script.
##
## Architectural Role:
##   The Controller Layer is the top layer in the script's architecture.
##   It provides the script entry point, establishes signal handling,
##   initializes the environment, and delegates to lower layers while
##   maintaining proper error propagation and cleanup.
##
## Design Philosophy:
##   - Clear Entry Point: Provide a single, well-defined entry point (main)
##   - Separation of Concerns: Delegate specialized operations to lower layers
##   - Robust Error Handling: Ensure proper error propagation and reporting
##   - Clean Termination: Handle signals and ensure proper cleanup
##
## Functions (in reverse dependency order):
##   - core_Logic: Coordinates the main audit workflow and reporting
##   - main: Script entry point, initializes environment and processes arguments
##
## Naming Convention:
##   - main: Standardized name for the script entry point
##   - core_Logic: Main workflow coordinator
##
## Dependencies:
##   - Foundation Layer environment variables and constants
##   - Utility Layer z_Utils functions
##   - Orchestration Layer functions for argument processing and execution
##
## Notes:
##   This section implements the highest-level control logic for the 
##   script. The main function is the entry point, while core_Logic 
##   handles top-level workflow and result presentation.
########################################################################

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Coordinates the main audit workflow, managing the execution of
#   assessment phases and presenting results. This function is
#   responsible for the overall flow of the audit process.
#
# Parameters:
#   None
#
# Returns:
#   Exit_Status_Success (0) if all local assessment phases (1-3) pass
#   Exit_Status_General (1) if any local assessment phase fails
#
# Required Script Variables:
#   Inception_Commit_Repo_Id - Inception commit hash from audit process
#   Repo_DID - Repository DID from audit process
#   Trust_Assessment_Status - Associative array tracking assessment results
#   Output_Verbose_Mode - Controls output verbosity
#
# Side Effects:
#   - Produces audit summary output
#   - May open web browser for GitHub compliance check
#
# Dependencies:
#   - execute_Audit_Phases for running assessment phases
#   - z_Output for status messaging
#   - z_Convert_Path_To_Relative for path display
#
# Usage Example:
#   core_Logic || exit $?
#----------------------------------------------------------------------#
function core_Logic {
    # Execute audit phases
    typeset AuditExitCode
    execute_Audit_Phases
    AuditExitCode=$?
    z_Output debug "Exit code from execute_Audit_Phases: $AuditExitCode"
    
    # Display trust assessment summary based on verbosity mode
    if ! (( Output_Verbose_Mode )); then
        # Condensed summary for non-verbose mode
        z_Output info "\nTrust Assessment Results:"
        
        # Use the phase information to categorize into local vs remote phases
        # Local phases (1-3) - affect exit code
        # Use proper zsh conditional expressions for emoji selection
        typeset StructureEmoji="❌"
        if (( ${Trust_Assessment_Status[structure]:-0} == TRUE )); then
            StructureEmoji="✅"
        fi
        
        typeset SignatureEmoji="❌"
        if (( ${Trust_Assessment_Status[signature]:-0} == TRUE )); then
            SignatureEmoji="✅"
        fi
        
        z_Output info Indent=2 Emoji="$StructureEmoji" "Wholeness (structure, content, format) - Phase 2"
        z_Output info Indent=2 Emoji="$SignatureEmoji" "Cryptographic Proofs (signature) - Phase 3"
        
        # Remote phases (4-5) - don't affect exit code, shown as warnings if failed
        typeset IdentityEmoji="⚠️"
        if (( ${Trust_Assessment_Status[identity]:-0} == TRUE )); then
            IdentityEmoji="✅"
        fi
        
        typeset StandardsEmoji="⚠️"
        if (( ${Trust_Assessment_Status[standards]:-0} == TRUE )); then
            StandardsEmoji="✅"
        fi
        
        typeset IdentityWarning=""
        if (( ${Trust_Assessment_Status[identity]:-0} != TRUE )); then
            IdentityWarning=" (warning only)"
        fi
        
        typeset StandardsWarning=""
        if (( ${Trust_Assessment_Status[standards]:-0} != TRUE )); then
            StandardsWarning=" (warning only)"
        fi
        
        z_Output info Indent=2 Emoji="$IdentityEmoji" "Trust References (identity) - Phase 4${IdentityWarning}"
        z_Output info Indent=2 Emoji="$StandardsEmoji" "Community Standards (GitHub) - Phase 5${StandardsWarning}"
        z_Output info Emoji="" ""
    else
        # Comprehensive assessment summary for verbose mode
        z_Output verbose Emoji="" "\nTrust Assessment Summary:"
        typeset CurrentPhase StatusValue StatusIcon PhaseNum PhaseType
        
        for CurrentPhase in "structure" "content" "format" "signature" "identity" "standards"; do
            StatusValue="${Trust_Assessment_Status[$CurrentPhase]:-0}"
            PhaseNum="${Trust_Assessment_Status[${CurrentPhase}_phase]:-0}"
            
            # Determine if this is a local phase (affects exit code) or remote phase (warning only)
            if (( PhaseNum <= 3 )); then
                PhaseType="(local - affects exit code)"
                if (( StatusValue == TRUE )); then
                    StatusIcon="✅"
                else
                    StatusIcon="❌"
                fi
            else
                PhaseType="(remote - warning only)"
                if (( StatusValue == TRUE )); then
                    StatusIcon="✅"
                else
                    StatusIcon="⚠️"
                fi
            fi
            
            z_Output verbose Indent=2 Emoji="" "$StatusIcon Phase $PhaseNum assessment: $CurrentPhase $PhaseType"
        done
    fi
    
    # Calculate local vs. remote phase status
    typeset -i LocalPhasesPassed=0
    typeset -i LocalPhasesTotal=0
    typeset -i RemotePhasesPassed=0
    typeset -i RemotePhasesTotal=0
    
    # Count phases by type
    typeset CheckPhase PhaseNum
    for CheckPhase in structure content format signature identity standards; do
        # Get phase number
        PhaseNum="${Trust_Assessment_Status[${CheckPhase}_phase]:-0}"
        
        # Process based on phase type
        if (( PhaseNum <= 3 )); then
            # Local phases (1-3)
            (( LocalPhasesTotal++ ))
            if (( ${Trust_Assessment_Status[$CheckPhase]:-0} == TRUE )); then
                (( LocalPhasesPassed++ ))
            fi
        else
            # Remote phases (4-5)
            (( RemotePhasesTotal++ ))
            if (( ${Trust_Assessment_Status[$CheckPhase]:-0} == TRUE )); then
                (( RemotePhasesPassed++ ))
            fi
        fi
    done
    
    # Get relative path for repository
    typeset RepoRelativePath
    RepoRelativePath="$(z_Convert_Path_To_Relative "$PWD")"
    
    # Final audit status - based on local phases only (1-3)
    # Debug the final exit code decision
    z_Output debug "Making exit code decision. AuditExitCode=$AuditExitCode, Exit_Status_Success=$Exit_Status_Success"
    
    if (( AuditExitCode == Exit_Status_Success )); then
        # All local phases passed
        if (( RemotePhasesPassed == RemotePhasesTotal )); then
            # All phases passed, local and remote
            z_Output success Emoji="🎯" "Audit Complete: Git repo at \`$RepoRelativePath\` (DID: $Repo_DID)\n   in compliance with Open Integrity specification for Inception Commits." Force=1
            z_Output verbose Emoji="" Indent=3 "(Progressive Trust phases 1-5 passed.)"
        else
            # Local phases passed, but some remote phases had warnings
            z_Output success Emoji="🎯" "Audit Complete: Git repo at \`$RepoRelativePath\` (DID: $Repo_DID)\n   in compliance with Open Integrity specification for local assessment.\n   Some remote assessment warnings noted." Force=1
            z_Output verbose Emoji="" Indent=3 "(Progressive Trust phases 1-3 passed, phases 4-5 have warnings.)"
        fi
        z_Output debug "Returning Exit_Status_Success=$Exit_Status_Success"
        exit $Exit_Status_Success  # Use exit instead of return to force the exit code
    else
        # Some local phases failed
        z_Output error Emoji="❌" "Audit Complete: Git repo at \`$RepoRelativePath\` (DID: $Repo_DID)\n   has critical issues with Open Integrity specification compliance." Force=1
        z_Output verbose Emoji="" Indent=3 "(Some Progressive Trust local phases 1-3 failed.)"
        z_Output debug "Returning Exit_Status_General=$Exit_Status_General"
        exit $Exit_Status_General  # Use exit instead of return to force the exit code
    fi
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Script entry point that handles initialization, argument processing,
#   and orchestrates the overall script execution. This function 
#   implements proper error handling, signal trapping, and cleanup.
#
# Parameters:
#   $@ - Command line arguments passed to the script
#
# Returns:
#   Exit_Status_Success (0) on successful execution
#   Various error codes on failure:
#   - Exit_Status_General (1) on general execution error
#   - Exit_Status_Usage (2) on invalid arguments
#   - Exit_Status_Dependency (127) on missing dependencies
#   - 130 on SIGINT (Ctrl+C)
#   - 143 on SIGTERM
#
# Required Script Variables:
#   Script_Running - Flag to prevent recursive execution
#
# Side Effects:
#   - Sets up signal handlers
#   - Initializes script environment
#   - Processes command-line arguments
#   - Executes the main audit workflow
#   - Performs cleanup on exit
#
# Dependencies:
#   - z_Setup_Environment for environment initialization
#   - z_Parse_Initial_Arguments for framework argument processing
#   - parse_Remaining_Arguments for domain argument processing
#   - core_Logic for main workflow execution
#   - z_Cleanup for resource cleanup
#
# Usage Example:
#   main "$@"  # Called by the script execution gateway
#----------------------------------------------------------------------#
function main {
    typeset ExitCode=0
    typeset ErrorMsg=""

    # Prevent recursive execution
    if (( Script_Running )); then
        z_Output error "Error: Recursive script execution detected"
        return $Exit_Status_General
    fi
    Script_Running=$TRUE

    # Setup error handling and cleanup
    trap 'z_Cleanup $TRUE ""' EXIT
    trap 'z_Cleanup $FALSE "Script interrupted by user"; return 130' INT
    trap 'z_Cleanup $FALSE "Script terminated by system"; return 143' TERM

    # Initialize environment
    if ! z_Setup_Environment; then
        ErrorMsg="Failed to initialize environment"
        ExitCode=$Exit_Status_Dependency
        z_Output error "${ErrorMsg}"
        return $ExitCode
    fi

    # Two-phase argument processing
    # Phase 1: Framework arguments
    if ! z_Parse_Initial_Arguments "$@"; then
        # Special case: help flag (function exits directly)
        ErrorMsg="Failed to parse framework arguments"
        ExitCode=$Exit_Status_Usage
        z_Output error "${ErrorMsg}"
        return $ExitCode
    fi
    
    # Phase 2: Domain-specific arguments
    if ! parse_Remaining_Arguments "$@"; then
        ErrorMsg="Failed to parse domain arguments"
        ExitCode=$Exit_Status_Usage
        z_Output error "${ErrorMsg}"
        return $ExitCode
    fi

    # Debug output if enabled
    if (( Output_Debug_Mode )); then
        z_Output debug "Starting script execution:"
        z_Output debug "- Script path: $Script_RealFilePath"
        z_Output debug "- Arguments: $Cmd_Args_String"
        z_Output debug "- Working directory: $PWD"
    fi

    # Run the core functionality
    if ! core_Logic; then
        ErrorMsg="Script execution failed."
        ExitCode=$Exit_Status_General
        z_Output debug "${ErrorMsg}"
        return $ExitCode
    fi

    # Success
    if (( Output_Debug_Mode )); then
        z_Output debug "Script completed successfully"
    fi

    return $Exit_Status_Success
}

########################################################################
## SCRIPT EXECUTION GATEWAY
##--------------------------------------------------------------------##
## Description:
##   This section determines how and when the script actually executes.
##   It checks if the file is being run directly (as a main program) or 
##   if it's merely being sourced by another script/library. If it's run 
##   directly, it calls the main() function to begin execution.
##
## Design Philosophy:
##   - Prevent automatic execution when sourced
##   - Provide a clean exit with proper status code
##   - Maintain clear separation between declaration and execution
##
## Implementation:
##   - Uses Zsh-specific syntax to detect direct execution
##   - Calls main() only when executed directly
##   - Propagates exit status from main()
##
## Notes:
##   - ${(%):-%N} expands to the script name when run directly,
##     but to the function name when sourced
##   - This differs from Bash's equivalent test:
##     [[ "${BASH_SOURCE[0]}" == "${0}" ]]
########################################################################

# Execute main() only if this script is being run directly (not sourced).
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
    exit $?  # Explicitly propagate the exit status from main
fi

########################################################################
## END of Script `audit_inception_commit-POC.sh`
########################################################################
