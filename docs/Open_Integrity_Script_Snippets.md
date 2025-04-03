# Open Integrity Project: Inception Script Snippets

> - _did: `did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/blob/main/docs/Open_Integrity_Script_Snippets.md`_
> - _github: `https://github.com/OpenIntegrityProject/core/blob/main/docs/Open_Integrity_Script_Snippets.md`_
> - _copyright: ©2025 by Blockchain Commons LLC, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)_
> - _created: 2025-02-02 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>_
> - _contributitions-from: @ShannonA <Shannon.Appelcline@gmail.com>_
> - _last-updated: 2025-04-01 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.01-blue.svg)](CHANGELOG.md)

This document contains a number of useful one-liner Git commands for evaluating and managing the inception commit (the first commit in a repository) based on the Open Integrity Project's specifications.

They are generally supported in `zsh`, though some may also be compatible with `bash 3.2`

**Contents:**

* [Get Your Signature Ready](#Get-Your-Signature-Ready)
* [Get GH Ready](#Get-GH-Ready)
* [Create a Repo with Inception Commit](#Create-a-Repo-with-Inception-Commit)
* [Check the Inception Commit](#Check-the-Inception-Commit)
* [Check Other Commits](#Check-Other-Commits)
* [Set & Check Allowed Signers](#Set-amp-Check-Allowed-Signers)
* [Set & Retrieve Username](#Set-amp-Retrieve-Username)
* [Create a Repo (Redux)](#Create-a-Repo-Redux)

## Get Your Signature Ready

The following one liners demonstrate how to get ready to use Open Integrity.

---

### Install Git

Obviously, you must install Git, which you probably already have. If not, see [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for your OS.

Be sure you've set your identity variables:
```
git config --global user.name "YOUR NAME"
git config --global user.email YOUR EMAIL
git config --global github.user YOURID
```
You can check what you've set already with the command `git config --global -l`.

---

### Prepare Your Signatures

In order to create or use Open Integrity repos, you must have keypairs on your machine (or machines) that can be used to sign commits. If you don't, you can generate one with `ssh-keygen`.

```sh
ssh-keygen -t ed25519 -f ~/.ssh/sign_id_ed25519-`hostname`-`whoami`-`date "+%Y-%m-%d"`@github
```
The above command creates a new `ed25519` keypair with a label for your user name, machine, the date, and its usage (`@github`). In the future having this metadata as part of the filename will allow you to easily identify what this keypair was used for.

Note that you'll be asking for a password when you create your signature. This is the password you'll later have to type in to use your key, so be sure it's something that's secure, but that you will remember.

The resulting keys can be found under `~/.ssh` and look something like this:
```sh
sign_id_ed25519-GuthrieMachine.local-Bob-2025-03-04@github
```

**How It Works:**
* `ssh-keygen` creates a keypair.
* `-t ed25519` chooses the type ed25519.
* `-f` stores the keypair in the selected filename.
* ~/.ssh/sign_id_ed25519-`hostname`-`whoami`-`date "+%Y-%m-%d" creates a file name based on the machine name, user name, and date.

---

### Upload Your Signature

You can add your new signature to GitHub at [http://github.com/settings/ssh/new](http://github.com/settings/ssh/new). Just copy the contents from the `.pub` file, which you can do with the following command:
```
pbcopy < ~/.ssh/sign_id_ed25519-`hostname`-`whoami`-`date "+%Y-%m-%d"`@github.pub
```
Then paste that into the GitHub page. Give the GitHub entry a name based on your local machine (e.g., `GuthrieMachine`) and be sure to mark it as a signing key not an auth key.

---

### Set Your Git Signing Variables

Open Integrity uses SSH signing. To prepare GitHub to use it, you must: tell Git to use SSH signing; tell it to use your signing file; and tell it to always sign commits and tags. This is all done using the `--global` config option for Git, meaning these choices will be made for all repos. (Obviously, you could use `--local` instead if you only wanted to apply this to some repos.)
```
git config --global gpg.format ssh ; git config --global commit.gpgsign true; git config --global tag.gpgsign true; git config --global user.signingkey ~/.ssh/sign_id_ed25519-`hostname`-`whoami`-`date "+%Y-%m-%d"`@github.pub
```
Note that for this to properly work you should enter it immediately after creating your keypairs, above. If some time has passed (or you've changed your username or account name), instead check your precise filename in `~/.ssh` and substitute that for "~/.ssh/sign_id_ed25519-\`hostname\`-\`whoami\`-\`date "+%Y-%m-%d"\`@github.pub".

**How It Works:**
* `git config` can be used to set a variety of variables either in the `global` (all your Git repos) or `local` (just a specific Git repo) name space.

---

### Create Your Initial Git Allowed Signers

Git uses an `allowed_signers` file to list signers who are authorized--either globally or for a specific repo. The following adds your new signature to your `allowed_signers` global file: 

```
touch ~/.ssh/allowed_signers ; git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
; echo "$(git config --get user.email) namespaces=\"git\" $(cat `git config --get user.signingkey`)" >> ~/.ssh/allowed_signers
```

**How It Works:**
* An `allowed_signers` file is created.
* `git config` sets its `allowedSignersFile` to be that file.
* Your signing key is placed into that file, for use in the "git" namespace, linked to the email you set in Git.

---

### View Your Git Variables

At this point, you can check that all the signing related variables have been entered correctly:

```
git config -l --global
```
You should see the following (likely among other variabless that have been set):
```
user.name=Bob
user.email=bob@bob.com
user.signingkey=/Users/Bob/.ssh/sign_id_ed25519-GuthrieMachine.local-Bob-2025-03-04@github
github.user=bob
gpg.format=ssh
commit.gpgsign=true
tag.gpgsign=true
gpg.ssh.allowedsignersfile=/Users/Bob/.ssh/allowed_signers
```

**How It Works:**
* `git config -l --global` lists your global Git variables.

---

### Verify Git Configuration for SSH Signing

The following, more extensive script will look at all of your configuration information and tell you whether you're ready to sign or not.

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
  git config --global gpg.ssh.allowedSignersFile ~/.ssh/
  "
```

**How It Works:**
- Runs a series of **Git configuration checks** to ensure **SSH signing is correctly set up**.
- If all required settings are present, it prints a ✅ **success message**.
- If any setting is missing or incorrect, it prints a ❌ **detailed error message with setup instructions**.

#### Use Case:
- Ensures that Git is correctly **configured for SSH-based signing**, a requirement for the Open Integrity Project.
- Helps debug signing issues **before attempting to create a repository**.

## Get GH Ready

Some commands also require the use of `gh`, the [GitHub CLI](https://github.com/cli/cli). 

---

### Install GH

See [GH Installation](https://github.com/cli/cli?tab=readme-ov-file#installation) for ways to install GH and then use your favorite package installer.

---

### Authorize GH

You will need to authorize your GitHub CLI. The easiest way to do so is:
```
gh auth login
```
You'll be asked to authenticate the CLI. If you're using GitHub, the easiest method is to auth with a web browser:
```
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser
```
This will take you to a web page. Once you OK the authorization, a one-time code will print at your command line and you must enter it into the browser.

At some points in the future, you may need to add permissions to undertake certain commands. The command line will provide you with a specific `gh auth refresh` command, which will repeat this process to add the required permissions.

---

### Check Your Keys

You can now check your keys uploaded to GitHub with the following command:
```
gh ssh-key list 
```
It will list out information on each auth and signing key.

(This will likely require the addition of `admin:ssh_signing_key` permissions to your GitHub CLI, which will be automatically requested and managed for you.)


## Create a Repo with Inception Commit

You're now ready to start using Open Integrity. At this point you want to grab the core repo and then use its script to create a new Open Integrity repo.

---

### Download the Core Repo

The core Open Integrity repo contains scripts (snippets) and documentation.
```
git clone https://github.com/OpenIntegrityProject/core.git
```

---

### Create an Open Integrity Repo

You're now ready to create an Open Integrity repo with an inception commit:
```
core/src/create_inception_commit.sh --repo OpenIntegrityTest
```
You'll be asked to enter your signing password, and then should see something like the following, hopefully with all of the ✅s showing a clean setup.

```
[main (root-commit) dd5a70c] Initialize repository and establish a SHA-1 root of trust
 Author: Bob <bob@bob.com>
✅ Repository initialized with signed inception commit at ./OpenIntegrityTest
Inception commit: ed6dd0268250a30cfd98b501b89b6ec23a9df2bd
✅ Commit signature verified successfully:
Good "git" signature with ED25519 key SHA256:1oCAdW5UY7LtbO723rCxI3YqfFDWf2SqJpu6EebgaKM
Repository DID: did:repo:ed6dd0268250a30cfd98b501b89b6ec23a9df2bd
```

---

### Push Your Open Integrity Repo

If you're going to use your Open Integrity repo for more than testing, you'll eventually want to upload it. If you're using GitHub, this is easily done with the `gh` command:
```
gh repo create
```
Afterward, you'll be given a string of choices that will allow you to create a new repo on GitHub. You will want to "Push an existing local repository to GitHub" and then type in your directory name, such as "OpenIntegrityTest". Afterward, the default options are likely right, as you chose your repo name and choose the owner, choose its visibility, OK the remote being called "origin", and OK push commits. The only thing you might need to add is a description.

## Check the Inception Commit

Commits are the chain in trust for your Open Integrity repo, starting with the inception commit. The following commands show how to retrieve information about that inception commit.

_All examples are assumed to be run from within the relevant repo. If you wanted to run commands outside of the repo, you would use `git`'s `-C` flag.

### Retrieve the First Commit (Inception Commit)

The inception commit is the core of Open Integrity's trust. You can look it up with the following command. (With this information in hand, you'll then be able to look up additional details on the commit.)

```sh
git rev-list --max-parents=0 HEAD 
```

**Example Output:**
```sh
115f7ab32f481ef9e360d763c5842e8415abd08f
```

**How It Works:**
- More efficient than reversing `git log`, making it ideal for large repositories.
- `rev-list` is a low-level Git command that lists commit hashes in a specified order.
- `--max-parents=0` filters for commits that have **no parents**, effectively returning only the **first commit** in the repository.
- `HEAD` typically refers to the latest commit, but with `--max-parents=0`, Git efficiently traces back to the first commit.

#### **Use Case**
- Can be embedded within `$(...)` in scripts or combined with `git show` to inspect the inception commit, as shown below.

---

### Show Committer Details of the Inception Commit

With the details of the inception commit in hand (or more specifically, with it in a `$( )`, you can look up the commiter of that inception commit. This allows you to see the original owner of the archive (as defined by their own git settings).

```sh
git log --format="%cn <%ce>" -1 $(git rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw <ChristopherA@LifeWithAlacrity.com>
```

**How It Works:**
- `git log` retrieves commit history.
- `--format="%cn <%ce>"` uses `log`'s formatting option to extract and display only the **committer's name and email**.
- `-1` ensures that only **one commit** is shown.
- `$(git rev-list --max-parents=0 HEAD)` was used in the previous example to dynamically retrieve the **first commit's hash**. Here, it ensures that `git log` inspects the inception commit.

#### **Use Case**
- Identifies **who committed** the inception commit in the repository.
- Assists in tracking the **initial committer’s identity** for auditing or documentation.
- If the repository adheres to **Open Integrity** specifications, the committer name should be the **thumbprint of the committer’s SSH key**.
- Required for merging a branch when the **author differs from the committer**.

---

### Show Full Details of the Inception Commit

The inception commit has more details. You can look up more information, including not just the original committer, but also dates, descriptions, and signatures.

```sh
git show --pretty=fuller $(git rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
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
- `$(git rev-list --max-parents=0 HEAD)` again draws on the first example to dynamically retrieve the **inception commit's hash**. Here, it ensures that `git show` inspects the inception commit.

#### **Use Case**
- Useful for verifying the **original author and committer** of the repository’s first commit.
- Helps in **auditing** and understanding the initial setup of the repository.

---

### Retrieve the Key Fingerprint Used for Signing the Inception Commit

When a commit is signed, a signature is embedded in its metadata, containing the public key from which a key fingerprint is derived.

Git verifies this fingerprint against the allowed commit signers list (configured via `git config --<global|local> gpg.ssh.allowedSignersFile <path/to/filename>`), ensuring that only trusted keys with the git namespace are authorized.

In the Open Integrity Project, this key fingerprint is also used as the committer’s name in the Inception Commit, establishing a cryptographic root of trust.

Use the following command to retrieve the key fingerprint of a repository’s Inception Commit:

```sh
git log --format="%GK" -1 $(git rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```

**How It Works:**
- `git log` retrieves commit history and formats output based on the provided format string.
- `--format="%GK"` extracts and displays the **GPG key fingerprint** used to sign the commit.
- `-1` ensures that **only the most recent commit** (or the one specified) is shown.
- `$(git rev-list --max-parents=0 HEAD)` dynamically retrieves the **first commit hash**, ensuring that the command inspects the **Inception Commit**.

**Use Cases:**
- **Verify the signing key** used for the Inception Commit (see below).
- **Ensure cryptographic integrity** by checking that the commit was signed with the correct key.
- **Confirm Open Integrity Project compliance**, ensuring that all commits originate from an **authorized key**.


### **Verify the Signature of the Inception Commit**

Besides just retrieving the fingerprint from the inception commit, you can also verify the validity of the signature.

```sh
git verify-commit $(git rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
Good "git" signature for ChristopherA@LifeWithAlacrity with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```

**How It Works:**
- `git verify-commit` checks the **cryptographic validity** of a signed commit.
- `$(git rev-list --max-parents=0 HEAD)` dynamically retrieves the **first commit hash** (the Inception Commit).
- If the commit is correctly signed, Git returns `"Good 'git' signature"` along with the **signer’s identity and key fingerprint**.

**Use Cases:**
- Ensure the **Inception Commit** is properly signed.
- Verify the commit was created by an **authorized key** in compliance with **Open Integrity Project specifications**.
- Prevent tampering by confirming that the commit remains **unaltered since it was signed**.

### **Verify the Signature of the Inception Commit with Extra Information**

For more detailed information about the inception commit, including its tree hash, author, committer, and full message, use `-v`:

```sh
git verify-commit -v $(git rev-list --max-parents=0 HEAD)
```

**Example Output:**
```sh
tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
author @ChristopherA <ChristopherA@LifeWithAlacrity.com> 1739870660 +0000
committer SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw <ChristopherA@LifeWithAlacrity.com> 1739870660 +0000

Initialize repository and establish a SHA-1 root of trust

Signed-off-by: @ChristopherA <ChristopherA@LifeWithAlacrity.com>

This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers.
Good "git" signature for @ChristopherA with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
```


---

### **Verify while Overriding Global & Local Allowed Signers Without Changing Git Config**

Commits are checked against an `allowedSignersFile`, which is set with `git config`, as described below. Instead of modifying your **`git config` settings** (either `--local` or `--global`), you can **override the allowed signers file** directly when verifying a commit.

Simply add your preferred signing file to the `GIT_ALLOWEDSIGNERS` variable.

```sh
GIT_ALLOWEDSIGNERS=./new_open_integrity_repo/.repo/config/verification/allowed_commit_signers \
git verify-commit $(git rev-list --max-parents=0 HEAD)
```

**How It Works:**
- `GIT_ALLOWEDSIGNERS=<file>` **temporarily overrides** the allowed signers file for this command.
- This means **you don’t need to change any `--global` or `--local` settings** in Git.
- The specified file (e.g., `.repo/config/verification/allowed_commit_signers`) **must exist** and contain valid signer entries.

**When to Use This:**
- **One-time verification** without modifying Git config.
- **Testing different allowed signers files** without changing repo-wide settings.
- **Ensuring a specific file is used** even if a different one is configured globally or locally.

### Verify An Error in a Commit

Here's how you could force an error by substituting in an empty signer's file:

```sh
signers_key="gpg.ssh.allowedsignersfile"
current_signers=$(git config --local --get "$signers_key")
touch /tmp/empty_signers; git config --local "$signers_key" /tmp/empty_signers
git verify-commit $(git rev-list --max-parents=0 head); [ -n "$current_signers" ] \
&& git config --local "$signers_key" "$current_signers" \
|| git config --unset "$signers_key"
```

The `No principal matched` is what reveals there's an error in the signature: the signer is not in the allowed signers file.

**Example Output:**
```
Good "git" signature with ED25519 key SHA256:a61TkTtLFGEYOmdRMbpYGkZwXw2QUrGkAWp3dok8jcw
No principal matched.
```

## Check Other Commits

For checking complete provenance of a repo, you'll also need to look at other commits.

_All examples are assumed to be run from within the relevant repo. If you wanted to run commands outside of the repo, you would use `git`'s `-C` flag.


### **List All Commits in Order (Oldest to Newest)**

You'll often want to look at more than just the inception commit. This can also be done with the `git log` command.

```sh
git log --oneline --reverse
```

**Example Output:**
```sh
115f7ab (HEAD -> main) Initialize repository and establish a SHA-1 root of trust
```

**How It Works:**
- `log` retrieves the commit history of the repository.
- `--oneline` condenses each commit into a **single-line format** (short hash + commit message), making it easier to scan.
- `--reverse` flips the order, displaying commits **from the first (oldest) to the most recent**.

#### **Use Case** 
- Useful for reviewing a repository’s history in the order it was built.

## Set & Check Allowed Signers

Open Integrity allows users to limit who can write to a repo—and checks against those limitations. This is done with the `allowedSignersFile`.

_All examples are assumed to be run from within the relevant repo. If you wanted to run commands outside of the repo, you would use `git`'s `-C` flag.

---

### Create a Local Signers Git Configuraiton

To set the allowed commit signers file **for a specific repository**, you must use:
  ```sh
  git config --local gpg.ssh.allowedSignersFile .repo/config/verification/allowed_commit_signers
  ```
  
  - This setting is stored in `.git/config`, affecting only the **current repository**.
  - **Not shared when cloning**: Each user must configure this manually after cloning.

**How It Works:**
- `config --local` sets a configuration variable for the current repo.

#### **Use Cases:**
- **Verify which SSH keys are authorized** for commit signing in your repository.
- **Ensure Open Integrity Project compliance** by confirming that only trusted signers are permitted.
- **Troubleshoot signature verification issues** by checking if an expected key is missing.

---

### Create a Global Signers Git Configuraiton

To apply a single allowed commit signers file to **all repositories**, use:
  ```sh
  git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
  ```
  - This is stored in `~/.gitconfig`, making it the **default for all repositories**.
  - Useful when working across multiple repositories **with the same signing policy**.
  - You initially set this file equal to your local signing key when you set up your Open Integrity workspace.

**How It Works:**
- `config --global` sets a configuration variable for the current repo.

#### **Use Cases:**
- **Verify which SSH keys are authorized** for commit signing in your repository.
- **Ensure Open Integrity Project compliance** by confirming that only trusted signers are permitted.
- **Troubleshoot signature verification issues** by checking if an expected key is missing.

---

### View the List of Allowed Commit Signers Configured in Git

To check which SSH keys are authorized for signing commits in your Git configuration, run:

```sh
cat $(git config --get gpg.ssh.allowedSignersFile)
```

**Example Output**
```sh
@ChristopherA namespaces="file,git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM+YMv6FoadhtecFcrESpq5ZIhxZzYIKky8C+3Xk0Sy sign_id_ed25519-athena.local-christophera
```

**How It Works:**
- `git config --get gpg.ssh.allowedSignersFile` retrieves the **file path** where allowed commit signers are stored.
- `cat $(git config --get gpg.ssh.allowedSignersFile)` displays the **list of trusted SSH keys** from that file path, each mapped to its Git namespace.

## Set & Retrieve Username

A variety of information can be retrived regarding a Git repo. This details some of the highlights

_All examples are assumed to be run from within the relevant repo. If you wanted to run commands outside of the repo, you would use `git`'s `-C` flag.

---

### **Retrieve GitHub Username (with Fallbacks)**

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
### **Set Git `user.name` Based on GitHub Username (with Fallbacks)**  

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


## Create a Repo (Redux)

The `create_inception_commit.sh` should typically be what you use to create an inception commit for a repo. The following one-line examples demonstrate some easier methods for doing so, using either the `zsh` or `bash 3.2` shell, and are offered mainly for educational purposes

## Create and Sign an Open Integrity Repository Inception Commit [ZSH]**

Assuming your `git config --global` configuration is correctly set up, this command **(for the ZSH shell)** will create a new repository and sign its initial **Inception Commit** according to Open Integrity Project specifications.

```zsh
eval "$(
  cat <<'EOF'
zsh_git_inception() {
  [ -d "$(pwd)/new_open_integrity_repo/.git" ] && echo "❌ Repo already exists." && return 1
  mkdir -p "$(pwd)/new_open_integrity_repo" && git -C "$(pwd)/new_open_integrity_repo" init > /dev/null
  SIGNING_KEY="$(git config user.signingkey)"
  GIT_AUTHOR_NAME="$(git config user.name)"; GIT_AUTHOR_EMAIL="$(git config user.email)"
  GIT_COMMITTER_NAME="$(ssh-keygen -E sha256 -lf "$SIGNING_KEY" | awk '{print $2}')"
  GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"; GIT_AUTHOR_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"; GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
  GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
  GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
  GIT_AUTHOR_DATE="$GIT_AUTHOR_DATE" GIT_COMMITTER_DATE="$GIT_COMMITTER_DATE" \
  git -C "$(pwd)/new_open_integrity_repo" -c gpg.format=ssh -c user.signingkey="$SIGNING_KEY" \
    commit --allow-empty --no-edit --gpg-sign \
    -m "Initialize repository and establish a SHA-1 root of trust" \
    -m "Signed-off-by: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>" \
    -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers."
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

#### **Use Case**
- A **fully automated** command for creating a **new Open Integrity-compliant Git repository**.
- Ensures **cryptographic integrity** from the first commit.
- **Prevents accidental overwrites** and **verifies correct Git signing configuration**.
