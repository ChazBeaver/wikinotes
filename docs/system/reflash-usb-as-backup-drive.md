=============================================================
# Reflash USB as Backup Drive (Arch Linux)
=============================================================

## 1. Identify the USB

```bash
lsblk
```

Look for your USB by size and note the device name (e.g., `/dev/sda`, `/dev/sdb`).  
**Do not assume it's the same device every time — always verify with `lsblk` first.**

---

## 2. Unmount all partitions on the USB

Replace `sdX` with your actual device letter (e.g., `sda`, `sdb`):

```bash
sudo umount /dev/sdX1
sudo umount /dev/sdX2
```

If there are more partitions (sdX3, etc.), unmount those too. Ignore "not mounted" errors.

---

## 3. Wipe the partition table

```bash
sudo wipefs -a /dev/sdX
```

---

## 4. Create a new partition table and partition

```bash
sudo fdisk /dev/sdX
```

Inside `fdisk`, run these commands one at a time:

| Key | Action |
|-----|--------|
| `g` | Create new GPT partition table |
| `n` | New partition |
| Enter x3 | Accept all defaults (partition number, first sector, last sector) |
| `w` | Write changes and exit |

---

## 5. Format as exFAT

Install `exfatprogs` if not already installed:

```bash
sudo pacman -S --needed exfatprogs
```

Format the partition:

```bash
sudo mkfs.exfat -L "Backup" /dev/sdX1
```

> **Why exFAT?** It works on Linux, macOS, and Windows with no extra setup.  
> Use `mkfs.ext4` instead if this drive will only ever be used on Linux.

---

## 6. Mount and verify

Choose a mount point (common options: `/mnt/backup`, `/mnt/usb`, `/run/media/$USER/Backup`):

```bash
sudo mkdir -p /mnt/backup
sudo mount /dev/sdX1 /mnt/backup
df -h /mnt/backup
```

The last command should show the full drive size confirming a successful mount.

---

## 7. Back up files with rsync

```bash
rsync -av --progress ~/path/to/source/ /mnt/backup/destination/
```

**`rsync` flags explained:**
- `-a` — archive mode (preserves permissions, timestamps, symlinks)
- `-v` — verbose output
- `--progress` — shows transfer progress per file

---

## 8. Safely eject when done

```bash
sudo umount /mnt/backup
```

---

## Quick Reference

```
lsblk                                        # find device name
sudo umount /dev/sdX1 /dev/sdX2              # unmount partitions
sudo wipefs -a /dev/sdX                      # wipe partition table
sudo fdisk /dev/sdX                          # g → n → Enter x3 → w
sudo pacman -S --needed exfatprogs           # install exFAT tools
sudo mkfs.exfat -L "Backup" /dev/sdX1       # format
sudo mkdir -p /mnt/backup                    # create mount point
sudo mount /dev/sdX1 /mnt/backup            # mount
rsync -av --progress ~/src/ /mnt/backup/    # backup
sudo umount /mnt/backup                      # eject
```
