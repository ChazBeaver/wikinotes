# Unattended Wikinotes registration

`./install.sh --non-interactive` reuses the existing registration writer, then
runs `./doctor.sh`. It registers this working checkout and its existing aliases
in `~/.dotfiles-env.sh`; it preserves other repositories' entries and repairs
its own duplicates. The no-argument `./install.sh` remains available.

Registration supports Linux and macOS. Search-tool installation remains with
Appdots. The doctor checks the checkout export and both aliases only; it does
not verify note content, search-tool availability, or restored personal files.

Registration requires a writable registry parent directory and the standard
Bash, awk, mktemp, and mv commands. It needs no package installation, network
access, or administrative privileges. For isolated checks, set
`DOTFILES_REGISTRY_FILE` to an explicit registry path with an existing parent;
the installer and doctor both honor it without changing `HOME`.

Run `bash tests/env.sh`, `bash tests/registration-install.sh`, and
`bash tests/unattended.sh` for the registration and installer fixtures.

## Calling contract

```bash
./install.sh --check
./install.sh --non-interactive
# Optional parent directory for this run's private logs:
./install.sh --non-interactive --log-dir /path/outside/git/install-logs
./install.sh --help
```

Run as the intended user, not root. Python 3 is required for this entrypoint.
`--check` runs prerequisites only, without registration, installation, or log
files. It is not a simulation of package resolution or a guarantee of eventual
success. A normal run checks prerequisites again, then installs and verifies.
There is no automatic rollback: after a failure, inspect the log, resolve the
reported prerequisite or drift, and rerun. Successful stages are not skipped
based on a past receipt.

The installer runs stages with stdin closed and no controlling terminal,
disables Git/SSH credential prompts, and stops at the first failed stage.
It never asks for a sudo password or grants privileges. Prepare required Git
credentials, SSH host keys, and non-interactive privilege access before calling
it. A terminal's cached sudo authorization may not apply to a detached process.

Logs default to `$XDG_STATE_HOME/wikinotes/install-logs/run-*/`, or
`~/.local/state/wikinotes/install-logs/run-*/`. The printed run directory is
private (0700); `output.log` and `result.json` are private (0600). Keep custom
log directories outside Git. The JSON records the repository, overall exit
code, and each attempted stage's exit code. It is a troubleshooting record,
not proof that later configuration still matches. No environment dump or
shell tracing is enabled. A lock prevents concurrent runs of this repository.

Exit zero means all stages passed. Child failures retain their nonzero exit
status. The entrypoint itself uses 2 for invalid arguments, 3 for a detected
reboot/session-restart prerequisite, 4 for missing prerequisites, 75 for an
already-running installer, and 130/143 for interruption. Other failures are
nonzero; callers must never interpret an unrecognized nonzero value as success.
A failure before log creation is reported on stderr and may have no run record.

Personal files and browser bookmarks are outside this installer. Their transfer
and import remain a separate future Setupdots project milestone.
