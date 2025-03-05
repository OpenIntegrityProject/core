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

## Branch: [enforce-ssh-signatures] (Example - Not Active)

Implementation of SSH signature enforcement under the Inception Authority trust model.

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

### Stage 1: Requirements
- [ ] **Create requirements for SSH signature enforcement** [enforce-ssh-signatures]
  - [ ] Create `src/requirements/REQUIREMENTS-configure_ssh_signatures.md` as a framework document
  - [ ] Define the goals, parameters, and process for enforcing SSH signatures
  - [ ] Include examples based on GitHub CLI commands

### Stage 2: Documentation
- [ ] **Update existing documentation** [enforce-ssh-signatures]
  - [ ] Enhance `docs/Enforcing_Signed_Commits_And_PRs_GitHub.md` to focus on SSH signatures
  - [ ] Update `src/issues/ISSUES-Open_Integrity_Scripting_Infrastructure.md` with progress
  - [ ] Document the implementation of the Inception Authority trust model in practice

### Stage 3: Implementation
- [ ] **Create automation script** [enforce-ssh-signatures]
  - [ ] Develop `src/configure_ssh_signatures.sh` following framework script requirements
  - [ ] Implement local and GitHub configuration capabilities
  - [ ] Add regression tests and test output reference files
  - [ ] Test against a dedicated GitHub test repository

### Stage 4: Issue Resolution
- [ ] **Update related issue documentation** [enforce-ssh-signatures]
  - [ ] Update the issue in ISSUES-Open_Integrity_Scripting_Infrastructure.md with implementation progress
  - [ ] Mark issue as PARTIALLY RESOLVED or RESOLVED as appropriate
  - [ ] Document any limitations or future work needed

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