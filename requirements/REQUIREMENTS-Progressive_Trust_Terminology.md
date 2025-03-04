# Progressive Trust Terminology Requirements and Best Practices
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md`_
> - _github: [`scripts/blob/main/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md`](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Progressive_Trust_Terminology.md)_
> - _Updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com> Github/Twitter/Bluesky: @ChristopherA_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

## Code Version and Source

This requirements document applies to the Open Integrity Project's **Proof-of-Concept** scripts, versioned **0.1.\***, which are available at the following source:

> **Origin:** [_github: `https://github.com/OpenIntegrityProject/scripts/`_](https://github.com/OpenIntegrityProject/scripts/)

Any updates or modifications to these scripts should reference this requirements document to ensure consistency with the outlined terminology requirements.

## Introduction

This document defines standardized terminology requirements for the Open Integrity Project, specifically focusing on Progressive Trust language conventions. These conventions ensure conceptual clarity when discussing different phases of the Progressive Trust model in code, documentation, and user interfaces.

Progressive Trust is a foundational concept introduced by Blockchain Commons that establishes trust gradually, mirroring how human trust relationships evolve in the real world - through progressive stages rather than binary "trust/don't trust" decisions. The Open Integrity Project applies this model to software integrity and cryptographic verification.

## Progressive Trust Phase Model

The Progressive Trust model consists of different phases that build upon each other. Each phase has distinct terminology that should be used consistently throughout the codebase:

### Phase 0: Context *(Interaction Considered)*
Initial consideration of whether a progressive trust approach is needed.

### Phase 1: Introduction *(Assertions Declared)*
Establishes the starting point for trusted interactions by declaring initial assertions.

### Phase 2: Wholeness *(Integrity Assessed)*
Checks that data assets are technically correct, well-formed, and sufficiently complete.

### Phase 3: Proofs *(Secrets Verified)*
Ensures cryptographic validity and authenticity through verification.

### Phase 4: References *(Trust Affirmed)*
Builds trust by affirming and cross-referencing against other trusted sources.

### Phase 5: Requirements *(Standards Audited)*
Evaluates compliance with community standards, specifications, and policies.

### Phase 6-10: Advanced Phases
Later phases (Approval, Agreement, Fulfillment, Inspection, Dispute) apply primarily to more complex interactions but may be referenced in documentation.

## Terminology Guidelines

### Reserved Terms

1. **verify/verification/verifying**
   - MUST be reserved exclusively for cryptographic operations in Phase 3 (Proofs)
   - Examples: "verify signature", "cryptographically verify", "verify hash"
   - MUST NOT be used for non-cryptographic checks
   - When used in function names, MUST indicate that cryptographic verification is occurring

2. **validate/validation/validating**
   - MUST NEVER be used in the Open Integrity Project
   - These terms imply a different trust model and create conceptual confusion
   - No exceptions to this rule

### Phase 2 Terminology Distinctions

For Phase 2 (Wholeness), three related terms have specific usage patterns:

1. **assess/assessment**
   - USE when the primary action is evaluating or judging quality
   - Example: "assess repository structure", "integrity assessment"
   - Appropriate for general evaluation activities
   - Example function: `assess_Repository_Structure()`

2. **assure/assurance**
   - USE when confirming and providing confidence in a specific state
   - Example: "assure empty commit", "assurance of format correctness"
   - Appropriate when checking specific conditions with binary outcomes
   - Example function: `assure_Empty_Commit()`

3. **ensure**
   - USE when guaranteeing that a condition is met (implementation detail)
   - Example: "ensure robust error handling", "ensure proper formatting"
   - Less preferred for user-facing terminology but acceptable in internal documentation
   - Example function: `ensure_Proper_Configuration()`

### Preferred Alternatives by Phase

1. **Phase 0 (Context) Terminology**
   - Preferred verbs: "consider", "plan", "survey"
   - Preferred objects: "interaction", "context", "ecosystem", "environment" 
   - Function naming pattern: `consider_*`, `plan_*`
   - Variable naming pattern: `*_Context`, `*_Plan`

2. **Phase 1 (Introduction) Terminology**
   - Preferred verbs: "declare", "assert", "commit", "establish", "introduce", "reveal"
   - Preferred objects: "assertion", "initial claim", "inception commit", "origin", "public declaration"
   - Function naming pattern: `declare_*`, `assert_*`, `establish_*`
   - Variable naming pattern: `*_Declaration`, `*_Assertion`

3. **Phase 2 (Wholeness) Terminology**
   - Preferred verbs: "assess", "assure", "examine", "structure", "cohere", "organize"
   - Preferred objects: "integrity", "consistency", "wholeness", "structure"
   - Function naming pattern: `assess_*`, `assure_*`, `examine_*`
   - Variable naming pattern: `*_Status`, `*_Integrity`, `*_Structure`

4. **Phase 3 (Proofs) Terminology**
   - Preferred verbs: "verify", "authenticate", "encode", "hash", "sign"
   - Preferred objects: "secret", "hash", "proof", "signature"
   - Function naming pattern: `verify_*`, `authenticate_*`
   - Variable naming pattern: `*_Verified`, `*_Proof`, `*_Signature`

5. **Phase 4 (References) Terminology**
   - Preferred verbs: "affirm", "aggregate", "check", "look up", "synthesize", "endorse"
   - Preferred objects: "trust", "declarations", "references", "trust model"
   - Function naming pattern: `affirm_*`, `reference_*`
   - Variable naming pattern: `*_Referenced`, `*_Trusted`, `*_Affirmed`

6. **Phase 5 (Requirements) Terminology**
   - Preferred verbs: "audit", "comply", "certify", "standardize", "test"
   - Preferred objects: "requirements", "expectations", "policies", "standards"
   - Function naming pattern: `audit_*`, `evaluate_*`, `meets_*`, `comply_*`
   - Variable naming pattern: `*_Compliance`, `*_Conformance`, `*_Requirement`

## Implementation Requirements

### Function Naming

1. Functions MUST be named according to their primary phase of operation
   - Example: `verify_Signature()` for a function that cryptographically verifies a signature
   - Example: `assess_Repository_Structure()` for a function that examines repository structure
   - Example: `assure_Empty_Commit()` for a function that confirms a commit contains no files

2. Functions that operate across multiple phases SHOULD use the terminology of their primary phase:
   - For a function spanning Phases 2 and 3, with primary focus on Phase 2: `assess_Repository_With_Verification()`
   - For a function spanning Phases 3 and 4, with primary focus on Phase 3: `verify_Signature_With_References()`

3. Functions that implement a specific part of a phase SHOULD use a more specific verb:
   - Example: `extract_Commit_Message()` instead of `check_Commit_Message()`
   - Example: `parse_Repository_Structure()` instead of `assess_Repository_Structure()`

4. Phase 2 (Wholeness) functions SHOULD distinguish between:
   - `assess_*` for evaluating quality or integrity (judgment-oriented)
   - `assure_*` for confirming specific conditions (state-oriented)
   - `locate_*` for finding specific elements within a structure

5. Function naming MUST follow a consistent pattern:
   - `<phase_verb>_<object>[_<modifier>]()`
   - Where `<phase_verb>` is the appropriate verb for the phase
   - Where `<object>` is the entity being acted upon
   - Where optional `<modifier>` provides additional context

### Variable Naming

1. Status variables MUST use phase-appropriate suffixes
   - Example: `Signature_Verified` rather than `Signature_Validated` (Phase 3)
   - Example: `Structure_Integrity` rather than `Structure_Verification` (Phase 2)

2. Boolean variables SHOULD use the appropriate phase prefix or suffix
   - Example: `Has_Inception_Commit` (Phase 1) vs `Is_Referenced_Externally` (Phase 4)
   - Example: `Integrity_Confirmed` (Phase 2) vs `Signature_Verified` (Phase 3)

3. Collection variables SHOULD use pluralized phase-appropriate naming
   - Example: `Verified_Signatures`, `Referenced_Identities`

4. Variables that track progress through phases SHOULD use clear phase indicators
   - Example: `Trust_Assessment_Status` with values indicating phase progress
   - Example: `Current_Phase` with numeric values corresponding to phases

### Error and Status Messages

1. User-facing messages MUST use phase-appropriate terminology
   - Example: "Signature verification failed" rather than "Signature validation failed"
   - Example: "Integrity assessment passed" rather than "Integrity verification passed"

2. Log messages SHOULD indicate the specific phase of operation
   - Example: "[PHASE 3] Verifying signature..."
   - Example: "[PHASE 2] Assessing repository structure..."

3. Exit codes and error handling SHOULD reflect phase-specific outcomes
   - Phases 1-3 (local phases) may warrant non-zero exit codes
   - Phases 4-5 (remote phases) may warrant warnings but not errors

## Detailed Examples by Phase

### Phase 2 (Wholeness) Examples

#### Good Examples from Existing Code:

```zsh
# Assessment header - properly uses "assessment" terminology
z_Output info "Wholeness Assessment:"
z_Output verbose Emoji="" "(Progressive Trust Phase 2)"

# Function for general evaluation (uses "assess")
function oi_Assess_Repository_Structure {
    z_Output verbose Indent=2 Emoji="📌" "Assessing repository structure..."
    # Evaluation code here
}

# Status variable with appropriate naming
Trust_Assessment_Status[structure]=$TRUE

# Proper output message with phase-appropriate terminology
z_Output success Indent=2 "Content Assessment: Commit is empty as required"
```

#### Improved Examples:

```zsh
# Function for binary confirmation (should use "assure" instead of "assess")
function oi_Assure_Empty_Commit {
    z_Output verbose Indent=2 Emoji="📌" "Assuring commit is empty..."
    # Binary check code here
}

# Function for finding elements (should use "locate")
function oi_Locate_Inception_Commit {
    z_Output verbose Indent=2 Emoji="📌" "Locating inception commit..."
    # Location code here
}

# Error message with proper terminology
z_Output error Indent=4 "Wholeness assessment failed: structure integrity issue"
```

### Phase 3 (Proofs) Examples

#### Good Examples from Existing Code:

```zsh
# Phase header - properly uses "proofs" terminology
z_Output info "Cryptographic Proofs:"
z_Output verbose Emoji="" "(Progressive Trust Phase 3)"

# Function using "authenticate" for cryptographic verification
function oi_Authenticate_Ssh_Signature {
    z_Output verbose Indent=2 Emoji="📌" "Authenticating SSH signature..."
    # Verification code here
}

# Status variable with verification terminology
Trust_Assessment_Status[signature]=$TRUE

# Proper verification message
z_Output verbose Indent=8 "✓ Signature cryptographically verified"
```

#### Improved Examples:

```zsh
# Function using explicit "verify" verb
function oi_Verify_Commit_Signature {
    z_Output verbose Indent=2 Emoji="📌" "Verifying commit signature..."
    # Verification code here
}

# Proper verification failure message
z_Output error Indent=4 "Signature verification failed: invalid key format"

# Status tracking with proper terminology
typeset -i Signature_Verified=$FALSE
```

### Phase 4 (References) Examples

#### Good Examples from Existing Code:

```zsh
# Phase header with proper terminology
z_Output info "Trust References:"
z_Output verbose Emoji="" "(Progressive Trust Phase 4)"

# Function using "affirm" for identity reference
function oi_Affirm_Committer_Signature {
    z_Output verbose Indent=2 Emoji="📌" "Affirming identity references..."
    # Reference checking code here
}

# Proper output message
z_Output success Indent=2 "Identity Check: Committer matches key fingerprint"
```

#### Improved Examples:

```zsh
# Function using "reference" verb
function oi_Reference_External_Identity {
    z_Output verbose Indent=2 Emoji="📌" "Referencing external identity sources..."
    # Reference checking code here
}

# Status variable with appropriate phase terminology
typeset -i Identity_Referenced=$TRUE

# Warning message with proper terminology
z_Output warn Indent=2 "Identity reference issue: unable to affirm external references"
```

### Phase 5 (Requirements) Examples

#### Good Examples from Existing Code:

```zsh
# Function using "comply" for standards
function oi_Comply_With_GitHub_Standards {
    z_Output info "Community Standards:"
    z_Output verbose Emoji="" "(Progressive Trust Phase 5)"
    # Standards compliance code here
}

# Status tracking with standards terminology
Trust_Assessment_Status[standards]=$TRUE
```

#### Improved Examples:

```zsh
# Function using "audit" verb
function oi_Audit_Community_Standards {
    z_Output verbose Indent=2 Emoji="📌" "Auditing community standards compliance..."
    # Standards auditing code here
}

# Function using "evaluate" verb
function oi_Evaluate_License_Compliance {
    z_Output verbose Indent=2 Emoji="📌" "Evaluating license compliance..."
    # Compliance evaluation code here
}

# Status variable with appropriate terminology
typeset -i Standards_Compliance=$TRUE

# Proper status message
z_Output success Indent=2 "Standards Audit: Repository meets community requirements"
```

## Phase Sections in Code

When organizing code by Progressive Trust phases, use consistent section headers:

```zsh
#----------------------------------------------------------------------#
# PHASE 2: WHOLENESS ASSESSMENT
#----------------------------------------------------------------------#
z_Output info "Wholeness Assessment:"
z_Output verbose Emoji="" "(Progressive Trust Phase 2)"

# Phase 2 operations here

#----------------------------------------------------------------------#
# PHASE 3: CRYPTOGRAPHIC PROOFS
#----------------------------------------------------------------------#
z_Output info "Cryptographic Proofs:"
z_Output verbose Emoji="" "(Progressive Trust Phase 3)"

# Phase 3 operations here
```

## Additional Guidelines

1. Documentation MUST maintain consistent terminology across all components
   - README files, comments, help text, and UI elements must align
   - Error messages and success messages must use the same terminology

2. When introducing new functionality:
   - Determine the appropriate phase of operation
   - Choose terminology from the corresponding phase
   - Use consistent naming patterns for functions, variables, and messages

3. When modifying existing code:
   - Refactor names to align with these guidelines
   - Document changes in commit messages with "Terminology alignment" noted
   - Update tests to reflect new terminology

## Change Management

1. Terminology changes SHOULD be made incrementally:
   - Focus on one phase or component at a time
   - Ensure all related functions, variables, and messages are updated together
   - Include comprehensive testing to verify behavior hasn't changed

2. Each terminology change SHOULD be in its own commit with:
   - Clear subject line: "Align Phase X terminology in [component]"
   - Detailed explanation of what was changed and why
   - Reference to this requirements document

## Conclusion

Adherence to these terminology requirements ensures conceptual clarity throughout the Open Integrity Project. These distinctions are not merely semantic but reflect the fundamental Progressive Trust model and its application to software integrity. Consistent terminology helps users, developers, and external observers understand the specific claims being made and the level of trust established at each phase.

## References

- [Progressive Trust lifecycle document](../progressive_trust_life_cycle.md)
- [Issue on Phase 2 Terminology](../issue_on_phase_2.md)
- [CLAUDE.md: Terminology Guidelines](../CLAUDE.md)
- [Blockchain Commons: Progressive Trust](https://www.blockchaincommons.com/musings/musings-progressive-trust/)