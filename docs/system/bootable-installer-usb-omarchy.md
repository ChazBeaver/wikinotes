=============================================================
HOW-TO: Create an Omarchy Bootable Installer USB (Arch Linux)
=============================================================

This guide walks through creating a bootable Omarchy USB installer
from an Arch Linux system.
It assumes you already downloaded the latest Omarchy ISO.

⚠️ WARNING: These commands will erase the selected USB device.
Double-check device names before running dd.

=============================================================
STEP 1 — Download the Latest Omarchy ISO
=============================================================

Download the latest Omarchy ISO from the official source.

Example:
https://omarchy.org/download

Place it somewhere convenient, for example:

~/Downloads/omarchy-latest.iso

Optional: Verify the ISO checksum if one is provided.

sha256sum ~/Downloads/omarchy-latest.iso

Compare the output with the official published checksum.

=============================================================
STEP 2 — Insert USB and Identify the Device
=============================================================

Insert your USB drive(s).

Run the following command to identify them:

lsblk

Or for filesystem details:

lsblk -f

Identify the USB by size and model.

Example output:

sda 239G Flash Drive
sdb 231G Flash Drive

Your system disk will likely be something like:
nvme0n1 — DO NOT TOUCH THIS

In this example, the USB devices are:
/dev/sda
/dev/sdb

=============================================================
STEP 3 — Unmount USB Partitions
=============================================================

Unmount any mounted partitions before writing the ISO.

sudo umount /dev/sda* 2>/dev/null
sudo umount /dev/sdb* 2>/dev/null

Ignore “not mounted” errors.

=============================================================
STEP 4 — (Optional) Wipe Existing Signatures
=============================================================

This step is optional but ensures a clean state.

sudo wipefs -a /dev/sda
sudo wipefs -a /dev/sdb

=============================================================
STEP 5 — Write the ISO to the USB (IMPORTANT STEP)
=============================================================

⚠️ This overwrites the entire USB device.
Do NOT write to a partition like /dev/sda1.
Always write to the whole device: /dev/sda

Write to first USB:

sudo dd if=~/Downloads/omarchy-latest.iso of=/dev/sda bs=4M status=progress oflag=sync

Wait until it completes.

sync

Write to second USB:

sudo dd if=~/Downloads/omarchy-latest.iso of=/dev/sdb bs=4M status=progress oflag=sync

sync

=============================================================
STEP 6 — Verify the USB Was Written Correctly
=============================================================

Quick structural verification:

lsblk -f

Expected output should show:

iso9660 filesystem
OMARCHY label
ARCHISO_EFI vfat partition

Example:

sda
├─sda1 iso9660 OMARCHY_202601
└─sda2 vfat ARCHISO_EFI

Confirm ISO signature directly:

sudo file -s /dev/sda
sudo file -s /dev/sdb

Expected output should contain:
ISO 9660 CD-ROM filesystem data

Optional full byte-level verification:

sudo cmp -n $(stat -c%s ~/Downloads/omarchy-latest.iso) ~/Downloads/omarchy-latest.iso /dev/sda

sudo cmp -n $(stat -c%s ~/Downloads/omarchy-latest.iso) ~/Downloads/omarchy-latest.iso /dev/sdb

If cmp returns no output, the image matches perfectly.

=============================================================
STEP 7 — Safely Eject the USB
=============================================================

sudo eject /dev/sda
sudo eject /dev/sdb

Or simply wait for sync to finish and safely remove.

=============================================================
STEP 8 — Boot and Install Omarchy
=============================================================

1. Insert the USB into the target system.
2. Enter BIOS/UEFI boot menu.
3. Select the USB device (UEFI entry).
4. Boot into Omarchy live environment.
5. Install to the internal disk (NOT the USB).

=============================================================
IMPORTANT NOTES
=============================================================

Installer USBs will show iso9660 and appear smaller.
This is normal.
You cannot copy files to an installer USB.
This is also normal.

Backup drives are formatted.
Installer drives are raw ISO writes.

=============================================================
END OF GUIDE
=============================================================
