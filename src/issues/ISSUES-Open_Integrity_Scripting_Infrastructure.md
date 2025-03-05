# Open Integrity Project - System-Wide Scripting Infrastructure Issues
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md`_
> - _github: [`core/src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.*-blue.svg)](CHANGELOG.md)

Issues related to system-wide scripting infrastructure for the Open Integrity Project, addressing cross-cutting concerns that impact multiple scripts and repositories.

## Code Version and Source

This issues document applies to the Open Integrity Project's core collection, **version 0.1.* (2025-03-04)**, which is available at the following sources:

> **Origin:**
> - [Core Repository: _github: `https://github.com/OpenIntegrityProject/core`_](https://github.com/OpenIntegrityProject/core/)
> - [Readme: _github: `https://github.com/OpenIntegrityProject/core/blob/main/README.md`_](https://github.com/OpenIntegrityProject/core/blob/main/README.md)

Each issue is structured with:
- **Context**: Background information about the issue
- **Current**: Description of the current implementation
- **Impact**: Consequences of the current implementation
- **Proposed Actions**: Recommended steps to address the issue
- **Status/Progress**: Current status of the issue (RESOLVED, IN PROGRESS, or OPEN)

## Progressive Trust

### ISSUE: System-Wide Progressive Trust Terminology Standardization (High Priority)
**Context:** Progressive Trust is a foundational concept in the Open Integrity Project that requires consistent terminology across all scripts and documentation. Recent work has clarified the specific terminology that should be used for each phase.

**Current:** While we've created `REQUIREMENTS-Progressive_Trust_Terminology.md` with detailed guidelines and examples, many existing scripts do not consistently follow these guidelines. Specific issues include:
1. Inconsistent use of phase-specific verbs (`assess` vs `assure` vs `verify` vs `affirm` vs `audit`)
2. Some function names don't properly reflect their phase of operation
3. Documentation and comments don't consistently use phase-appropriate terminology
4. Variable names sometimes mix terminology from different phases
5. Output messages don't clearly indicate which Progressive Trust phase they relate to

**Impact:** 
- **Conceptual Confusion:** Inconsistent terminology creates confusion about which Progressive Trust phase an operation belongs to
- **Reduced Clarity:** Users and developers may misunderstand the level of trust being established
- **Documentation Inconsistency:** Makes it difficult to understand how different scripts relate to the Progressive Trust model
- **Maintenance Challenges:** New contributors may not understand the importance of using phase-specific terminology

**Proposed Actions:**
1. **Create a Progressive Trust Terminology Audit Tool:**
   - Develop a script that audits codebase for terminology inconsistencies
   - Flag function names, variables, and comments that use incorrect phase terminology
   - Generate detailed reports of needed terminology changes

2. **Implement System-Wide Standards:**
   - Update all Open Integrity scripts to follow the terminology guidelines
   - Add phase indicators in output messages and section headers
   - Standardize function naming patterns across the codebase
   - Create consistent documentation templates that emphasize phase-specific terminology

3. **Incorporate in Development Workflow:**
   - Add terminology verification to pre-commit hooks and CI/CD pipelines
   - Create a terminology checklist for code reviews
   - Update all script templates with phase-appropriate terminology examples

4. **Training and Documentation:**
   - Create a quick reference guide for Progressive Trust terminology
   - Add examples of correct and incorrect terminology usage
   - Develop a tutorial on applying terminology standards in code

**Progress:**
- 2025-03-04: Created `REQUIREMENTS-Progressive_Trust_Terminology.md` with detailed guidelines
- 2025-03-04: Added issue to `ISSUES-audit_inception_commit-POC.md` to address terminology inconsistencies
- 2025-03-04: Identified specific inconsistencies in existing scripts that need to be addressed

**Status:** IN PROGRESS (Requirements document created, implementation pending)

### Progressive Trust Phase Warning Reporting

### ISSUE: Standardized Warning Reporting for Progressive Trust Phases 4-5
**Context:** The Progressive Trust model includes phases that extend beyond local repository assessment (phases 1-2) verification (phase 3) to include remote affirmation and conformance (phases 4-5)
**Current:** Remote verification failures are reported inconsistently and may inappropriately affect exit codes
**Impact:** Creates confusion for users and automation tools about the severity and meaning of different verification outcomes
**Proposed Actions:**
- Define a standardized approach for reporting phase 4-5 "warnings" that doesn't affect exit codes
- Create a consistent warning reporting mechanism that distinguishes from critical failures
- Implement structured output format (e.g., JSON) for machine-readable warning information
- Develop visual indicators in human-readable output (colors, emoji, sections)
- Document the warning reporting standard for all Open Integrity tools

**Progress:**
- 2025-03-04: Implemented architectural decision in `audit_inception_commit-POC.sh` (v0.1.05) that:
  - Uses exit code 0 when local phases (1-3) pass, even if remote phases (4-5) have warnings
  - Shows warning emoji (⚠️) for remote phase issues rather than error symbols
  - Explicitly labels remote phase issues as "(warning only)" in output
  - Updated documentation to clarify exit code behavior across phases

**Status:** IN PROGRESS (Implemented in audit script, needs system-wide standardization)

## Open Integrity Commit Enforcement

### ISSUE: Automating GitHub & Git Enforcement of Signed Commits and Sign-Offs

**Context:**  
To ensure repository integrity, Open Integrity requires that:
1. **All commits be cryptographically signed (`git commit -S`).**
2. **All commits contain `Signed-off-by:` (`git commit -s`).**
3. **Only merge commits (not squash/rebase) are used to preserve commit signatures.**
4. **Direct commits from the GitHub web interface are blocked.**
5. **Automated enforcement exists across all repositories.**

Git and GitHub offer tools for enforcing these policies, but **there is no single automated system** that ensures consistency across all repositories.

**Current Challenges:**  
- **Unsigned commits can be merged**, undermining repository trust.
- **Sign-offs (`Signed-off-by:`) are not enforced natively** and require separate validation.
- **Squash and rebase merges strip commit signatures**, breaking the cryptographic chain.
- **The GitHub web interface allows commits without signatures**, bypassing signing policies.
- **GitHub Actions provide validation, but no uniform enforcement** exists across repositories.

**Impact of Lack of Enforcement:**  
- **Security Risks:** Unsigned or improperly attributed commits reduce verifiability.
- **Compliance Issues:** Missing sign-offs weaken the **Developer Certificate of Origin (DCO)** process.
- **Manual Overhead:** Maintainers must manually check and enforce signing policies.
- **Loss of Trust:** If signatures are stripped or bypassed, the repository chain of trust is broken.

## **Proposed Actions:**

### **1. Enforce Signed Commits & Sign-Off Locally Using Git Hooks**
Ensure that **all commits are signed and include a Signed-off-by line** at the commit level.

**Example `commit-msg` Hook to Require `Signed-off-by:`**  
```sh
#!/bin/sh
commit_msg_file="$1"
signoff_pattern="^Signed-off-by:"

if ! grep -q "$signoff_pattern" "$commit_msg_file"; then
    echo "ERROR: Your commit message must include a Signed-off-by line."
    echo "Please sign off your commit using: git commit -s"
    exit 1
fi
```

**Example `pre-commit` Hook to Require GPG-Signed Commits:**  
```sh
#!/bin/sh
if ! git verify-commit HEAD &>/dev/null; then
    echo "ERROR: Your commit must be GPG signed."
    exit 1
fi
```

**Automation:**
✅ Provide **setup scripts** to automatically install Git hooks.  
✅ Update **documentation** on enforcing commit signing locally.  

### **2. Enforce Signed Commits & Sign-Offs on GitHub via API**
Enable **branch protections** that require **signed commits and prevent GitHub web UI commits**.

#### **Require Signed Commits via GitHub API**
```sh
gh api --method PATCH \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/<owner>/<repo>/branches/main/protection" \
  -f required_signatures=true
```
To verify:
```sh
gh api "/repos/<owner>/<repo>/branches/main/protection"
```

#### **Disable Squash and Rebase Merges (Preserve Commit Signatures)**
```sh
gh api --method PATCH \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/<owner>/<repo>" \
  -f allow_squash_merge=false \
  -f allow_rebase_merge=false
```

#### **Prevent Commits via GitHub Web Interface**
```sh
gh api --method PUT \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/<owner>/<repo>/branches/main/protection" \
  -f required_status_checks='{"strict":true,"contexts":[]}' \
  -f enforce_admins=true \
  -f restrictions='{"users":[],"teams":[]}'
```

**Automation:**
✅ Provide a **script to configure repository settings automatically**.  
✅ Update **repository documentation** on enforcing GitHub signing policies.  

---

### **3. Enforce Signed Commits & Sign-Off in PRs via GitHub Actions**
Create a **GitHub Action** that blocks PRs with unsigned commits or missing `Signed-off-by`.

#### **Example GitHub Action (`.github/workflows/enforce-signatures.yml`)**
```yaml
name: "Verify Signed Commits & Sign-Offs"
on: [pull_request]

jobs:
  check-signatures:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Verify commit signatures and sign-offs
        run: |
          for commit in $(git rev-list origin/main..HEAD); do
            if ! git verify-commit "$commit" &>/dev/null; then
              echo "❌ ERROR: Commit $commit is NOT signed!"
              exit 1
            fi
            if ! git log -1 --format=%B $commit | grep -q "Signed-off-by:"; then
              echo "❌ ERROR: Commit $commit is missing a Signed-off-by line!"
              exit 1
            fi
          done
```

**Automation:**
✅ Create **a reusable GitHub Action** for all Open Integrity repositories.  
✅ Document **how to integrate this into repository CI/CD workflows**.  

### **4. Automate Repository Compliance Audits**
To ensure **all repositories remain compliant**, schedule automated audits.

#### **Example GitHub Action: Audit Repository Signing Policies**
```yaml
name: "Audit GitHub Repo Signing Enforcement"
on:
  schedule:
    - cron: "0 0 * * *" # Runs daily

jobs:
  audit-branch-protection:
    runs-on: ubuntu-latest
    steps:
      - name: Check Branch Protection Settings
        run: |
          gh api /repos/${{ github.repository }}/branches/main/protection || exit 1
```

**Automation:**
✅ Provide a **GitHub Action template for automated policy audits**.  
✅ Ensure **repositories stay compliant with enforced policies**.  

### **Summary of Enforcement Methods**
| Enforcement | `gh` / API | GitHub Action | Documentation |
|------------|-----------|--------------|--------------|
| Require signed commits | ✅ `gh api` | ✅ `enforce-signatures.yml` | ✅ |
| Require sign-offs (`Signed-off-by`) | ❌ (Not built-in) | ✅ `enforce-signatures.yml` | ✅ |
| Preserve commit signatures on merges | ✅ `gh api` (disable squash/rebase) | ❌ | ✅ |
| Block GitHub web UI commits | ✅ `gh api` (branch protection) | ❌ | ✅ |

---

### **Next Steps**
- [ ] Write detailed **documentation** for local and GitHub-based commit enforcement.
- [ ] Develop **automation scripts** to apply enforcement across repositories.
- [ ] Provide a **repository template** with pre-configured policies.
- [ ] Implement **automated audits** to detect unsigned commits or missing sign-offs.

By implementing these actions, Open Integrity repositories will **enforce cryptographic integrity, prevent signature loss, and automate compliance monitoring**.
```

### Improve Contributor Documentation  
- Update repository guidelines to emphasize **signed commit policies**.  
- Add a **pre-commit checklist** in `CONTRIBUTING.md`.  
- Provide instructions on setting up local Git hooks for enforcement.  

By implementing these actions, Open Integrity repositories will maintain **compliance, security, and auditability** across all projects.

## Repository Transition from Inception Key Authority to Delegated Key Authority

### ISSUE: Automating Allowed Signers Configuration for Delegated Key Authority  
**Context:** When transitioning an Open Integrity Project repository from **Inception Key Authority** to **Delegated Key Authority**, the `.repo/config/verification/allowed_commit_signers` file is added to the repository. However, Git does not automatically use this file for commit signature verification, requiring contributors to manually configure it.  

**Current:**  
- The `allowed_commit_signers` file can be stored in the repository, but `git config --local gpg.ssh.allowedSignersFile .repo/config/verification/allowed_commit_signers` **must be manually set** for each new clone.  
- Git **does not automatically recognize or apply this setting** when the repository is cloned or updated.  
- Contributors unaware of this requirement may experience **signature verification failures**.  
- There is **no existing automation** to ensure that contributors automatically configure Git to use the allowed signers file.  

**Impact:**  
- **Security Risk:** If contributors fail to configure the allowed signers file, they may **unknowingly accept unsigned or unverified commits**.  
- **Contributor Confusion:** Without clear automation, contributors may be unaware that they must manually configure `gpg.ssh.allowedSignersFile`.  
- **Barriers to Adoption:** Increased friction in enforcing Open Integrity signing policies, leading to inconsistent verification practices across repositories.  

**Proposed Actions:**  
1. **Automate Configuration with Git Hooks**
   - Use a `post-checkout` Git hook to automatically configure `gpg.ssh.allowedSignersFile` when contributors switch branches or update their working copy.
   - Use a `post-merge` hook to ensure the correct configuration is applied when the file is updated via a pull or merge.

   **Example `post-checkout` Hook:**
   ```sh
   #!/bin/sh
   SIGNERS_FILE=".repo/config/verification/allowed_commit_signers"

   if [ -f "$SIGNERS_FILE" ]; then
       git config --local gpg.ssh.allowedSignersFile "$SIGNERS_FILE"
       echo "Configured gpg.ssh.allowedSignersFile to $SIGNERS_FILE"
   fi
   ```

2. **Distribute Hooks Automatically**
   - Add instructions for users to run:
     ```sh
     git config --local core.hooksPath .repo/hooks/
     ```
     so that hooks can be stored **inside the repository** rather than requiring manual installation.

3. **Improve Documentation**
   - Update contributor guides to explicitly mention the required configuration.
   - Add a warning message in commit verification scripts when `gpg.ssh.allowedSignersFile` is not set.

4. **Consider Alternative Approaches**
   - Evaluate whether an **alternative Git feature** or **environment variable** can be used to apply the allowed signers file automatically.
   - Investigate whether Git could support a **default allowed signers configuration** at the repository level in future updates.

By implementing these actions, we ensure that when a repository transitions to **Delegated Key Authority**, all contributors automatically configure Git to verify signed commits correctly, improving both **security** and **usability**.

## System Documentation Management

### ISSUE: Requirement and Issue Tracking Process
**Context:** No standardized process for managing system requirements and issues that works across different git hosting platforms
**Current:** Inconsistent documentation and tracking of system improvements
**Impact:** Difficulty in maintaining and evolving the system
**Proposed Actions:**
- Develop a formal requirement change tracking process
- Create a standardized issue management system
- Implement versioning for requirements documentation
- Establish a clear review and approval process for changes
- Create migration guides for significant updates

### ISSUE: Improve Requirements Change Tracking
**Context:** Need consistent way to propose and track requirement changes
**Current:** No documented format for tracking requirement changes
**Impact:** Documentation addition only, establishes standard for future changes
**Proposed Actions:** Add new section to `zsh_requirements_best_practices.md` with a standardized change tracking format:

    ### Tracking Requirement Changes
    Changes to these requirements should be proposed using this format:

    ## Change Title
    **Context:** Why change is needed (observed confusion, problems, etc.)
    **Current:** Current requirement text (quoted)
    **Impact:** Required code changes, backwards compatibility notes
    **Proposed Actions:** New requirement text, with examples if relevant
    **Progress:** Dated list of progress to address the issue with files or commit links

## Documentation and Maintenance

### ISSUE: Function Documentation Inconsistency
**Context:** Varying levels of function documentation across different scripts
**Current:** Inconsistent documentation format, missing implementation notes, and unclear parameter descriptions
**Impact:** Reduces code understandability and makes maintenance challenging
**Proposed Actions:**
- Create a standardized function documentation template
- Ensure all functions include:
  - Clear purpose description
  - Detailed parameter explanations
  - Return value documentation
  - Potential side effects
  - Usage examples
  - Implement a documentation review process
**Progress:**
- 2025-02-26 There are now some recommended function documentation requirements for Zsh Snippet at [Zsh Core Scripting Requirements and Best Practices: § Script Documentation](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#zsh-snippet-scripting---script-documentation)


## Code Reuse and Modularity

### ISSUE: Error Handling Standardization
**Context:** Inconsistent error handling across scripts
**Current:** Different scripts use varied approaches to error reporting and exit codes
**Impact:** Reduces predictability and makes error tracking more difficult
**Proposed Actions:**
- Define a comprehensive set of standard exit codes
- Create a consistent error reporting mechanism
- Implement a centralized error logging approach
- Develop a standard error message format
- Ensure all scripts follow the same error handling pattern
**Progress:**
- 2025-02-26: Added recommended error codes, best practices and examples in [Zsh Core Scripting Requirements and Best Practices: §Error Handling Requirment](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md#zsh-core-scripting---error-handling-requirements)
- 2025-03-04: Added architectural decision: non-zero exit codes should fundamentally represent issues with the first phases of Progressive Trust against the local repository (phases 1-3). Problems in phases 4-5 should be reported as warnings rather than affecting exit codes.
- 2025-03-04: Implemented this architectural decision in `audit_inception_commit-POC.sh` v0.1.05:
  - Made local verification failures (phases 1-3) return non-zero exit codes
  - Made remote verification issues (phases 4-5) display as warnings without affecting exit codes
  - Added clear visual differentiation of local vs. remote phase issues in output
  - Updated documentation to explain exit code behavior reasoning

### ISSUE: Limited Code Reusability
**Context:** Scripts lack a clear modular structure for easy reuse
**Current:** Utility functions and core logic are not well-separated
**Impact:** Difficult to adapt scripts for different use cases
**Proposed Actions:**
- Redesign scripts with clear modular architecture
- Create a centralized utility library
- Standardize function and module interfaces
- Document customization points
- Develop guidelines for script template usage

## Testing and Validation

### ISSUE: Limited and Inconsistent Test Coverage
**Context:** Current test approaches lack comprehensive coverage and consistency
**Current:** Basic test harnesses with limited scenarios and duplicated code
**Impact:** Reduced confidence in script reliability and maintainability
**Proposed Actions:**
- Develop a unified test framework
- Create a shared utility library for testing
- Expand test cases to cover:
  - Edge cases
  - Error handling
  - Different configuration scenarios
- Implement performance and security-focused test scenarios
- Standardize test output formatting
- Create missing tests for scripts that currently lack them

### ISSUE: Missing Test for get_repo_did.sh (Priority: Medium)
**Context:** The script get_repo_did.sh doesn't have a test script and test output reference
**Current:** 
- Two of the three core scripts have tests: audit_inception_commit-POC.sh and create_inception_commit.sh
- get_repo_did.sh lacks a test script (TEST-get_repo_did.sh) and test output reference (OUTPUT-TEST-get_repo_did.txt)
**Impact:** 
- No automated verification of get_repo_did.sh functionality
- No regression testing capability for this script
- Inconsistent testing approach across the codebase
**Proposed Actions:**
- Create TEST-get_repo_did.sh following the pattern of existing test scripts
- Include tests for different repository scenarios
- Test error cases and edge conditions
- Generate OUTPUT-TEST-get_repo_did.txt reference file
- Ensure the test script properly cleans up after itself
**Status:** OPEN

### ISSUE: Inconsistent Test Output File Naming (Priority: Low)
**Context:** There are inconsistencies in test output file naming and content
**Current:** 
- We have both OUTPUT-TEST-audit_inception_commit-POC.txt and OUTPUT-TEST-audit_inception_commit.txt
- The test script is named TEST-audit_inception_commit.sh (without "-POC")
- OUTPUT-TEST-audit_inception_commit-POC.txt contains outdated paths (references to /scripts/ instead of /core/)
**Impact:** 
- Confusing naming convention
- Outdated references in test output files
- Potential issues when comparing test results
**Proposed Actions:**
- Standardize naming convention for all test output files
- Update all test output files to use current paths
- Remove redundant or outdated test output files
- Update CLAUDE.md to clarify the naming convention for test outputs
**Status:** OPEN

### ISSUE: Test Scripts Not Cleaning Up Temporary Directories
**Context:** Test scripts create temporary directories in /tmp/ (such as oi_test_repos_*) that are not always cleaned up after tests complete
**Current:** The test scripts accumulate tmp/ directories over time, causing disk space usage to grow
**Impact:** 
- Consumes unnecessary disk space
- Makes test environments less isolated
- May lead to confusion when analyzing test outputs
- Reduces the cleanliness of the testing process
**Proposed Actions:**
- Modify test cleanup functions to ensure all temporary directories are properly removed
- Add a proper EXIT trap to ensure cleanup even when tests fail or are interrupted
- Implement a periodic cleanup routine that removes old test directories
- Add automated cleanup checks to CI/CD pipelines
- Update test documentation to include information about cleanup expectations
**Status:** OPEN

### ISSUE: Inconsistent z_Output() Implementation and Documentation
**Context:** Multiple implementations of `z_Output()` across different scripts with varying behaviors and features. Current best implementations are split between:
- `z_min_frame.sh` (current best minimal implementation)
- `audit_inception_commit-POC.sh` (most proven full version with bug fixes)
- `z_frame.sh` (variant with semantic themes and possible improvements)
- `z_output_demo.sh` (best function test harness but missing recent improvements)
**Current:** Different scripts use varied approaches to output handling, semantic themes, and error reporting.
**Impact:** Reduces code reusability, makes maintenance more difficult, and creates confusion in output handling.
**Proposed Actions:**
- Evaluate if the minimal version of `z_Output()` is really needed
- Consolidate code from different versions into `z_output_demo.sh` and update test script
- Ensure consistent parameter handling
- Standardize emoji and formatting across implementations
- Puzzle out solution for `Wrap=` issues with SSH keys and other long content
- Puzzle out solution for prompt mode known bug
- Implement consistent debug output formatting
- Create a canonical version of the full `z_Output` function in `z_output_demo.sh` at `ChristopherA/z_utils`
  - Add comprehensive documentation and examples
