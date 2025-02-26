_file: `https://github.com/OpenIntegrityProject/scripts/blob/main/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md`_

# Open Integrity Project - System-Wide Scripting Infrastructure Issues
_(Last updated: 2025-02-26, Christopher Allen <ChristopherA@LifeWithAlacrity.com>)_

## Commit Signature, Sign-Off, and Pull Request Enforcement

### ISSUE: Enforcing Commit Sign-Off at Git and GitHub Levels  

**Context:**  
Open Integrity repositories require all commits to be **signed off** by the `git` author using the `Signed-off-by` trailer, either by using the `-s|--signoff` argument in `git commit` or by manually adding it to the commit message. However, there is currently no enforcement mechanism at the local `git` level or on GitHub to **ensure compliance** with this requirement.

**Current:**  
- Developers may forget to sign off their commits, leading to **policy non-compliance**.  
- Git does not provide **built-in enforcement** for the presence of a `Signed-off-by` trailer.  
- GitHub allows enforcement via **branch protection rules**, **GitHub Actions**, or **pre-receive hooks** on Enterprise plans, but no standardized enforcement mechanism exists across repositories.  
- There is **no automatic verification at commit time** unless users set up a local `commit-msg` hook.  

**Impact:**  
- **Policy Violation:** Non-compliant commits may be merged without proper sign-offs.  
- **Legal and Compliance Risk:** The sign-off process aligns with the Developer Certificate of Origin (DCO), ensuring authorship attestation. Missing sign-offs weaken compliance.  
- **Inconsistent Enforcement:** Some contributors may enforce sign-offs manually, while others may not.  
- **Manual Overhead:** Maintainers must **manually check** commits for compliance.  

**Proposed Actions:**  

### 1. Enforce Sign-Off Locally Using Git Hooks  
Implement a **local Git commit-msg hook** to prevent commits **without a Signed-off-by trailer**. This ensures enforcement at commit time.

**Example `commit-msg` Hook:**  
```sh
#!/bin/sh
# Prevent commits without Signed-off-by trailer

commit_msg_file="$1"
signoff_pattern="^Signed-off-by:"

if ! grep -q "$signoff_pattern" "$commit_msg_file"; then
    echo "ERROR: Your commit message must include a Signed-off-by line."
    echo "Please sign off your commit using: git commit -s"
    exit 1
fi
```

**Distribution Strategy:**  
- **Option 1:** Add instructions for developers to set up hooks manually.  
- **Option 2:** Store hooks inside the repository (`.repo/hooks/commit-msg`) and instruct contributors to run:  
```sh
git config --local core.hooksPath .repo/hooks/
```

### 2. Enforce Sign-Off on GitHub Using Branch Protection Rules  
GitHub allows enforcement of sign-offs using the **DCO App** or **branch protection rules**:  
- Enable **"Require commit sign-off"** in repository settings.  
- Enforce via **GitHub Actions** by adding a workflow that checks for the `Signed-off-by` trailer.

**Example GitHub Action (`.github/workflows/signoff-check.yml`):**  
```yaml
name: Enforce Signed-Off Commits

on: [pull_request]

jobs:
  check-signoff:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Check for Signed-off-by line
        run: |
          if ! git log --format=%B -n 1 | grep -q "Signed-off-by:"; then
            echo "ERROR: Commit is missing Signed-off-by line."
            exit 1
          fi
```

### 3. Enforce Sign-Off via GitHub CLI (`gh`) or API  
For repository maintainers who use `gh` or the GitHub API:  
- Use `gh pr list` and `gh pr view` to check commits before merging.  
- Use the GitHub API to **automate checks** before pull requests are merged.

**Example API Check (using `gh` CLI):**  
```sh
PR_NUMBER=$(gh pr list --json number --jq '.[0].number')
COMMITS=$(gh pr view "$PR_NUMBER" --json commits --jq '.commits[].message')

if ! echo "$COMMITS" | grep -q "Signed-off-by:"; then
    echo "ERROR: One or more commits are missing Signed-off-by."
    exit 1
fi
```

### 4. Improve Contributor Documentation  
- Update repository guidelines to emphasize **commit sign-off policies**.  
- Add a **pre-commit checklist** in `CONTRIBUTING.md`.  
- Include **instructions** on configuring local Git hooks for automatic enforcement.  

By implementing these actions, we ensure all commits to Open Integrity repositories are **properly signed off**, improving **compliance**, **security**, and **auditability**.

### ISSUE: Enforcing Signed Commits and PR-Based Workflows

**Context:**  
The Open Integrity repositories require that all commits be signed and that pull request workflows be enforced to ensure repository integrity. However, there is currently no system-wide enforcement mechanism to ensure that these policies are consistently applied across all repositories.

**Current:**  
- Developers may commit unsigned changes, leading to compliance gaps.  
- GitHub allows enforcement via **branch protection rules**, **GitHub Actions**, and **pre-receive hooks** (Enterprise), but no standardized enforcement exists across all repositories.  
- No **automated verification** occurs at the commit or PR level without explicit setup.  

**Impact:**  
- **Policy Violation:** Unsigned commits may be merged, bypassing security policies.  
- **Inconsistent Enforcement:** Different repositories may apply different rules, leading to confusion.  
- **Manual Overhead:** Maintainers must manually verify compliance, increasing workload.  

**Comparison of Enforcement Methods:**

| **Method**                     | **Enforcement Level** | **Pros**                                               | **Cons**                                                 |
|--------------------------------|----------------------|------------------------------------------------------|--------------------------------------------------------|
| **Git Hooks (Local)**          | Developer's Machine  | Immediate feedback, enforced at commit time         | Requires manual setup by each developer               |
| **Branch Protection Rules**    | GitHub Repository   | Centralized enforcement via GitHub settings        | Only applies to direct pushes, not PR merges         |
| **GitHub Actions**             | PR-Level Automation | Automatic verification before merging              | Adds CI overhead, must be maintained                  |
| **GitHub API/CLI Checks**      | Manual Review       | Can be integrated into custom review processes    | Requires manual execution or additional automation    |

**Proposed Actions:**  

### Enforce Signed Commits Locally Using Git Hooks  
Implement a local **Git commit-msg hook** to prevent unsigned commits.  

Example `commit-msg` hook:
```sh
#!/bin/sh
commit_msg_file="$1"
signoff_pattern="^Signed-off-by:"

gpg --verify $(git rev-parse HEAD) 2>/dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: Your commit must be GPG signed."
    exit 1
fi

if ! grep -q "$signoff_pattern" "$commit_msg_file"; then
    echo "ERROR: Your commit message must include a Signed-off-by line."
    echo "Please sign off your commit using: git commit -s"
    exit 1
fi
```

To automate hook installation, developers should configure:
```sh
git config --local core.hooksPath .repo/hooks/
```
Alternatively, using the [`pre-commit` framework](https://pre-commit.com/) can simplify setup:
```yaml
- repo: local
  hooks:
    - id: signed-commits
      name: Enforce Signed Commits
      entry: ./check_signed_commit.sh
      language: system
      types: [commit-msg]
```

### Enforce Signed Commits on GitHub via Branch Protection Rules  
- Enable **"Require signed commits"** in repository settings. This setting ensures that all commits pushed directly to a protected branch must be signed, but it does not check PR merges.
- Enforce via **GitHub Actions** by adding a workflow that checks for both commit signatures and `Signed-off-by` trailers.
- Require **GitHub Actions as a status check** to enforce PR merge compliance:
```sh
gh api --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/<OWNER>/<REPO>/branches/main/protection \
  -f required_status_checks='{"strict": true, "contexts": ["Enforce Signed Commits"]}'
```

### Improve GitHub Actions Enforcement

Example GitHub Action (`.github/workflows/enforce-signed-commits.yml`):
```yaml
name: Enforce Signed Commits

on: [pull_request]

jobs:
  verify-signatures:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Verify Signed Commits
        run: |
          for commit in $(git rev-list --format=%H ${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }} | grep -v '^commit'); do
            if ! git verify-commit $commit; then
              echo "❌ Commit $commit is NOT signed!"
              exit 1
            fi
            if ! git log -1 --format=%B $commit | grep -q "Signed-off-by:"; then
              echo "❌ Commit $commit is missing a Signed-off-by line!"
              exit 1
            fi
          done
      - name: Comment on PR if Unsigned Commits Exist
        if: failure()
        uses: actions/github-script@v6
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: "❌ This PR contains unsigned commits. Please sign your commits before merging."
            })
```

### Automate Repository Compliance Audits
To detect unwanted changes or relaxed enforcement settings, schedule periodic audits using GitHub Actions:
```yaml
name: Audit Branch Protections

on:
  schedule:
    - cron: "0 0 * * *" # Runs daily

jobs:
  audit-protections:
    runs-on: ubuntu-latest
    steps:
      - name: Check Protection Settings
        run: |
          gh api /repos/${{ github.repository }}/branches/main/protection || exit 1
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
- 2025-02-26 There are now some recommended function documentation requirements for Zsh Snippet at  [Zsh Core Scripting Requirements and Best Practices: § Script Documentation](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md#zsh-snippet-scripting---script-documentation)

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
- 2025-02-26 There are now some recommended error codes, best practices and examples in [Zsh Core Scripting Requirements and Best Practices: §Error Handling Requirment](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md#zsh-core-scripting---error-handling-requirements)

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
