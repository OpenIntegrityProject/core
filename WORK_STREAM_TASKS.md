# Open Integrity Project: Work Stream Tasks

This document tracks tasks across multiple work streams (branches) for the Open Integrity Project. It serves as the single source of truth for project status and planning.

## Work Stream Management Strategy

To maintain this document's integrity while supporting parallel development, follow these guidelines:

1. **Single Source of Truth**
   - This document in `main` is the official record of all work streams
   - Each task is tagged with its branch name in square brackets: `[branch-name]`
   - Only update your branch's sections, leave other sections intact

2. **Status Updates**
   - When making significant progress in a branch, update this document with status
   - Create a small, focused PR to update just your branch's tasks in this document
   - Keep documentation changes separate from code changes where possible

3. **Branch Creation Process**
   - When creating a new branch, add a new section to this document
   - Follow the existing format: branch name, description, and priority levels
   - Tag all tasks with the branch name in square brackets

4. **Completion Updates**
   - When a task is completed, mark it as done and add the completion date
   - Move completed tasks to the "Completed" section under your branch
   - Final branch PR should include the completed status in this document

This approach keeps all status information in one place while clearly assigning ownership of tasks to specific branches.

## Branch: [work-stream-management]

Implementation of a standardized work stream tracking system for multi-branch development.

**Related Issues:**
- [ISSUES-Open_Integrity_Scripting_Infrastructure.md: System-Wide Issues](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md)
  > While there's no specific issue for work stream management, this work addresses broader system documentation management needs.

**Related Requirements:**
- [REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md: Documentation](src/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
  > Covers general documentation requirements applicable to all project aspects.

### Stage 1: Strategy & Planning
- [x] **Define work stream management strategy** (2025-03-05)
  - [x] Define document format and branching workflow
  - [x] Add strategy section to document header
  - [x] Document task tagging approach with branch names

### Stage 2: Implementation
- [x] **Implement work stream tracking system** (2025-03-05) [work-stream-management]
  - [x] Rename and move OPEN_TASKS.md to WORK_STREAM_TASKS.md in root directory
  - [x] Update branch section with new format and tags
  - [x] Design PR workflow for status updates

### Stage 3: Documentation
- [x] **Document process in developer guides** (2025-03-05) [work-stream-management]
  - [x] Add work stream management to CLAUDE.md
  - [x] Create example for onboarding new developers

### Stage 4: System Documentation
- [ ] **Update system-wide documentation** [work-stream-management]
  - [ ] Add work stream management section to ISSUES-Open_Integrity_Scripting_Infrastructure.md
  - [ ] Document the process as a formalized system practice
  - [ ] Create a GitHub Issue for tracking future improvements to the workflow

### Stage 5: Integration
- [ ] **Create and review pull request** [work-stream-management]
  - [x] Perform thorough pre-commit review of all changes (2025-03-05)
    - [x] Use `git diff` to review each file individually  
    - [x] Verify consistency across files
    - [x] **CRITICAL**: Human author personally reviewed all changes
  - [x] Stage files individually with separate `git add <file>` commands (2025-03-05)
  - [x] Human author created properly formatted commits following CLAUDE.md guidance (2025-03-05)
  - [x] Push branch to GitHub (2025-03-05)
  - [x] Create PR for merging to main (2025-03-05)
  - [x] Review PR locally (2025-03-05)
  - [ ] Review PR on GitHub
  - [ ] Approve and merge PR

### Completed in this Branch
- [x] **Branch creation and setup** (2025-03-05)
  - [x] Create 'work-stream-management' branch
  - [x] Move and rename OPEN_TASKS.md to WORK_STREAM_TASKS.md
- [x] **Process definition** (2025-03-05)
  - [x] Define document format and branching workflow
  - [x] Add strategy section to document header
  - [x] Document task tagging approach with branch names
- [x] **Implementation** (2025-03-05)
  - [x] Update document with branch tagging format
  - [x] Design PR workflow for status updates
  - [x] Document the process in CLAUDE.md
- [x] **Documentation** (2025-03-05)
  - [x] Add work stream management to CLAUDE.md
  - [x] Create example document in docs/examples/
- [x] **Pre-commit review requirements** (2025-03-05)
  - [x] Document human review requirements for all changes
  - [x] Add pre-commit review section to CLAUDE.md
  - [x] Distinguish between AI assistance and human responsibility
  - [x] Emphasize proper signing and certification by human authors

## Branch: [enforce-ssh-signatures]

Implementation of SSH signature enforcement under the Inception Authority trust model with GitHub and local git integration.

**Related Issues:**
- [ISSUES-Open_Integrity_Scripting_Infrastructure.md: Automating GitHub & Git Enforcement](src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md#issue-automating-github--git-enforcement-of-signed-commits-and-sign-offs)
  > "To ensure repository integrity, Open Integrity requires that all commits be cryptographically signed (`git commit -S`) and contain `Signed-off-by:` (`git commit -s`)."

**Related Requirements/Documentation:**
- [Open_Integrity_Problem_Statement.md: Signature Requirement](docs/Open_Integrity_Problem_Statement.md#linking-a-chain-of-trust)
  > "Every commit after the _Inception Commit_ requires an authorized SSH signature, ensuring proof of authenticity and tamper resistance."
- [Progressive_Trust_Terminology.md: Verification Terms](src/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md)
  > Contains terminology for signature verification in the Progressive Trust model
- [Enforcing_Signed_Commits_And_PRs_GitHub.md](docs/Enforcing_Signed_Commits_And_PRs_GitHub.md)
  > Current documentation on enforcing commits that needs to be updated
  
### Stage 1: Branch Initialization and Task Planning

- [x] **Initialize branch for development** [enforce-ssh-signatures] (High Priority)
  - [x] Sync branch with latest changes from main (`git pull origin main`)
  - [x] Review updated task list and make final adjustments

- [x] **Review and update branch tasks** [enforce-ssh-signatures] (High Priority)
  - [x] Review untracked/GITHUB_API_ISSUES_LOG.md for details on GitHub API challenges
  - [x] Review ISSUES-Open_Integrity_Scripting_Infrastructure.md for relevant sections
  - [x] Analyze docs/Enforcing_Signed_Commits_And_PRs_GitHub.md for outdated content
  - [x] Update WORK_STREAM_TASKS.md with comprehensive task list for the branch

- [ ] **Complete initial branch setup** [enforce-ssh-signatures] (High Priority)
  - [ ] Stage WORK_STREAM_TASKS.md file for commit (`git add WORK_STREAM_TASKS.md`)
  - [ ] Create properly formatted commit with sign-off (`git commit -S -s -m "..."`)
  - [ ] Push branch to GitHub repository (`git push origin enforce-ssh-signatures`)

### Stage 2: Branch Management Strategy

- [ ] **Establish branch update strategy** [enforce-ssh-signatures] (High Priority)
  - [ ] Research best practices for updating WORK_STREAM_TASKS.md in main without disrupting branch work
  - [ ] Document cherry-pick process for selective updates to WORK_STREAM_TASKS.md to main from feature branch
  - [ ] Create guidance for handling WORK_STREAM_TASKS.md conflicts during branch updates
  - [ ] Consider updating CLAUDE.md with branch status update procedures if needed

- [ ] **Implement branch management practices** [enforce-ssh-signatures]
  - [ ] Keep branch up-to-date with main using `git pull origin main`
  - [ ] Resolve any conflicts, particularly in WORK_STREAM_TASKS.md, maintaining branch tasks
  - [ ] Push updated branch to GitHub regularly (`git push origin enforce-ssh-signatures`)
  - [ ] Consider creating a draft PR early to track progress
  - [ ] Research how "in-progress" PRs work on GitHub, so we can push early draft PR there.
  - [ ] Push the draft PR to GitHub as an "in-progress" PR.

- [ ] **Create process for status updates to main** [enforce-ssh-signatures]
  - [ ] Create small, focused PRs for WORK_STREAM_TASKS.md updates only
  - [ ] Use cherry-picking to select only status-related commits
  - [ ] Document process for other branches to follow
  - [ ] Test process with a small status update PR

### Stage 3: Documentation of Current Challenges

- [ ] **Document existing GitHub API issues and limitations** [enforce-ssh-signatures] (High Priority)
  - [ ] Create `src/issues/ISSUES-GitHub_API_Integration.md` based on `untracked/GITHUB_API_ISSUES_LOG.md`
  - [ ] Format it according to standard ISSUES document structure with Context/Current/Impact/Proposed Actions
  - [ ] Document issues with GitHub API compatibility with existing documentation
  - [ ] Document issues with GitHub's transition from Branch Protection Rules to Repository Rulesets
  - [ ] Document bootstrapping challenges for new repositories with single collaborators

- [ ] **Separate GitHub-specific issues from general infrastructure issues** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Review `src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md` for GitHub-specific content
  - [ ] Move relevant GitHub-specific sections to the new GitHub issues document
  - [ ] Ensure cross-references between documents maintain clarity

### Stage 4: Research and Requirements Definition

- [ ] **Research current GitHub API and CLI limitations** [enforce-ssh-signatures] (High Priority)
  - [ ] Test current GitHub Ruleset API using `gh api` to determine proper format and parameters
  - [ ] Document the process for repository configuration via GitHub API vs. UI
  - [ ] Investigate how repository rulesets can be created and modified via API
  - [ ] Research alternatives to deprecated GitHub CLI commands

- [ ] **Define requirements for different hosting environments** [enforce-ssh-signatures] (High Priority)
  - [ ] Create `src/requirements/REQUIREMENTS-configure_ssh_signatures.md` as a framework document
  - [ ] Define separate requirements for self-hosted git repositories vs. platform services
  - [ ] Document specific requirements for GitHub, with notes for future platform support
  - [ ] Define bootstrapping process requirements for new repositories

- [ ] **Identify git hooks requirements for local enforcement** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Research requirements for local git repository hooks implementation
  - [ ] Document how hooks should be distributed and installed
  - [ ] Define verification process for local commits vs. remote/pulled commits

### Stage 5: Update Documentation

- [ ] **Update existing documentation** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Enhance `docs/Enforcing_Signed_Commits_And_PRs_GitHub.md` based on current GitHub API
  - [ ] Update with instructions for Repository Rulesets vs. Branch Protection Rules
  - [ ] Add documentation on required bypass configurations for repository setup
  - [ ] Include troubleshooting section for common GitHub API issues

- [ ] **Create new documentation for architecture** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Document the overall architecture for signature enforcement
  - [ ] Create clear separation between local git hooks and remote platform integrations
  - [ ] Establish terminology aligned with `REQUIREMENTS-Progressive_Trust_Terminology.md`
  - [ ] Document implementation strategies for different authentication models

### Stage 6: Implementation

- [ ] **Create GitHub configuration automation script** [enforce-ssh-signatures] (High Priority)
  - [ ] Develop `src/configure_github_signatures.sh` following framework script requirements
  - [ ] Implement GitHub repository ruleset configuration capabilities
  - [ ] Support optional bypass configurations for repository admins
  - [ ] Create functions to verify repository settings match intended configuration

- [ ] **Implement local git hooks** [enforce-ssh-signatures] (High Priority)
  - [ ] Create pre-commit hook template for SSH signature verification
  - [ ] Develop commit-msg hook to enforce Signed-off-by requirements
  - [ ] Create installation script to configure hooks in local repositories
  - [ ] Support check and configuration of `gpg.ssh.allowedSignersFile`

- [ ] **Develop GitHub Action for PR verification** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Create GitHub Action workflow template for verifying commit signatures
  - [ ] Ensure compatibility with both GPG and SSH signatures
  - [ ] Add comprehensive verification for Signed-off-by attestations
  - [ ] Create clear and user-friendly error messaging

- [ ] **Add regression tests** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Create comprehensive test cases for local git hook functionality
  - [ ] Develop tests for GitHub configuration script
  - [ ] Generate test output reference files
  - [ ] Ensure proper cleanup of test artifacts

### Stage 7: Documentation and Integration

- [ ] **Update infrastructure issues documentation** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Update `src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md` with progress
  - [ ] Document architectural decisions made during implementation
  - [ ] Mark relevant issues as PARTIALLY RESOLVED or RESOLVED as appropriate
  - [ ] Document any limitations or future work needed

- [ ] **Create comprehensive user guides** [enforce-ssh-signatures] (Medium Priority)
  - [ ] Create step-by-step guides for repository administrators
  - [ ] Document bootstrapping process for new repositories
  - [ ] Create troubleshooting guides for common issues
  - [ ] Include guidance for transitioning from legacy protection mechanisms

### Stage 8: Final Pull Request and Integration

- [ ] **Prepare final changes for review** [enforce-ssh-signatures]
  - [ ] Perform thorough pre-commit review of all changes
    - [ ] Use `git diff` to review each file individually
    - [ ] Verify consistency across files
    - [ ] **CRITICAL**: Human author personally reviews all changes
  - [ ] Stage files individually with separate `git add <file>` commands
  - [ ] Human author creates properly formatted commits following CLAUDE.md guidance
  - [ ] Ensure commits are signed (`-S`) and include sign-off (`-s`)
  
- [ ] **Create and process final pull request** [enforce-ssh-signatures]
  - [ ] Push branch to GitHub (if not already using draft PR)
  - [ ] Create or convert to ready PR for merging to main
  - [ ] Review PR locally
  - [ ] Review PR on GitHub
  - [ ] Address any feedback from PR review
  - [ ] Approve and merge PR

## Unassigned to Branch

### Testing Infrastructure
- [ ] **Fix test cleanup issues** [unassigned] (High Priority)
  - [ ] Add proper cleanup code to TEST-audit_inception_commit.sh to remove sandbox directory
  - [ ] Add proper EXIT trap to ensure cleanup even when tests fail or are interrupted
  - [ ] Consider moving test directories to a temporary location instead of repository root

- [ ] **Create test for get_repo_did.sh** [unassigned] (High Priority)
  - [ ] Create TEST-get_repo_did.sh following pattern of existing test scripts
  - [ ] Include tests for different repository scenarios
  - [ ] Test error cases and edge conditions
  - [ ] Generate OUTPUT-TEST-get_repo_did.txt reference file
  - [ ] Ensure the test script properly cleans up after itself

### Standards and Specifications
- [ ] **Complete DID URL standardization** [unassigned] (Medium Priority)
  - [ ] Review and standardize all DID URLs to follow a consistent pattern
  - [ ] Document DID generation and usage processes

### Future Infrastructure
- [ ] **Develop periodic test artifact cleanup script** [unassigned] (Low Priority)
  - [ ] Create script to remove old test artifacts
  - [ ] Add automated cleanup checks to CI/CD pipelines

- [ ] **Implement integration tests** [unassigned] (Medium Priority)
  - [ ] Create comprehensive tests across all scripts
  - [ ] Test interactions between components

## Recently Completed from Main Branch

- [x] **Add documentation for test output naming conventions** (2025-03-04)
  - [x] Update CLAUDE.md with clear guidelines
  - [x] Document process for updating test output files
  - [x] Add file staging requirements for test scripts and output files

- [x] **Update remaining GitHub URLs** (2025-03-04)
  - [x] Complete update of URL references in content of requirements documents
  - [x] Check for any remaining BlockchainCommons references that should be updated
  - [x] Updated all primary document headers with correct repository paths

- [x] **Fix license references** (2025-03-04)
  - [x] Fix incorrect BSD-3-Clause license references in script headers (should be BSD-2-Clause-Patent)
  - [x] Files updated in src/ directory and test scripts
  - [x] Updated REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md with correct license references

- [x] **Fix test output inconsistencies** (2025-03-04)
  - [x] Standardize naming convention by removing redundant file
  - [x] Removed outdated OUTPUT-TEST-audit_inception_commit-POC.txt (using git rm)
  - [x] Keeping only current OUTPUT-TEST-audit_inception_commit.txt