# GitLab PAT Setup (Scoped Per GitLab Instance)


This guide ensures that **each GitLab instance** has its **own Personal Access Token (PAT)** stored securely in **macOS Keychain**, and that those tokens are **only used for their respective GitLab hosts** — never GitHub.


Git automatically scopes credentials by **protocol + host**, so multiple GitLab instances are fully supported.


---


## ⚠️ Critical Note: UI URL vs Clone URL (READ THIS FIRST)


A GitLab instance may use **different hostnames** for:
- The **web UI** you log into
- The **Git endpoint** used to clone repositories


🔑 **Your PAT must be associated with the host used for cloning repositories — NOT necessarily the UI URL.**


Example:
- GitLab UI:        https://second.git.com
- Clone URL host:  https://sync.git.com


In this case:
- You log into **second.git.com** to create the PAT
- You store the PAT in Keychain under **host=sync.git.com**


❗ If you scope the PAT to the UI host instead of the clone host, Git will continue to prompt for credentials.


Always confirm the correct host by checking the clone URL:
  git clone https://<HOST>/group/repo.git


---


## ✅ Step 1: Create a Personal Access Token (PAT)


For **each GitLab instance**, generate a PAT:


1. Log into the GitLab UI
   - `https://gitlab.com`
   - `https://second.git.com`


2. Navigate to:
   **User Settings → Access Tokens**


3. Create a token with:
   - **Name:** something descriptive (e.g. `macbook-git`)
   - **Expiration:** recommended
   - **Scopes:**
     - `read_repository`
     - `write_repository`
     - `api` (only if required)


4. Copy the token — you’ll store it next.


---


## 🔐 Step 2: Store PAT for `gitlab.com`


```bash
printf "protocol=https\nhost=gitlab.com\nusername=your-gitlab-username\npassword=your-gitlab-pat\n" | git credential-osxkeychain store
```


Replace:
- `your-gitlab-username`
- `your-gitlab-pat`


This credential is now **strictly scoped to `gitlab.com`**.


---


## 🔐 Step 3: Store PAT for the Clone Host (Example: `sync.git.com`)


⚠️ Use the **clone URL host**, NOT the UI host


```bash
printf "protocol=https\nhost=sync.git.com\nusername=your-test-gitlab-username\npassword=your-test-gitlab-pat\n" | git credential-osxkeychain store
```


This creates a **separate Keychain entry** that will **only** be used when Git talks to `sync.git.com`.


Tokens will never cross hosts — Git treats these as entirely different credentials.


---


## ⚙️ Step 4: Ensure `credential.useHttpPath` Is Disabled


Credentials should be scoped **by host**, not by repository path.


```bash
git config --global --unset credential.useHttpPath
```


Verify it’s unset:


```bash
git config --global credential.useHttpPath
# should return nothing
```


---


## 🔍 Step 5: Verify Credentials Are Correctly Scoped


### Confirm GitHub Has No Stored Credentials


```bash
git credential-osxkeychain get
```

Then enter:

protocol=https
host=github.com


✔️ **Expected:** no password returned


---


### Verify `gitlab.com`


```bash
git credential-osxkeychain get
```

Enter:

protocol=https
host=gitlab.com

✔️ **Expected:** your `gitlab.com` username + PAT


---


### Verify Clone Host (Example: `sync.git.com`)


```bash
git credential-osxkeychain get
```

Enter:

protocol=https
host=sync.git.com

✔️ **Expected:** your clone-host username + PAT


---


## 🧠 How This Works (Important Mental Model)

Git credentials are scoped by:

protocol + host

That means:


| Host           | Credential Used |
|----------------|-----------------|
| gitlab.com     | GitLab PAT #1   |
| sync.git.com   | GitLab PAT #2   |
| github.com     | Nothing (unless you add one) |


No collisions. No overrides. No accidental leaks.


---


## ✅ You’re Done


You now have:
- Separate PATs per GitLab instance
- Correct scoping based on **clone URL hosts**
- Secure storage in macOS Keychain
- Zero risk of GitHub accidentally using a GitLab token
- A setup that scales cleanly to **any number of GitLab hosts**
