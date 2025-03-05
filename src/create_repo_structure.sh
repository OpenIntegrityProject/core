#!/usr/bin/env zsh
########################################################################
## Script:        create_repo_structure.sh
## Version:       0.1.00 (2025-03-05)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/create_repo_structure.sh
## Description:   Creates the standard Open Integrity .repo directory
##                structure in a specified Git repository, initializing
##                required files and directories.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Authored by Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         create_repo_structure.sh [-r|--repo <path>]
## Examples:      create_repo_structure.sh
##                create_repo_structure.sh --repo /path/to/repo
## Security:      This script only creates the directory structure and initial
##                configuration files. It does not modify any existing Git
##                configuration or commit files.
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.00"

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
typeset -r Exit_Status_IO=3
typeset -r Exit_Status_Git_Failure=5
typeset -r Exit_Status_Config=6
typeset -r Exit_Status_Dependency=127

# Predefined boolean constants
typeset -r TRUE=1
typeset -r FALSE=0

# Default repository path is current directory
typeset Repo_Path="."

#----------------------------------------------------------------------#
# Function: z_Report_Error
#----------------------------------------------------------------------#
# Description:
#   Centralized error reporting with consistent formatting
# Parameters:
#   $1 - Error message
#   $2 - Optional exit code (defaults to Exit_Status_General)
# Returns:
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
function show_Usage() {
   print "$Script_Name v$Script_Version - Create Open Integrity repository structure"
   print ""
   print "Usage: $Script_Name [-r|--repo <directory>]"
   print "Creates the .repo directory structure in a Git repository."
   print ""
   print "Options:"
   print "  -r, --repo <directory>  Specify repository directory path"
   print "                          (default: current directory)"
   print "  -h, --help              Show this help message"
   print ""
   print "Examples:"
   print "  $Script_Name                      Create in current directory"
   print "  $Script_Name --repo my_repo       Create in custom directory"
   
   # Exit with success for help, error for invalid usage
   if [[ "${1:-}" == "error" ]]; then
       exit $Exit_Status_Usage
   else
       exit $Exit_Status_Success
   fi
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
#----------------------------------------------------------------------#
function check_Dependencies() {
   typeset -a required_commands=("git" "zsh")
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
# Function: verify_Git_Repository
#----------------------------------------------------------------------#
# Description:
#   Verifies that the specified directory is a valid Git repository
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Exit_Status_Success if directory is a valid Git repository
#   Exit_Status_Git_Failure if it's not a Git repository
#----------------------------------------------------------------------#
function verify_Git_Repository() {
   typeset Repo_Dir="$1"
   
   # Check if it's a Git repository
   if ! git -C "$Repo_Dir" rev-parse --git-dir >/dev/null 2>&1; then
       z_Report_Error "Not a Git repository: $Repo_Dir" $Exit_Status_Git_Failure
       return $Exit_Status_Git_Failure
   fi
   
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: create_Repo_Structure
#----------------------------------------------------------------------#
# Description:
#   Creates the .repo directory structure in the specified repository
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Exit_Status_Success if structure is created successfully
#   Exit_Status_IO if directory creation fails
#----------------------------------------------------------------------#
function create_Repo_Structure() {
   typeset Repo_Dir="$1"
   typeset Base_Dir="${Repo_Dir}/.repo"
   
   # Create the main .repo directory
   if ! mkdir -p "${Base_Dir}"; then
       z_Report_Error "Failed to create .repo directory" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Create the directory structure as per specification
   typeset -a directories=(
      "${Base_Dir}/hooks"
      "${Base_Dir}/scripts"
      "${Base_Dir}/config/pipeline"
      "${Base_Dir}/config/environment"
      "${Base_Dir}/config/verification"
      "${Base_Dir}/docs"
      "${Base_Dir}/monitoring"
   )
   
   # Create each directory
   for dir in "${directories[@]}"; do
       if ! mkdir -p "$dir"; then
           z_Report_Error "Failed to create directory: $dir" $Exit_Status_IO
           return $Exit_Status_IO
       fi
   done
   
   print "✅ Created .repo directory structure in ${Repo_Dir}"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: initialize_Config_Files
#----------------------------------------------------------------------#
# Description:
#   Initializes basic configuration files in the .repo directory
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Exit_Status_Success if files are created successfully
#   Exit_Status_IO if file creation fails
#----------------------------------------------------------------------#
function initialize_Config_Files() {
   typeset Repo_Dir="$1"
   typeset Base_Dir="${Repo_Dir}/.repo"
   typeset Config_Dir="${Base_Dir}/config"
   typeset Verification_Dir="${Config_Dir}/verification"
   typeset Docs_Dir="${Base_Dir}/docs"
   typeset Hooks_Dir="${Base_Dir}/hooks"
   typeset Scripts_Dir="${Base_Dir}/scripts"
   
   # Create README.md in .repo
   cat > "${Base_Dir}/README.md" <<EOF
# Open Integrity Repository Configuration

This directory contains configuration, scripts, and hooks for maintaining
cryptographic integrity in this repository through the Open Integrity Project
framework.

- **hooks/**: Git hooks for enforcing signing policies
- **scripts/**: Utility scripts for repository management
- **config/**: Configuration files for verification and trust management
- **docs/**: Documentation specific to this repository's integrity model
- **monitoring/**: Scripts and tools for monitoring repository integrity

For more information, see the Open Integrity Project documentation:
https://github.com/OpenIntegrityProject/core
EOF

   # Create placeholder allowed_commit_signers file
   cat > "${Verification_Dir}/allowed_commit_signers" <<EOF
# Allowed Commit Signers for this repository
# Format: <principal> [namespaces="git"] <key-type> <key>
# Example: @username namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0NeESRoALg+HOC9FrnL
#
# Note: This file must be signed by an authorized key to take effect
EOF

   # Create pre-commit hook 
   cat > "${Hooks_Dir}/pre-commit.sh" <<EOF
#!/usr/bin/env zsh
# Open Integrity pre-commit hook
# Ensures all commits are properly signed with an authorized key

# Check for signature
if [[ "\$(git config --get commit.gpgsign)" != "true" ]]; then
    echo "❌ Error: commit.gpgsign must be set to true for this repository"
    echo "Run: git config --local commit.gpgsign true"
    exit 1
fi

# Check for SSH signing format
if [[ "\$(git config --get gpg.format)" != "ssh" ]]; then
    echo "❌ Error: gpg.format must be set to ssh for this repository"
    echo "Run: git config --local gpg.format ssh"
    exit 1
fi

# Success
exit 0
EOF
   chmod +x "${Hooks_Dir}/pre-commit.sh"

   # Create verify_signatures script
   cat > "${Scripts_Dir}/verify_signatures.sh" <<EOF
#!/usr/bin/env zsh
# Verify signatures on all commits in the repository
# Usage: verify_signatures.sh [branch]

BRANCH="\${1:-HEAD}"

echo "🔒 Verifying signatures on branch \$BRANCH"
git log "\$BRANCH" --show-signature
EOF
   chmod +x "${Scripts_Dir}/verify_signatures.sh"

   # Create initial docs README
   cat > "${Docs_Dir}/README.md" <<EOF
# Repository Integrity Documentation

This directory contains documentation specific to the integrity model of this repository.

## Key Documents

- **Trust Model**: Describes the trust model used in this repository
- **Authorized Signers**: Information about the authorized signers
- **Verification Process**: How to verify the integrity of this repository
EOF

   print "✅ Initialized basic configuration files in ${Base_Dir}"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: setup_Git_Config
#----------------------------------------------------------------------#
# Description:
#   Sets up Git configuration for repository integrity
# Parameters:
#   $1 - Repository directory path
# Returns:
#   Exit_Status_Success if configuration is set up successfully
#   Exit_Status_Git_Failure if Git configuration fails
#----------------------------------------------------------------------#
function setup_Git_Config() {
   typeset Repo_Dir="$1"
   typeset Verification_Dir="${Repo_Dir}/.repo/config/verification"
   typeset Hooks_Dir="${Repo_Dir}/.repo/hooks"
   
   # Configure allowed signers file
   if ! git -C "$Repo_Dir" config --local gpg.ssh.allowedSignersFile '.repo/config/verification/allowed_commit_signers'; then
       z_Report_Error "Failed to configure gpg.ssh.allowedSignersFile" $Exit_Status_Git_Failure
       return $Exit_Status_Git_Failure
   fi
   
   # Set up custom hooks path
   if ! git -C "$Repo_Dir" config --local core.hooksPath '.repo/hooks'; then
       z_Report_Error "Failed to configure core.hooksPath" $Exit_Status_Git_Failure
       return $Exit_Status_Git_Failure
   fi
   
   print "✅ Configured Git settings for Open Integrity"
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
#   Exit_Status_Success if parameters are valid
#   Exit_Status_Usage if parameters are invalid
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
   check_Dependencies || exit $?

   # Parse command line parameters
   parse_Arguments "$@" || exit $?

   # Verify repository is a valid Git repository
   verify_Git_Repository "$Repo_Path" || exit $?

   # Create .repo directory structure
   create_Repo_Structure "$Repo_Path" || exit $?

   # Initialize configuration files
   initialize_Config_Files "$Repo_Path" || exit $?

   # Set up Git configuration
   setup_Git_Config "$Repo_Path" || exit $?

   print "\n🎉 Open Integrity repository structure created successfully!"
   print "To complete setup, update the allowed signers file with your SSH key:"
   print "  ${Repo_Path}/.repo/config/verification/allowed_commit_signers"
   
   return $Exit_Status_Success
}

# Execute main() only if this script is being run directly (not sourced)
if [[ "${(%):-%N}" == "$0" ]]; then
   main "$@"
   exit $?
fi
