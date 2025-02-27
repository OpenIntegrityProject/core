# Open Integrity Project: Scripts Hub
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/README.md`_
> - _github: [`Open Integrity Scripts`](https://github.com/OpenIntegrityProject/scripts/blob/main/README.md)_
> - _Updated: 2025-02-26 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## 🛡 Open Integrity Project: Cryptographic Roots of Trust for Open Source Development

The **Open Integrity Project** integrates cryptographic trust mechanisms into Git repositories, enabling them to serve as cryptographic roots of trust to ensure **verifiable chains of integrity, provenance, and authorship**. By leveraging Git's native **SSH-based signing** capabilities and structured verification processes, Open Integrity ensures transparency and immutability for software projects without requiring modifications to Git itself. An [Open Development](https://www.blockchaincommons.com/articles/Open-Development/) initiative hosted by [Blockchain Commons](https://www.BlockchainCommons.com).

This repository offers implementations of Open Integrity specifications using Zsh-based command-line scripting.

⚠️ IMPORTANT: All of these scripts are **proof-of-concept** implementations, intended for evaluation of the Open Integrity approach and explore implementation challenges. They are intended for evaluation only and are **not for production use** without further endorsement. While they demonstrate the viability of using Git repositories as cryptographic roots of trust, they currently have significant limitations: they largely operate only against **local repositories**,  with **limited Git platform integration (currently only GitHub)**, and only partial implementation of **Progressive Trust** capabilities. Their primary value is in proving core concepts and informing the development of future production-ready tools.

🔗 **For full project details, visit the** [📖 Open Integrity Documentation Hub](https://github.com/OpenIntegrityProject/docs)

## 🛠 Available Scripts

### ⚙️ Primary Scripts *(Coming Soon!)*
The development of core Open Integrity scripts is underway. These will include comprehensive audit tools for verifying cryptographic trust in repositories.

### ✂️ Snippet Scripts (Utilities)
Small, focused scripts that perform specific Open Integrity functions:

- 🔍 **`get_repo_did.sh`** – Retrieves a repository's DID based on its inception commit
- 🏗 **`create_inception_commit.sh`** – Creates a repository with a properly signed inception commit
- ✂️ **`snippet_template.sh`** – Template for creating new snippet scripts

## 📁 Repository Structure

This repository follows a structured layout to separate different types of scripts and documentation:

### 📂 Repository Layout

```console
.
├── .gitignore
├── README.md
├── issues
│   ├── ISSUES-Open_Integrity_Scripting_Infrastructure.md
│   └── ISSUES-Zsh_Core_Scripting_Best_Practices.md
├── requirements
│   ├── REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md
│   └── REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md
├── snippets
│   ├── create_inception_commit.sh
│   ├── get_repo_did.sh
│   ├── requirements
│   │   ├── REQUIREMENTS-check_git_config_for_oi_signing.md
│   │   ├── REQUIREMENTS-create_inception_commit.md
│   │   └── REQUIREMENTS-get_repo_did.md
│   ├── snippet_template.sh
│   └── tests
│       └── TEST-create_inception_commit.sh
└── tests
```

### 📌 Purpose of Each Directory

- **Root** – Contains this `README.md` and will eventually house primary Open Integrity automation scripts.
- **`/requirements/`** – Defines **coding standards** and **best practices**.
- **`/issues/`** – Tracks known issues and improvements.
- **`/snippets/`** – Small, reusable utility scripts under 200 lines.
  - **`/snippets/requirements/`** – Specifies individual script requirements.
  - **`/snippets/tests/`** – Regression tests ensuring snippet functionality.
- **`/tests/`** – Comprehensive testing framework for the project.

## 💡 More Information

For further details about the **Open Integrity Project**, visit:

- 📖 [**Documentation Hub**](https://github.com/OpenIntegrityProject/docs) – Architecture, problem statement, and guides
- 📋 [**Project Roadmap**](https://github.com/orgs/OpenIntegrityProject/projects) – Development phases and milestones
- 💬 [**Discussions**](https://github.com/OpenIntegrityProject/docs/discussions) — Join the conversation

## 🚀 Getting Started

To use these scripts, **clone the repository** and ensure dependencies are installed:

```sh
# Clone the repository
git clone https://github.com/OpenIntegrityProject/scripts.git
cd scripts

# Make scripts executable
chmod +x *.sh
chmod +x snippets/*.sh

# Example: Create a repository with a signed inception commit
./snippets/create_inception_commit.sh -r my_new_repo

# Example: Retrieve a repository's DID
./snippets/get_repo_did.sh -C /path/to/repo
```

🔍 **For script details, refer to the** [📜 `snippets/requirements/` directory](snippets/requirements/)

## 🛠 Development Guidelines

All script development follows strict coding standards outlined in:
- 📜 [Zsh Core Scripting Best Practices](requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md)
- ✍️ [Zsh Snippet Script Best Practices](requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md)

### 🧪 Running Tests

Each script includes **automated regression tests**. Run them as follows:

```sh
# Run tests for create_inception_commit.sh
./snippets/tests/TEST-create_inception_commit.sh
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
