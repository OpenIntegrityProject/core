# Open Integrity Project
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/README.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/README.md`_
> - _updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

## 📖 Introduction

_**Cryptographic Roots of Trust for Open Source Development**_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

**Open Integrity** is an initiative by [Blockchain Commons](https://www.blockchaincommons.com) to integrate cryptographic trust mechanisms into Git repositories. By leveraging Git's native SSH signing capabilities and structured verification processes, we ensure transparency, provenance, and immutability for software projects.

Whether you're a developer, security researcher, or open-source maintainer, Open Integrity provides the tools to:
- Provide a **developer-friendly framework** for cryptographic integrity.
- Establish **verifiable proof-of-origin** for commits and code artifacts through direct verification by inception key holder.
- Expand that proof-of-origin through a **chain of trust** that allows delegated verification of authorized signers.
- Detect **tampering or unauthorized modifications** in repository history.
- Enable **cross-platform trust verification** across Git hosting services

## 🎯 Project Goals

- 🛡 **Immutable Proof-of-Origin** – Verify the authenticity of software artifacts
- 🔏 **Signed Commits & Tags** – Ensure authorship integrity through SSH signatures (~128-bit security).
- 🔍 **Tamper Detection** – Maintain verifiable repository history.
- 🔗 **Trust Delegation** – Enable controlled transition from inception key to authorized signers.
- 🌍 **Platform-Agnostic Validation** – Work across GitHub, GitLab, and self-hosted solutions.

## 🔑 Key Features

- **Inception Commits** – Immutable starting points that combine:
  - Empty commit for SHA-1 collision resistance
  - Ricardian Contract defining trust rules
  - SSH signature providing strong cryptographic proofs
- **Trust Models**:
  - Direct inception key verification
  - Delegated verification through authorized signers
- **Automated Tamper Detection** – Integrity checks throughout history
- **Audit Tools** – Comprehensive repository inspection
- **Cross-Platform Trust** – GitHub, GitLab, P2P, or self-hosted support

## 📚 Documentation Organization

This repository contains the core implementation and documentation for the Open Integrity Project, offering both conceptual guidance and practical tools for establishing and maintaining cryptographic trust using Git repositories.

### 📁 Core Documentation

- 📜 [Problem Statement](docs/Open_Integrity_Problem_Statement.md) – Challenges & solutions for cryptographic roots of trust using Git repositories
- 📟 [Script Snippets](docs/Open_Integrity_Script_Snippets.md) – Practical command-line shortcuts for Open Integrity
- 📂 [Repository Structure](docs/Open_Integrity_Repo_Directory_Structure.md) – Open Integrity repository structure reference
- 🛣️ [Project Roadmap](ROADMAP.md) – Development milestones and plans
- 🤝 [Contributing Guidelines](CONTRIBUTING.md) – How to contribute
- 🔒 [Security Policy](SECURITY.md) – Reporting vulnerabilities

### 📌 Project Resources

- 📖 [Documentation Website](https://OpenIntegrityProject.info)
- 💬 [Community Discussions](https://github.com/orgs/OpenIntegrityProject/discussions)
- ❗ [Initial Issue Tracker](https://github.com/OpenIntegrityProject/community/issues)

### 📝 Planned Resources

- 🚀 [Getting Started Guide] – Step-by-step guide to set up your first Open Integrity repository
- 🏛 [Architecture Documentation] – System design & implementation details

### 🛠 Core Implementation

- ⚙️ [Source Code](src/) – Essential Open Integrity Project tools & automation scripts
- 📜 [Requirements](src/requirements/) – Requirements documents for Open Integrity Project scripts
- ❗ [Issues](src/issues/) – Tracks known issues and planned improvements
- 🔎 [Tests](src/tests/) – Comprehensive regression tests
- 🤖 [Main Scripts](src/) – Implementation of Open Integrity functionality:
  - 🔍 [`audit_inception_commit-POC.sh`](src/audit_inception_commit-POC.sh) - Audit repositories for compliance
  - 🏗️ [`create_inception_commit.sh`](src/create_inception_commit.sh) - Create repositories with inception commits
  - 🪪 [`get_repo_did.sh`](src/get_repo_did.sh) - Retrieve repository DIDs

## 🚀 Quick Start

Get started with Open Integrity by:
1. Set up your development environment for signing
2. Create a repository with an inception commit establishing your root of trust
3. Choose your trust model:
   - Direct verification using the inception key
   - OR delegated verification through authorized signers
4. Run Open Integrity audits on your repositories

```bash
# Example: Create a repository with a signed inception commit
./src/create_inception_commit.sh -r my_new_repo

# Example: Audit a repository's inception commit
./src/audit_inception_commit-POC.sh -C /path/to/repo

# Example: Get a repository's DID
./src/get_repo_did.sh -C /path/to/repo
```

For a deeper dive, check out our [Problem Statement](docs/Open_Integrity_Problem_Statement.md) and documentation.

## 🚦 Project Status & Roadmap

### **Current Phase: Early Research & Proof-of-Concept (v0.1.0)**
🔹 Core concepts & initial implementation complete
🔹 Seeking community feedback for improvements
🔹 Developing integration with CI/CD & key management solutions
🔹 **Not yet production-ready**

📍 See our [ROADMAP.md](ROADMAP.md) for detailed development plans and our [Development Phases](https://github.com/BlockchainCommons/Community/blob/master/release-path.md) for general approach.

## ❗ Issue Management

We track issues in two complementary ways:

1. **Repository-specific issues** are tracked directly in the [src/issues/](src/issues/) directory with detailed context and proposed solutions.

2. **General project issues** start in GitHub's 💬 [Community Discussions](https://github.com/orgs/OpenIntegrityProject/discussions) to encourage open dialogue before they are moved to our ❗ [Initial Issue Tracker](https://github.com/OpenIntegrityProject/community/issues).

This dual approach aligns with our commitment to decentralized repository management, allowing issues to be tracked both in version control and across multiple Git hosting platforms, ensuring greater resilience and accessibility beyond any single platform.

## 🌟 Support the Open Integrity Project

- ⭐ **Star** our repositories to show support
- 📢 **Sharing** your discoveries with your network
- 💬 Ask a question or engage in discussions in our [**Community Discussions**](https://github.com/orgs/OpenIntegrityProject/discussions)
- ✍️ Report an issue in our [**Initial Issue Tracker**](https://github.com/OpenIntegrityProject/community/issues)
- 🔎 Find [**Good First Issues**](https://github.com/OpenIntegrityProject/community/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) to get started
- 💰 Become a financial patron to our host [Blockchain Commons via GitHub Sponsors](https://github.com/sponsors/BlockchainCommons)

For commercial support, visit: **[Blockchain Commons Support](https://www.blockchaincommons.com/support/)**.

## 🤝 How to Contribute

We welcome contributions from developers, researchers, and security experts!

1. Read our **[Contributing Guide](CONTRIBUTING.md)**
2. Fork the repository & create a feature branch
3. Implement your feature or fix
4. Digitally sign all your commits with an SSH signing key (`gitc commit -S`) and attribute authorship (`git commit --signoff`).
4. Submit a **Pull Request** for review

All contributors must adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

## 👨‍💻 **Lead Developer**
**Christopher Allen** ([@ChristopherA](https://github.com/ChristopherA)), [\<ChristopherA@LifeWithAlacrity.com/>](mailto:ChristopherA@LifeWithAlacrity.com)

For a full list of contributors, see [CONTRIBUTORS.md](CONTRIBUTORS.md).

## 🕵️ Security & Trust

Ensuring security is a top priority for the Open Integrity Project. If you discover a security vulnerability, please report it responsibly:

- **Email**: [team@BlockchainCommons.com](mailto:team@BlockchainCommons.com)
- **GPG Encrypted Reports**: See [SECURITY.md](SECURITY.md) for responsible disclosure guidelines

### 👥 Security Contacts

| Name              | Email                              | GPG Fingerprint                                     |
|-------------------|----------------------------------|-----------------------------------------------------|
| Christopher Allen | ChristopherA@LifeWithAlacrity.com | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED  |

## 📞 Contact & Support

- **Security Issues**: [team@BlockchainCommons.com](mailto:team@BlockchainCommons.com)
- **General Questions**: [Community Discussions](https://github.com/orgs/OpenIntegrityProject/discussions)
- **Bug Reports**: [Initial Issue Tracker](https://github.com/OpenIntegrityProject/community/issues)

## 📜 Copyright & License

Unless otherwise noted, all files are ©2025 Open Integrity Project / Blockchain Commons LLC., and licensed under the [BSD 2-Clause Pluse Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html) – See [LICENSE](LICENSE) for details.

## 🌍 About Us

The **Open Integrity Project** is an [Open Development](https://www.blockchaincommons.com/articles/Open-Development/) initiative hosted by [Blockchain Commons](https://www.BlockchainCommons.com), dedicated to advancing **open, interoperable, secure & compassionate digital infrastructure**, and embracing the [Gordian Principles](https://developer.BlockchainCommons.com/principles/) of **independence, privacy, resilience, and openness**.
