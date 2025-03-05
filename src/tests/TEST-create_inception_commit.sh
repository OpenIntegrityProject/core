#!/usr/bin/env zsh
########################################################################
## Script:        TEST-create_inception_commit.sh
## Version:       0.1.03 (2025-03-04)
## Origin:        https://github.com/BlockchainCommons/open_integrity-git_inception_WIP/snippets/tests
## Description:   Regression test harness for create_inception_commit.sh
##                script, testing conformance to Open Integrity Project
##                standards and Zsh scripting requirements.
## License:       BSD-3-Clause (https://spdx.org/licenses/BSD-3-Clause.html)
## Copyright:     (c) 2025 Blockchain Commons LLC (https://www.BlockchainCommons.com)
## Attribution:   Christopher Allen <ChristopherA@LifeWithAlacrity.com>
## Usage:         TEST-create_inception_commit.sh [-v|--verbose]
## Examples:      TEST-create_inception_commit.sh 
##                TEST-create_inception_commit.sh --verbose
## Testing Strategy:
##   - Comprehensive coverage of script functionality
##   - Flexible error message matching
##   - Detailed diagnostic output
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options
setopt errexit nounset pipefail localoptions warncreateglobal

# Script constants
typeset -r Script_Name=$(basename "$0")
typeset -r Script_Version="0.1.03"  # Updated version
typeset -r Script_Dir=$(dirname "$0:A")

# Define TRUE/FALSE constants
typeset -r TRUE=1
typeset -r FALSE=0

# Script-scoped variables
typeset -r Target_Script="${Script_Dir}/../create_inception_commit.sh"
typeset -i Verbose_Mode=$FALSE

# Generate unique test directory names to prevent collisions
typeset -r Timestamp=$(date +%s)
typeset -r Random_Suffix=$RANDOM
typeset -r Test_Base_Dir="/tmp/oi_test_repos_${Timestamp}_${Random_Suffix}"
typeset -r Temp_Repo="/tmp/oi_test_tmp_repo_${Timestamp}_${Random_Suffix}"

# Script-scoped exit status codes
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2
typeset -r Exit_Status_Test_Failure=3
typeset -r Exit_Status_IO=3
typeset -r Exit_Status_Git_Failure=5

# Tracking variables
typeset -i Tests_Total=0
typeset -i Tests_Passed=0
typeset -i Tests_Failed=0
typeset -A test_results

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
    
    # Try to remove the directories directly first
    rm -rf "$Test_Base_Dir" 2>/dev/null || {
        # If removal fails, try resetting permissions using Zsh glob qualifiers
        # (/DN) for directories, recursively, don't sort
        # (.DN) for regular files, recursively, don't sort
        chmod 755 "$Test_Base_Dir"/**/*(/DN) 2>/dev/null || true
        chmod 644 "$Test_Base_Dir"/**/*(.DN) 2>/dev/null || true
        rm -rf "$Test_Base_Dir" 2>/dev/null || true
    }
    
    rm -rf "$Temp_Repo" 2>/dev/null || {
        chmod 755 "$Temp_Repo"/**/*(/DN) 2>/dev/null || true
        chmod 644 "$Temp_Repo"/**/*(.DN) 2>/dev/null || true
        rm -rf "$Temp_Repo" 2>/dev/null || true
    }
    
    # Ensure test directories don't exist before creating them
    if [[ -d "$Test_Base_Dir" ]]; then
        print "Warning: Unable to fully remove existing test directory: $Test_Base_Dir"
        print "Using new unique directory instead."
        return $Exit_Status_Success
    fi
    
    # Create fresh test directories
    mkdir -p "$Test_Base_Dir" || {
        print "Error: Failed to create test base directory: $Test_Base_Dir"
        return $Exit_Status_General
    }
    
    print "Test directories prepared at $Test_Base_Dir"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Run_Test
#----------------------------------------------------------------------#
# Description:
#   Runs a single test and reports results with more flexible error matching
# Parameters:
#   $1 - Test name
#   $2 - Command to run
#   $3 - Expected exit code
#   $4 - Pattern(s) to search for in output (pipe-separated, case-insensitive)
# Returns:
#   Exit_Status_Success if test passes
#   Exit_Status_Test_Failure if test fails
#----------------------------------------------------------------------#
z_Run_Test() {
    typeset TestName="$1"
    typeset Command="$2"
    typeset ExpectedExit="$3"
    typeset PatternString="${4:-}"
    
    (( Tests_Total++ ))
    
    print "TEST: $TestName"
    
    # Run the command and capture output
    typeset Output
    typeset ActualExit
    
    if (( Verbose_Mode )); then
        print "COMMAND: $Command"
        # Run command and capture both output and exit code
        Output=$(eval "$Command" 2>&1)
        ActualExit=$?
        print "$Output"
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
        test_results[$TestName]="FAIL (exit code mismatch)"
        return $Exit_Status_Test_Failure
    fi
    
    # Check output pattern if provided using standard grep
    if [[ -n "$PatternString" ]]; then
        # Split pipe-separated patterns into an array using Zsh parameter expansion
        # (s:|:) splits the string on the '|' character
        typeset -a Patterns
        Patterns=(${(s:|:)PatternString})
        
        typeset -i PatternMatched=$FALSE
        typeset Pattern
        
        # Try matching any of the patterns using grep instead of Zsh regex
        for Pattern in "${Patterns[@]}"; do
            if echo "$Output" | grep -qi "$Pattern"; then
                PatternMatched=$TRUE
                break
            fi
        done
        
        if (( PatternMatched == FALSE )); then
            print "❌ FAILED: Output doesn't match any expected patterns"
            print "EXPECTED PATTERNS: ${(j:, :)Patterns}"
            print "FULL OUTPUT: $Output"
            (( Tests_Failed++ ))
            test_results[$TestName]="FAIL (output mismatch)"
            return $Exit_Status_Test_Failure
        fi
        
        if (( Verbose_Mode )); then
            print "MATCHING PATTERN: $Pattern"
        fi
    fi
    
    print "✅ PASSED"
    (( Tests_Passed++ ))
    test_results[$TestName]="PASS"
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Print_Summary
#----------------------------------------------------------------------#
# Description:
#   Prints a summary of test results with enhanced readability
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
        return $Exit_Status_Success
    else
        print "\n❌ SOME TESTS FAILED! Detailed review required:"
        
        # Properly scope the variable with typeset
        typeset test_name
        for test_name in ${(k)test_results}; do
            if [[ ${test_results[$test_name]} != "PASS" ]]; then
                print "  - $test_name: ${test_results[$test_name]}"
            fi
        done
        
        return $Exit_Status_Test_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: test_Help_And_Basic_Functionality
#----------------------------------------------------------------------#
# Description:
#   Tests help display and basic functionality of the script
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
        "usage|help"
    
    z_Run_Test "Default repository creation" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/default_repo\"" \
        0 \
        "repository initialized|inception commit|initialized with signed inception"
    
    z_Run_Test "Named repository with --repo" \
        "\"$Target_Script\" --repo \"$Test_Base_Dir/named_repo\"" \
        0 \
        "repository initialized|inception commit|initialized with signed inception"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Path_Creation
#----------------------------------------------------------------------#
# Description:
#   Tests path creation capabilities of the script
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
        "created parent directory|repository initialized|initialized with signed inception"
    
    z_Run_Test "Relative path creation" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/relative_path_repo\"" \
        0 \
        "repository initialized|initialized with signed inception"
    
    z_Run_Test "Absolute path creation" \
        "\"$Target_Script\" -r \"$(pwd)/$Test_Base_Dir/absolute_path_repo\"" \
        0 \
        "repository initialized|initialized with signed inception"
    
    z_Run_Test "System temp directory" \
        "\"$Target_Script\" -r \"$Temp_Repo\"" \
        0 \
        "repository initialized|initialized with signed inception"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: test_Error_Cases
#----------------------------------------------------------------------#
# Description:
#   Tests error handling scenarios for the script
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
        "unknown option|invalid option"
    
    # Create a repo that will already exist
    mkdir -p "$Test_Base_Dir/existing_dir"
    "$Target_Script" -r "$Test_Base_Dir/existing_dir" > /dev/null 2>&1 || true
    
    z_Run_Test "Existing repository (should fail)" \
        "\"$Target_Script\" -r \"$Test_Base_Dir/existing_dir\" 2>&1" \
        3 \
        "already exists"
    
    # Test no arguments (from within test dir)
    z_Run_Test "No arguments (creates default name)" \
        "cd \"$Test_Base_Dir\" && \"$Target_Script\" && cd - > /dev/null" \
        0 \
        "repository initialized|inception commit|initialized with signed inception"
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: oi_Check_Inception_Commit_Conformance
#----------------------------------------------------------------------#
# Description:
#   Performs a comprehensive conformance check on a repository's inception
#   commit according to Open Integrity Project standards. Validates the
#   commit structure, signature, authorship, and content requirements.
#
# Parameters:
#   $1 - Repository path to check (must be a valid Git repository)
#
# Returns:
#   Exit_Status_Success (0) if the repository conforms to standards
#   Exit_Status_Git_Failure (5) if any conformance check fails
#   Exit_Status_IO (3) if repository access fails
#
# Required Script Variables:
#   Exit_Status_Success - Success exit code constant
#   Exit_Status_Git_Failure - Git failure exit code constant
#   Exit_Status_IO - I/O failure exit code constant
#
# Side Effects:
#   - Updates test counters when used within a test harness
#   - Outputs test results to stdout
#
# Dependencies:
#   - git command must be available
#   - z_Run_Test function for test execution (when used in test harness)
#
# Usage Example:
#   oi_Check_Inception_Commit_Conformance "/path/to/repo" || return $?
#----------------------------------------------------------------------#
function oi_Check_Inception_Commit_Conformance() {
    typeset RepoPath="$1"
    typeset -i ConformanceStatus=$TRUE
    
    # Validate parameter
    if [[ -z "$RepoPath" ]]; then
        print "ERROR: Repository path parameter required"
        return $Exit_Status_IO
    fi
    
    # Validate repository exists and is accessible
    if [[ ! -d "$RepoPath" ]]; then
        print "ERROR: Repository directory does not exist: $RepoPath"
        return $Exit_Status_IO
    fi
    
    # Validate it's a Git repository
    if [[ ! -d "$RepoPath/.git" ]]; then
        print "ERROR: Not a Git repository: $RepoPath"
        return $Exit_Status_IO
    fi
    
    print "\n===== Checking repository conformance: $RepoPath ====="
    
    # Check 1: Repository has a commit with valid SHA
    z_Run_Test "Repository DID consistency" \
        "cd \"$RepoPath\" && git rev-parse HEAD && cd - > /dev/null" \
        0 \
        "[0-9a-f]" || ConformanceStatus=$FALSE
    
    # Check 2: Initial commit has expected structure
    z_Run_Test "Empty commit conformance" \
        "cd \"$RepoPath\" && git show --name-only HEAD | grep -A 5 \"commit\"" \
        0 \
        "initialize" || ConformanceStatus=$FALSE
    
    # Check 3: Committer name is in proper format (SHA256)
    typeset CommitterName
    CommitterName=$(cd "$RepoPath" && git show --no-patch --format="%cn" HEAD 2>/dev/null)
    
    # Using grep for pattern matching
    z_Run_Test "Committer name format" \
        "echo \"$CommitterName\" | grep -q \"^SHA256:\"" \
        0 \
        "" || ConformanceStatus=$FALSE
    
    # Display the actual committer name for reference
    if [[ -n "$CommitterName" ]]; then
        print "INFO: Committer name set to: $CommitterName"
    fi
    
    # Check 4: Verify required commit message text
    # Using grep for pattern matching
    z_Run_Test "Commit message content" \
        "cd \"$RepoPath\" && git log -1 --pretty=%B | grep -q \"Initialize repository and establish a SHA-1 root of trust\"" \
        0 \
        "" || ConformanceStatus=$FALSE
    
    # Check 5: Verify commit message has proper sign-off
    # Using grep for pattern matching
    z_Run_Test "Commit sign-off present" \
        "cd \"$RepoPath\" && git log -1 --pretty=%B | grep -q \"^Signed-off-by:\"" \
        0 \
        "" || ConformanceStatus=$FALSE
    
    # Check 6: Verify authorship
    z_Run_Test "Commit authorship" \
        "cd \"$RepoPath\" && git show --no-patch --format=\"%an <%ae>\" HEAD" \
        0 \
        "" || ConformanceStatus=$FALSE
    
    # Check 7: Verify signature
    z_Run_Test "Signature conformance" \
        "cd \"$RepoPath\" && ! git verify-commit HEAD 2>&1 | grep -q 'No principal matched' && git verify-commit HEAD 2>&1" \
        0 \
        "good.*signature" || ConformanceStatus=$FALSE
    
    # Check 8: Verify the commit is truly empty (has no files)
    # Using wc and tr for empty tree verification
    z_Run_Test "Empty tree verification" \
        "cd \"$RepoPath\" && git ls-tree -r HEAD | wc -l | tr -d ' '" \
        0 \
        "^0$" || ConformanceStatus=$FALSE
    
    # Return appropriate status
    if (( ConformanceStatus == TRUE )); then
        print "✅ Repository conforms to Open Integrity inception commit standards"
        return $Exit_Status_Success
    else
        print "❌ Repository does NOT conform to Open Integrity inception commit standards"
        return $Exit_Status_Git_Failure
    fi
}

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Orchestrates the main script workflow with enhanced tracking
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
    z_Cleanup_Test_Directories || {
        print "ERROR: Failed to clean up test directories"
        return $Exit_Status_General
    }
    
    # Run test suites and capture results
    {
        test_Help_And_Basic_Functionality
        test_Path_Creation
        test_Error_Cases
        
        # Run test repositories creation first
        "$Target_Script" -r "$Test_Base_Dir/conformance_test_repo" > /dev/null 2>&1 || {
            print "ERROR: Failed to create test repository for conformance testing"
            return $Exit_Status_Test_Failure
        }
        
        # Then check inception commit conformance
        oi_Check_Inception_Commit_Conformance "$Test_Base_Dir/conformance_test_repo"
    } || {
        print "Warning: One or more test suites encountered failures"
    }
    
    # Print summary
    z_Print_Summary
    
    # Return based on test results
    if (( Tests_Failed > 0 )); then
        return $Exit_Status_Test_Failure
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: parse_Parameters
#----------------------------------------------------------------------#
# Description:
#   Processes command line parameters with enhanced error handling
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
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Main entry point for the script with comprehensive error handling
# Parameters:
#   $@ - Command line arguments
# Returns:
#   Exit_Status_Success on success
#   Various error codes on failure
#----------------------------------------------------------------------#
main() {
    print "=== TEST-create_inception_commit.sh v$Script_Version ==="
    
    # Trap to ensure cleanup even if script fails
    trap 'print "Test script interrupted. Cleaning up..."; z_Cleanup_Test_Directories' INT TERM
    
    # Parse command line parameters
    parse_Parameters "$@" || exit $?
    
    # Execute core logic with enhanced error tracking
    core_Logic || {
        typeset exit_code=$?
        print "Test execution failed with exit code $exit_code"
        exit $exit_code
    }
    
    return $Exit_Status_Success
}

# Execute main() only if script is run directly, not sourced
# Zsh-specific syntax for direct execution check
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
    exit $?  # Explicitly propagate the exit status from main
fi
