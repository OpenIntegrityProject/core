# Open Integrity Project Scripts

## Terminology Guidelines

When working with Open Integrity Project scripts, please adhere to these Progressive Trust terminology conventions:

1. **Reserved Terms**:
   - Only use "verify/verification/verifying" for cryptographic operations in Phase 3 (Proofs)
   - Never use "validate/validation/validating" as it implies a different trust model

2. **Preferred Alternatives**:
   - Use "assess/assessment" for general checks
   - Use "examine/examination" for detailed inspection
   - Use "check" for basic operational tests
   - Use "evaluate/evaluation" for qualitative judgments

3. **Phase Terminology**:
   - Phase 2 (Wholeness): "assess integrity", "examine structure"
   - Phase 3 (Proofs): "verify signature", "cryptographically verify"
   - Phase 4 (References): "affirm identity", "check references"
   - Phase 5 (Requirements): "evaluate compliance", "check standards"

These distinctions help maintain conceptual clarity in the Progressive Trust model.

The Open Integrity Project integrates cryptographic trust mechanisms into Git repositories, establishing verifiable chains of integrity, provenance, and authorship. For a comprehensive overview, see the [README.md](README.md).

## Common Commands
- Audit this repository: `./audit_inception_commit-POC.sh`
- Audit another repository: `./audit_inception_commit-POC.sh -C /path/to/repo`
- Create repository with signed inception commit: `./snippets/create_inception_commit.sh -r my_new_repo`
- Get a repository's DID: `./snippets/get_repo_did.sh -C /path/to/repo`

## Development Commands
- Run regression tests: `./tests/TEST-audit_inception_commit.sh`
- Run regression tests with verbose output: `./tests/TEST-audit_inception_commit.sh --verbose`
- Update regression test output reference: `./tests/TEST-audit_inception_commit.sh > tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1`

## Version Update Process
When preparing a new version release, follow these steps:

1. Update version numbers in affected scripts:
   - Update `VERSION:` header comment
   - Update `Script_Version` constant
   - Add CHANGE LOG entry with details of changes

2. Run regression tests and update reference output:
   ```
   ./tests/TEST-audit_inception_commit.sh --verbose  # Verify all tests pass
   ./tests/TEST-audit_inception_commit.sh > tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1  # Update reference
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

### 🔍 `audit_inception_commit-POC.sh`
- **Purpose**: Audit a repository's inception commit
- **Requirements**: [requirements/REQUIREMENTS-audit_inception_commit-POC.md](requirements/REQUIREMENTS-audit_inception_commit-POC.md)
- **Issues**: [issues/ISSUES-audit_inception_commit-POC.md](issues/ISSUES-audit_inception_commit-POC.md)
- **Test**: [tests/TEST-audit_inception_commit.sh](tests/TEST-audit_inception_commit.sh)

### 🏗️ `snippets/create_inception_commit.sh`
- **Purpose**: Create a repository with a signed inception commit
- **Requirements**: [snippets/requirements/REQUIREMENTS-create_inception_commit.md](snippets/requirements/REQUIREMENTS-create_inception_commit.md)
- **Test**: [snippets/tests/TEST-create_inception_commit.sh](snippets/tests/TEST-create_inception_commit.sh)

### 🔍 `snippets/get_repo_did.sh`
- **Purpose**: Get a repository's DID
- **Requirements**: [snippets/requirements/REQUIREMENTS-get_repo_did.md](snippets/requirements/REQUIREMENTS-get_repo_did.md)

## Reference Documents

### Requirements
- Core principles: [requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md](requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
- Snippet scripts: [requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md](requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)
- Framework scripts: [requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md](requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md)
- Utility functions: [requirements/REQUIREMENTS-z_Utils_Functions.md](requirements/REQUIREMENTS-z_Utils_Functions.md)
- Regression tests: [requirements/REQUIREMENTS-Regression_Test_Scripts.md](requirements/REQUIREMENTS-Regression_Test_Scripts.md)
- Snippet requirements: [snippets/requirements/](snippets/requirements/)

### Issues
- Core issues: [issues/](issues/)
- Infrastructure issues: [issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md](issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)

## Templates
- Snippet: [snippets/snippet_template.sh](snippets/snippet_template.sh)
- Framework: `z_min_frame.sh` or `z_frame.sh`