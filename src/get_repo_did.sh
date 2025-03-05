#!/usr/bin/env zsh
########################################################################
## Script:        get_repo_did.sh
## Version:       0.1.00 (2025-02-25)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/get_repo_did.sh
## Description:   Retrieves the first commit (Inception Commit) hash of a Git 
##                repository and formats it as a W3C Decentralized Identifier (DID).
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
## Usage:         get_repo_did.sh [-C|--chdir <path>]
## Examples:      get_repo_did.sh -C /path/to/repo
##                touch "/path/to/repo/$(get_repo_did.sh -C /path/to/repo)"
## Security:      Git uses SHA-1 for commit identifiers, which has known  
##                cryptographic weaknesses. This DID should only be trusted 
##                when verified by a full Open Integrity inception commit audit.
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0            # Successful execution
typeset -r Exit_Status_General=1            # General error (unspecified)
typeset -r Exit_Status_Usage=2              # Invalid usage or arguments (e.g., missing required argument)
typeset -r Exit_Status_IO=3                 # Input/output error (e.g., missing or unreadable file)
typeset -r Exit_Status_Git_Failure=5        # Local Git repository functional error (e.g., not a Git repo)
typeset -r Exit_Status_Config=6             # Missing configuration or non-executable dependency (e.g., missing Git)
typeset -r Exit_Status_Dependency=127       # Missing executable (e.g., gh CLI not found)

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Prints usage instructions and examples to stderr, then exits
# Parameters:
#   None
# Returns:
#   Does not return - exits with Exit_Status_Usage
#----------------------------------------------------------------------#
show_Usage() {
    print -u2 "Usage:     $0 [-C|--chdir <path>]
Examples:  get_repo_did.sh -C /path/to/repo
           touch \"/path/to/repo/\$(get_repo_did.sh -C /path/to/repo)\""
    exit $Exit_Status_Usage
}

#----------------------------------------------------------------------#
# Function: assure_Functional_Git_Repo
#----------------------------------------------------------------------#
# Description:
#   Validates a directory is a readable, writable Git repository with commits
# Parameters:
#   $1 - Repository directory path to verify
# Returns:
#   Exit_Status_Success if repository is valid
#   Exit_Status_IO if directory is invalid/unreadable/unwritable
#   Exit_Status_Git_Failure if not a Git repo or has no commits
# Dependencies:
#   Requires git command
#----------------------------------------------------------------------#
assure_Functional_Git_Repo() {
    typeset RepoDir="$1" GitOutput
    
    [[ -d "$RepoDir" && -r "$RepoDir" && -w "$RepoDir" ]] || { 
        print -u2 "Error: Invalid, unreadable, or unwritable directory '$RepoDir'."
        return $Exit_Status_IO
    }
    
    # Check if it's a Git repository
    GitOutput=$(git -C "$RepoDir" rev-parse --is-inside-work-tree 2>&1) || {
        print -u2 "Error: Not a Git repository. Git reported: $GitOutput"
        return $Exit_Status_Git_Failure
    }
    
    # Check if repository has any commits
    GitOutput=$(git -C "$RepoDir" rev-list --max-count=1 HEAD 2>&1) || {
        print -u2 "Error: Git repository state check failed. Git reported: $GitOutput"
        return $Exit_Status_Git_Failure
    }
    
    return $Exit_Status_Success
}

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
    typeset RepoDir="$1" CommitHash GitOutput
    
    GitOutput=$(git -C "$RepoDir" rev-list --max-parents=0 HEAD 2>&1) || {
        print -u2 "Error: Unable to retrieve first commit. Git reported: $GitOutput"
        return $Exit_Status_Git_Failure
    }
    
    CommitHash=$(print -- "$GitOutput" | grep -v '^[[:space:]]*$' | head -n1)
    
    if [[ -n "$CommitHash" ]]; then
        print -- "$CommitHash"
        return $Exit_Status_Success
    fi
    
    print -u2 "Error: No initial commit found (repository may be empty)."
    return $Exit_Status_Git_Failure
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Creates a DID from repository's inception commit hash
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Prints DID in format "did:repo:<commit-hash>" to stdout
#   Exit_Status_Success on success
#   Exit_Status_Error or Git operation status on failure
# Dependencies:
#   Calls assure_Functional_Git_Repo and get_First_Commit_Hash
#----------------------------------------------------------------------#
core_Logic() {
    typeset RepoDir="$1"

    assure_Functional_Git_Repo "$RepoDir" || return $?
    print "did:repo:$(get_First_Commit_Hash "$RepoDir")" || return $Exit_Status_Error
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes command line arguments and validates directory path
# Parameters:
#   $@ - Command line arguments (optional -C|--chdir with path)
# Returns:
#   Prints validated repository path to stdout
#   Exit_Status_Success on success
#   Exit_Status_Usage for invalid arguments (via show_Usage)
#----------------------------------------------------------------------#
parse_Parameters() {
    typeset RepoDir="$PWD:A"  # Default to current directory

    case "${1:-}" in
        -C|--chdir)
            if [[ -z "${2:-}" ]]; then
                print -u2 "Error: -C|--chdir requires a directory argument"
                show_Usage
            fi
            typeset RepoDir="$2"
            ;;
        "")
            typeset RepoDir="$PWD:A"
            ;;
        *)
            show_Usage
            ;;
    esac

    print -- "$RepoDir"  # Return RepoDir as output
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Orchestrates script execution flow
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Various error status codes on failure
# Dependencies:
#   Coordinates parse_Parameters and core_Logic functions
#----------------------------------------------------------------------#
main() {
    typeset RepoDir # Local variable for RepoDir

    RepoDir="$(parse_Parameters "$@")" || exit $?  # Capture output and handle errors
    core_Logic "$RepoDir" || exit $?  # Pass RepoDir to core_Logic
    exit $Exit_Status_Success
}

# Execute only if the script is not being sourced
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi