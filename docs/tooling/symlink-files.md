# Symlinking Files in Unix/Linux

This walkthrough shows how to symlink a file from one path to another.

## Goal
Symlink a file named `starship.toml` from a directory (called `patha`)
to the expected Starship configuration location: `$HOME/.config/starship.toml`

## Example 1: Absolute Path

Use this if you know the full path to the file.

ln -s /full/path/to/patha/starship.toml $HOME/.config/starship.toml

Explanation:
- `ln` is the link command
- `-s` creates a symbolic link
- `/full/path/to/patha/starship.toml` is the source file
- `$HOME/.config/starship.toml` is the target symlink location

## Example 2: Relative Path from Inside patha

If you're already inside the source directory (`patha`), you can run:

```bash
ln -s "$(pwd)/starship.toml" "$HOME/.config/starship.toml"
```

`$(pwd)` dynamically inserts the present working directory

## Example 3: Overwrite Existing File or Symlink

If a file already exists at the destination, and you want to replace it:

```bash
ln -sf /full/path/to/patha/starship.toml $HOME/.config/starship.toml
```

`-f` forces overwrite of existing file or link

## Notes

- This will not copy the file, it only creates a reference to it
- Editing the symlinked file edits the original
- Useful for dotfile management and portable config setups

✅ Done!
