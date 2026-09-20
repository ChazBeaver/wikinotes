# USB Wipe + Reformat Guide (Backup Disk Prep)

This document covers **two ways** to wipe and reformat a USB drive so it can be used for backups (including files > 4GB):

1. **NixOS Method** – uses `nix-shell` to pull tools on demand.
2. **Portable Linux Method** – works on almost any Linux system without Nix.

> ⚠️ **Danger:** These commands will erase all data on the selected USB device. Double-check the device name (`/dev/sdX`) before running anything.

======================================================================

## 1. NixOS Method (Using `nix-shell` Tools)

### 1.1. Dependencies

- NixOS or Nix installed
- `nix-shell` available
- Internet access (if tools not already cached)
- Core utilities:
  - `lsblk`
  - `umount`
  - `wipefs`

All extra tools (`parted`, `mkfs.exfat`, `mkfs.vfat`) are provided using `nix-shell`.

======================================================================

### 1.2. Step 1 — Identify the USB Device

```bash
lsblk -f
```

Find your USB by size/label. It will look like:

```text
sda
├─sda1  iso9660  ...
└─sda2  vfat     ...
```

Replace `sdX` with the actual device (e.g., `sda`).

> ⚠️ NEVER use `/dev/nvme0n1` or your system disk.

======================================================================

### 1.3. Step 2 — Unmount USB Partitions

```bash
sudo umount -f /dev/sdX1 2>/dev/null
sudo umount -f /dev/sdX2 2>/dev/null
```

Ignore “not mounted” errors.

======================================================================

### 1.4. Step 3 — Wipe Existing Signatures

```bash
sudo wipefs -a /dev/sdX
```

======================================================================

### 1.5. Step 4 — Create a New GPT Partition Table (using `parted` via Nix)

```bash
sudo nix-shell -p parted --run "parted /dev/sdX --script mklabel gpt"
```

======================================================================

### 1.6. Step 5 — Create a Single Full-Disk Partition

```bash
sudo nix-shell -p parted --run "parted /dev/sdX --script mkpart primary 0% 100%"
```

This creates `/dev/sdX1` using the entire USB.

======================================================================

### 1.7. Step 6 — Format the New Partition

#### Option A: exFAT (Recommended; supports files > 4GB)

```bash
sudo nix-shell -p exfatprogs --run "mkfs.exfat -n BACKUP /dev/sdX1"
```

#### Option B: FAT32 (Max file size 4GB)

```bash
sudo nix-shell -p dosfstools --run "mkfs.vfat -F 32 -n BACKUP /dev/sdX1"
```

======================================================================

### 1.8. Step 7 — Verify Result

```bash
lsblk -f
```

Expected output:

```text
sda
└─sda1  exfat  1.0  BACKUP  XXXX-XXXX
```

======================================================================

### 1.9. Step 8 — Replug and Use

- Unplug the USB and plug it back in.
- Your desktop environment should auto-mount it.
- It is ready for backups (including >4GB files if exFAT).

======================================================================

## 2. Portable Linux Method (No Nix, Minimal Dependencies)

This method works on any Linux distro (Ubuntu, Fedora, Arch, etc.).

### 2.1. Dependencies

Required tools:
- `lsblk` (util-linux)
- `umount` (util-linux)
- `wipefs` (util-linux)
- `fdisk` (util-linux)
- `mkfs.exfat` (exfatprogs) for exFAT
- `mkfs.vfat` (dosfstools) for FAT32

======================================================================

### 2.2. Step 1 — Identify the USB Device

```bash
lsblk -f
```

Locate the USB by size/label.

======================================================================

### 2.3. Step 2 — Unmount USB Partitions

```bash
sudo umount -f /dev/sdX1 2>/dev/null
sudo umount -f /dev/sdX2 2>/dev/null
```

======================================================================

### 2.4. Step 3 — Wipe Existing Signatures

```bash
sudo wipefs -a /dev/sdX
```

======================================================================

### 2.5. Step 4 — Create GPT + Partition Using `fdisk` (most portable)

```bash
sudo fdisk /dev/sdX
```

Inside fdisk, type:

```text
g
n
(enter)
(enter)
(enter)
w
```

======================================================================

### 2.6. Step 5 — Format the New Partition

#### Option A: exFAT

```bash
sudo mkfs.exfat -n BACKUP /dev/sdX1
```

#### Option B: FAT32

```bash
sudo mkfs.vfat -F 32 -n BACKUP /dev/sdX1
```

======================================================================

### 2.7. Step 6 — Verify

```bash
lsblk -f
```

======================================================================

### 2.8. Step 7 — Replug and Use

The USB is now ready for backups.

======================================================================

## 3. Quick Reference Cheat Sheet

### NixOS Version

```bash
lsblk -f
sudo umount -f /dev/sdX1 2>/dev/null
sudo umount -f /dev/sdX2 2>/dev/null
sudo wipefs -a /dev/sdX
sudo nix-shell -p parted --run "parted /dev/sdX --script mklabel gpt"
sudo nix-shell -p parted --run "parted /dev/sdX --script mkpart primary 0% 100%"
sudo nix-shell -p exfatprogs --run "mkfs.exfat -n BACKUP /dev/sdX1"
lsblk -f
```

### Portable Linux Version

```bash
lsblk -f
sudo umount -f /dev/sdX1 2>/dev/null
sudo umount -f /dev/sdX2 2>/dev/null
sudo wipefs -a /dev/sdX
sudo fdisk /dev/sdX
sudo mkfs.exfat -n BACKUP /dev/sdX1
lsblk -f
```
