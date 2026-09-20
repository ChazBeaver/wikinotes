============================================================
HOW-TO: Install Omarchy on a New Machine Using the USB Installer
============================================================

This guide assumes you already created a bootable Omarchy installer USB.
The steps below cover booting from the USB and installing Omarchy onto the internal disk of a new machine.

⚠️ WARNING: Installing an OS can erase the internal drive.
Double-check the target disk before you click “Install” or confirm any destructive step.

============================================================
STEP 1 — Insert the Omarchy Installer USB
============================================================

1) Power OFF the target machine completely.
2) Insert the Omarchy installer USB into the target machine.
3) If possible, plug the USB directly into the machine (avoid hubs/docks).

============================================================
STEP 2 — Enter the BIOS / UEFI Boot Menu
============================================================

Turn the machine ON and immediately press the Boot Menu key repeatedly.
Common Boot Menu keys (varies by manufacturer):
- F12
- F10
- F2
- DEL
- ESC

If you miss it, reboot and try again.

============================================================
STEP 3 — Boot from the USB in UEFI Mode
============================================================

In the Boot Menu, select the USB entry that starts with “UEFI”.
Examples:
- UEFI: Kingston
- UEFI: Samsung
- UEFI: ARCHISO
- UEFI: <USB Brand Name>

Choose UEFI, not Legacy/CSM, unless you specifically need legacy boot.

============================================================
STEP 4 — Boot into the Omarchy Live Environment
============================================================

On the Omarchy boot screen, select the default boot option.
Example:
- Boot Omarchy (Default)

Wait for the live desktop environment to load fully.

============================================================
STEP 5 — Identify the Internal Disk (CRITICAL)
============================================================

Open a terminal in the live environment and run:
lsblk

Identify:
- The USB installer disk (often /dev/sda, size matches your USB)
- The internal disk you want to install to (often /dev/nvme0n1 or /dev/sda, size matches internal storage)

Example (common):
- /dev/sda      = USB installer (DO NOT INSTALL HERE)
- /dev/nvme0n1  = internal SSD/NVMe (INSTALL TARGET)

If you want filesystem details (optional):
lsblk -f

Take a moment to be 100% sure which disk is the internal target.

============================================================
STEP 6 — Start the Omarchy Installer
============================================================

Omarchy may provide a graphical installer (common) or a terminal-based install flow.
Look for an “Install Omarchy” icon, menu entry, or installer app in the live environment.

If you see a GUI installer:
1) Launch “Install Omarchy”.
2) Proceed through the prompts.
3) When asked for the install destination, select the INTERNAL DISK (not the USB).
4) Confirm partitioning/formatting options carefully.
5) Set your timezone, user, and password when prompted.
6) Start the install and wait for completion.

============================================================
STEP 7 — Verify You Chose the Correct Target Disk
============================================================

Before you click any final “Install” / “Erase disk” / “Write changes” prompt:
- Re-check the disk name (e.g., /dev/nvme0n1)
- Re-check the disk size
- Confirm it is NOT the USB disk

If you are unsure, cancel and re-run:
lsblk
lsblk -f

============================================================
STEP 8 — Finish Installation and Reboot
============================================================

When the installer finishes:
1) Close the installer.
2) Reboot the machine.

You can reboot via terminal (optional):
sudo reboot

============================================================
STEP 9 — Remove the USB at the Right Time
============================================================

If the machine tries to boot back into the USB live environment:
- Power off or reboot
- Remove the USB
- Boot again

Many installers will prompt you when it’s safe to remove the USB.
If prompted, remove the USB then press Enter to reboot.

============================================================
STEP 10 — First Boot Checks (Optional but Recommended)
============================================================

After booting into your newly installed Omarchy system:
Open a terminal and run:
lsblk
lsblk -f

Confirm the system is running from the internal disk and not the USB.
Confirm /boot exists and the system disk layout looks correct.

============================================================
COMMON PITFALLS
============================================================

1) Installing to the USB by accident (double-check disk name + size).
2) Booting the “Legacy” USB entry instead of “UEFI”.
3) Leaving the USB inserted and booting back into the live environment.
4) Selecting the wrong internal disk on multi-disk systems.

============================================================
END OF GUIDE
============================================================
