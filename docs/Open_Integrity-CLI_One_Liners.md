# Open Integrity Project: Inception CLI One-Liners
> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Open_Integrity-CLI_One_Liners.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity-CLI_One_Liners.md`_
> - _updated: 2025-03-04 by Christopher Allen <ChristopherA@LifeWithAlacrity.com>_

This document contains a number of useful one-liner Git commands for evaluating and managing the inception commit (the first commit in a repository) based on the Open Integrity Project's specifications.

---

## **Retrieve the First Commit (Inception Commit)**

```sh
git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD 
```

**Example Output:**
```sh
115f7ab32f481ef9e360d763c5842e8415abd08f
```

**How It Works:**
- `rev-list` is a low-level Git command that lists commit hashes in a specified order.
- `--max-parents=0` filters commits that have **no parents**, effectively returning only the **first commit** in the repository.
- `HEAD` typically refers to the latest commit, but with `--max-parents=0`, Git efficiently traces back to the first commit.
- More efficient than reversing `git log`, making it ideal for large repositories.

### **Use Case**
- Can be embedded within `$(...)` in scripts or combined with `git show` to inspect the inception commit.

---

## **List All Commits in Order (Oldest to Newest)**

```sh
git -C ./new_open_integrity_repo log --oneline --reverse
```

**Example Output:**
```sh
115f7ab (HEAD -> main) Initialize repository and establish a SHA-1 root of trust
```

**How It Works:**
- `log` retrieves the commit history of the repository.
- `--oneline` condenses each commit into a **single-line format** (short hash + commit message), making it easier to scan.
- `--reverse` flips the order, displaying commits **from the first (oldest) to the most recent**.

### **Use Case** 
- Useful for reviewing a repository’s history in the order it was built.

---

## **Show Full Details of the First Commit**

```sh
git -C ./new_open_integrity_repo show --pretty=fuller $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
./new_open_integrity_repo show --pretty=fuller $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
commit 115f7ab32f481ef9e360d763c5842e8415abd08f (HEAD -> main)
Author:     @ChristopherA <ChristopherA@LifeWithAlacrity.com>
AuthorDate: Tue Feb 18 09:24:20 2025 +0000
Commit:     SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw <ChristopherA@LifeWithAlacrity.com>
CommitDate: Tue Feb 18 09:24:20 2025 +0000

    Initialize repository and establish a SHA-1 root of trust
    
    Signed-off-by: @ChristopherA <ChristopherA@LifeWithAlacrity.com>
    
    This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers.
```

**How It Works:**
- `git show` displays detailed information about a specific commit, including the diff of changes.
- `--pretty=fuller` ensures that **both the author and committer details** are displayed, along with their timestamps.
- `$(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)` dynamically retrieves the **first commit's hash**, ensuring that `git show` inspects the inception commit.

### **Use Case**
- Useful for verifying the **original author and committer** of the repository’s first commit.
- Helps in **auditing** and understanding the initial setup of the repository.

---

## **Retrieve the Key Fingerprint Used for Signing the Inception Commit**

When a commit is signed, a signature is embedded in its metadata, containing the public key from which a key fingerprint is derived.

Git verifies this fingerprint against the allowed commit signers list (configured via `git config --<global|local> gpg.ssh.allowedSignersFile <path/to/filename>`), ensuring that only trusted keys with the git namespace are authorized.

In the Open Integrity Project, this key fingerprint is also used as the committer’s name in the Inception Commit, establishing a cryptographic root of trust.

Use the following command to retrieve the key fingerprint of a repository’s Inception Commit:

```sh
git -C ./new_open_integrity_repo log --format="%GK" -1 $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```

**How It Works:**
- `git log` retrieves commit history and formats output based on the provided format string.
- `--format="%GK"` extracts and displays the **GPG key fingerprint** used to sign the commit.
- `-1` ensures that **only the most recent commit** (or the one specified) is shown.
- `$(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)` dynamically retrieves the **first commit hash**, ensuring that the command inspects the **Inception Commit**.

**Use Cases:**
- **Verify the signing key** used for the Inception Commit.
- **Ensure cryptographic integrity** by checking that the commit was signed with the correct key.
- **Confirm Open Integrity Project compliance**, ensuring that all commits originate from an **authorized key**.

---

## **Find the Committer of the Inception Commit**

```sh
git -C ./new_open_integrity_repo log --format="%cn <%ce>" -1 $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw <ChristopherA@LifeWithAlacrity.com>
```

**How It Works:**
- `git log` retrieves commit history and allows formatted output.
- `--format="%cn <%ce>"` extracts and displays only the **committer's name and email**.
- `-1` ensures that only **one commit** is shown.
- `$(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)` dynamically fetches the **first commit hash**, ensuring the correct commit is targeted.

### **Use Case**
- Identifies **who committed** the inception commit in the repository.
- Assists in tracking the **initial committer’s identity** for auditing or documentation.
- Required for merging a branch when the **author differs from the committer**.
- If the repository adheres to **Open Integrity** specifications, the committer name should be the **thumbprint of the committer’s SSH key**.

---

## **Understanding `--local` vs. `--global` Allowed Commit Signers**

- **Local Configuration (`--local`)**  
  When you set the allowed commit signers file **for a specific repository**, you must use:
  ```sh
  git config --local gpg.ssh.allowedSignersFile .repo/config/verification/allowed_commit_signers
  ```
  - This setting is stored in `.git/config`, affecting only the **current repository**.
  - **Not shared when cloning**: Each user must configure this manually after cloning.

- **Global Configuration (`--global`)**  
  To apply a single allowed commit signers file to **all repositories**, use:
  ```sh
  git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
  ```
  - This is stored in `~/.gitconfig`, making it the **default for all repositories**.
  - Useful when working across multiple repositories **with the same signing policy**.

---

## **Use Cases**
- **Verify which SSH keys are authorized** for commit signing in your repository.
- **Ensure Open Integrity Project compliance** by confirming that only trusted signers are permitted.
- **Troubleshoot signature verification issues** by checking if an expected key is missing.
- **Easily update or replace entries** for commit signers when needed.

# **Viewing Allowed Commit Signers in Git**

To check which SSH keys are currently authorized for signing commits, run:

```sh
cat "$(git config --get gpg.ssh.allowedSignersFile)"
```

## **Example Output**
```sh
@ChristopherA namespaces="file,git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+YMv6FoadhtecFcrESpq5ZIhxZzYIKky8C+3Xk0Sy sign_id_ed25519-athena.local-christophera
```

## **How It Works**
- `git config --get gpg.ssh.allowedSignersFile` retrieves the **file path** where Git expects the list of allowed signers.
  - Git first checks the **local repository configuration** (`git config --local`).
  - If not set, it falls back to the **global configuration** (`git config --global`).
- `cat "$(git config --get gpg.ssh.allowedSignersFile)"` displays the **full list of trusted SSH keys**, each mapped to a specific Git namespace.

## **How Git Uses the Allowed Signers File**
When verifying a signed commit, Git:
1. Extracts the **signer's SSH public key** from the commit signature.
2. Checks if the key is listed in the **allowed signers file**.
3. Confirms that the entry includes the **`git` namespace** (if required).
4. If all conditions are met, Git considers the signature **valid**.

In the example above, any commit signed with:
```sh
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+YMv6FoadhtecFcrESpq5ZIhxZzYIKky8C+3Xk0Sy
```
will be **accepted as valid** if:
- The key exists in the allowed signers file specified by `git config --get gpg.ssh.allowedSignersFile`.
- The corresponding entry includes the `git` namespace.

## **Limitations of `git verify-commit`**
Running:
```sh
git verify-commit -v <commit-hash>
```
produces output like:
```sh
gpg: Good signature from "@ChristopherA"
```
However, **Git does not enforce that `@ChristopherA` matches the commit author or committer**. This means:
- **A commit can be signed by one identity but authored by another.**
- **Git only checks if the signature is cryptographically valid and in the allowed signers list.**
- It does **not** verify the identity of `@ChristopherA` against the commit’s metadata.

This ensures **only locally trusted commit signers** are recognized while maintaining strong verification.

## **Additional Verification Steps**
For stricter identity validation, manually cross-check `@ChristopherA` or the public key against:  
- The **GitHub Signing Key API** to verify that the signing key belongs to the expected user.  
- Internal **organization records** or **key management systems** to confirm key ownership.  
- **Peer-to-peer** trust models.

🔹 **Note:** The **comment field** (e.g., `sign_id_ed25519-athena.local-christophera`) at the end of each allowed signers entry is **arbitrary metadata**. It may contain a filename, a date, or other identifiers, but **Git does not enforce a standard format** for it. There are **no official Open Integrity specifications** for how it should be structured (yet), so organizations may define their own conventions for tracking signers.

---

## **View What an Entry for `allowed_signers` Should Look Like Based on `user.signingkey`**
To generate the **expected format** for an entry based on the configured signing key, run:

```sh
printf "%s namespaces=\"file,git\" %s %s\n" \
  "@$(git config --get user.name)" \
  "$(ssh-keygen -y -f "$(git config --get user.signingkey)")" \
  "$(basename "$(git config --get user.signingkey)")"
```

**Example Output:**

```sh
@ChristopherA namespaces="file,git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+YMv6FoadhtecFcrESpq5ZIhxZzYIKky8C+3Xk0Sy sign_id_ed25519-athena.local-christophera
```
Use this to verify whether an entry already exists in the `allowed_signers` file.

---

## **Replace an Entry in `allowed_signers` Based on `user.signingkey`**
If you need to **update an existing entry** in the `allowed_signers` file, use:

```sh
SIGNERS_FILE=$(git config --get gpg.ssh.allowedSignersFile) && \
printf "%s namespaces=\"file,git\" %s %s\n" \
  "@$(git config --get user.name)" \
  "$(ssh-keygen -y -f "$(git config --get user.signingkey)")" \
  "$(basename "$(git config --get user.signingkey)")" | \
tee -a "$SIGNERS_FILE" | sort -u -o "$SIGNERS_FILE" && \
unset SIGNERS_FILE
```

**Explanation:**
- `grep -v "$(basename "$(git config --get user.signingkey)")\$"` → Removes any existing entry matching the signing key.
- The new entry is **appended** to a temporary file.
- The temporary file is **moved back** to replace the original `allowed_signers` file.

---

## **Append a New Entry to `allowed_signers` If It Doesn’t Already Exist**
If the entry **isn’t already in the file**, this command **appends it**:

```sh
SIGNERS_FILE=$(git config --get gpg.ssh.allowedSignersFile)
ENTRY=$(printf "%s namespaces=\"file,git\" %s %s\n" \
  "@$(git config --get user.name)" \
  "$(ssh-keygen -y -f "$(git config --get user.signingkey)")" \
  "$(basename "$(git config --get user.signingkey)")")

grep -qxF "$ENTRY" "$SIGNERS_FILE" || echo "$ENTRY" >> "$SIGNERS_FILE"
```

**Explanation:**
- Retrieves the allowed signers file path `(SIGNERS_FILE=$(git config --get gpg.ssh.allowedSignersFile))`.
- Generates the allowed signers entry.
- Appends it using `tee -a` to ensure it's added to the file.
- Removes duplicates using `sort -u -o "$SIGNERS_FILE"` (ensuring a clean list).
- Unsets SIGNERS_FILE to avoid polluting the shell environment.

---

## **Verify the Signature of the Inception Commit**

```sh
git -C ./new_open_integrity_repo verify-commit $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
Good "git" signature for ChristopherA@LifeWithAlacrity with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```

**How It Works:**
- `git verify-commit` checks the **cryptographic validity** of a signed commit.
- `$(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)` dynamically retrieves the **first commit hash** (the Inception Commit).
- If the commit is correctly signed, Git returns `"Good 'git' signature"` along with the **signer’s identity and key fingerprint**.

**Use Cases:**
- Ensure the **Inception Commit** is properly signed.
- Verify the commit was created by an **authorized key** in compliance with **Open Integrity Project specifications**.
- Prevent tampering by confirming that the commit remains **unaltered since it was signed**.

For more detailed information about the commit, including its tree hash, author, committer, and full message, use `-v`:

```sh
git -C ./new_open_integrity_repo verify-commit -v $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
author @ChristopherA <ChristopherA@LifeWithAlacrity.com> 1739870660 +0000
committer SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw <ChristopherA@LifeWithAlacrity.com> 1739870660 +0000

Initialize repository and establish a SHA-1 root of trust

Signed-off-by: @ChristopherA <ChristopherA@LifeWithAlacrity.com>

This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers.
Good "git" signature for @ChristopherA with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```

To see what the error message would be if the allowed signer files doesn't exist:

```sh
repo="./new_open_integrity_repo"; signers_key="gpg.ssh.allowedsignersfile"
current_signers=$(git -C "$repo" config --local --get "$signers_key")
touch /tmp/empty_signers; git -C "$repo" config --local "$signers_key" /tmp/empty_signers
git -C "$repo" verify-commit $(git -C "$repo" rev-list --max-parents=0 head); [ -n "$current_signers" ] \
&& git -C "$repo" config --local "$signers_key" "$current_signers" \
|| git -C "$repo" config --unset "$signers_key"
```

**Example Output:**
```
Good "git" signature with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
No principal matched.
```

---

## **Override Global & Local Allowed Signers Without Changing Git Config**
Instead of modifying your **`git config` settings** (either --local or --global), you can **override the allowed signers file** directly when verifying the commit:

```sh
GIT_ALLOWEDSIGNERS=./new_open_integrity_repo/.repo/config/verification/allowed_commit_signers \
git -C ./new_open_integrity_repo verify-commit $(git -C ./new_open_integrity_repo rev-list --max-parents=0 HEAD)
```

**How It Works:**
- `GIT_ALLOWEDSIGNERS=<file>` **temporarily overrides** the allowed signers file for this command.
- This means **you don’t need to change any `--global` or `--local` settings** in Git.
- The specified file (e.g., `.repo/config/verification/allowed_commit_signers`) **must exist** and contain valid signer entries.

**When to Use This:**
- **One-time verification** without modifying Git config.
- **Testing different allowed signers files** without changing repo-wide settings.
- **Ensuring a specific file is used** even if a different one is configured globally or locally.

---

## **Retrieve GitHub Username in Zsh (with Fallbacks)**

The Open Integrity Project Project encourages the use of **developer public nicknames** over real names, though both are allowed. This convention balances **privacy** (not requiring a real name) with **accountability** (associating commits with a public identity). 

This Zsh one-liner retrieves your **GitHub public nickname** from `gh` CLI config data if available. If not, it falls back to `git config --get github.user`, and if that is also missing, it defaults to `git config --get user.name` (which is often a real name).

```sh
while IFS=: read -r k v; do [[ $k == user ]] && echo ${v# } && exit; done < ~/.config/gh/hosts.yml || git config --get github.user || git config --get user.name
```

**Example Output:**
```sh
ChristopherA
```

**How It Works:**
- Reads `~/.config/gh/hosts.yml` and extracts the `user:` field.
- If found, it prints the value and **exits immediately**.
- If not found, it tries `git config --get github.user`.
- If that is also missing, it defaults to `git config --get user.name`.

**Use Cases:**
- Ensures scripts retrieve a **consistent GitHub identity**.
- Works **entirely in Zsh** without requiring `sed` or `awk`.
- Supports **privacy-conscious workflows** by prioritizing public nicknames.
- If you want this to be your your git `user.name` then `git config user.name `

---

## **Set Git `user.name` Based on GitHub Username (with Fallbacks)**  

In the Open Integrity Project, developers often prefer using **public nicknames** instead of real names for Git commits. This conventions enhances developer **privacy** while maintaining **accountability** by linking their commits to a verifiable public account, but not necessarily an identifiable natural person.

**Set `user.name` for This Repository Only:**
Run the following command inside your repository to set `user.name` **locally** in each repository:

```sh
git config --local user.name "@$(while IFS=: read -r k v; do [[ $k == user ]] && echo ${v# } && exit; done < ~/.config/gh/hosts.yml || git config --get github.user || git config --get user.name)"
```

**Note:**  
_Local Git configurations (such as `user.name` set with `--local`) are stored in `.git/config` and **are not included when the repository is cloned**. Each user must configure their own settings manually after cloning._

**How It Works:**
1. **Checks `~/.config/gh/hosts.yml`** for the `user:` field (GitHub CLI username).
2. If not found, **falls back to `git config --get github.user`** (GitHub username stored in Git).
3. If neither exists, **defaults to `git config --get user.name`** (often a real name).
4. NOTE: This works **entirely in Zsh**, avoiding external tools like `awk` or `sed`. A Bash 3.2+ version TBD.

**Set `user.name` Globally:**
To apply this setting across **all repositories**, use:
```sh
git config --global user.name "@$(while IFS=: read -r k v; do [[ $k == user ]] && echo ${v# } && exit; done < ~/.config/gh/hosts.yml || git config --get github.user || git config --get user.name)"
```
This updates your global `~/.gitconfig`, making it the **default for all Git repositories**.

**Why Use This?**
- Ensures **your commits use a developer nickname** rather than your real name.
- Enables **different identities for different repositories** when needed.
- Supports **Open Integrity Project best practices** by keeping commit authorship tied to a **public and verifiable account** not a personal identity.

**Use Cases:**
- Use **distinct nicknames per repository** (e.g., "@OpenSourceDev" for public projects, "@WorkDev" for private repos).
- Maintain **consistent identity** between your public profile and Git commits.
- Prevent exposure of **your real name** when contributing to open-source projects.

This command ensures Git **automatically selects the best available source** for your username, keeping your commits aligned with your preferred identity.

## **Check Git Configuration for SSH Signing**

A CLI one-liner (works in ZSH and Bash 3.2+) to check if your `git config` configuration is correctly set up for SSH signing of commits:

```sh
( git config --get user.name > /dev/null && \
  git config --get user.email > /dev/null && \
  git config --get user.signingkey > /dev/null && \
  git config --get gpg.format > /dev/null && \
  git config --get commit.gpgSign > /dev/null && \
  git config --get gpg.ssh.allowedSignersFile > /dev/null && \
  ssh-keygen -E sha256 -lf "$(git config --get user.signingkey)" > /dev/null ) && \
  echo "✅ All required Git config settings for SSH signing in this $(basename "$PWD") directory are correctly set." || \
  echo -e "❌ Error: Missing or invalid Git settings. Ensure you have these configured (either --global for all repositories, or --local for a specific repository):\n
  git config --global user.name 'Your Name'\n
  git config --global user.email 'your@email.com'\n
  git config --global user.signingkey '/path/to/your/private/key'\n
  git config --global gpg.format ssh\n
  git config --global commit.gpgSign true\n
  git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers"
```

**How It Works:**
- Runs a series of **Git configuration checks** to ensure **SSH signing is correctly set up**.
- If all required settings are present, it prints a ✅ **success message**.
- If any setting is missing or incorrect, it prints a ❌ **detailed error message with setup instructions**.

### **Use Case**
- Ensures that Git is correctly **configured for SSH-based signing**, a requirement for the Open Integrity Project.
- Helps debug signing issues **before attempting to create a repository**.

---

## **ZSH One-Liner: Create and Sign an Open Integrity Repository Inception Commit**

Assuming your `git config --global` configuration is correctly set up (see the previous one-liner), this command **(for the ZSH shell)** will create a new repository and sign its initial **Inception Commit** according to Open Integrity Project specifications.

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


**How It Works:**
- **Checks if the repository already exists**; exits early if it does.
- **Creates a new repository** (`new_open_integrity_repo`).
- **Configures Git signing settings** and generates an **SSH fingerprint-based committer identity**.
- **Commits an empty inception commit** that **establishes a root of trust**.
- **Prints success or failure messages** after execution.

### **Use Case**
- A **fully automated** command for creating a **new Open Integrity-compliant Git repository**.
- Ensures **cryptographic integrity** from the first commit.
- **Prevents accidental overwrites** and **verifies correct Git signing configuration**.

## **Bash 3.2+ One-Liner: Create and Sign an Open Integrity Repository Inception Commit**

Assuming your `git config --global` configuration is correctly set up (see the previous one-liner), this command **(for the ZSH shell)** will create a new repository and sign its initial **Inception Commit** according to Open Integrity specifications.

```bash
[ -d "$(pwd)/new_open_integrity_repo/.git" ] && echo "Error: Repository 'new_open_integrity_repo' already exists." && kill -INT $$ || mkdir -p "$(pwd)/new_open_integrity_repo" && git -C "$(pwd)/new_open_integrity_repo" init > /dev/null; GIT_AUTHOR_NAME="$(git config user.name | tr -d '\n')"; GIT_AUTHOR_EMAIL="$(git config user.email | tr -d '\n')"; GIT_COMMITTER_NAME="$(ssh-keygen -E sha256 -lf "$(git config user.signingkey | tr -d '\n')" | awk '{print $(NF-1)}')"; GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"; GIT_AUTHOR_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"; GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"; COMMIT_MESSAGE="Initialize repository and establish a SHA-1 root of trust.\n\nSigned-off-by: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>\n\nThis key also certifies future commits' integrity and origin. Additional keys can be authorized by creating a \`./.repo/config/verification/allowed_commit_signers\` file, initially signed by this repo’s inception key."; env GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" GIT_AUTHOR_DATE="$GIT_AUTHOR_DATE" GIT_COMMITTER_DATE="$GIT_COMMITTER_DATE" git -C "$(pwd)/new_open_integrity_repo" commit --allow-empty --no-edit --gpg-sign -m "$COMMIT_MESSAGE" && echo "Success: 'new_open_integrity_repo' repository successfully initialized." || echo "Error: Failed to initialize repository. Check Git settings and signing key."
```

ISSUE: This works, but there are still extra `\n\n` that the zsh script does not have. TBD.

**How It Works:**
- **Detects if the repository already exists**  
  - If yes: **Stops execution using `kill -INT $$`** (prevents `exit 1` from closing the shell).
- **Creates a new repository** (`new_open_integrity_repo`).
- **Assigns Git author and committer details**, ensuring **the committer identity is based on SSH fingerprints**.
- **Signs an empty inception commit** that acts as a **cryptographic root of trust**.

### **Interactive vs. Non-Interactive Shell Handling**
- `kill -INT $$` ensures the script **exits cleanly in both interactive and non-interactive shells**:
  - **Interactive (`bash -i`)** → Stops execution without closing Bash.
  - **Non-Interactive (`bash -c`)** → Terminates the script cleanly.

### **Use Case**
- Works **even in older Bash 3.2 environments** (e.g., early macOS default shell).
- Automates **Git repository initialization** and ensures **cryptographic security**.
- Ensures the first commit is **signed and verified**.

### **Why Two Separate One-Liners?**
| Feature | **Zsh One-Liner** | **Bash 3.2+ One-Liner** |
|---------|------------------|------------------|
| Fully **automated cryptographic root of trust** | ✅ Yes | ✅ Yes |
| Works in **Zsh** (default current macOS)| ✅ Yes | ⚠ No |
| Works in **Bash 3.2+** (default Linux and older macOS)| ⚠ No | ✅ Yes |
| Handles **interactive & non-interactive shells** | ✅ Yes | ✅ Yes |
| Stops if repo exists **without closing the shell** | ✅ Yes | ✅ Yes |

### **Final Thoughts**
- If you're using **Zsh**, use the **Zsh One-Liner**.
- If you're on **Bash 3.2+ (e.g., Linux or older macOS default shell)**, use the **Bash One-Liner**.
- **Both scripts ensure cryptographic integrity** from the **first commit**.
- **Both handle interactive and non-interactive shells properly**.

**Now your Open Integrity git repository is structured, clean, and fully optimized for both Bash and Zsh!**


### **Instructions to Push a Local Repository to GitHub in the OpenIntegrityProject Organization**

1. **Authenticate with GitHub**  
   Ensure you are logged in with GitHub CLI:  
```sh
gh auth login

2. **Rename the repo**
```sh
typeset -g GITHUB_COMMUNITY_OR_USER="<your_github_destination>"
typeset -g NEW_GITHUB_REPO_NAME="<your_new_repo_name>"
mv ./new_open_integrity_repo ./$NEW_GITHUB_REPO_NAME
```

3. **Create the Repository on GitHub**  

Run the following command to create the repository under your user name, or communnity name, or the `OpenIntegrityProject` with useful defaults:  

```sh
cd $NEW_GITHUB_REPO_NAME
gh repo create $GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME \
  --public \
  --source=. \
  --remote=origin \
  --push 
```

4. **Verify and Set Upstream Remote**  

Check if a remote already exists:  

```sh
git remote -v
```
If a remote named `origin` already exists and is incorrect, remove it:  
```sh
git remote remove origin
```
Manually add the correct remote if needed:  
```sh
git remote add origin https://github.com/$GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME.git
```

5. **Ensure the Branch is Set to Main**  
  ```sh
  git branch -M main
  ```

6. **Push to GitHub and Set Upstream**  
  ```sh
  git push --set-upstream origin main
  ```

7. **Verify Repository on GitHub**  
   ```sh
   gh repo view $GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME
   ```
   Or visit:  
   ```
   https://github.com/$GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME
   ```
8. Change GitHub Repository Setting

You can use `gh` to define useful GitHub repository settings:

gh repo edit $GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME \
  --description "A useful description for this project." \
  --homepage "https://github.com/$GITHUB_COMMUNITY_OR_USER/$NEW_GITHUB_REPO_NAME" \
  --enable-issues \
  --enable-discussions \
  --enable-projects \
  --delete-branch-on-merge
Now the repository is created, configured, and linked with GitHub.

NOTE: You might NOT want to set `--delete-branch-on-merge` for a repo under Inception Authority until you and your contributors have learned PR and merge best practices for signed commits. If the branches are not deleted, and there is a problem with the merge, you can rewind and try again.

9. Unset

Keep your global environment clean.

```sh
unset GITHUB_COMMUNITY_OR_USER
unset NEW_GITHUB_REPO_NAME
```

---
---

## Old Misc.

# Remove any old git relics — we are creating an empty commit for a new identifier
    rm -rf ./.git
    git init # --object-format=sha256


# Load the first line from the SSH key file
    read -r line < ~/.ssh/id_sign_ed25519_${INCEPTION_CREATOR_NICK}.local-admin-2024-04-27@github.com.pub

# Extract the first two fields only (key type and key data)
    INCEPTION_CREATOR_SSH_PUB_KEY=$(echo $line | awk '{print $1, $2}')



# Construct the entry for the allowed_signers file
    entry="$INCEPTION_CREATOR_NICK $INCEPTION_CREATOR_SSH_PUB_KEY # Inception key authorized on $(date -u +'%Y-%m-%d %H:%M:%S %Z')"

# Write the entry to the allowed_signers file
    echo $entry > ./_repo:allowed_commit_signers

# Configure these local to this repo
    git config --local gpg.ssh.allowedSignersFile ./_repo:allowed_commit_signers
    git config --local gpg.format ssh        
    git config --local commit.gpgsign true
    git config --local tag.gpgsign true



git verify-commit $REPO_ID
echo "Repository SHA-256 DID (based on inception commit)" $REPO_DID
gh repo create my-project --private --source=. --remote=upstream
