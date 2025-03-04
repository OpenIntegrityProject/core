# Open Integrity Project Scripts

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

6. Push commits and create a script-specific version tag:
   ```
   # Push commits to origin
   git push origin main
   
   # Create signed tag with script-specific name
   git tag -s <script-name>-v<version> -m "Release <version> (<date>) of <script-name>"
   # Example: git tag -s audit_inception_commit-POC-v0.1.04 -m "Release 0.1.04 (2025-03-04) of audit_inception_commit-POC.sh"
   
   # Push the tag
   git push origin <script-name>-v<version>
   ```
   
   Note: Use script-specific tags rather than repository-wide version tags
   since each script maintains its own version numbering.

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