# Open Integrity Project: Source Code
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/src/README.md`_
> - _github: [`Open Integrity Core Source`](https://github.com/OpenIntegrityProject/core/blob/main/src/README.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## 🛡 Open Integrity Project: Cryptographic Roots of Trust for Open Source Development

The **Open Integrity Project** integrates cryptographic trust mechanisms into Git repositories, enabling them to serve as cryptographic roots of trust to ensure **verifiable chains of integrity, provenance, and authorship**. By leveraging Git's native **SSH-based signing** capabilities and structured verification processes, Open Integrity ensures transparency and immutability for software projects without requiring modifications to Git itself. An [Open Development](https://www.blockchaincommons.com/articles/Open-Development/) initiative hosted by [Blockchain Commons](https://www.BlockchainCommons.com).

This directory contains the source code implementation of Open Integrity specifications using Zsh-based command-line scripting.

⚠️ IMPORTANT: All of these scripts are **proof-of-concept** implementations, intended for evaluation of the Open Integrity approach and to explore implementation challenges. They are intended for evaluation only and are **not for production use** without further endorsement. While they demonstrate the viability of using Git repositories as cryptographic roots of trust, they currently have significant limitations: they largely operate only against **local repositories**, with **limited Git platform integration (currently only GitHub)**, and only partial implementation of **Progressive Trust** capabilities. Their primary value is in proving core concepts and informing the development of future production-ready tools.

🔗 **For full project details, visit the** [📖 Open Integrity Project README](../README.md)

## 🛠 Available Scripts

The Open Integrity Project implements two types of scripts:

### 🏗️ Framework Scripts

Complex, multi-component scripts with extensive functionality:

- 🔍 **`audit_inception_commit-POC.sh`** – Performs multi-phase audits of Git repository inception commits
  - [Script](audit_inception_commit-POC.sh) - The framework audit script
  - [Requirements](requirements/REQUIREMENTS-audit_inception_commit-POC.md) - Detailed requirements
  - [Issues](issues/ISSUES-audit_inception_commit-POC.md) - Tracked issues and improvements
  - [Test Script](tests/TEST-audit_inception_commit.sh) - Comprehensive regression test
  - [Test Output](tests/OUTPUT-TEST-audit_inception_commit.txt) - Reference test output

### ✂️ Snippet Scripts

Small, focused scripts (generally under 200 lines) that perform specific functions:

- 🏗 **`create_inception_commit.sh`** – Creates a repository with a properly signed inception commit
  - [Requirements](requirements/REQUIREMENTS-create_inception_commit.md) - Detailed requirements
  - [Test Script](tests/TEST-create_inception_commit.sh) - Regression test
  - [Test Output](tests/OUTPUT-TEST-create_inception_commit.txt) - Reference test output

- 🔍 **`get_repo_did.sh`** – Retrieves a repository's DID based on its inception commit
  - [Requirements](requirements/REQUIREMENTS-get_repo_did.md) - Detailed requirements

- ✂️ **`snippet_template.sh`** – Template for creating new snippet scripts

## 📁 Source Directory Structure

The source code follows a structured organization:

### 📂 Source Layout

```console
src/
├── README.md                           # This file
├── audit_inception_commit-POC.sh       # Framework script for inception commit audits
├── create_inception_commit.sh          # Snippet script for repository creation
├── get_repo_did.sh                     # Snippet script for DID retrieval
├── snippet_template.sh                 # Template for new scripts
├── issues/                             # Tracks known issues and improvements
│   ├── ISSUES-Open_Integrity_Scripting_Infrastructure.md
│   ├── ISSUES-Zsh_Core_Scripting_Best_Practices.md
│   └── ISSUES-audit_inception_commit-POC.md
├── requirements/                        # Defines standards and requirements
│   ├── REQUIREMENTS-Progressive_Trust_Terminology.md
│   ├── REQUIREMENTS-Regression_Test_Scripts.md
│   ├── REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md
│   ├── REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md
│   ├── REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices-Aspirations.md
│   ├── REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md
│   ├── REQUIREMENTS-audit_inception_commit-POC.md
│   ├── REQUIREMENTS-create_inception_commit.md
│   ├── REQUIREMENTS-get_repo_did.md
│   └── REQUIREMENTS-z_Utils_Functions.md
└── tests/                              # Testing framework
    ├── OUTPUT/                         # Directory for test output
    ├── OUTPUT-TEST-audit_inception_commit.txt
    ├── OUTPUT-TEST-audit_inception_commit-POC.txt
    ├── OUTPUT-TEST-create_inception_commit.txt
    ├── TEST-audit_inception_commit.sh
    └── TEST-create_inception_commit.sh
```

### 📌 Directory Purposes

- **Root (`src/`)** – Contains all source code including:
  - Framework scripts for complex functionality
  - Snippet scripts for targeted tasks
  - Script template for standardized development

- **`issues/`** – Tracks known issues and improvements:
  - System-wide scripting infrastructure concerns
  - Language-specific scripting best practices
  - Script-specific issues and enhancements

- **`requirements/`** – Defines standards and specifications:
  - Core Zsh scripting principles and best practices
  - Framework and snippet script development guidelines
  - Progressive Trust terminology and implementation standards
  - Specific requirements for individual scripts

- **`tests/`** – Contains comprehensive testing framework:
  - Test scripts to verify functionality
  - OUTPUT directories for structured test results
  - Reference output files for regression testing

## 💡 More Information

For further details about the **Open Integrity Project**, visit:

- 📖 [**Root README**](../README.md) – Overview, problem statement, and organization
- 📋 [**Project Roadmap**](../ROADMAP.md) – Development phases and milestones
- 💬 [**Community Discussions**](https://github.com/orgs/OpenIntegrityProject/discussions) — Join the conversation

## 🚀 Getting Started

To use these scripts, **clone the repository** and ensure dependencies are installed:

```sh
# Clone the repository
gh repo clone OpenIntegrityProject/core
# or `git clone https://github.com/OpenIntegrityProject/core.git`
cd core

# Make scripts executable
chmod +x src/*.sh

# Example: Audit this repository's inception commit
./src/audit_inception_commit-POC.sh

# Example: Audit another repository's inception commit
./src/audit_inception_commit-POC.sh -C /path/to/repo

# Example: Create a repository with a signed inception commit
./src/create_inception_commit.sh -r my_new_repo

# Example: Retrieve a repository's DID
./src/get_repo_did.sh -C /path/to/repo
```

🔍 **For script details, refer to the** [`requirements/` directory](requirements/)

## 🛠 Development Guidelines

All script development follows strict coding standards outlined in:
- 📜 [Zsh Core Scripting Best Practices](requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
- ✍️ [Zsh Snippet Script Best Practices](requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)
- 🏗️ [Zsh Framework Script Best Practices](requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md)
- 🧪 [Regression Test Scripts](requirements/REQUIREMENTS-Regression_Test_Scripts.md)

### 🧪 Running Tests

Scripts include **automated regression tests**. Run them as follows:

```sh
# Run tests for create_inception_commit.sh
./src/tests/TEST-create_inception_commit.sh

# Run tests for audit_inception_commit-POC.sh
./src/tests/TEST-audit_inception_commit.sh

# Run tests and capture both standard and verbose output
./src/tests/TEST-audit_inception_commit.sh > src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
./src/tests/TEST-audit_inception_commit.sh --verbose >> src/tests/OUTPUT-TEST-audit_inception_commit.txt 2>&1
```

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

## ❗ Issue Management

We recommend starting general issues in GitHub's 💬 [Community Discussions](https://github.com/orgs/OpenIntegrityProject/discussions) to encourage open dialogue before they are formally moved to our ❗ [Initial Issue Tracker](https://github.com/OpenIntegrityProject/community/issues). 

However, in alignment with our commitment to decentralized repository management, we plan to develop GitHub Action scripts that will automatically populate `/issues/` directories within each repository. This will allow issues to be mirrored across multiple Git hosting platforms, ensuring greater resilience and accessibility beyond GitHub.

## 👨‍💻 **Lead Developer**
**Christopher Allen** ([@ChristopherA](https://github.com/ChristopherA)), [\<ChristopherA@LifeWithAlacrity.com/>](mailto:ChristopherA@LifeWithAlacrity.com)

For a full list of contributors, see [CONTRIBUTORS.md](CONTRIBUTORS.md).

## 🕵️ Security & Trust

Ensuring security is a top priority for the Open Integrity Project. If you discover a security vulnerability, please report it responsibly:

- **Email**: [team@BlockchainCommons.com](mailto:team@BlockchainCommons.com)
- **GPG Encrypted Reports**: See [SECURITY.md](https://github.com/OpenIntegrityProject/docs/blob/main/SECURITY.md) for responsible disclosure guidelines

### 👥 Security Contacts

| Name              | Email                              | GPG Fingerprint                                     |
|-------------------|----------------------------------|-----------------------------------------------------|
| Christopher Allen | ChristopherA@LifeWithAlacrity.com | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED  |

## 📞 Contact & Support

- **Security Issues**: [team@BlockchainCommons.com](mailto:team@BlockchainCommons.com)
- **General Questions**: [Community Discussions](https://github.com/orgs/OpenIntegrityProject/discussions)
- **Bug Reports**: [Initial Issue Tracker](https://github.com/OpenIntegrityProject/community/issues)

## 📜 Copyright & License

Unless otherwise noted, all files are **©2025 Open Integrity Project / Blockchain Commons LLC** and licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html). See [LICENSE](LICENSE) for details.

## 🌍 About Us

The **Open Integrity Project** is an [Open Development](https://www.blockchaincommons.com/articles/Open-Development/) initiative hosted by [Blockchain Commons](https://www.BlockchainCommons.com), dedicated to advancing **open, interoperable, secure & compassionate digital infrastructure**, and embracing the [Gordian Principles](https://developer.BlockchainCommons.com/principles/) of **independence, privacy, resilience, and openness**.
