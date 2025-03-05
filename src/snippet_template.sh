#!/usr/bin/env zsh
########################################################################
## Script:        snippet_template.sh
## Version:       0.1.00 (2025-03-04)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/snippet_template.sh
## Description:   Shows detailed status information for a file, supporting
##                multiple output formats (default, json, yaml).
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         show_file_status.sh [-f|--format default|json|yaml] <file>
## Examples:      show_file_status.sh ~/.zshrc
##                show_file_status.sh --format json /etc/hosts
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0            # Successful execution
typeset -r Exit_Status_General=1            # General error (unspecified)
typeset -r Exit_Status_Usage=2              # Invalid usage or arguments
typeset -r Exit_Status_IO=3                 # Input/output error
typeset -r Exit_Status_Format=4             # Invalid format specified

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Prints usage instructions and examples to stderr
# Parameters:
#   None
# Returns:
#   Does not return - exits with Exit_Status_Usage
#----------------------------------------------------------------------#
show_Usage() {
    print -u2 "Usage: $0 [-f|--format default|json|yaml] <file>
Examples:
  $0 ~/.zshrc             # Show status in default format
  $0 --format json /etc/hosts  # Show status in JSON format"
    exit $Exit_Status_Usage
}

# Additional functions go here. Each function should be reusable, with
# clear input/output contracts to let other functions rely on them with 
# with minimal side effects. Each should be self-contained and should
# not depend on each other functions unless explicitly stated in 
# the function's documentation.

#----------------------------------------------------------------------#
# Function: format_Output
#----------------------------------------------------------------------#
# Description:
#   Formats file status information in the requested output style
# Parameters:
#   $1 - Format type (default|json|yaml)
#   $2 - File path
#   $3 - File size in bytes
#   $4 - Modification time
#   $5 - Permissions string
# Returns:
#   Exit_Status_Success and prints formatted output
#   Exit_Status_Format on invalid format
#----------------------------------------------------------------------#
format_Output() {
    typeset Format="$1" FilePath="$2" Size="$3" MTime="$4" Perms="$5"

    case "$Format" in
        default)
            print "File: $FilePath"
            print "Size: $Size bytes"
            print "Modified: $MTime"
            print "Permissions: $Perms"
            ;;
        json)
            print '{'
            print "  \"file\": \"$FilePath\","
            print "  \"size\": $Size,"
            print "  \"modified\": \"$MTime\","
            print "  \"permissions\": \"$Perms\""
            print '}'
            ;;
        yaml)
            print "file: $FilePath"
            print "size: $Size"
            print "modified: $MTime"
            print "permissions: $Perms"
            ;;
        *)
            print -u2 "Error: Invalid format '$Format'"
            return $Exit_Status_Format
            ;;
    esac
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: get_File_Status
#----------------------------------------------------------------------#
# Description:
#   Retrieves detailed status information for a file
# Parameters:
#   $1 - Path to file
# Returns:
#   Prints space-separated status string to stdout:
#   "<size> <mtime> <perms>"
#   Exit_Status_Success on success
#   Exit_Status_IO if file cannot be accessed
#----------------------------------------------------------------------#
get_File_Status() {
    typeset FilePath="$1"
    
    # Check file exists and is readable
    [[ -r "$FilePath" ]] || {
        print -u2 "Error: File '$FilePath' does not exist or is not readable"
        return $Exit_Status_IO
    }
    
    # Get file information using stat
    typeset Size MTime Perms
    
    Size=$(stat -f %z "$FilePath")
    MTime=$(stat -f %Sm "$FilePath")
    Perms=$(stat -f %Sp "$FilePath")
    
    print -- "$Size $MTime $Perms"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Main processing function
# Parameters:
#   $1 - Output format
#   $2 - File path
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_IO on file access error
#   Exit_Status_Format on invalid format
#----------------------------------------------------------------------#
core_Logic() {
    typeset Format="$1" FilePath="$2"
    typeset Status StatusArray
    
    # Get status info
    Status=$(get_File_Status "$FilePath") || return $?
    
    # Split status into array
    StatusArray=("${(@s: :)Status}")
    
    # Format and output
    format_Output "$Format" "$FilePath" "${StatusArray[1]}" "${StatusArray[2]}" "${StatusArray[3]}" || return $?
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes command line arguments
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Prints "<format> <filepath>" to stdout
#   Exit_Status_Success on success
#   Exit_Status_Usage on invalid arguments
#----------------------------------------------------------------------#
parse_Parameters() {
    typeset Format="default"
    typeset FilePath=""
    
    while (( $# > 0 )); do
        case "$1" in
            -f|--format)
                (( $# > 1 )) || show_Usage
                Format="$2"
                shift 2
                ;;
            -h|--help)
                show_Usage
                ;;
            -*)
                print -u2 "Error: Unknown option '$1'"
                show_Usage
                ;;
            *)
                FilePath="$1"
                shift
                break
                ;;
        esac
    done
    
    [[ -n "$FilePath" ]] || show_Usage
    
    print -- "$Format $FilePath"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: check_Dependencies
#----------------------------------------------------------------------#
# Description:
#   Verifies required external commands are available
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all dependencies are met 
#   Exit_Status_Dependency if any required command is missing
# Dependencies:
#   Requires stat command with BSD-style arguments
#----------------------------------------------------------------------#
check_Dependencies() {
    # Check for stat command
    command -v stat >/dev/null || {
        print -u2 "Error: Required command 'stat' not found"
        return $Exit_Status_Dependency
    }
    
    # Verify BSD-style stat (for macOS compatibility)
    if ! stat -f %z . >/dev/null 2>&1; then
        print -u2 "Error: Requires BSD-style stat command (macOS/BSD)"
        return $Exit_Status_Dependency
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Script entry point
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
#----------------------------------------------------------------------#
main() {
    typeset Params Format FilePath
    
    # Check dependencies first
    check_Dependencies || exit $?
    
    # Get and parse parameters
    Params=$(parse_Parameters "$@") || exit $?
    read -r Format FilePath <<< "$Params"
    
    # Execute core logic
    core_Logic "$Format" "$FilePath" || exit $?
    
    exit $Exit_Status_Success
}

## Script Entry Point

# Execute only if run directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi
