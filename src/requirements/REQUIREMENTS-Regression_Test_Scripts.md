# Regression Test Scripts Requirements
> - _DID: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/REQUIREMENTS-Regression_Test_Scripts.md`_
> - _GitHub: [`scripts/requirements/REQUIREMENTS-Regression_Tests_Scripts.md`](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Regression_Tests_Scripts.md)_
> - _Updated: 2025-03-02 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

# Introduction
Regression test scripts are **lightweight, targeted tests** designed to check the behavior of Zsh scripts. These tests should remain **concise (under 200 lines of code)** and focus on **parameter checking, error handling, and expected script behavior**.

This document outlines the **minimum requirements** for regression test scripts. If testing needs become more extensive—requiring complex mocking, full test suites, or structured test frameworks—consider refactoring into a **broader testing strategy** aligned with the Zsh Framework Scripting Best Practices.

All regression test scripts must follow:
- **[Zsh Core Scripting Best Practices](REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)**
- **[Zsh Snippet Script Best Practices](REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)**

This document covers additional considerations specific to regression test scripts.

## Purpose and Scope

Regression test scripts focus on verifying the correctness and robustness of Zsh scripts, particularly in handling different CLI arguments and error scenarios. The goal is to catch regressions early by systematically exercising all defined options and variations in script execution.

These tests are especially useful when scripts accept user input, interact with the environment, or manipulate files. By checking both expected behaviors and edge cases, they help maintain reliability over time. While not required for the smaller Zsh Snippet scripts (50 - 200 lines of code), they are still recommended to ensure ongoing script stability.

These regression tests are designed to be simple and efficient. They should not introduce unnecessary complexity, require large mock environments, or involve detailed performance benchmarking. Instead, they should focus on ensuring scripts handle valid and invalid inputs as expected, with clear error messages and predictable behavior.

## Handling Changes to Expected Exit Codes

When architectural decisions change the expected exit code behavior of scripts, regression tests must be updated carefully to maintain accuracy while preserving the history of these changes.

### Requirements for Exit Code Changes

1. **Documentation of Exit Code Changes**
   - When expected exit codes change due to architectural decisions, the reason MUST be documented in:
     - The script's ISSUES document (e.g., ISSUES-script_name.md)
     - The script's CHANGELOG entry
     - The test script itself as a clear comment

2. **Test Script Updates**
   - When updating test expectations for exit codes:
     - Add comments explaining the architectural change and its date
     - Update all affected test cases with consistent exit code expectations
     - Update any patterns that match output containing exit code information

3. **Reference Output File Updates**
   - When exit code changes require updating reference output files:
     - Include the update as a separate commit from code changes
     - Document the specific exit code changes in the commit message
     - Include before/after examples in the commit message

4. **Transition Period Handling**
   - For major exit code behavior changes, consider:
     - Adding temporary compatibility test modes
     - Documenting the deprecation timeline
     - Providing migration examples

### Example Documentation for Exit Code Changes

```zsh
# The following test now expects exit code 0 (success) instead of 1 (failure)
# ARCHITECTURAL CHANGE (2025-03-04): Non-zero exit codes now only represent 
# issues with local verification phases (1-3). Issues with remote phases (4-5)
# are reported as warnings but don't affect the exit code.
run_test "GitHub compliance" \
  "$SCRIPT_PATH --no-prompt -C $TEST_REPO_PATH" \
  0 \  # Previously expected 1
  "Audit Complete: Git repo .* in compliance with Open Integrity specification"
```

## Security Considerations

When creating regression test scripts, consider the following security guidelines:
- Never use real sensitive data in test cases
- Avoid executing commands with elevated privileges
- Sanitize and validate all test inputs
- Use temporary directories with restricted permissions
- Ensure test scripts cannot modify system-critical files or configurations
- Implement input validation to prevent potential injection risks
- Log test activities securely, avoiding exposure of sensitive information

## Performance and Efficiency

Regression test scripts should:
- Execute quickly, typically completing within seconds
- Minimize system resource consumption
- Avoid creating large temporary files
- Use lightweight command execution methods
- Prioritize test coverage over exhaustive testing
- Minimize external dependencies
- Use built-in Zsh utilities instead of external commands when possible

Performance anti-patterns to avoid:
- Extensive file I/O operations
- Complex nested loops
- Unnecessary command substitutions
- Repeated invocations of the same test logic
- Large-scale data generation
- Network or resource-intensive validation

## Error Handling and Reporting

Effective error handling is crucial for regression test scripts:

### Error Reporting Principles
- Provide clear, actionable error messages
- Include context about the failed test scenario
- Report both the expected and actual outcomes
- Use consistent error reporting mechanisms

### Error Handling Strategies
- Validate all input parameters
- Check command execution status
- Handle edge cases and unexpected inputs
- Implement graceful error recovery
- Ensure tests can continue after individual test failures

### Utility Functions for Error Management

#### z_Run_Test
Executes a single test case with comprehensive error tracking and reporting. Key features include:
- Detailed failure reporting
- Capturing and analyzing command output
- Tracking total tests, passed tests, and failures
- Supporting both successful and error scenarios

#### z_Error_Report
Provides a standardized method for generating detailed error messages:
- Captures test context
- Formats error information consistently
- Supports different verbosity levels
- Allows for optional logging of error details

#### z_Validate_Input
Offers robust input validation for test scenarios:
- Checks input types and ranges
- Validates command-line argument combinations
- Prevents invalid test configurations
- Provides clear feedback on input issues

## How Regression Tests Work

A well-structured regression test script follows a clear and repeatable pattern. Each test case exercises a specific command scenario, verifies the expected output, and ensures that failure cases return appropriate error codes. 

A typical test case follows this structure:

```zsh
test_CLI_Behavior() {
    z_Run_Test "Scenario Description" \
        "command_to_test --option value" \
        ExpectedExitCode \
        "Optional output pattern"
}
```

Each test case should be designed to check one specific behavior—whether it's checking a correct input, handling an invalid flag, or confirming a script's response to missing arguments.

## Making Tests Reusable

A good regression test suite is modular and reusable. Instead of writing repetitive code, it's best to use shared test functions that handle common patterns. Utility functions help standardize testing by ensuring test results are formatted consistently and failures are easy to debug.

Key functions include:
- **`z_Run_Test`** – Runs a test case, verifies the exit code, and optionally checks output.
- **`z_Cleanup_Test_Environment`** – Cleans up any test artifacts left behind.
- **`z_Print_Summary`** – Displays test results, summarizing total tests, passed tests, and failures.
- **`z_Error_Report`** – Generates standardized error messages
- **`z_Validate_Input`** – Validates test inputs and configurations

Using these functions ensures test scripts are easy to maintain and extend as new test scenarios arise.

### Managing the Test Environment

To keep tests clean and repeatable, regression test scripts should avoid leaving behind files, directories, or altered configurations. Any temporary files should be created only when necessary and cleaned up immediately after the test completes. Tests should always restore the system state so they can be run multiple times without side effects.

Built-in functions help manage this:
- `z_Cleanup_Test_Environment` ensures test files and directories are removed after execution.
- `z_Ensure_Temporary_Directory` creates safe, isolated directories for running tests.

By using these functions, test scripts remain consistent and avoid interfering with the user's environment.

# Conclusion

Regression test scripts provide a lightweight but effective way to check Zsh scripts. By keeping them simple, repeatable, and well-structured, they help ensure scripts behave predictably across different environments and edge cases. With a focus on parameter handling, error checking, and proper cleanup, these tests act as a reliable safeguard against unintended regressions.
