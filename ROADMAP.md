# Open Integrity Project: Core Roadmap

> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/ROADMAP.md`_
> - _github: [`core/ROADMAP.md`](https://github.com/OpenIntegrityProject/core/blob/main/ROADMAP.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

This roadmap outlines the development priorities and timeline for the Open Integrity Project scripts. It is organized by version series, aligning with our progressive implementation of trust models.

## Current Phase: Inception Authority Base (v0.1.*)

We are currently in the initial development phase focusing on the basic Inception Authority model where:
- All commits are both authored and committed by the holder of the Inception Key
- Core scripts establish the foundation for creating, auditing, and managing repositories
- Progressive Trust implementation guides all script architecture
- Zsh scripting framework and best practices are standardized

## v0.1.* Series Goals: Inception Authority Foundation

### Repository Organization Evaluation and Restructuring [HIGH PRIORITY]
- Evaluate whether to merge the docs repository (../docs) into this repository
- Research best practices for repository organization in similar projects
- Consider reorganizing current contents into appropriate subdirectories (scripts, src, etc.)
- Use `git mv` to preserve history when relocating files
- Update all internal links and references to reflect the new structure
- Reconcile and merge README.md files from both repositories
- Consider repository renaming to better reflect the project scope
- Ensure consistent documentation across the reorganized structure
- Update all existing issues, requirements, and roadmap to reflect the new organization
- Create guidelines for future repository organization and file placement

### Core Script Stabilization [HIGH PRIORITY]
- Complete Progressive Trust terminology standardization in audit_inception_commit-POC.sh
- Address exit code inconsistency issues
- Enhance error reporting with actionable guidance
- Support auditing repositories beyond local filesystem
- Complete comprehensive regression testing for audit scripts
- Develop early draft of verify_repo_signatures-POC.sh to test all commits against Inception Key

### Inception Commit Creation [HIGH PRIORITY]
- Address open issues in create_inception_commit.sh
- Enhance user guidance during repository creation
- Improve error handling for edge cases
- Add support for custom inception commit messages
- Complete regression test suite

### Git Configuration & Signing [HIGH PRIORITY]
- Complete check_git_config_for_oi_signing.sh implementation
- Create automated signing configuration tools
- Develop generate_local_signing_keys.sh snippet for users without signing keys
- Create framework script to interactively fix git configuration issues
- Document best practices for SSH key management with Inception Authority
- Research and document security measures for Inception Key protection

### Progressive Trust Implementation [HIGH PRIORITY]
- Implement and enforce Progressive Trust terminology across all scripts
- Create a Progressive Trust terminology audit tool
- Standardize output format for different Progressive Trust phases
- Document phase transitions and error handling

### Framework Templates [HIGH PRIORITY]
- Develop at least one framework template (z_frame.sh or z_min_frame.sh or both)
- Create regression tests for framework templates
- Update snippet template if needed
- Create standalone template for regression testing
- Document template usage and customization

### Decentralized Issue Management Standardization [HIGH PRIORITY]
- Review all existing ISSUES files to identify current patterns and practices
- Create a REQUIREMENTS-In_Repository_Issues.md document detailing the current manual process
- Document how to add, update, and track issues without platform-specific tools
- Establish guidelines for issue formatting, status tracking, and linking to ROADMAP.md
- Normalize all existing issue documents to follow these established best practices
- Create templates for different issue types (bug, feature, research, etc.)
- Document workflow for transitioning issues through different states

### Utility Libraries [MEDIUM PRIORITY]
- Begin development of common z_utils library
- Make utilities more generalized and broadly useful
- Implement function-specific testing approach
- Research approaches for selective sourcing from _z_Utils.zsh
- Prototype and test library loading mechanisms
- Begin similar standardization for oi_* common code with relaxed requirements

### Decentralized Repository Management [HIGH PRIORITY]
- Research best practices for in-repo issue tracking
- Document approaches for decentralized repository management
- Refine current issue document format and organization
- Explore options for visualizing and working with in-repo issues
- Evaluate possibilities for bidirectional syncing with platform issue systems
- Develop tooling to assist with in-repo issue management

### GitHub Integration Foundations [MEDIUM PRIORITY]
- Develop framework script to upload developer signing keys to GitHub via gh API
- Test basic GitHub integrations for key verification
- Document GitHub API requirements for key management

### Repository DID Management [MEDIUM PRIORITY]
- Enhance get_repo_did.sh functionality
- Support alternative DID formats and representations
- Research DID resolution requirements for future implementation
- Document DID best practices for repository identification

### Research Questions [HIGH PRIORITY]
- What are the security implications of the Inception Authority model?
- How can we ensure secure Inception Key management?
- What limitations affect single-key repositories in collaborative settings?
- How do we balance usability with security for Inception Authority?
- What are the best patterns for function-specific testing in Zsh?
- What are the most effective approaches for decentralized issue tracking?
- How can we make in-repo issues as usable as platform-specific issue systems?
- What repository organization best serves the needs of both developers and users?

## v0.2.* Series Goals: Signing Key Management & Verification

### Public Key Management [HIGH PRIORITY]
- Develop tools to publish and update signer keys on GitHub
- Create functionality for self-signing keys in public repositories
- Implement utilities to extract keys from various sources
- Build review mechanisms for key verification before adding to trust stores
- Create tools to manage allowed_signers files

### Enhanced Key Management [HIGH PRIORITY]
- Research approaches for adding multiple signers to allowed_signers files
- Investigate use of comments feature for trust classification metadata
- Create snippets to extract signing keys for adding to various allowed_signers files
- Develop tools to categorize keys by trust level
- Implement mechanisms to manage different trust levels in configuration

### Cross-Platform Key Verification [MEDIUM PRIORITY]
- Extend verify_repo_signatures-POC.sh to verify against GitHub's published Signer Keys API
- Add support for verification against self-signed options in public repositories
- Begin research on GitLab and other platform integrations
- Develop platform-agnostic verification interfaces

### Signer Management Utilities [MEDIUM PRIORITY]
- Create utilities to manage signing keys on GitHub
- Begin development for GitLab and other git hosting platforms
- Implement self-signed public key management in personal repositories
- Build tools for key rotation and updates

### Key Trust Models [MEDIUM PRIORITY]
- Document trust models for different key verification scenarios
- Implement differentiated trust levels for different key sources
- Create guidelines for key verification workflows
- Develop trust visualization tools

### Enhanced Decentralized Issue Management [MEDIUM PRIORITY]
- Develop tooling for creating and updating in-repo issues
- Build search and query capabilities for in-repo issues
- Research approaches for issue references in commit messages
- Explore integration with external tools via standardized formats

### Research Questions [HIGH PRIORITY]
- What are the optimal patterns for allowed_signers file management?
- How can we effectively categorize different levels of trust for signing keys?
- What are the cross-platform differences in key management and verification?
- How can self-signed public keys complement platform-managed keys?
- What preparation is needed for the eventual transition to PR workflows?
- How can we make decentralized issue tracking more accessible to contributors?

## v0.3.* Series Goals: Enhanced Inception Authority with PR Support

### PR & Branch Merge Support [HIGH PRIORITY]
- Develop mechanisms to preserve authorship information during merges
- Create tools to maintain signature metadata that would otherwise be lost
- Document and implement merge strategies that maintain trust chains
- Research optimal approaches for preserving PR contributor information

### Hooks & Enforcement [HIGH PRIORITY]
- Implement repository hooks to enforce signing requirements
- Create pre-commit hooks for signature verification
- Develop post-merge hooks for trust chain validation
- Build tools to prevent accidental loss of author data

### GitHub Integration [HIGH PRIORITY]
- Complete GitHub workflow for commit and PR enforcement
- Create GitHub Actions for automated verification
- Implement branch protection rules via API
- Develop verification status reporting for PRs

### Enhanced Audit Capabilities [MEDIUM PRIORITY]
- Expand audit_inception_commit-POC.sh to validate PR merges
- Develop branch auditing capabilities
- Create tools to verify the integrity of merge commits
- Implement validation of signature preservation

### Testing Framework Enhancement [HIGH PRIORITY]
- Develop test scenarios specifically for PR and merge workflows
- Create test environments that simulate collaborative contributions
- Enhance test output for merge-specific validations
- Document test expectations for enhanced inception authority

### Cross-Platform Testing [MEDIUM PRIORITY]
- Test PR workflows across different Git hosting platforms
- Document platform-specific implementation differences
- Create platform-specific guidelines for Inception Authority usage
- Begin research on cross-platform support requirements

### Collaborative Issue Management [MEDIUM PRIORITY]
- Develop mechanisms for collaborative issue management with in-repo issues
- Create tools for issue assignment and status updating
- Implement milestone and project tracking for in-repo issues
- Build reporting and visualization tools for issue progress

### Research Questions [HIGH PRIORITY]
- How can we effectively preserve signatures during merges?
- What metadata needs to be maintained to ensure audit capabilities?
- What are the platform-specific challenges for PR workflows?
- How can we balance collaboration with the constraints of Inception Authority?
- What preparations are needed for eventual transition to Delegated Authority?
- How can multiple contributors effectively collaborate on in-repo issues?

## v0.4.* Series Goals: Transition to Delegated Authority

### Delegated Authority Implementation [HIGH PRIORITY]
- Develop scripts for transition from Inception Authority to Delegated Authority
- Create utilities for managing allowed_signers configurations
- Implement key rotation and revocation workflows
- Build verification tools for delegated authority model

### Trust Chain Verification [HIGH PRIORITY]
- Create tools for verifying unbroken chain of trust through authority transitions
- Support multiple trust transitions within a repository
- Develop auditing capabilities for complex trust models
- Build reporting mechanisms for trust relationships

### Enhanced Security Models [MEDIUM PRIORITY]
- Support for multiple signing key types (Ed25519, ECDSA, etc.)
- Key custody and management tools for multiple authorized keys
- Implement guidelines for key distribution among team members
- Develop secure key management documentation

### Transition Tooling [HIGH PRIORITY]
- Create migration tools for converting existing Inception Authority repositories
- Develop scripts to generate and manage allowed_signers files
- Build verification tools for transition integrity
- Create documentation for transition process

### Platform Integration [MEDIUM PRIORITY]
- Extend GitHub integration to support Delegated Authority
- Begin exploration of other platform integrations (GitLab, Gitea)
- Document platform-specific requirements for Delegated Authority
- Develop cross-platform consistency guidelines

### Multi-Contributor Issue Management [MEDIUM PRIORITY]
- Enhance issue management for multi-contributor environments
- Implement role-based access patterns for issue management
- Develop tools for managing issue assignments across teams
- Create templates for standardized issue reporting

### Research Questions [HIGH PRIORITY]
- What are the security implications of transitioning from single key to multiple keys?
- How can we ensure proper key management in team environments?
- What verification processes are needed after transition?
- What are the administrative overhead trade-offs in Delegated Authority?
- How can decentralized issue tracking scale to larger teams and projects?

## v0.5.* Series Goals: Enhanced Delegated Authority

### Framework Evolution [HIGH PRIORITY]
- Extract shared utilities into standalone packages
- Implement modular component architecture
- Create reusable verification modules
- Develop plugin system for extensibility

### CI/CD Integration [MEDIUM PRIORITY]
- Create standardized CI/CD pipeline components
- Implement verification reporting in automated environments
- Develop failure notification and remediation guidance
- Create attestation artifacts for build processes

### Cross-Platform Support [MEDIUM PRIORITY]
- Fully implement support for GitLab, Gitea, and other Git platforms
- Create platform adaptation layers
- Develop comprehensive platform-specific guidelines
- Build cross-platform verification tools

### User Experience Improvements [MEDIUM PRIORITY]
- Implement interactive modes for complex operations
- Develop better visualization for trust relationships
- Create simplified workflows for common operations
- Improve error messaging and recovery guidance

### Performance Optimization [LOW PRIORITY]
- Optimize verification process for large repositories
- Implement caching for repeated operations
- Develop parallel processing capabilities
- Reduce resource utilization for constrained environments

### Advanced Issue Management [MEDIUM PRIORITY]
- Develop advanced visualization and reporting for in-repo issues
- Create tools for complex issue queries and analytics
- Implement integration with external reporting systems
- Build automation for issue management workflows

## v1.0 Long-Term Goals

### Advanced Trust Ecosystem [HIGH PRIORITY]
- Create tools for checking full repository compliance
- Implement comprehensive auditing capabilities
- Develop remediation utilities for non-compliant repositories
- Build migration tools for legacy repositories

### Enterprise Features [MEDIUM PRIORITY]
- Hardware security module (HSM) integration
- Threshold signature schemes
- Enterprise key management integration
- Role-based access control for trust operations

### Interoperability Enhancement [MEDIUM PRIORITY]
- Implement Verifiable Credential integration
- Support additional DID methods
- Create bridges to other trust systems
- Develop standards for cross-project integrity verification

### Documentation & Community [HIGH PRIORITY]
- Develop comprehensive learning resources
- Create interactive tutorials and examples
- Build documentation website with rich examples
- Develop best practice guides for specific industries

### Ecosystem Development [MEDIUM PRIORITY]
- Support third-party tool integration
- Create developer APIs for custom integrations
- Build community plugin registry
- Develop certification program for compliant implementations

### Federated Git Trust Networks [MEDIUM PRIORITY]
- Develop consensus mechanisms for distributed trust
- Create federated verification systems
- Implement cross-repository trust attestations
- Build reputation systems for trust authorities

### Extended Trust Applications [LOW PRIORITY]
- Supply chain security verification tools
- Software bill of materials (SBOM) integration
- Vulnerability assessment integration
- Release signing and verification automation

### Enterprise-Grade Issue Management [MEDIUM PRIORITY]
- Develop enterprise-scale issue management capabilities
- Create advanced reporting and analytics tools
- Implement governance mechanisms for issue tracking
- Build integration with enterprise project management systems

## Implementation Strategy

This roadmap will be implemented following these guiding principles:

- **Progressive Trust Approach**: Build trust incrementally through well-defined phases
- **Open Development**: Maintain public visibility into all aspects of the project
- **Community Engagement**: Actively seek feedback and contributions from users
- **Modular Design**: Create components that can be used independently or together
- **Thorough Testing**: Maintain comprehensive test coverage for all functionality
- **Clear Documentation**: Ensure all features are well-documented with examples
- **Decentralized Approach**: Prioritize techniques that work across different Git hosting platforms

## Timeline and Milestones

| Milestone | Target Date | Key Deliverables |
|-----------|-------------|------------------|
| v0.1.5 | Q1 2025 | Stabilized core scripts, Progressive Trust terminology standardization |
| v0.2.0 | Q2 2025 | Signing key management and verification across platforms |
| v0.3.0 | Q3 2025 | Enhanced Inception Authority with PR workflow support |
| v0.4.0 | Q4 2025 | Transition to Delegated Authority, multiple key support |
| v0.5.0 | Q1 2026 | Cross-platform support, CI/CD integration, modular framework |
| v1.0.0 | Q2 2026 | Production-ready functionality with enterprise features |

## Contribution Opportunities

We welcome community contributions in the following areas:

- **Script Development**: Enhancing existing scripts or creating new ones
- **Documentation**: Improving guides, examples, and specifications
- **Testing**: Expanding test coverage and reporting
- **Integration**: Building connections to other tools and platforms
- **Security Review**: Auditing and hardening existing implementations
- **Decentralized Issue Management**: Researching and improving in-repo issue tracking

For more information on how to contribute, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Progress Tracking

We track progress using our decentralized in-repository issue management approach:

- **In-Repo Issues**: Located in the `/issues` directory of this repository
- **Requirements Documents**: Found in the `/requirements` directory
- **Release Notes**: Documenting completed roadmap items in change logs
- **Repository Tags**: Marking significant milestones and versions

This decentralized approach ensures that our project management remains platform-independent and consistent with our commitment to open, interoperable, and decentralized infrastructure.

We welcome feedback on our decentralized issue management approach, including suggestions for improving usability, accessibility, and effectiveness. This is an active area of research and development within the project.

This roadmap is a living document and will be updated as the project evolves based on user feedback, technological developments, and changing priorities.