#!/usr/bin/env zsh
########################################################################
## Script:        create_inception_commit.sh
## Version:       0.1.03 (2025-03-03)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/create_inception_commit.sh
## Description:   Creates a new Git repository with a properly signed empty
##                inception commit following Open Integrity Project standards.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
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
typeset -r Script_Version="0.1.02"

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

# Predefined boolean constants
typeset -r TRUE=1
typeset -r FALSE=0

#----------------------------------------------------------------------#
# Function: z_Convert_Path_To_Relative
#----------------------------------------------------------------------#
# Description:
#   Converts an absolute path into a relative path based on current directory
# Parameters:
#   $1 - Absolute path to convert
# Returns:
#   Prints relative path to stdout
#----------------------------------------------------------------------#
function z_Convert_Path_To_Relative() {
   typeset pathAbsolute="${1:A}"   # Canonical absolute path
   typeset pwdAbsolute="${PWD:A}"  # Canonical current directory
   
   # If it's exactly the current dir, just return "."
   if [[ "$pathAbsolute" == "$pwdAbsolute" ]]; then
       print "."
       return
   fi

   # If it's a sub-path of the current dir, prefix with "./"
   if [[ "$pathAbsolute" == "$pwdAbsolute/"* ]]; then
       print "./${pathAbsolute#$pwdAbsolute/}"
       return
   fi
   
   # Otherwise, attempt to find a common ancestor
   typeset pathCommon="$pwdAbsolute"
   typeset pathResult=""
   
   # Step upwards until we find shared directory
   while [[ "$pathAbsolute" != "$pathCommon"* ]]; do
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
}

#----------------------------------------------------------------------#
# Function: z_Convert_Path_To_Relative
#----------------------------------------------------------------------#
# Description:
#   Converts an absolute path into a relative path based on current directory
# Parameters:
#   $1 - Absolute path to convert
# Returns:
#   Prints relative path to stdout
#----------------------------------------------------------------------#
function z_Convert_Path_To_Relative() {
   typeset pathAbsolute="${1:A}"   # Canonical absolute path
   typeset pwdAbsolute="${PWD:A}"  # Canonical current directory
   
   # If it's exactly the current dir, just return "."
   if [[ "$pathAbsolute" == "$pwdAbsolute" ]]; then
       print "."
       return
   fi

   # If it's a sub-path of the current dir, prefix with "./"
   if [[ "$pathAbsolute" == "$pwdAbsolute/"* ]]; then
       print "./${pathAbsolute#$pwdAbsolute/}"
       return
   fi
   
   # Otherwise, attempt to find a common ancestor
   typeset pathCommon="$pwdAbsolute"
   typeset pathResult=""
   
   # Step upwards until we find shared directory
   while [[ "$pathAbsolute" != "$pathCommon"* ]]; do
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
}

#----------------------------------------------------------------------#
# Function: z_Report_Error
#----------------------------------------------------------------------#
# Description:
#   Centralized error reporting with consistent formatting
# Parameters:
#   $1 - Error message
#   $2 - Optional exit code (defaults to Exit_Status_General)
# Returns:
#   Prints error to stderr
#   Returns specified or default error code
#----------------------------------------------------------------------#
function z_Report_Error() {
   typeset ErrorMessage="$1"
   typeset -i ErrorCode="${2:-$Exit_Status_General}"
   
   # Consistent error formatting
   print -u2 "❌ ERROR: $ErrorMessage"
   return $ErrorCode
}

#----------------------------------------------------------------------#
# Function: oi_Extract_Ssh_Key_Fingerprint
#----------------------------------------------------------------------#
# Description:
#   Extracts the SSH key fingerprint using Zsh-native parsing
# Parameters:
#   $1 - Path to SSH key file
# Returns:
#   Prints the fingerprint to stdout in SHA256 format
#   Exit_Status_Success on success
#   Exit_Status_Config on extraction failure
#----------------------------------------------------------------------#
function oi_Extract_Ssh_Key_Fingerprint() {
   typeset KeyPath="$1"
   typeset SshKeygenOutput
   typeset Fingerprint
   typeset -a OutputParts
   typeset -a match mbegin mend  # Required for Zsh regex capturing

   # Capture ssh-keygen output
   SshKeygenOutput=$(ssh-keygen -E sha256 -lf "$KeyPath" 2>/dev/null)

   # Exit on failure to get output
   if [[ -z "$SshKeygenOutput" ]]; then
       z_Report_Error "Failed to get fingerprint for key: $KeyPath"
       return $Exit_Status_Config
   fi

   # Split output into parts using Zsh array splitting
   OutputParts=(${(s: :)SshKeygenOutput})

   # Second part should be the SHA256 fingerprint
   if (( ${#OutputParts} >= 2 )); then
       Fingerprint="${OutputParts[2]}"
   else
       z_Report_Error "Unexpected ssh-keygen output format: $SshKeygenOutput"
       return $Exit_Status_Config
   fi

   # Ensure the fingerprint is in SHA256: format
   if [[ ! "$Fingerprint" =~ ^SHA256: ]]; then
       z_Report_Error "Invalid fingerprint format: $Fingerprint"
       return $Exit_Status_Config
   fi

   # Print and return
   print -- "$Fingerprint"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Get_First_Commit_Hash
#----------------------------------------------------------------------#
# Description:
#   Retrieves the hash of the first commit in a Git repository
# Parameters:
#   $1 - Repository path
# Returns:
#   Prints first commit hash to stdout
#   Exit_Status_Success if hash found
#   Exit_Status_Git_Failure if no commits exist
#----------------------------------------------------------------------#
function oi_Get_First_Commit_Hash() {
   typeset RepoPath="$1"
   typeset -a CommitHashes

   # Zsh-native array splitting of commit hashes
   CommitHashes=($(git -C "$RepoPath" rev-list --max-parents=0 HEAD 2>/dev/null))

   # Robust array length checking
   if (( ${#CommitHashes} == 0 )); then
       z_Report_Error "No initial commit found in repository" $Exit_Status_Git_Failure
       return $Exit_Status_Git_Failure
   fi

   # Always return the first commit hash
   print -- "${CommitHashes[1]}"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Verify_Commit_Signature
#----------------------------------------------------------------------#
# Description:
#   Verifies the signature of a Git commit
# Parameters:
#   $1 - Repository path
#   $2 - Commit hash
# Returns:
#   Exit_Status_Success if signature valid
#   Exit_Status_Git_Failure if verification fails
#----------------------------------------------------------------------#
function oi_Verify_Commit_Signature() {
    typeset RepoPath="$1"
    typeset CommitHash="$2"
    typeset -a VerifyLines
    typeset -i SignatureValid=$FALSE
    typeset line

    # Capture verify output as array, preserving line breaks
    VerifyLines=(${(f)"$(git -C "$RepoPath" verify-commit "$CommitHash" 2>&1)"})

    # Zsh-native pattern matching for signature verification
    for line in $VerifyLines; do
        if [[ $line == *"Good"*"signature"* ]]; then
            SignatureValid=$TRUE
            break
        fi
    done

    # Error handling with Zsh-native conditionals
    if (( SignatureValid == FALSE )); then
        z_Report_Error "Signature verification failed for commit $CommitHash"
        (( ${#VerifyLines} > 0 )) && print -u2 "${VerifyLines[1]}"
        return $Exit_Status_Git_Failure
    fi

    # Output verification details
    print "✅ Commit signature verified successfully:"
    printf '%s\n' "${VerifyLines[@]}" | grep -E "Good.*signature"

    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Get_Git_Config
#----------------------------------------------------------------------#
# Description:
#   Retrieves Git configuration values with robust error handling
# Parameters:
#   $1 - Configuration key to retrieve
# Returns:
#   Prints configuration value to stdout
#   Exit_Status_Success if value found
#   Exit_Status_Config if configuration not set
#----------------------------------------------------------------------#
function oi_Get_Git_Config() {
   typeset ConfigKey="$1"
   typeset ConfigValue

   # Use parameter expansion for config retrieval
   ConfigValue=${$(git config "$ConfigKey" 2>/dev/null):-}

   if [[ -z "$ConfigValue" ]]; then
       z_Report_Error "Git configuration '$ConfigKey' not set"
       return $Exit_Status_Config
   fi

   print -- "$ConfigValue"
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
function oi_Get_Repo_DID() {
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
       z_Report_Error "Directory does not exist: $RepoPath" $Exit_Status_IO
       return $Exit_Status_IO
   fi

   # Verify path is a Git repository
   if ! git -C "$RepoPath" rev-parse --git-dir >/dev/null 2>&1; then
       z_Report_Error "Not a Git repository: $RepoPath" $Exit_Status_Git_Failure
       return $Exit_Status_Git_Failure
   fi

   return $Exit_Status_Success
}

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
           z_Report_Error "Required command '$cmd' not found" $Exit_Status_Dependency
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
           z_Report_Error "Parent directory does not exist and could not be created: $ParentPath" $Exit_Status_IO
           return $Exit_Status_IO
       }
       print "Created parent directory: $ParentPath"
   fi

   # Check if parent directory is writable
   if [[ ! -w "$ParentPath" ]]; then
       z_Report_Error "Parent directory is not writable: $ParentPath" $Exit_Status_IO
       return $Exit_Status_IO
   fi

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
function parse_Arguments() {
   while (( $# > 0 )); do
       case "$1" in
           -r|--repo)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               Repo_Path="$2"
               shift 2
               ;;
           -h|--help)
               show_Usage
               ;;
           -*)
               z_Report_Error "Unknown option: $1" $Exit_Status_Usage
               show_Usage "error"
               ;;
           *)
               z_Report_Error "Unexpected argument: $1" $Exit_Status_Usage
               show_Usage "error"
               ;;
       esac
   done

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
function oi_Verify_Git_Config() {
   # Check for required Git config settings
   typeset Username SigningKey EmailAddress Format CommitSign

   Username=$(oi_Get_Git_Config user.name) || return $?
   EmailAddress=$(oi_Get_Git_Config user.email) || return $?
   SigningKey=$(oi_Get_Git_Config user.signingkey) || return $?

   # Check SSH key exists and is readable
   if [[ ! -r "$SigningKey" ]]; then
       z_Report_Error "SSH signing key not found or not readable: $SigningKey"
       return $Exit_Status_Config
   fi

   # Verify gpg.format is set to ssh
   Format=$(git config gpg.format 2>/dev/null)
   if [[ "$Format" != "ssh" ]]; then
       z_Report_Error "Git gpg.format not set to 'ssh'."
       print -u2 "Run: git config --global gpg.format ssh"
       return $Exit_Status_Config
   fi

   # Verify commit.gpgSign is true
   CommitSign=$(git config commit.gpgsign 2>/dev/null)
   if [[ "$CommitSign" != "true" ]]; then
       print "Warning: Git commit.gpgsign not set to 'true'."
       print "For automatic signing, run: git config --global commit.gpgsign true"
   fi

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
function oi_Create_Inception_Commit() {
    typeset RepoPath="$1"
    typeset SigningKey UserName UserEmail AuthorDate CommitterName

    # Handle absolute vs relative paths
    if [[ ! "$RepoPath" =~ ^/ ]]; then
        RepoPath="$(pwd)/$RepoPath"
    fi

    # Check if repository already exists
    if [[ -d "$RepoPath/.git" ]]; then
        z_Report_Error "Repository already exists at $RepoPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi

    # Create repository directory
    if ! mkdir -p "$RepoPath"; then
        z_Report_Error "Failed to create directory: $RepoPath" $Exit_Status_IO
        return $Exit_Status_IO
    fi

    # Initialize Git repository
    if ! git -C "$RepoPath" init > /dev/null; then
        z_Report_Error "Failed to initialize Git repository" $Exit_Status_Git_Failure
        return $Exit_Status_Git_Failure
    fi

    # Get Git configuration values
    SigningKey=$(oi_Get_Git_Config user.signingkey) || return $?
    UserName=$(oi_Get_Git_Config user.name) || return $?
    UserEmail=$(oi_Get_Git_Config user.email) || return $?
    
    # Use system date for UTC timestamp
    AuthorDate=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get SSH key fingerprint for committer name
    CommitterName=$(oi_Extract_Ssh_Key_Fingerprint "$SigningKey") || return $?

    # Create the inception commit
    if ! GIT_AUTHOR_NAME="$UserName" GIT_AUTHOR_EMAIL="$UserEmail" \
       GIT_COMMITTER_NAME="$CommitterName" GIT_COMMITTER_EMAIL="$UserEmail" \
       GIT_AUTHOR_DATE="$AuthorDate" GIT_COMMITTER_DATE="$AuthorDate" \
       git -C "$RepoPath" -c gpg.format=ssh -c user.signingkey="$SigningKey" \
         commit --allow-empty --no-edit --gpg-sign \
         -m "Initialize repository and establish a SHA-1 root of trust" \
         -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo, including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers." --signoff; then
        z_Report_Error "Failed to create inception commit" $Exit_Status_Git_Failure
        return $Exit_Status_Git_Failure
    fi

    print "✅ Repository initialized with signed inception commit at $(z_Convert_Path_To_Relative "$RepoPath")"

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
function core_Logic() {
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
function main() {
   # Check for dependencies
   z_Check_Dependencies "git" "ssh-keygen" "awk" || exit $?

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
# but to the function name when sourced.
if [[ "${(%):-%N}" == "$0" ]]; then
   main "$@"
   exit $?  # Explicitly propagate the exit status from main
fi

########################################################################
## END of Script `create_inception_commit.sh`
########################################################################
