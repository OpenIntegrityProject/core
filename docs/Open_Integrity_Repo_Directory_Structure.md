# Open Integrity Project: Git Repository Directory Structure
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Open_Integrity_Repo_Directory_Structure.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity_Repo_Directory_Structure.md`_
> - _updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

This is a first pass of organizing various data and scripts about a repository. One open question is seperation of data about a repository vs scripts that use that data.

Note that much of this doesn't currently work with various Git hosting services (for instance GitHub & GitLab put their files in `.github/` `.gitlab/` respectively). Instead, this is more of a proposal.

Git itself uses `.git/hooks`. but you can set `git config --local core.hooksPath /path/to/your/hooks` to the path inside the repository that you want. However, this is setting unique for each user, and is not automatically established on clone.

## v0

Currently I'm leaning to `.repo` as the name for the root directory of this stack.

```
.repo/
│
├── hooks/
│   ├── pre-commit.sh
│   ├── pre-push.sh
│   ├── commit-msg.sh
│   ├── post-merge
│   └── (etc.)
│
├── scripts/
│   ├── verify_commit_signers.sh
│   ├── verify_tag_signers.sh
│   ├── verify_release_signers.sh
│   ├── deploy_helpers.sh
│   ├── setup_environment.sh
│   └── security_checks.sh
│
├── config/
│   ├── pipeline/
│   │   ├── github_actions.yml
│   │   ├── gitlab_ci.yml
│   │   └── bitbucket_pipelines.yml
│   ├── environment/
│   │   ├── prod_env_settings.env
│   │   └── test_env_settings.env
│   └── verification/
│       ├── allowed_commit_signers.txt
│       ├── allowed_tag_signers.txt
│       └──trust-manifest.env
│
├── docs/
│   ├── README.md
│   ├── config_guide.md
│   ├── setup_instructions.md
│   └── usage_guidelines.md
│
└── monitoring/
    ├── log_analysis.py
    └── performance_monitoring.sh
```

### Explanation of Directory Components

1. **Hooks**:
   - The `hooks/` directory straightforwardly contains all Git hooks used in the repository. This setup aligns with the `git config core.hooksPath` command pointing to this folder, enabling direct application of these hooks without additional configuration.
   
2. **Scripts**:
   - The `scripts/` directory holds all executable scripts related to deployment, verification, and security checks. This separation ensures that scripts are easily manageable and clearly differentiated from configuration data.

3. **Config**:
   - This directory is divided into subdirectories for different configurations:
     - `pipeline/` contains CI/CD configurations for various platforms.
     - `environment/` holds environment-specific settings.
     - `verification/` stores data files like allowed signers which are crucial for commit validation processes.
   - This organization ensures that configuration data is kept separate from scripts, enhancing security and clarity.

4. **Docs**:
   - Documentation related to the repository’s structure, script usage, and configuration guidelines is stored here, providing a central location for all informational content.

5. **Monitoring**:
   - Includes scripts for log analysis and performance monitoring, ensuring that operational aspects of the repository are monitored and maintained effectively.

### Key Benefits

- **Clarity and Accessibility**: The structure is clear, with a logical separation of hooks, scripts, configuration data, and documentation.
- **Security and Integrity**: By separating executable scripts from configuration data, the repository maintains high security and integrity standards, crucial for operations like commit validation and code review.
- **Scalability and Flexibility**: This structure allows easy updates and additions in scripts and configurations without affecting other repository areas, supporting scalability.


## Git Hooks

In a Git repository, several types of hooks can be used to trigger custom scripts at various points in the Git lifecycle. Each hook corresponds to a particular operation within Git and can be placed in the `.git/hooks` folder. 

### Client-Side Hooks
1. **pre-commit**: Runs before a commit is recorded, allowing you to run checks on the changes to be committed.
2. **prepare-commit-msg**: Runs before the commit message editor is opened, allowing you to modify the default commit message.
3. **commit-msg**: Runs after the commit message is written, allowing you to check the contents of the message.
4. **post-commit**: Runs after a commit is completed, useful for notification or other post-commit operations.
5. **pre-rebase**: Runs before a rebase operation starts, giving you a chance to prevent the rebase if necessary.
6. **post-checkout**: Runs after a successful checkout, useful for setting up the working directory properly for your project environment.
7. **post-merge**: Runs after a successful merge, useful for restoring project state or dependencies altered by the merge.
8. **pre-push**: Runs during `git push`, before any objects are transferred, allowing you to run tests or checks.
9. **pre-auto-gc**: Runs automatically before the garbage collection process, which is generally triggered by other commands.

### Server-Side Hooks
1. **pre-receive**: Runs before any commits are accepted into the repository, allowing you to enforce project standards or perform checks.
2. **update**: Runs once for each branch being pushed to check if the push should be accepted.
3. **post-receive**: Runs after all branches and their refs have been updated on the server, often used to update other services or send notifications.
4. **reference-transaction**: Runs during a reference transaction, which can be either during the update of a reference or during the creation/deletion of a reference.
5. **push-to-checkout**: Invoked on the server when a push tries to update a ref that is currently checked out.
6. **post-index-change**: Runs after the staging area (index) is updated.

## Standard Repo Files

Here is a comprehensive list of standard repository files supported by GitHub, GitLab, and Bitbucket, including those within their specific directories like `.github/` or `.gitlab/`:

### GitHub
1. **README.md** - Provides essential information about the project.
2. **LICENSE.md** - Details the licensing terms of the project.
3. **.gitignore** - Specifies intentionally untracked files to ignore.
4. **.gitattributes** - Helps manage attributes of the paths in the Git repository.
5. **.github/** - Contains GitHub-specific files like issue and pull request templates:
   - **ISSUE_TEMPLATE/** - For custom issue templates.
   - **PULL_REQUEST_TEMPLATE.md** - Templates for pull requests.
   - **CODEOWNERS** - Specifies individuals or teams responsible for code in the repository.
   - **FUNDING.yml** - Displays a sponsor button to increase the visibility of funding options.
   - **CODE_OF_CONDUCT.md** - Standards for how to engage in the community.
   - **CONTRIBUTING.md** - Guidelines on how to contribute to the project.
   - **SECURITY.md** - Security policy and reporting guidelines.
   - **workflows/** - For GitHub Actions CI/CD configuration files.

### GitLab
1. **.gitlab-ci.yml** - GitLab CI/CD configuration file.
2. **.gitlab/** - Directory for GitLab-specific templates and configuration:
   - **issue_templates/** - Custom issue templates.
   - **merge_request_templates/** - Templates for merge requests.

### Bitbucket
1. **bitbucket-pipelines.yml** - Bitbucket Pipelines CI/CD configuration file.
2. **.bitbucket/** - Contains Bitbucket-specific configurations (less commonly used compared to GitHub and GitLab).