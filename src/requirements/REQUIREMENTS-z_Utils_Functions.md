# Z_Utils: Zsh Utility Library Requirements

> - _did: `did:repo:z_utils_function_requirements`_
> - _github: [Z_Utils Requirements](https://github.com/ChristopherA/Z_Utils)_
> - _Updated: 2025-02-28 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.00-blue.svg)](CHANGELOG.md)

## Overview

Z_Utils is a collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities across different projects and contexts.

This requirements document serves as a living specification for the Z_Utils library, guiding its development, maintenance, and evolution.

## Core Design Principles

1. **Reusability**
   - Functions must be applicable across diverse scripting scenarios
   - Minimize external dependencies
   - Support multiple use cases without modification

2. **Consistency**
   - Uniform naming conventions
   - Standardized error handling
   - Predictable function behaviors

3. **Robustness**
   - Comprehensive error checking
   - Graceful failure modes
   - Clear, informative error messages

## Naming Conventions

### Function Naming
- Prefix: `z_`
- Pattern: `z_Verb_Object()`
- Examples:
  - `z_Convert_Path_To_Relative()`
  - `z_Check_Dependencies()`
  - `z_Report_Error()`
  - `z_Affirm_Audi
- The verb `verify` (and associated words with same root) in variable names, it is reserved solely for cryptographic verification `verify_Commit`. Don't use it otherwise.
- Avoid using the verb `validate` (and associated words with same root), use an alternative.

### Variable Naming
- Use `Mixed_Snake_Case`
- Descriptive and context-specific
- Avoid single-letter or overly generic names

## Utility Function Categories

### Error Handling Utilities

#### z_Report_Error Function
- **Signature:** `z_Report_Error(message, [exit_code])`
- **Purpose:** Centralized error reporting mechanism
- **Requirements:**
  - Use `z_Output` for error messaging when available
  - Fall back to direct stderr printing if `z_Output` unavailable
  - Default to `Exit_Status_General` if no exit code provided
  - Always return the specified or default exit code

#### Error Handling Principles
- Prefer returning error codes over direct script termination
- Provide clear, actionable error messages
- Support logging and debugging modes

### Environment and Dependency Utilities

#### z_Setup_Environment Function
- **Purpose:** Initialize script execution environment
- **Requirements:**
  - Verify system and script requirements
  - Check Zsh version compatibility
  - Validate external command dependencies
  - Set up global variables and configurations
  - Return appropriate success or failure status

#### z_Check_Dependencies Function
- **Signature:** `z_Check_Dependencies(command1 command2 ...)`
- **Requirements:**
  - Accept variable number of command arguments
  - Verify availability of each specified command
  - Use `command -v` for dependency checking
  - Provide detailed error messages for missing commands
  - Return `Exit_Status_Dependency` if any command is unavailable

### Path and Directory Management Utilities

#### z_Convert_Path_To_Relative Function
- **Purpose:** Convert absolute paths to user-friendly relative paths
- **Requirements:**
  - Handle current directory conversions
  - Support both absolute and relative input paths
  - Return `./dirname` instead of `.` for readability
  - Use Zsh parameter expansion for efficient path manipulation

#### z_Ensure_Parent_Path_Exists Function
- **Signature:** `z_Ensure_Parent_Path_Exists(path)`
- **Requirements:**
  - Create parent directories if they do not exist
  - Handle both relative and absolute paths
  - Verify directory writability
  - Support optional permission settings
  - Provide clear error messages for creation failures

### Output and Messaging Utilities

#### z_Output Function
- **Purpose:** Standardized script output with formatting and type support
- **Message Types:**
  - print, info, verbose, success, warn, error, debug, vdebug, prompt
- **Requirements:**
  - Detect terminal color capabilities
  - Support emoji-based messaging
  - Handle interactive and non-interactive modes
  - Support verbosity levels
  - Provide consistent formatting across message types

### Cleanup and Resource Management

#### z_Cleanup Function
- **Purpose:** Manage script termination and resource cleanup
- **Requirements:**
  - Handle cleanup for temporary files and directories
  - Support trap-based execution
  - Report cleanup status
  - Ensure cleanup occurs even with abnormal script termination

## Error Code Standards

### Standardized Exit Codes
- `Exit_Status_Success` (0): Successful execution
- `Exit_Status_General` (1): Generic failure
- `Exit_Status_Usage` (2): Command-line usage error
- `Exit_Status_IO` (3): Input/output related error
- `Exit_Status_Dependency` (127): Missing dependency

## Testing and Validation

### Function Testing Requirements
- Each utility function must include:
  - Comprehensive error handling tests
  - Edge case scenario validation
  - Performance considerations
- Support for unit testing and integration testing
- Minimal external testing dependencies

## Compatibility and Portability

### System Requirements
- Zsh 5.8+ with extended globbing
- Minimal external command dependencies
- Compatible with macOS and Linux
- Support for various terminal environments

## Contribution Guidelines

### Development Workflow
- Maintain backward compatibility
- Comprehensive documentation
- Include usage examples
- Provide clear migration paths for changes

## Versioning

### Versioning Strategy
- Semantic versioning
- Backward-compatible updates in minor versions
- Breaking changes in major versions
- Deprecation notices for removed functionality

## Future Roadmap

- Expand utility function library
- Improve cross-platform compatibility
- Enhanced error reporting mechanisms
- More comprehensive testing infrastructure

## Licensing

- BSD-2-Clause Plus Patent License
- Open-source and freely usable
- Requires attribution



## 1. Additions for `REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`

```markdown
## Error Propagation Exception for Help Display

While functions should generally avoid using `exit` directly and instead return error codes to the calling function, specific utility functions like `show_Usage()` may be exempted from this requirement.

### Help Output Exception
- The `show_Usage()` function is allowed to use `exit $Exit_Status_Success` directly after displaying help information.
- This exception is reasonable since help display is a terminal action by design and simplifies the control flow.
- The documentation for such functions should clearly indicate this behavior with a note like "Does not return - exits with Exit_Status_Success (0)" in the function header.

```

## 2. Additions for `REQUIREMENTS-audit_inception_commit.md`

```markdown
## DID Output Requirements
- The repository's DID (`did:repo:<commithashid>`) must be displayed in the default (non-verbose) output mode.
- The DID should be integrated into the final success/failure message using the format:
  ```
  Audit Complete: Git repo at `./reponame` (DID: did:repo:<commithash>) in compliance...
  ```
- This integration provides a clean, readable output while ensuring the critical DID information is prominently displayed.

## Path Display Requirements
- All repository paths displayed to the user must use the `z_Convert_Path_To_Relative()` function for improved readability.
- When the current directory is the repository root, the path should be displayed as `./reponame` rather than just `.`.
- Paths should be displayed consistently across all output modes (verbose and non-verbose).

## Trust Assessment Results Display Requirements
- In non-verbose mode, display a condensed version of the trust assessment results using the following format:
  ```
  Trust Assessment Results:
    ✅ Wholeness (structure, content, format)
    ✅ Cryptographic Proofs (signature)
    ✅ Trust References (identity)
    ✅ Community Standards (GitHub)
  ```
- This format groups assessments by logical phases and provides just enough detail.
- Emojis should be aligned on the left for visual scanning.
