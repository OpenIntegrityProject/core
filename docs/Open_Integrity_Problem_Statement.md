# Open Integrity Project: A Cryptographic Root of Trust for Git Repositories
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Open_Integrity_Problem_Statement.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity_Problem_Statement.md`_
> - _updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## Introduction

The _**Open Integrity**_ project, an initiative of [Blockchain Commons](https://www.blockchaincommons.com/), demonstrates how a Git repository can serve as a **cryptographic root of trust** and offer a continuing **chain of trust**, ensuring **integrity, provenance, and accountability** in software development. By combining Git's native signing capabilities with structured cryptographic verification and auditing processes, this proof-of-concept creates tamper-resistant and independently verifiable software and data stores.

This approach enables:
- **Platform-independent verification** that works across any Git hosting service
- **Verifiable commit authenticity** from both authors and committers
- **Immutable proof-of-origin** for software artifacts
- **Immutable signature chains** to ensure that past commits remain cryptographically verifiable
- **Tamper detection** throughout repository history

Through this project, Blockchain Commons advances its mission of developing **open, interoperable, and secure digital infrastructure**. This proof-of-concept's work with cryptographic roots of trust focuses on the [Gordian Principle](https://github.com/BlockchainCommons/Gordian) of independence by creating a system that can operate independently of any single platform or authority as well as the goal of [progressive trust](https://www.lifewithalacrity.com/article/progressive-trust/). It also supports privacy (through the minimal disclosure of verifiable proofs), resilience (through secure commits), and interoperability (through platform-agnostic inspection) and enables [open development](https://www.blockchaincommons.com/articles/Open-Development/).

## Problem Statement

Git is a powerful **distributed version control system**, but its default configuration lacks **cryptographic enforcement of commit authenticity, history integrity, and repository provenance**. While Git efficiently tracks changes, it does not provide built-in mechanisms to prevent forgery, tampering, or unauthorized modification.

Without cryptographic trust, repositories face several risks.

**General Risks:**
- **Git account info is not verified.** Any user can access Git with a fake name and email and make it appear as though someone else authored a commit.
- **Push access and commit access are intertangled.** Any developer with push access can commit, regardless of trust status.
- **Unsigned commits provide no cryptographic proof of origin.** Git does not enforce commit signing, permitting misuse of a stolen account (and again allowing forgery).
- **Unsigned commits can be merged into signed repositories.** Even if a Git hosting service enforces commit signing, unsigned commits can still be merged from branches without triggering a verification warning or failure.
- **Commit history can be rewritten.** Unless explicitly protected, Git allows history to be altered or deleted, making it possible for attackers (or even well-intentioned users) to modify past commits without detection.
- **Chain of trust functionality is nonexistant.** There is no functionality for creating longer term trust, such as delegating trust or meaningfully revoking keys. Support for the chains of trust required between authors of PRs and committers of those PRs is also limited.
- **Feature branches may be deleted after merging.** Once an author's branch is merged and deleted, it may be impossible to verify whether the original commits were properly signed before merging, creating another violation of the chain of trust.

These weaknesses undermine confidence in the **long-term trustworthiness and verifiability of a repository**, impacting both open-source projects and enterprise software development.

Though there are no _native_ ways to resolve many of these issues, they can nonetheless be solved using Git's existing infrastructure. By combining Git's native support for SSH key signing (which provides ~128-bit security through modern cryptographic signatures), its hooks system for enforcing policies, and its ability to track metadata through commit messages, notes, and configuration files, we can create a robust trust framework.

The Open Integrity project implements this framework through a structured set of scripts and processes that integrate seamlessly with standard Git workflows to create both a inception **root of trust** and an ongoing **chain of trust**. 

**Open Integrity Design:**
- **SSH-signed Root of Trust.** SSH-signed Inception Commits serve as the cryptographically verifiable foundation for repository history. 
- **Linked Chain of Trust.** The list of authorized keys for a repo can be updated through transition commits; keys can also be expired or revoked. 
- **Signature Requirement. Every commit after the _Inception Commit_ requires an authorized SSH signature, ensuring proof of authenticity and tamper resistance.
- **Platform-agnostic Inspection.** Trust records can be inspected across GitHub, GitLab, peer-to-peer Git networks, or even local environments.

Open Integrity requires no modifications to Git itself. This practical approach remains fully compatible with existing Git hosting platforms,  without the need for proprietary tools or external dependencies.

## Establishing the Root of Trust

A Git repository's **first commit** is a critical **trust anchor**, yet Git does not require it to be **signed or immutable**. 

**Root of Trust Risks:**
- **Unsigned first commits allow repository forgery.** Without a cryptographic signature, anyone can create a repository and claim it as authoritative.
- **First commits can be rewritten.** Even if the first commit was signed, an attacker can later modify a repository's history, effectively changing its origin without detection.
- **No built-in method verifies repository origin.** If a repository is cloned and altered, there is no cryptographic link to its original creator.

Open Integrity solves these problems by introducing the **Inception Commit**, a specially crafted empty commit that serves as a cryptographic foundation. This commit includes both a Ricardian Contract establishing trust rules and a cryptographic signature. Though Git's commits use SHA-1 (which has known cryptographic weaknesses), the Inception Commit mitigates these risks with careful management of the repo's initial commit.

**Root of Trust Design:**
- **Content Constraint.** An empty commit (containing no files) with minimal metadata reduces the attack surface for SHA-1 collisions (~80-bit security).
- **Deterministic State.** The empty tree hash is predictable and easily verified, creating a deterministic state for the Inception Commit.
- **Verifiable Origin.** The first commit is signed by the repository’s first trusted key, creating a verifiable origin. Even if a hash collision were achieved due to the weakness of SHA-1, an attacker would still need to forge a valid SSH signature (~128-bit security).
- **Immutable Inspection.** Because it is platform-agnostic, this commit can be authenticated, affirmed, and audited regardless of where the repository is hosted.

## Linking a Chain of Trust

With a singular root of trust, created by an Inception Commit to authorize an inception key, a repo can be managed in the following way, demonstrating Inception Authority:

1. All commits in protected branches (such as main) are verified directly against the inception key.
2. Other developers can author commits in feature branches.
3. The inception key holder must verify and commit these changes to protected branches.

However, this is insufficient for many uses of Git repositories. Not only does it ignore existing infrastructural problems with the merging of non-privileged developer content, but it also doesn't support the needs of larger teams or the needs of teams working over longer time periods. To fully enable software or data store collaboration requires going beyond the model of Inception Authority to support:

* **Delegating Authority.** The Inception Commit lists one trusted key. Other keys can be added.
* **Managing Expirations & Revocations.** Keys are not eternal. They may need to be changed over time.
* **Merging Content.** Content might come from authors who are not authorities at the repo. Merging in that third-party authorial content requires care, especially to maintain the original information about the author.

### Delegating Authority

Git does not provide an auditable way to delegate commit signing permissions.

**Non-Delegation Risks:**
* **The inception key is a single point of failure.** If the inception key is lost, there is no longer a way to make authorized commits to the repo.
* **The Inception Key worsens compromise risks.** Any lost key could compromise a repo. (They're all Single Points of Compromise!) However, if a singular inception key is shared among many developers, this multiplies the risk, as any developer's key being stolen puts all of their commits at risk.
* **A singular signing system considerably burdens a singular developer.** Contrariwise, a single developer gatekeeping all content puts a considerable burden on them. This is likely to lead to either backlog (if they're diligent) or poorly considered merges (if they're not).

To mitigate these issues, Open Integrity implements 
Delegated Authority as an alternative to Inception Authority.

**Delegated Authority Design:**
- **Key Delegation.** A trust transition commit signed by the inception key gives authority to additional keys. This creates an unbroken chain of trust from inception through subsequent authorizations.
- **Transition Commit.** Like the inception commit, the transition commit is designed to be empty to minimize attack surfaces.
- **Decentralized Governance.** Any authorized key can later be removed by trusted keys, allowing key rotation.
- **Delegation File.** A transition commit records rights in the local `allowed_commit_signers` file within the repository. Each modification to `allowed_commit_signers` must be signed by an authorized key (initially the inception key).
- **Superceding Keys.** The inception key is no longer used after a transition commit, with the new delegated keys now having all the authority.

### Managing Expirations & Revocations

Git does not provide an auditable way to **manage key expiration or revocation**.

**Expiration Risks:**
- **Old keys remain trusted unless manually removed.** There is no way to automatically expire a key, though periodic updates would create a more secure environment.
- **Revoked keys are not automatically rejected by Git for future commits.** Even if a key has been revoked, it might still be used for signing, and Git doesn't present any **bold** and obvious warnings of this fact. This might be particularly problematic when a committer is merging an author's content.
- **Compromised keys are a danger.** Keys that have been compromised might link with either of the above problems, and there's a disincentive to revoke them because of Git's inability to chain trust.

Open Integrity mitigates these problems with logging that is reported out on future commits.

**Revocation Design:**
- **Timestamped Revocation.** Revocation of keys is timestamped with Git's notes function.
- **Revocation Reporting.** Attempts to use a revoked key in a commit are not only reported, but will also stop the merging of that commit.

### Merging Content

The **chain of trust** largely focuses on the management of keys to control a software or data store, centered on the life cycle of an inception key, delegated keys, and (later) revoked or expired keys.

However, **authors** who do not have key permissions also make commits to repos. 

**Authorial Commit Risks:**
- **Contributor agreements can't be cryptographically enforced.** Many projects require contributors to sign agreements, but Git provides no way to verify that authors consented to these terms.
- **Author attribution can be claimed without proof.** There is no requirement for author signatures. 

Authorial pulls are merged by **committers** who do have full permissions. This creates additional challenges for maintaining both **author authenticity** and **committer authorization**.

**Authorial Merge Risks:**
- **Validation is too shallow to consider authors.** While Git records both the author and committer of changes, it doesn't verify that the stated author actually wrote or approved the changes.
- **Committers can modify author attribution.** When merging changes, committers can alter the author field without detection.
- **Rebase and squash operations lose author signatures.** Common Git workflows can strip away proof of original authorship, losing the chain of proof, making it impossible to verify after the fact.
- **Feature branches may be deleted after merging.** More generally, feature branches can be deleted, erasing verification records.

Open Integrity ensures both **authorship authenticity** and **committer authorization**.

**Authorial Merge Design:**
- **Agreement Chain of Consent.** A verifiable chain of consent for repository agreements is stored in configuration files.
- **Signature Requirement.** Cryptographic signatures are required from _both_ authors and committers.
- **Signature Preservation.** Original authorial signatures are preserved through merge operations.
- **Attribution Preservation.** Any unauthorized modifications to authorship claims are detected.

## The Open Integrity Software

The following examples show Open Integrity code that embodies these expansions to Git's core methodology as well as commit details that assess the integrity of the commit and verify its signatures.

## Example: Establing the Root of Trust

Assuming your `git config --global` configuration is correctly set up (see the test snippet in `Open_Integrity_Script_Snippets.md`), this command **(for the ZSH shell)** will create a new repository and sign its initial **Inception Commit** according to Open Integrity specifications.

```zsh
eval "$(
  cat <<'EOF'
zsh_git_inception() {
  [ -d "$(pwd)/new_open_integrity_repo/.git" ] && echo "❌ Repo already exists." && return 1
  mkdir -p "$(pwd)/new_open_integrity_repo" && git -C "$(pwd)/new_open_integrity_repo" init > /dev/null
  SIGNING_KEY="$(git config user.signingkey)"
  GIT_AUTHOR_NAME="$(git config user.name)"
  GIT_AUTHOR_EMAIL="$(git config user.email)"
  GIT_AUTHOR_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  GIT_COMMITTER_NAME="$(ssh-keygen -E sha256 -lf "$SIGNING_KEY" | awk '{print $2}')"
  GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
  GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
  GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
  GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  GIT_AUTHOR_DATE="$GIT_AUTHOR_DATE" GIT_COMMITTER_DATE="$GIT_COMMITTER_DATE" \
  git -C "$(pwd)/new_open_integrity_repo" -c gpg.format=ssh -c user.signingkey="$SIGNING_KEY" \
    commit --allow-empty --no-edit --gpg-sign \
    -m "Initialize repository and establish a SHA-1 root of trust" \
    -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo, including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers." --signoff
  [ $? -eq 0 ] && echo "✅ Repo initialized!" || echo "❌ Commit failed. Check Git settings."
}
zsh_git_inception
EOF
)"
```

This establishes an immutable foundation for all future commits.

**Commit Result:**
```
🔹 Commit: #a3306ef [🏁 Inception Commit] (Signed ✅)
    ├─ Message: "Initialize repository and establish a SHA-1 root of trust"
    ├─ Signed by: @a61TkTtL... (🏁 Alice using Device 1 <alice@example.com>)
    ├─ Empty: true (no files added)
    ├─ SHA-1 Protection: Constrained content + SSH signature
└─ Verification: Platform-independent
```

### Example: Delegating Authority

The creation of the initial `allowed_commit_signers` is accomplished through the following `zsh` script:

  ```sh
# Configure allowed commit signers verification
git config --local gpg.ssh.allowedSignersFile .repo/config/verification/allowed_commit_signers
    
# Install pre-receive hook for validation
cat > .git/hooks/pre-receive <<'EOF'
#!/bin/sh
while read oldrev newrev refname; do
    verify_authorized_signer $newrev
done
EOF
```

This script expands the trust of the inception commit into a chain of trust, beginning with a transition from the inception key.

**Commit Result:**
```
🔹 Commit: #b24d9c1 [🔑 New Allowed Commit Signers File] (Signed ✅)
    ├─ Message: "Added second device key for Alice"
    ├─ Signed by: @a61TkTtL... (🏁 Alice using Device 1 <alice@example.com>)
    └─ New Authorized Commit Signers:  
        - 🏁 Inception Key explicitly not included for future commits
        - + @a61TkTtL... (Alice using Device 1 <alice@example.com>)  
        - + @f84PmWnY... (Alice using Device 2 <alice@example.com>)
```
After this point, only keys listed in the `allowed_commit_signers`  file can make commits (not the inception key). As trust expands, additional commit signers can be added by any already authorized key:

**Commit Result:**
```
🔹 Commit: #f75e3b9 [🔑 Added Bob and Charlie as Signers] (Signed ✅)
    ├─ Message: "Added Bob and Charlie to allowed commit signers"
    ├─ Signed by: @a61TkTtL... (Alice using Device 1 <alice@example.com>)
    └─ New Authorized Commit Signers found:  
        - @a61TkTtL... (Alice using Device 1 <alice@example.com>)  
        - @f84PmWnY... (Alice using Device 2 <alice@example.com>)
        - + @b73RkKpQ... (Bob using Work Laptop <bob@example.com>)  
        - + @c58XmWpL... (Charlie using Home PC <charlie@example.com>)  
```

### Example: Managing Expirations & Revocations

Open Integrity can enforce **structured key rotation** using Git's native timestamping and notes features:

```sh
# Record key authorization with timestamp
git notes --ref=key-history add -m "Authorized: $(date -u +"%Y-%m-%dT%H:%M:%SZ") $keyid"
```

Key recovations are shown as commits.

**Commit Result:**
```
🔹 Commit: #c3d7f12 [🔄 Key Rotation: Removed Alice's Second Device] (Signed ✅)
    ├─ Message: "Revoked second device key"
    ├─ Signed by: @f84PmWnY... (Alice using Device 2 <alice@example.com>)
    ├─ Authorized Commit Signers changed:
        - 🗑️ @f84PmWnY... (Alice using Device 1 <alice@example.com>) is no longer authorized.
        - @f84PmWnY... (Alice using Device 2 <alice@example.com>)
        - @b73RkKpQ... (Bob using Work Laptop <bob@example.com>)  
        - @c58XmWpL... (Charlie using Home PC <charlie@example.com>)  
```

If someone tries to use a revoked key, not only does that show up in the commit, but merges are prevented!

**Commit Result:**
```
🔹 Commit: #e9a1b78 [❌ Invalid Signature - Not Authorized!]
    ├─ Message: "Fix security vulnerability"
    ├─ Signed by: @a61TkTtL... (Alice using Device ` <alice@example.com>)
    ├─ 🚨 ERROR: Commit was signed using a previously revoked key!
    └─ ❌ ERROR: Commit was not merged into main
```

### Example: Merging Content

The challenges of committers merging author content are managed by enforcing a dual-signature model through merges:

```sh
# During merge, verify both author and committer signatures
git merge feature-branch --verify-signatures \
    --require-author-signature \
    --require-committer-authorization
    
# Preserve both signature chains
git notes --ref=signatures add -m "$(git verify-commit HEAD)" $commit
```

A merge then maintains full verification records for both parties.

    🔹 Commit: #fa34d76 [🔀 Merge Commit with Verified Author] (Signed ✅)
        ├─ Message: "Merge feature-branch: Added authentication layer"
        ├─ Committer: @c58XmWpL... (Charlie using Home PC <charlie@example.com>)
        ├─ Author: @e83TkLqM... (Eve using Dev Machine <eve@example.com>)
        ├─ Author Signature: Verified ✓ (signed 2024-02-10T15:30:00Z)
        ├─ Committer Authorization: Verified ✓ (in allowed_signers since 2024-01-15)
        └─ Signatures stored: ./config/verification/signatures

If author signatures are lost during a squash/rebase, that's reported as well.

**Commit Result:**
```
🔹 Commit: #g61x3p4 [⚠️ Merge Commit with Lost Author Signature] (Signed ✅)
    ├─ Message: "Merge feature-branch: Database optimization"
    ├─ Committer: @b73RkKpQ... (Bob using Work Laptop <bob@example.com>)
    ├─ Author: @e83TkLqM... (Eve using Dev Machine <eve@example.com>)
    ├─ ⚠️ WARNING: Original author signature not found
    ├─ Committer Authorization: Verified ✓
    └─ ⚠️ Recommended Action: Author to re-sign changes
```

### Example: Summary of Trust Evolution

The following table shows the evolution of trust in an Open Integrity repo, beginning with inception (0), continuing through delegation of authority (2), and the rotation of a key (4). It also demonstrates valid commits (0-5), a lost author (6), and an entirely unauthorized signature (7). Together, this lays out the entire trust history of the repo.
```
    #  Commit    Signed By    Status      Message           Special Event
    ------------------------------------------------------------------------------------------
    0  #a3306ef  @a61TkTtL... ✅  Initialize repository...  🏁 Inception Commit
    1  #d74f9b2  @a61TkTtL... ✅  Fix typo in README       
    2  #b24d9c1  @a61TkTtL... ✅  Initial allowed_commit... 🔑 Initial Commit Signers File
    3  #f75e3b9  @b73RkKpQ... ✅  Refactor logging system                               
    4  #c3d7f12  @c58XmWpL... ✅  Rotate out Alice from...  🔄 Key Rotation (🗑️ Removed Alice)
    5  #fa34d76  @c58XmWpL... ✅  Merge feature-branch...   🔀 Verified Author Signature (✔️)
    6  #g61x3p4  @b73RkKpQ... ⚠️  Merge feature-branch...   ⚠️ Lost Author Signature
    7  #e9a1b78  @a61TkTtL... ❌  Fix security vulnerab...  🚨 Unauthorized Signature

    🔹 **Total Commits Checked:** 8  
    ✅ **Commits with Valid Signatures:** 6  
    ❌ **Commits with Unauthorized Signers:** 1  
    🔄 **Key Rotation Events:** 1 (Alice removed)  
    🔀 **Merge Commits with Verified Authors:** 1  
    ⚠️ **Merge Commits with Lost Author Signatures:** 1  
```

## Conclusion

Open Integrity establishes cryptographic trust in Git repositories by securing **commit authenticity, key governance, and repository provenance**. The MVA provides immediate benefits through local verification, while future enhancements will enable a broader trust ecosystem for software development. Together, these features create a **self-sovereign, platform-independent trust framework** for verifiable software provenance.

## Appendix: Future Opportunities

While the **Minimal Viable Architecture (MVA)** of Open Integrity secures local repository trust through **commit authenticity, signer governance, key rotation, and merge verification**, additional opportunities can further strengthen resilience, governance, and decentralized trust.

### Multi-Source Key Authentication

Currently, Open Integrity relies on manually maintained lists of authorized signing keys, but this model does not account for broader authentication sources. There is no **distributed way to verify commit signers across multiple independent trust networks**.

To expand trust verification, Open Integrity could integrate **multi-source key authentication**:

  ```sh
   # Future: Verify key against multiple sources
    verify_key() {
        # Check local allowed_signers
        if ! check_local_authorization "$keyid"; then
            return 1
        fi
        
        # Query GitHub's SSH key API
        if ! verify_github_key "$keyid" "$username"; then
            return 1
        fi
        
        # Check Web of Trust attestations
        if ! verify_wot_attestations "$keyid"; then
            return 1
        fi
        
        # Verify cross-repository attestations
        if ! verify_repo_attestations "$keyid"; then
            return 1
        fi
        
        # Verify hardware-backed keys
        if ! verify_hardware_key "$keyid"; then
            return 1
        fi
        
        return 0
    }
  ```

This **cross-repository trust validation** could support a number of trust sources, such as:

- Git platform authentication services (GitHub, GitLab, etc.)
- Platform key stores (macOS Keychain, Windows Certificate Store)
- Hardware security modules (FIDO/YubiKey, TPM)

It could do so without compromising independence.

### Repository Resilience

Open Source Git repositories are typically tied tightly to centralized hosting providers such as GitHub or GitLab. If a repository is removed, censored, or lost due to platform failure, it may become inaccessible. Open Integrity could introduce **decentralized archival and recovery mechanisms**:

  ```sh
    # Future: Push to decentralized storage
    git push ipfs://QmHash...        # Store on IPFS
    git push bt://InfoHash...        # Store on BitTorrent
    
    # Future: Verify repository integrity
    git verify-integrity ipfs://QmHash... \
        --inception-commit a3306ef \
        --trust-root @a61TkTtL...
        
    # Future: Emergency key recovery using SSKR
    git key recover --shares 2 \
        --threshold 3 \
        --recovery-method sskr
        
    # Future: Automated key rotation during compromise
    git key rotate-emergency \
        --revoke compromised-key \
        --activate backup-key \
        --notify all-signers
  ```

This would ensure repository resilience.

### Personal Developer Trust Roots

While Open Integrity ensures cryptographic trust within a repository, individual developers have no way to **cryptographically prove authorship across multiple repositories** due to a lack of a built-in mechanism in Git.

Open Integrity could establish **personal cryptographic roots of trust**:

  ```sh
    # Future: Create developer trust root
    git trust-root init "Alice" \
        --key @a61TkTtL... \
        --device "Device 1" \
        --email alice@example.com
    
    # Future: Cross-repository attestation
    git attest-contribution \
        --repo alice/alice \
        --commit abc123 \
        --sign @a61TkTtL...
  ```

### Repository Identity and Uniqueness

Git repositories currently rely solely on **the initial commit hash for uniqueness**, which presents challenges.
- **Repositories can be cloned and rehosted** under different names
- **No cryptographic link** exists between copies of the same repository
- **No way to verify authenticity** exists when repositories move between platforms
- **Two different repositories** can share the same commit history if they originated from the same base commits, forging new commits.

Open Integrity could solve this through a unique identity model:
  ```sh
    # Future: Generate globally unique repository identifier
    git repo generate-id \
        --inception-commit a3306ef \
        --initial-signer @a61TkTtL...
        
    # Future: Verify repository authenticity across platforms
    git verify-repo-uniqueness \
        --id "repo:a3306ef:@a61TkTtL..." \
        --verify-history
  ```

This ensures repositories maintain their identity regardless of location:
  ```
    🔹 Repository Identity Verification
       ├─ Unique ID: repo:a3306ef:@a61TkTtL...
       ├─ Inception Commit: #a3306ef
       ├─ Initial Signer: @a61TkTtL...
       ├─ Creation Date: 2024-02-12T14:30:00Z
       └─ Verification: Independent of hosting location
  ```

### W3C Decentralized Identifiers

Open Integrity could introduce full W3C DID integration:

  ```sh
   # Future: Generate W3C-compliant repository DID
   did:repo:git:$(git rev-parse HEAD):$(git config user.signingkey)
   
   # Future: Verify repository identity
   git verify-repo-id did:repo:git:a3306ef:@a61TkTtL...
  ```

An example W3C Controller Document for a git repository from a DID Resolver:

  ```json
    {
        "@context": "https://www.w3.org/ns/did/v1",
        "id": "did:repo:deedb3380e3e75266a009ee43b1dec54619f1b0f",
        "verificationMethod": [
            {
            "id": "did:repo:deedb3380e3e75266a009ee43b1dec54619f1b0f#ssh-key-1",
            "type": "SshPublicKey",
            "controller": "did:repo:dbe44e2f99347b403b8b649605dd718bf5a69614?serviceEndpoint=https%3A%2F%2Fgithub.com%2FChristopherA%2FChristopherA"
            "publicKeySsh": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC2O9n9I7RK1DXvnd7+eKYT+0Cr1bCJvdN/pdkb7625S"
            }
        ],
        "authentication": [
            {
            "id": "did:repo:deedb3380e3e75266a009ee43b1dec54619f1b0f#ssh-key-1",
            "type": "SshPublicKey",
            "controller": "did:repo:dbe44e2f99347b403b8b649605dd718bf5a69614?serviceEndpoint=https%3A%2F%2Fgithub.com%2FChristopherA%2FChristopherA"
            "publicKeySsh": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC2O9n9I7RK1DXvnd7+eKYT+0Cr1bCJvdN/pdkb7625S",
            "proofPurpose": "authenticationCommitOnly"  // Indicating restricted use specifically for commit authentication
            }
        ]
    }
  ```

### Decentralized Distribution Networks

Git's current distribution model relies on centralized hosting platforms or direct peer connections. Open Integrity could leverage existing peer-to-peer networks for resilient, decentralized distribution:

  ```sh
   # Future: Publish repository updates to BitTorrent's MainlineDHT
   git publish-update mainlinedht \
       --update-type key-rotation \
       --signed-by @a61TkTtL... \
       --dht-key "repo:a3306ef:updates"
       
   # Future: Subscribe to repository updates
   git subscribe-updates mainlinedht \
       --repo did:repo:git:a3306ef \
       --verify-signatures \
       --trust-root @a61TkTtL...
  ```

Example distributed update:
  ```
   🔹 Repository Update via MainlineDHT
      ├─ Type: Key Rotation Event
      ├─ DHT Key: repo:a3306ef:updates
      ├─ Signed By: @a61TkTtL... (Alice using Device 1)
      ├─ Timestamp: 2024-02-12T14:30:00Z
      ├─ Content: New authorized key @h92MnPq...
      └─ Verification: Independent of hosting platform
  ```
 
This would enable resilient, real-time deliveries of updates without central servers, making good use of existing Distributed Hash Table (DHT) infrastructure, while supporting independent verification of update authenticity.

### Repository Trust Roles & Governance

Git repositories require different levels of trust for commits, tags, and releases. Open Integrity could manage these distinct privileges through separate authorized signer lists:

  ```
   # Future: Configure role-based signing authorities
   git trust configure-roles \
       --commit-signers .repo/config/verification/allowed_commit_signers \
       --tag-signers .repo/config/verification/allowed_tag_signers \
       --release-signers .repo/config/verification/allowed_release_signers
  ```

Example role configuration:
  ```
   🔹 Repository Signing Roles
      ├─ Commit Signers: Regular developers making changes
      |   └─ @a61TkTtL..., @b73RkKpQ..., @c58XmWpL...
      ├─ Tag Signers: Release managers marking versions
      |   └─ @d94NmRs..., @e82PkQt...
      └─ Release Signers: Security team signing binaries
          └─ @f71MnPp..., @g63LkOr...
  ```

### Repository Trust Manifest: Additional Privacy Controls

Open Integrity could standardize repository trust through manifest files that balance transparency with developer privacy using commitments, elided data, or zk-proofs:

  ```
   # Future: Create repository trust manifest
   git trust init-manifest \
       --governance threshold-2-of-3 \
       --privacy elision-enabled \
       --audit structured-transparency
       
   # Future: Multi-party authorization using FROST
   git trust authorize-change \
       --signers required-2-of-3 \
       --protocol frost \
       --preserve-privacy
  ```

Example trust manifest capabilities:
  ```
   🔹 Repository Trust Manifest
      ├─ Governance: Threshold 2-of-3 signing
      ├─ Privacy: Elidable commit metadata
      ├─ Authorization: FROST threshold signatures
      ├─ Audit: Privacy-preserving trails
      └─ Verification: Independent assessment
  ```

### Independent Auditing Capabilities

While Git is decentralized, most auditing processes depend on **platform-specific tools such as GitHub or GitLab**. Open Integrity could ensure platform-independent verification:

  ```sh
   # Future: Independent repository audit
   git audit-repo \
       --trust-root @a61TkTtL... \
       --allowed-signers-file .github/allowed_signers \
       --verification-period "2024-01-01/2024-12-31" \
       --privacy-preserving
  ```

Example audit output:

    🔹 Repository Audit Report: 2024-01-01 to 2024-12-31
       ├─ Total Commits: 247
       ├─ Valid Signatures: 245
       ├─ Invalid/Missing Signatures: 2
       ├─ Key Rotation Events: 3
       ├─ Merge Commits (Verified): 15
       ├─ Merge Commits (Lost Author Signatures): 1
       ├─ Privacy: All sensitive data properly elided
       ├─ Trust Chain: All keys affirmed from Inception (#a3306ef) to head (#3f9245bc)
       └─ Endorsements: Security review by key @bf8640d1 (Rebecca <reviewer@security-reviews.com>)

## Conclusion

Open Integrity establishes cryptographic trust in Git repositories by securing **commit authenticity, key governance, and repository provenance**. The MVA provides immediate benefits through local verification, while future enhancements will enable a broader trust ecosystem for software development. Together, these create a **self-sovereign, platform-independent trust framework** for verifiable software provenance.
