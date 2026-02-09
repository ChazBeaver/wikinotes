# Viewing Git PATs Stored in macOS Keychain (Corrected for Included & System Configs)

This guide explains how to view and verify Git Personal Access Tokens (PATs) stored in macOS Keychain,
accounting for split Git configs (`include` / `includeIf`) and system-level Git settings.

---

## Step 1: Understand Why `--get credential.helper` May Return Nothing

If you use multiple Git config files (e.g. `.gitconfig`, `.gitconfig.work`, `.gitconfig.personal`),
`git config --global --get credential.helper` may return nothing even though a helper is active.

This is because:
- The helper may be defined in an included file
- Or it may be defined at the system level

---

## Step 2: View the Active Credential Helper (Correct Command)

Use this command to see where Git actually gets the credential helper from:

```bash
git config --list --show-origin | grep credential.helper
```

Example output:
```
file:/Library/Developer/CommandLineTools/usr/share/git-core/gitconfig credential.helper=osxkeychain
```

This confirms Git is using `osxkeychain`, even if it is not set in your user config.

---

## Step 3: View All Credential-Related Settings

To see all credential-related configuration values and their source files:

```bash
git config --list --show-origin | grep credential
```

This reveals:
- Which file defines the helper
- Whether `credential.useHttpPath` is set
- Whether anything is overridden in included configs

---

## Step 4: Verify Stored PATs Using the Terminal (Git Helper)

Query the macOS Keychain via Git for a specific host:

```bash
git credential-osxkeychain get
```

When prompted, paste:
```
protocol=https
host=sync.gitlab.com
```

**Remember that the `host` is the link/address in which repos are cloned from; not the web ui main address!**


If a PAT exists, Git will return the username and token.

---

## Step 5: Verify Stored PATs Using the Terminal (Keychain CLI)

You can also query the Keychain directly:

```bash
security find-internet-password -s sync.gitlab.com -g
```
Triggered behavior:
- Prompts for macOS login password
- Prints the stored PAT under `password:`

This command is read-only and does not modify credentials.

---

## Step 6: Remove a Stored PAT (Optional)

To remove a PAT for a specific host using the terminal:

```bash
git credential-osxkeychain erase
protocol=https
host=sync.gitlab.com
```

**Remember that the `host` is the link/address in which repos are cloned from; not the web ui main address!**


Press Enter twice — no output indicates success.

---

## Important Notes

- Git credentials are scoped by `protocol + host`
- PATs apply only to HTTPS, not SSH
- SSH authentication uses SSH keys
- System Git config may define defaults even if user config does not

---

## Summary

If `git config --global --get credential.helper` returns nothing:
- Use `git config --list --show-origin` instead
- Look for system-level or included config sources
- Confirm credentials via Keychain or the Git helper

This approach reflects the *actual* configuration Git is using on macOS.
