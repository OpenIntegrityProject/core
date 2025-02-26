#!/usr/bin/env zsh
########################################################################
## Script:        create_inception_commit.sh
## Version:       0.1.01 (2025-02-26)
## Origin:        https://github.com/BlockchainCommons/open_integrity-git_inception_WIP
## Description:   Creates a new Git repository with a properly signed empty
##                inception commit following Open Integrity Project standards.
## License:       BSD-3-Clause (https://spdx.org/licenses/BSD-3-Clause.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         create_inception_commit.sh [-r|--repo <directory>]
## Examples:      create_inception_commit.sh
##                create_inception_commit.sh --repo my_open_integrity_repo
##                create_inception_commit.sh --repo /full/path/to/new_repo
## Security:      The Inception Commit establishes an immutable cryptographic
##                root of trust using a combination of Git's SHA-1 hashing and
##                SSH signature verification. Always verify the signature
##                to ensure trust integrity.
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.00"

# Capture original arguments for help flag detection
typeset -r Original_Args="$*"

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
typeset -r Exit_Status_IO=3
typeset -r Exit_Status_Git_Failure=5
typeset -r Exit_Status_Config=6
typeset -r Exit_Status_Dependency=127

# Default repository name if not specified
typeset -r Default_Repo_Name="new_open_integrity_repo"
typeset Repo_Path="$Default_Repo_Name"

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Displays usage information for the script
# Parameters:
#   $1 - Optional error flag (if not provided, exits with success)
# Returns:
#   Exit_Status_Success when called with no error flag
#   Exit_Status_Usage when called with error flag
#----------------------------------------------------------------------#
show_Usage() {
    print "$Script_Name v$Script_Version - Create an Open Integrity signed inception commit"
    print ""
    print "Usage: $Script_Name [-r|--repo <directory>]"
    print "Creates a new Git repository with a properly signed inception commit."
    print ""
    print "Options:"
    print "  -r, --repo <directory>  Specify repository directory path"
    print "                          (default: $Default_Repo_Name)"
    print "  -h, --help              Show this help message"
    print ""
    print "Examples:"
    print "  $Script_Name                      Create with default name"
    print "  $Script_Name --repo my_repo       Create with custom name"
    print "  $Script_Name --repo /path/to/repo Create with full path"
    
    # Exit with success for help, error for invalid usage
    if [[ "${1:-}" == "error" ]]; then
        exit $Exit_Status_Usage
    else
        exit $Exit_Status_Success
    fi
}

#----------------------------------------------------------------------#
# Function: z_Check_Dependencies
#----------------------------------------------------------------------#
# Description:
#   Verifies required external commands are available
# Parameters:
#   $@ - List of required commands
# Returns:
#   Exit_Status_Success if all dependencies are met
#   Exit_Status_Dependency if any required command is missing
#----------------------------------------------------------------------#
z_Check_Dependencies() {
    typeset -a required_commands=("$@")
    typeset cmd

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print -u2 "Error: Required command '$cmd' not found"
            return $Exit_Status_Dependency
        fi
    done

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Ensure_Parent_Path_Exists
#----------------------------------------------------------------------#
# Description:
#   Validates that the parent directory exists and is writable
#   Creates parent directories if needed
# Parameters:
#   $1 - Path to check/create
# Returns:
#   Exit_Status_Success if path is valid or created successfully
#   Exit_Status_IO if directory doesn't exist or isn't writable
#----------------------------------------------------------------------#
z_Ensure_Parent_Path_Exists() {
    typeset RepoPath="$1"
    typeset ParentPath

    # Get parent directory path
    if [[ "$RepoPath" =~ ^/ ]]; then
        # Absolute path
        ParentPath="${RepoPath:h}"
    else
        # Relative path
        if [[ "$RepoPath" == */* ]]; then
            # Has directory structure
            ParentPath="$(pwd)/${RepoPath:h}"
        else
            # Just filename, use current directory
            ParentPath="$(pwd)"
        fi
    fi

    # Check if parent directory exists
    if [[ ! -d "$ParentPath" ]]; then
        # Try to create parent directory
        mkdir -p "$ParentPath" 2>/dev/null || {
            print -u2 "Error: Parent directory does not exist and could not be created: $ParentPath"
            print -u2 "Create the parent directory first or use a different path."
            return $Exit_Status_IO
        }
        print "Created parent directory: $ParentPath"
    fi

    # Check if parent directory is writable
    if [[ ! -w "$ParentPath" ]]; then
        print -u2 "Error: Parent directory is not writable: $ParentPath"
        return $Exit_Status_IO
    fi

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Assure_Functional_Git_Repo
#----------------------------------------------------------------------#
# Description:
#   Verifies a path is a functional Git repository
# Parameters:
#   $1 - Repository path
# Returns:
#   Exit_Status_Success if repository is functional
#   Exit_Status_Git_Failure if not a Git repository
# Dependencies:
#   git command
#----------------------------------------------------------------------#
oi_Assure_Functional_Git_Repo() {
    typeset RepoPath="$1"

    # Verify path exists and is a directory
    if [[ ! -d "$RepoPath" ]]; then
        print -u2 "Error: Directory does not exist: $RepoPath"
        return $Exit_Status_IO
    fi

    # Verify path is a Git repository
    if ! git -C "$RepoPath" rev-parse --git-dir >/dev/null 2>&1; then
        print -u2 "Error: Not a Git repository: $RepoPath"
        return $Exit_Status_Git_Failure
    fi

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Get_First_Commit_Hash
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
oi_Get_First_Commit_Hash() {
    typeset RepoPath="$1"
    typeset CommitHash

    # Verify path is a git repository
    if ! git -C "$RepoPath" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print -u2 "Error: Not a Git repository at '$RepoPath'"
        return $Exit_Status_Git_Failure
    fi

    # Get the first commit hash
    CommitHash=$(git -C "$RepoPath" rev-list --max-parents=0 HEAD 2>/dev/null)

    if [[ -z "$CommitHash" ]]; then
        print -u2 "Error: No initial commit found in repository"
        return $Exit_Status_Git_Failure
    fi

    print -- "$CommitHash"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Verify_Commit_Signature
#----------------------------------------------------------------------#
# Description:
#   Verifies that a commit is properly signed with SSH key
# Parameters:
#   $1 - Repository directory path
#   $2 - Commit hash to verify
# Returns:
#   Exit_Status_Success if signature is valid
#   Exit_Status_Git_Failure if signature verification fails
# Dependencies:
#   git command
#----------------------------------------------------------------------#
oi_Verify_Commit_Signature() {
    typeset RepoPath="$1"
    typeset CommitHash="$2"
    typeset VerifyOutput

    VerifyOutput=$(git -C "$RepoPath" verify-commit "$CommitHash" 2>&1)

    if [[ $? -ne 0 ]]; then
        print -u2 "Error: Signature verification failed for commit $CommitHash"
        print -u2 "$VerifyOutput"
        return $Exit_Status_Git_Failure
    fi

    print "✅ Commit signature verified successfully:"
    print "$VerifyOutput" | grep -E "Good.*signature"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Verify_Git_Config
#----------------------------------------------------------------------#
# Description:
#   Verifies Git configuration includes required signing settings
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if configuration is valid
#   Exit_Status_Config if required settings are missing
# Dependencies:
#   git command
#----------------------------------------------------------------------#
oi_Verify_Git_Config() {
    # Check for required Git config settings
    typeset Username SigningKey EmailAddress Format CommitSign

    Username=$(git config user.name 2>/dev/null) || {
        print -u2 "Error: Git user.name not configured."
        print -u2 "Run: git config --global user.name \"@yourusername\""
        return $Exit_Status_Config
    }

    EmailAddress=$(git config user.email 2>/dev/null) || {
        print -u2 "Error: Git user.email not configured."
        print -u2 "Run: git config --global user.email \"your.email@example.com\""
        return $Exit_Status_Config
    }

    SigningKey=$(git config user.signingkey 2>/dev/null) || {
        print -u2 "Error: Git user.signingkey not configured."
        print -u2 "Run: git config --global user.signingkey ~/.ssh/id_ed25519"
        return $Exit_Status_Config
    }

    # Check SSH key exists and is readable
    if [[ ! -r "$SigningKey" ]]; then
        print -u2 "Error: SSH signing key not found or not readable: $SigningKey"
        return $Exit_Status_Config
    fi

    # Verify gpg.format is set to ssh
    Format=$(git config gpg.format 2>/dev/null)
    if [[ "$Format" != "ssh" ]]; then
        print -u2 "Error: Git gpg.format not set to 'ssh'."
        print -u2 "Run: git config --global gpg.format ssh"
        return $Exit_Status_Config
    fi

    # Verify commit.gpgSign is true
    CommitSign=$(git config commit.gpgsign 2>/dev/null)
    if [[ "$CommitSign" != "true" ]]; then
        print -u2 "Warning: Git commit.gpgsign not set to 'true'."
        print -u2 "For automatic signing, run: git config --global commit.gpgsign true"
    fi

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Get_Repo_DID
#----------------------------------------------------------------------#
# Description:
#   Gets the DID for a repository based on its inception commit
# Parameters:
#   $1 - Repository path
# Returns:
#   Prints DID in the format "did:repo:<hash>"
#   Exit_Status_Success if DID is found
#   Various error codes on failure
#----------------------------------------------------------------------#
oi_Get_Repo_DID() {
    typeset RepoPath="$1"
    typeset CommitHash

    # Verify repository is valid
    oi_Assure_Functional_Git_Repo "$RepoPath" || return $?

    # Get inception commit hash
    CommitHash=$(oi_Get_First_Commit_Hash "$RepoPath") || return $?

    # Format and return DID
    print "did:repo:$CommitHash"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Create_Inception_Commit
#----------------------------------------------------------------------#
# Description:
#   Creates a new repository with a properly signed inception commit
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Exit_Status_Success if repository is created and commit is signed
#   Exit_Status_IO if directory creation fails
#   Exit_Status_Git_Failure if git operations fail
#   Exit_Status_Config if git configuration is invalid
# Dependencies:
#   git and ssh-keygen commands
#----------------------------------------------------------------------#
oi_Create_Inception_Commit() {
    typeset RepoPath="$1"
    typeset SigningKey UserName UserEmail AuthorDate CommitterName

    # Handle absolute vs relative paths
    if [[ ! "$RepoPath" =~ ^/ ]]; then
        RepoPath="$(pwd)/$RepoPath"
    fi

    # Check if repository already exists
    if [[ -d "$RepoPath/.git" ]]; then
        print -u2 "❌ Repository already exists at $RepoPath"
        return $Exit_Status_IO
    fi

    # Create repository directory
    if ! mkdir -p "$RepoPath"; then
        print -u2 "❌ Failed to create directory: $RepoPath"
        return $Exit_Status_IO
    fi

    # Initialize Git repository
    if ! git -C "$RepoPath" init > /dev/null; then
        print -u2 "❌ Failed to initialize Git repository"
        return $Exit_Status_Git_Failure
    fi

    # Get Git configuration values
    SigningKey=$(git config user.signingkey)
    UserName=$(git config user.name)
    UserEmail=$(git config user.email)
    AuthorDate=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get SSH key fingerprint for committer name
    CommitterName=$(ssh-keygen -E sha256 -lf "$SigningKey" | awk '{print $2}')

    # Create the inception commit
    if ! GIT_AUTHOR_NAME="$UserName" GIT_AUTHOR_EMAIL="$UserEmail" \
       GIT_COMMITTER_NAME="$CommitterName" GIT_COMMITTER_EMAIL="$UserEmail" \
       GIT_AUTHOR_DATE="$AuthorDate" GIT_COMMITTER_DATE="$AuthorDate" \
       git -C "$RepoPath" -c gpg.format=ssh -c user.signingkey="$SigningKey" \
         commit --allow-empty --no-edit --gpg-sign \
         -m "Initialize repository and establish a SHA-1 root of trust" \
         -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo, including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers." --signoff; then
        print -u2 "❌ Failed to create inception commit"
        return $Exit_Status_Git_Failure
    fi

    print "✅ Repository initialized with signed inception commit at $RepoPath"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Arguments
#----------------------------------------------------------------------#
# Description:
#   Processes command line parameters
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Sets Repo_Path variable
#   Exit_Status_Success if parameters are valid
#   Calls show_Usage() for invalid parameters
#----------------------------------------------------------------------#
parse_Arguments() {
    while (( $# > 0 )); do
        case "$1" in
            -r|--repo)
                if (( $# < 2 )); then
                    print -u2 "Error: Option $1 requires an argument"
                    show_Usage "error"
                fi
                Repo_Path="$2"
                shift 2
                ;;
            -h|--help)
                show_Usage
                ;;
            -*)
                print -u2 "Error: Unknown option: $1"
                show_Usage "error"
                ;;
            *)
                print -u2 "Error: Unexpected argument: $1"
                show_Usage "error"
                ;;
        esac
    done

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Orchestrates the main script workflow
# Parameters:
#   None (uses script-scoped variable Repo_Path)
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
#----------------------------------------------------------------------#
core_Logic() {
    typeset CommitHash

    # Validate parent directory exists and is writable
    z_Ensure_Parent_Path_Exists "$Repo_Path" || return $?

    # Create repository with inception commit
    oi_Create_Inception_Commit "$Repo_Path" || return $?

    # Verify repository is functional
    oi_Assure_Functional_Git_Repo "$Repo_Path" || return $?

    # Get the hash of the inception commit
    CommitHash=$(oi_Get_First_Commit_Hash "$Repo_Path") || return $?
    print "Inception commit: $CommitHash"

    # Verify commit signature
    oi_Verify_Commit_Signature "$Repo_Path" "$CommitHash" || return $?

    # Get repository DID
    typeset Repo_DID
    Repo_DID=$(oi_Get_Repo_DID "$Repo_Path") || return $?
    print "Repository DID: $Repo_DID"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Main entry point for the script
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
#----------------------------------------------------------------------#
main() {
    # Check for dependencies
    z_Check_Dependencies "git" "ssh-keygen" "date" "awk" || exit $?

    # Parse command line parameters
    parse_Arguments "$@" || exit $?

    # Verify Git configuration
    oi_Verify_Git_Config || exit $?

    # Execute core logic
    core_Logic || exit $?

    return $Exit_Status_Success
}

# Script Entry Point

# Execute main() only if this script is being run directly (not sourced).
# Zsh-specific syntax: ${(%):-%N} expands to the script name when run directly,
# but to the function name when sourced. This is different from Bash's
# equivalent test: [[ "${BASH_SOURCE[0]}" == "${0}" ]]
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
    exit $?  # Explicitly propagate the exit status from main
fi

########################################################################
## END of Script `create_inception_commit.sh`
########################################################################