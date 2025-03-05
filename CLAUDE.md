# Open Integrity Project Scripts

## Progressive Trust Terminology

The Open Integrity Project uses specific terminology for each phase of the Progressive Trust model. For the comprehensive terminology guidelines, please refer to:

- [Progressive Trust Terminology Requirements](src/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md)

The Open Integrity Project integrates cryptographic trust mechanisms into Git repositories, establishing verifiable chains of integrity, provenance, and authorship. For a comprehensive overview, see the [README.md](README.md).

## Common Commands
- Audit this repository: `./src/audit_inception_commit-POC.sh`
- Audit another repository: `./src/audit_inception_commit-POC.sh -C /path/to/repo`
- Create repository with signed inception commit: `./src/create_inception_commit.sh -r my_new_repo`
- Get a repository's DID: `./src/get_repo_did.sh -C /path/to/repo`

## Development Commands
- Run regression tests: `./src/tests/TEST-audit_inception_commit.sh`
- Run regression tests with verbose output: `./src/tests/TEST-audit_inception_commit.sh --verbose`
- Update regression test output reference:
  ```bash
  # First capture regular output
  ./src/tests/TEST-audit_inception_commit.sh > src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
  
  # Then append verbose output
  ./src/tests/TEST-audit_inception_commit.sh --verbose >> src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
  ```

## Post-Test Process
When tests pass successfully, follow these steps:

1. For non-version updates (bug fixes, minor changes):
   ```bash
   # Update test output reference - both regular and verbose outputs
   ./src/tests/TEST-script-name.sh > src/tests/OUTPUT-TEST-script-name.txt 2>&1
   ./src/tests/TEST-script-name.sh --verbose >> src/tests/OUTPUT-TEST-script-name.txt 2>&1
   
   # Commit test script and output reference together
   git add src/tests/TEST-script-name.sh src/tests/OUTPUT-TEST-script-name.txt
   git commit -S -s -m "Update TEST-script-name.sh and test output reference
   
   - Fix test expectations to match current behavior
   - Update test output reference to reflect changes
   
   Tests reflect current functionality accurately."
   ```

2. For structural changes or file path modifications:
   ```bash
   # Commit test script changes first
   git add src/tests/TEST-script-name.sh
   git commit -S -s -m "Update TEST-script-name.sh path references
   
   - Adjust file paths to match new directory structure
   - Update test expectations for changed behavior"
   
   # Update output reference files after script changes are committed
   ./src/tests/TEST-script-name.sh > src/tests/OUTPUT-TEST-script-name.txt 2>&1
   ./src/tests/TEST-script-name.sh --verbose >> src/tests/OUTPUT-TEST-script-name.txt 2>&1
   
   # Commit output reference separately
   git add src/tests/OUTPUT-TEST-script-name.txt
   git commit -S -s -m "Update test output reference for TEST-script-name.sh
   
   - Reflect new directory structure in output
   - Include both regular and verbose test outputs
   - Match current script behavior"
   ```

## Version Update Process
When preparing a new version release, follow these steps:

1. Update version numbers in affected scripts:
   - Update `VERSION:` header comment
   - Update `Script_Version` constant
   - Add CHANGE LOG entry with details of changes

2. Run regression tests and update reference output:
   ```bash
   # Verify all tests pass
   ./src/tests/TEST-audit_inception_commit.sh --verbose
   
   # Update reference output with both regular and verbose outputs
   ./src/tests/TEST-audit_inception_commit.sh > src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
   ./src/tests/TEST-audit_inception_commit.sh --verbose >> src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
   ```

3. Update any relevant issue documents:
   - Mark resolved issues as `RESOLVED` with version number
   - Update version references in issues documents
   - Document any architectural decisions or open questions

4. Create separate commits for each file:
   ```
   git add <single-file>
   git commit -S -s -m "Update <file> to version X.Y.Z

   - Bullet point list of specific changes
   - Be thorough but concise
   - Focus on what changed and why

   Broader explanation of the impact and rationale
   behind these changes, if needed."
   ```

5. Repeat for each modified file:
   - Main script (e.g., audit_inception_commit-POC.sh)
   - Test script (e.g., TEST-audit_inception_commit.sh)
   - Issue documents
   - Test output references

6. Push commits and create tags as appropriate:
   ```
   # Push commits to origin
   git push origin main
   
   # For script changes only: Create signed tag with script-specific name
   git tag -s <script-name>-v<version> -m "Release <version> (<date>) of <script-name>"
   # Example: git tag -s audit_inception_commit-POC-v0.1.04 -m "Release 0.1.04 (2025-03-04) of audit_inception_commit-POC.sh"
   
   # Push the tag (for script changes only)
   git push origin <script-name>-v<version>
   ```
   
   Important tagging notes:
   - Create and push script-specific version tags only for changes to scripts (not for documentation-only changes)
   - Documentation-only changes (to requirements, issues, etc.) should be pushed but do not need version tags
   - Each script maintains its own version numbering
   - Always push changes to the upstream repository when complete, regardless of whether a tag is created

## Debugging Strategies

When encountering issues with script behavior:

1. **Add temporary debug output statements**:
   ```zsh
   z_Output debug "Variable value: $variable_name"
   z_Output debug "Exit code from function: $?"
   ```

2. **Debug critical control flow points**:
   - Add debug output before/after key decision points
   - Track values of variables that influence control flow
   - Pay special attention to exit code propagation

3. **Test with --debug flag** before making changes permanent:
   ```
   ./script_name.sh --debug [other options]
   ```

4. **Remove or comment out debug statements** after resolving issues unless they provide ongoing value for maintenance.

## Implementing Architectural Decisions

When implementing system-wide architectural decisions:

1. **Progressive implementation approach**:
   - First implement in one script as a reference implementation
   - Document the architectural decision in the relevant ISSUES document
   - Mark as "PARTIALLY RESOLVED" or "IN PROGRESS (implemented in X script)"
   - Plan for system-wide standardization

2. **Document implementation details** in both:
   - Script-specific issue document (e.g., ISSUES-script_name.md)
   - System-wide issue document (e.g., ISSUES-Open_Integrity_Scripting_Infrastructure.md)

3. **Update regression tests** to align with new architectural decisions
   - Consider both immediate and long-term impact on test expectations
   - Document reason for changes in test expectations

## Enhanced Commit Message Guidelines

When creating commits:

1. **Structure commit messages** with:
   - Clear, concise title (50 chars or less) that identifies the change
   - Blank line after title
   - Bullet points listing specific changes (what changed)
   - Blank line after bullets
   - Paragraph explaining rationale (why it changed)

2. **Use bullet points for specific changes**:
   ```
   - Added tracking of phase numbers in Trust_Assessment_Status
   - Improved output with clear warnings for non-critical issues
   - Enhanced documentation explaining exit code behavior
   ```

3. **Sign and sign-off your commits**:
   ```
   git commit -S -s -m "Your message"
   ```
   - `-S` cryptographically signs with your key
   - `-s` adds DCO sign-off line

4. **Handle quoting in commit messages**:
   - Use single quotes for the entire message when it contains double quotes
   ```
   git commit -S -s -m 'Update "Error Handling" section'
   ```
   - Use double quotes for the message when it contains single quotes
   ```
   git commit -S -s -m "Fix issue with user's input"
   ```

5. **Create separate commits for each file** when implementing architectural changes or addressing issues that span multiple files.

## Main Scripts

### 🔍 `src/audit_inception_commit-POC.sh`
- **Purpose**: Audit a repository's inception commit
- **Requirements**: [src/requirements/REQUIREMENTS-audit_inception_commit-POC.md](src/requirements/REQUIREMENTS-audit_inception_commit-POC.md)
- **Issues**: [src/issues/ISSUES-audit_inception_commit-POC.md](src/issues/ISSUES-audit_inception_commit-POC.md)
- **Test**: [src/tests/TEST-audit_inception_commit.sh](src/tests/TEST-audit_inception_commit.sh)

### 🏗️ `src/create_inception_commit.sh`
- **Purpose**: Create a repository with a signed inception commit
- **Requirements**: [src/requirements/REQUIREMENTS-create_inception_commit.md](src/requirements/REQUIREMENTS-create_inception_commit.md)
- **Test**: [src/tests/TEST-create_inception_commit.sh](src/tests/TEST-create_inception_commit.sh)

### 🔍 `src/get_repo_did.sh`
- **Purpose**: Get a repository's DID
- **Requirements**: [src/requirements/REQUIREMENTS-get_repo_did.md](src/requirements/REQUIREMENTS-get_repo_did.md)

## Reference Documents

### Requirements
- Core principles: [src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md](src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
- Script best practices: [src/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md](src/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)
- Framework scripts: [src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md](src/requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md)
- Utility functions: [src/requirements/REQUIREMENTS-z_Utils_Functions.md](src/requirements/REQUIREMENTS-z_Utils_Functions.md)
- Regression tests: [src/requirements/REQUIREMENTS-Regression_Test_Scripts.md](src/requirements/REQUIREMENTS-Regression_Test_Scripts.md)
- Progressive Trust terminology: [src/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md](src/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md)

### Issues
- Infrastructure issues: [src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)
- Core scripting issues: [src/issues/ISSUES-Zsh_Core_Scripting_Best_Practices.md](src/issues/ISSUES-Zsh_Core_Scripting_Best_Practices.md)

## Templates
- Script template: [src/snippet_template.sh](src/snippet_template.sh)
- Framework: `z_min_frame.sh` or `z_frame.sh`