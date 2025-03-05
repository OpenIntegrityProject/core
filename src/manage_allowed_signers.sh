#!/usr/bin/env zsh
########################################################################
## Script:        manage_allowed_signers.sh
## Version:       0.1.00 (2025-03-05)
## Origin:        https://github.com/OpenIntegrityProject/core/blob/main/src/manage_allowed_signers.sh
## Description:   Manages the allowed signers file for Open Integrity repositories,
##                providing commands to add, remove, and list authorized signers.
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Authored by Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         manage_allowed_signers.sh <command> [options]
## Commands:      add     Add a new signer to the allowed signers file
##                remove  Remove a signer from the allowed signers file
##                list    List all allowed signers
##                show    Show a specific allowed signer
## Examples:      manage_allowed_signers.sh add --key ~/.ssh/id_ed25519.pub --name "Alice"
##                manage_allowed_signers.sh remove --name "Alice"
##                manage_allowed_signers.sh list
## Security:      After modifying the allowed signers file, the script creates a signed
##                commit to ensure the change is cryptographically verifiable.
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

# Default file path (can be overridden with --file option)
typeset Signers_File="./.repo/config/verification/allowed_commit_signers"
typeset Repo_Path="."
typeset SSH_Key_Path=""
typeset Signer_Name=""
typeset Signer_Email=""
typeset Command=""

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
   print "$Script_Name v$Script_Version - Manage allowed signers for Open Integrity repositories"
   print ""
   print "Usage: $Script_Name <command> [options]"
   print ""
   print "Commands:"
   print "  add     Add a new signer to the allowed signers file"
   print "  remove  Remove a signer from the allowed signers file"
   print "  list    List all authorized signers"
   print "  show    Show details for a specific signer"
   print ""
   print "Options:"
   print "  -f, --file <path>   Path to allowed signers file"
   print "                      (default: ./.repo/config/verification/allowed_commit_signers)"
   print "  -r, --repo <path>   Repository path (default: current directory)"
   print "  -k, --key <path>    Path to SSH public key file (for add command)"
   print "  -n, --name <n>   Signer name (for add/remove/show commands)"
   print "  -e, --email <email> Signer email (for add command, optional)"
   print "  -h, --help          Show this help message"
   print ""
   print "Examples:"
   print "  $Script_Name add --key ~/.ssh/id_ed25519.pub --name 'Alice'"
   print "  $Script_Name add --key ~/.ssh/id_ed25519.pub --name 'Alice' --email 'alice@example.com'"
   print "  $Script_Name remove --name 'Alice'"
   print "  $Script_Name list"
   print "  $Script_Name show --name 'Alice'"
   
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
   typeset -a required_commands=("git" "zsh" "ssh-keygen")
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
# Function: verify_SSH_Key
#----------------------------------------------------------------------#
# Description:
#   Verifies that the specified file is a valid SSH public key
# Parameters:
#   $1 - Path to SSH public key file
# Returns:
#   Exit_Status_Success if file is a valid SSH public key
#   Exit_Status_IO if file is invalid or cannot be read
# Output:
#   Sets global variable SSH_Key_Content with the key content
#----------------------------------------------------------------------#
function verify_SSH_Key() {
   typeset Key_Path="$1"
   
   # Check if file exists
   if [[ ! -f "$Key_Path" ]]; then
       z_Report_Error "SSH key file not found: $Key_Path" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Check if file is readable
   if [[ ! -r "$Key_Path" ]]; then
       z_Report_Error "SSH key file not readable: $Key_Path" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Verify it's a valid SSH public key
   if ! ssh-keygen -l -f "$Key_Path" >/dev/null 2>&1; then
       z_Report_Error "Invalid SSH public key: $Key_Path" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Read key content
   SSH_Key_Content=$(cat "$Key_Path")
   
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: verify_Signers_File
#----------------------------------------------------------------------#
# Description:
#   Verifies that the allowed signers file exists and is writable
# Parameters:
#   $1 - Path to allowed signers file
# Returns:
#   Exit_Status_Success if file exists and is writable
#   Exit_Status_IO if file does not exist or is not writable
#----------------------------------------------------------------------#
function verify_Signers_File() {
   typeset File_Path="$1"
   typeset Dir_Path=$(dirname "$File_Path")
   
   # Check if directory exists, create if needed
   if [[ ! -d "$Dir_Path" ]]; then
       if ! mkdir -p "$Dir_Path"; then
           z_Report_Error "Failed to create directory: $Dir_Path" $Exit_Status_IO
           return $Exit_Status_IO
       fi
   fi
   
   # Check if file exists, create if needed
   if [[ ! -f "$File_Path" ]]; then
       # Create an empty file with header
       cat > "$File_Path" <<EOF
# Allowed Commit Signers for this repository
# Format: <principal> [namespaces="git"] <key-type> <key>
# Example: @username namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0NeESRoALg+HOC9FrnL
#
# Note: This file must be signed by an authorized key to take effect
EOF
       
       if [[ $? -ne 0 ]]; then
           z_Report_Error "Failed to create allowed signers file: $File_Path" $Exit_Status_IO
           return $Exit_Status_IO
       fi
   fi
   
   # Check if file is writable
   if [[ ! -w "$File_Path" ]]; then
       z_Report_Error "Allowed signers file not writable: $File_Path" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: command_Add_Signer
#----------------------------------------------------------------------#
# Description:
#   Adds a new signer to the allowed signers file
# Parameters:
#   None (uses global variables)
# Returns:
#   Exit_Status_Success if signer is added successfully
#   Various error codes on failure
#----------------------------------------------------------------------#
function command_Add_Signer() {
   # Verify parameters
   if [[ -z "$SSH_Key_Path" ]]; then
       z_Report_Error "Missing required parameter: --key" $Exit_Status_Usage
       return $Exit_Status_Usage
   fi
   
   if [[ -z "$Signer_Name" ]]; then
       z_Report_Error "Missing required parameter: --name" $Exit_Status_Usage
       return $Exit_Status_Usage
   fi
   
   # Verify SSH key
   verify_SSH_Key "$SSH_Key_Path" || return $?
   
   # Extract key details
   typeset Key_Type=$(echo "$SSH_Key_Content" | awk '{print $1}')
   typeset Key_Value=$(echo "$SSH_Key_Content" | awk '{print $2}')
   typeset Fingerprint=$(ssh-keygen -l -f "$SSH_Key_Path" | awk '{print $2}')
   
   # Verify allowed signers file
   verify_Signers_File "$Signers_File" || return $?
   
   # Check if signer already exists
   if grep -q "@$Signer_Name" "$Signers_File"; then
       z_Report_Error "Signer '$Signer_Name' already exists in the allowed signers file" $Exit_Status_General
       return $Exit_Status_General
   fi
   
   # Format email part if provided
   typeset Email_Part=""
   if [[ -n "$Signer_Email" ]]; then
       Email_Part=" <$Signer_Email>"
   fi
   
   # Add signer to file
   echo "@$Signer_Name$Email_Part namespaces=\"git\" $Key_Type $Key_Value" >> "$Signers_File"
   
   # Commit the change
   git -C "$Repo_Path" add "$Signers_File"
   git -C "$Repo_Path" commit -S -m "Add signer '$Signer_Name' to allowed signers" \
       -m "Added SSH key with fingerprint: $Fingerprint" \
       -m "This change is cryptographically signed to ensure trust chain integrity."
   
   print "✅ Added signer '$Signer_Name' to allowed signers with key fingerprint: $Fingerprint"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: command_Remove_Signer
#----------------------------------------------------------------------#
# Description:
#   Removes a signer from the allowed signers file
# Parameters:
#   None (uses global variables)
# Returns:
#   Exit_Status_Success if signer is removed successfully
#   Various error codes on failure
#----------------------------------------------------------------------#
function command_Remove_Signer() {
   # Verify parameters
   if [[ -z "$Signer_Name" ]]; then
       z_Report_Error "Missing required parameter: --name" $Exit_Status_Usage
       return $Exit_Status_Usage
   fi
   
   # Verify allowed signers file exists
   if [[ ! -f "$Signers_File" ]]; then
       z_Report_Error "Allowed signers file not found: $Signers_File" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Check if signer exists
   if ! grep -q "@$Signer_Name" "$Signers_File"; then
       z_Report_Error "Signer '$Signer_Name' not found in the allowed signers file" $Exit_Status_General
       return $Exit_Status_General
   fi
   
   # Create a temporary file
   typeset Temp_File=$(mktemp)
   
   # Remove signer from file
   grep -v "@$Signer_Name" "$Signers_File" > "$Temp_File"
   cat "$Temp_File" > "$Signers_File"
   rm "$Temp_File"
   
   # Commit the change
   git -C "$Repo_Path" add "$Signers_File"
   git -C "$Repo_Path" commit -S -m "Remove signer '$Signer_Name' from allowed signers" \
       -m "This change is cryptographically signed to ensure trust chain integrity."
   
   print "✅ Removed signer '$Signer_Name' from allowed signers"
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: command_List_Signers
#----------------------------------------------------------------------#
# Description:
#   Lists all signers in the allowed signers file
# Parameters:
#   None (uses global variables)
# Returns:
#   Exit_Status_Success if listing is successful
#   Various error codes on failure
#----------------------------------------------------------------------#
function command_List_Signers() {
   # Verify allowed signers file exists
   if [[ ! -f "$Signers_File" ]]; then
       z_Report_Error "Allowed signers file not found: $Signers_File" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Extract and display signers
   print "Allowed Signers in $Signers_File:"
   print "----------------------------------------------"
   
   grep -v "^#" "$Signers_File" | grep "@" | while read line; do
       if [[ -n "$line" ]]; then
           typeset Signer=$(echo "$line" | awk '{print $1}')
           typeset Key_Type=$(echo "$line" | awk '{print $3}')
           typeset Key_Value=$(echo "$line" | awk '{print $4}')
           
           print "$Signer ($Key_Type)"
       fi
   done
   
   return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: command_Show_Signer
#----------------------------------------------------------------------#
# Description:
#   Shows details for a specific signer
# Parameters:
#   None (uses global variables)
# Returns:
#   Exit_Status_Success if signer is found and displayed
#   Various error codes on failure
#----------------------------------------------------------------------#
function command_Show_Signer() {
   # Verify parameters
   if [[ -z "$Signer_Name" ]]; then
       z_Report_Error "Missing required parameter: --name" $Exit_Status_Usage
       return $Exit_Status_Usage
   fi
   
   # Verify allowed signers file exists
   if [[ ! -f "$Signers_File" ]]; then
       z_Report_Error "Allowed signers file not found: $Signers_File" $Exit_Status_IO
       return $Exit_Status_IO
   fi
   
   # Find and display signer
   typeset Signer_Line=$(grep "@$Signer_Name" "$Signers_File")
   
   if [[ -z "$Signer_Line" ]]; then
       z_Report_Error "Signer '$Signer_Name' not found in the allowed signers file" $Exit_Status_General
       return $Exit_Status_General
   fi
   
   typeset Key_Type=$(echo "$Signer_Line" | awk '{print $3}')
   typeset Key_Value=$(echo "$Signer_Line" | awk '{print $4}')
   
   # Create a temporary file to calculate fingerprint
   typeset Temp_Key=$(mktemp)
   echo "$Key_Type $Key_Value" > "$Temp_Key"
   typeset Fingerprint=$(ssh-keygen -l -f "$Temp_Key" 2>/dev/null | awk '{print $2}')
   rm "$Temp_Key"
   
   print "Signer Details for '$Signer_Name':"
   print "----------------------------------------------"
   print "Name: $Signer_Name"
   if [[ "$Signer_Line" =~ "<([^>]+)>" ]]; then
       print "Email: ${match[1]}"
   fi
   print "Key Type: $Key_Type"
   print "Fingerprint: $Fingerprint"
   print "Full Entry: $Signer_Line"
   
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
   # First argument should be the command
   if [[ $# -eq 0 ]]; then
       z_Report_Error "No command specified" $Exit_Status_Usage
       show_Usage "error"
   fi
   
   Command="$1"
   shift
   
   # Validate command
   case "$Command" in
       add|remove|list|show)
           # Valid command
           ;;
       help|-h|--help)
           show_Usage
           ;;
       *)
           z_Report_Error "Unknown command: $Command" $Exit_Status_Usage
           show_Usage "error"
           ;;
   esac
   
   # Process remaining arguments
   while (( $# > 0 )); do
       case "$1" in
           -f|--file)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               Signers_File="$2"
               shift 2
               ;;
           -r|--repo)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               Repo_Path="$2"
               shift 2
               ;;
           -k|--key)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               SSH_Key_Path="$2"
               shift 2
               ;;
           -n|--name)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               Signer_Name="$2"
               shift 2
               ;;
           -e|--email)
               if (( $# < 2 )); then
                   z_Report_Error "Option $1 requires an argument" $Exit_Status_Usage
                   show_Usage "error"
               fi
               Signer_Email="$2"
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

   # Adjust the signers file path if repository is specified
   if [[ "$Repo_Path" != "." && "$Signers_File" == "./.repo/config/verification/allowed_commit_signers" ]]; then
       Signers_File="${Repo_Path}/.repo/config/verification/allowed_commit_signers"
   fi

   # Verify repository is a valid Git repository
   verify_Git_Repository "$Repo_Path" || exit $?

   # Execute the requested command
   case "$Command" in
       add)
           command_Add_Signer || exit $?
           ;;
       remove)
           command_Remove_Signer || exit $?
           ;;
       list)
           command_List_Signers || exit $?
           ;;
       show)
           command_Show_Signer || exit $?
           ;;
   esac
   
   return $Exit_Status_Success
}

# Execute main() only if this script is being run directly (not sourced)
if [[ "${(%):-%N}" == "$0" ]]; then
   main "$@"
   exit $?
fi
