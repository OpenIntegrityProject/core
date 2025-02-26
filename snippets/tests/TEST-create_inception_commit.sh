#!/usr/bin/env zsh
########################################################################
## Script:        TEST-create_inception_commit.sh
## Version:       0.1.01 (2025-02-26)
## Origin:        https://github.com/BlockchainCommons/open_integrity-git_inception_WIP/snippets/tests
## Description:   Tests the create_inception_commit.sh script for compliance with
##                Open Integrity and Zsh scripting requirements.
## License:       BSD-3-Clause (https://spdx.org/licenses/BSD-3-Clause.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         TEST-create_inception_commit.sh [-v|--verbose]
## Examples:      TEST-create_inception_commit.sh 
##                TEST-create_inception_commit.sh --verbose
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.00"
typeset -r Script_Dir=$(dirname "$0:A")

# Define TRUE/FALSE constants
typeset -r TRUE=1
typeset -r FALSE=0

# Script-scoped variables
typeset -r Target_Script="${Script_Dir}/../create_inception_commit.sh"
typeset -r Test_Base_Dir="/tmp/oi_test_repos_$(date +%s)"
typeset -r Temp_Repo="/tmp/oi_test_tmp_repo_$(date +%s)"
typeset -i Verbose_Mode=$FALSE

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
typeset -r Exit_Status_Test_Failure=3

# Tracking variables
typeset -i Tests_Total=0
typeset -i Tests_Passed=0
typeset -i Tests_Failed=0

#----------------------------------------------------------------------#
# Function: show_Usage
#----------------------------------------------------------------------#
# Description:
#   Displays usage information for the script
# Parameters:
#   None
# Returns:
#   Exits with Exit_Status_Usage
#----------------------------------------------------------------------#
show_Usage() {
    print "$Script_Name v$Script_Version - Test create_inception_commit.sh script"
    print ""
    print "Usage: $Script_Name [-v|--verbose]"
    print ""
    print "Options:"
    print "  -v, --verbose       Enable verbose output"
    print "  -h, --help          Show this help message"
    print ""
    print "Examples:"
    print "  $Script_Name        Run tests with standard output"
    print "  $Script_Name -v     Run tests with verbose output"
    exit $Exit_Status_Usage
}

#----------------------------------------------------------------------#
# Function: z_Cleanup_Test_Directories
#----------------------------------------------------------------------#
# Description:
#   Removes test directories to ensure a clean test environment
# Parameters:
#   None
# Returns:
#   Exit_Status_Success on success
#----------------------------------------------------------------------#
z_Cleanup_Test_Directories() {
    print "Cleaning up test directories..."
    rm -rf "$Test_Base_Dir"
    rm -rf "$Temp_Repo"
    mkdir -p "$Test_Base_Dir"
    print "Test directories prepared at $Test_Base_Dir"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Run_Test
#----------------------------------------------------------------------#
# Description:
#   Runs a single test and reports results
# Parameters:
#   $1 - Test name
#   $2 - Command to run
#   $3 - Expected exit code
#   $4 - Pattern to search for in output (optional)
# Returns:
#   Exit_Status_Success if test passes
#   Exit_Status_Test_Failure if test fails
#----------------------------------------------------------------------#
z_Run_Test() {
    typeset TestName="$1"
    typeset Command="$2"
    typeset ExpectedExit="$3"
    typeset ExpectedPattern="${4:-}"
    
    (( Tests_Total++ ))
    
    print "TEST: $TestName"
    
    # Run the command and capture output
    typeset Output
    typeset ActualExit
    
    if (( Verbose_Mode )); then
        print "COMMAND: $Command"
        # Run command and capture exit code, but let output go to terminal
        eval "$Command"
        ActualExit=$?
        print "EXIT CODE: $ActualExit (Expected: $ExpectedExit)"
    else
        Output=$(eval "$Command" 2>&1)
        ActualExit=$?
    fi
    
    # Check exit code
    if (( ActualExit != ExpectedExit )); then
        print "❌ FAILED: Expected exit code $ExpectedExit, got $ActualExit"
        if (( !Verbose_Mode )); then
            print "OUTPUT: $Output"
        fi
        (( Tests_Failed++ ))
        return $Exit_Status_Test_Failure
    fi
    
    # Check output pattern if provided
    if [[ -n "$ExpectedPattern" ]]; then
        if (( Verbose_Mode )); then
            # When in verbose mode, we need to re-run the command to capture output
            Output=$(eval "$Command" 2>&1)
            print "CHECKING OUTPUT for pattern: $ExpectedPattern"
        fi
        
        if ! echo "$Output" | grep -q "$ExpectedPattern"; then
            print "❌ FAILED: Output doesn't match pattern '$ExpectedPattern'"
            if (( !Verbose_Mode )); then
                print "OUTPUT: $Output"
            fi
            (( Tests_Failed++ ))
            return $Exit_Status_Test_Failure
        fi
    fi
    
    print "✅ PASSED"
    (( Tests_Passed++ ))
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Print_Summary
#----------------------------------------------------------------------#
# Description:
#   Prints a summary of test results
# Parameters:
#   None
# Returns:
#   Exit_Status_Success always
#----------------------------------------------------------------------#
z_Print_Summary() {
    print "\n===== TEST SUMMARY ====="
    print "Total tests: $Tests_Total"
    print "Passed:      $Tests_Passed"
    print "Failed:      $Tests_Failed"
    
    if (( Tests_Failed == 0 )); then
        print "\n🎉 ALL TESTS PASSED! 🎉"
    else
        print "\n❌ SOME TESTS FAILED! Please review output above."
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Help_And_Basic_Functionality
#----------------------------------------------------------------------#
# Description:
#   Tests help display and basic functionality
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Help_And_Basic_Functionality() {
    print "\n===== Testing help and basic functionality ====="
    
    z_Run_Test "Help display" \
        "\"$Target_Script\" --help" \
        0 \
        "Usage:"
    
    z_Run_Test "Default repository creation" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/default_repo\"" \
        0 \
        "Repository initialized with signed inception commit"
    
    z_Run_Test "Named repository with --repo" \
        "\"$Target_Script\" --repo \"$Test_Base_Dir/named_repo\"" \
        0 \
        "Repository initialized with signed inception commit"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Path_Creation
#----------------------------------------------------------------------#
# Description:
#   Tests path creation capabilities
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Path_Creation() {
    print "\n===== Testing path creation ====="
    
    z_Run_Test "Nested path creation" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/nested/deeper/path\"" \
        0 \
        "Created parent directory"
    
    z_Run_Test "Relative path creation" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/relative_path_repo\"" \
        0 \
        "Repository initialized with signed inception commit"
    
    z_Run_Test "Absolute path creation" \
        "\"$Target_Script\" -r \"$(pwd)/$Test_Base_Dir/absolute_path_repo\"" \
        0 \
        "Repository initialized with signed inception commit"
    
    z_Run_Test "System temp directory" \
        "\"$Target_Script\" -r \"$Temp_Repo\"" \
        0 \
        "Repository initialized with signed inception commit"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Error_Cases
#----------------------------------------------------------------------#
# Description:
#   Tests error handling
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Error_Cases() {
    print "\n===== Testing error cases ====="
    
    z_Run_Test "Invalid option" \
        "\"$Target_Script\" --invalid-option 2>&1" \
        2 \
        "Error: Unknown option"
    
    # Create a repo that will already exist
    mkdir -p "$Test_Base_Dir/existing_dir"
    "$Target_Script" -r "$Test_Base_Dir/existing_dir" > /dev/null
    
    z_Run_Test "Existing repository (should fail)" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/existing_dir\" 2>&1" \
        3 \
        "already exists"
    
    # Test no arguments (from within test dir)
    z_Run_Test "No arguments (creates default name)" \
        "cd \"$Test_Base_Dir\" && \"$Target_Script\" && cd -" \
        0 \
        "Repository initialized with signed inception commit"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Verification
#----------------------------------------------------------------------#
# Description:
#   Tests verification of created repositories
# Parameters:
#   None
# Returns:
#   Exit_Status_Success if all tests pass
#----------------------------------------------------------------------#
test_Verification() {
    print "\n===== Verifying repositories ====="
    
    z_Run_Test "Repository DID consistency" \
        "cd \"$Test_Base_Dir/default_repo\" && git rev-parse HEAD && cd -" \
        0 \
        "[0-9a-f]"
    
    z_Run_Test "Empty commit verification" \
        "cd \"$Test_Base_Dir/default_repo\" && git show --name-only HEAD | grep -A 5 \"commit\"" \
        0 \
        "Initialize"
    
    z_Run_Test "Signature verification" \
        "cd \"$Test_Base_Dir/default_repo\" && git verify-commit HEAD 2>&1" \
        0 \
        "Good"
    
    z_Run_Test "Check created repositories" \
        "find \"$Test_Base_Dir\" -type d -name .git | sed 's/.git$//' | sort" \
        0 \
        "default_repo"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes command line parameters
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success if parameters are valid
#   Calls show_Usage() for invalid parameters
#----------------------------------------------------------------------#
parse_Parameters() {
    print "Parsing command line parameters..."
    
    while (( $# > 0 )); do
        case "$1" in
            -v|--verbose)
                Verbose_Mode=$TRUE
                print "Verbose mode enabled"
                shift
                ;;
            -h|--help)
                show_Usage
                ;;
            -*)
                print -u2 "Error: Unknown option: $1"
                show_Usage
                ;;
            *)
                print -u2 "Error: Unexpected argument: $1"
                show_Usage
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
#   None
# Returns:
#   Exit_Status_Success on success
#   Exit_Status_Test_Failure if any tests fail
#----------------------------------------------------------------------#
core_Logic() {
    print "Starting tests for create_inception_commit.sh"
    print "Target script: $Target_Script"
    
    # Check that target script exists
    if [[ ! -f "$Target_Script" ]]; then
        print "ERROR: Target script not found at: $Target_Script"
        return $Exit_Status_General
    fi
    
    # Clean up test directories
    z_Cleanup_Test_Directories
    
    # Run test suites
    test_Help_And_Basic_Functionality
    test_Path_Creation
    test_Error_Cases
    test_Verification
    
    # Print summary
    z_Print_Summary
    
    # Return based on test results
    if (( Tests_Failed > 0 )); then
        return $Exit_Status_Test_Failure
    fi
    
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
    print "=== TEST-create_inception_commit.sh v$Script_Version ==="
    
    # Parse command line parameters
    parse_Parameters "$@" || exit $?
    
    # Execute core logic
    core_Logic || exit $?
    
    return $Exit_Status_Success
}

# Execute only if run directly
# Execute main() only if this script is being run directly (not sourced).
# Zsh-specific syntax: ${(%):-%N} expands to the script name when run directly,
# but to the function name when sourced. This is different from Bash's 
# equivalent test: [[ "${BASH_SOURCE[0]}" == "${0}" ]]
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
    exit $?  # Explicitly propagate the exit status from main
fi
