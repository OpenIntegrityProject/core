# Issues - Zsh Core Scripting Requirements and Best Practices
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/issues/ISSUES-Zsh_Core_Scripting_Best_Practices.md`_
> - _github: [Zsh Core Scripting Requirements and Best Practices](https://github.com/OpenIntegrityProject/scripts/blob/main/issues/ISSUES-Zsh_Core_Scripting_Best_Practices.md)_
> - _Updated: 2025-02-27 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

Issues related to the [Zsh Core Scripting Requirements and Best Practices](https://github.com/OpenIntegrityProject/scripts/blob/main/requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md).

## Update Function Naming Conventions

## ISSUE: Verb First, but what else?
**Context:** We current recommend verb-first order in function names (e.g. `assess_Commit`).
**Current:** Examples of function naming after verb first are varied.
**Impact:** Inconsistent interpretation
**Proposed Actions:**
- Clarify criteria for naming verb-first naming of functions
- Evaluate if there criteria and conventions for second and third words used in function names?
- Provide explicit, unambiguous examples

### ISSUE: Progressive Trust in Function Names
**Context:** We are inconsistent in our terminology for various evaluation phases
**Current:** Terminology and examples for function naming conventions are inconsistent, `audit_inception_commit-POC.sh` is currently best (but probably imperfect)
**Impact:** Inconsistent interpretation of trust level, or false expectation of binary trust.
**Proposed Actions:**
- Clarify criteria for naming of functions that get or set code related to trust.
- Provide explicit, unambiguous examples
- Add section explaining exceptions to these naming rules.

### ISSUE: Ambiguity in Naming Convention Terminology 
**Context:** The requirements document contains non-conventional terminology for function naming conventions. 

**Current:** 
2. Naming Conventions section says:
   - **Scripts:** Use `lower_snake_case.sh` (not `.zsh`) in `verb_preposition_object.sh` order (e.g., `create_inception_commit.sh`).
   - **Functions:** Use `lowerfirst_Camel_Case` in `verb_Preposition_Object` order (e.g., `verify_Commit_Signature()`).

**Impact:** 
- Developers may be confused by the conflicting terms
- Makes it harder to verify if code meets requirements
- Could lead to inconsistent implementation across scripts
- Non-standard terminology makes requirements harder to understand

**Proposed Actions:**
1. Choose a single, clear term for the convention:
   - Research other names used for this case convention
     - `lowerfirst_Pascal_Snake_Case` is one suggestion.
   - Consider established terms like "initial-lowercase with capitalized words"
   - Or define a new term with explicit format rules
   - Ensure the chosen term is consistently used throughout documentation

2. Provide clear, multiple examples:
    ```
    correct:     verify_Commit_Signature()
    correct:     push_Repo_To_GitHub()
    incorrect:   Verify_Commit_Signature()  # First word capitalized
    incorrect:   verify_commit_signature()  # Subsequent words not capitalized
    incorrect:   verifyCommitSignature()    # No underscores
    ```
3. Add explicit rules, e.g.:
   - First word must be lowercase
   - Subsequent words must be capitalized
   - Words must be separated by underscores
   - Applies to all functions except `main()`

4. Consider adding a brief explanation of why this convention was chosen:
   - Enhances readability
   - Makes function names clearly distinguishable
   - Aligns with other naming conventions in the codebase

5. Update all related documentation to use the chosen terminology consistently

**Progress:**
- For now I've searched and replaced function requirements that had `lowerfirst_Camel_Case`to `lowerfirst_Pascal_Snake_Case`.