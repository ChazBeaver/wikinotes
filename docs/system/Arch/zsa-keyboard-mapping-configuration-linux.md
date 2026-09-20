# ZSA Keymapp / Wally Linux Install

Official documentation reference:
https://github.com/zsa/wally/wiki/Linux-install

This document contains:
1) The official Linux install steps from ZSA documentation
2) The exact sudo tee method used to write the udev rules file
3) The additional troubleshooting steps required to resolve the /dev/hidraw permission error

---

## 1) Install Required Dependencies (Official Documentation)

Keymapp 1.2.0+ requires WebKitGTK 4.1 (not 4.0).
CLI-only flashing requires libusb at minimum.

Arch / Manjaro / Arch-based:
sudo pacman -S libusb webkit2gtk-4.1 gtk3

Debian / Ubuntu / Mint / Kali:
sudo apt install libwebkit2gtk-4.1-0 libgtk-3-0 libusb-1.0-0

Fedora / RHEL / CentOS:
sudo yum install gtk3 webkit2gtk4.1 libusb

If using a Snap browser, ensure raw USB access is granted (example from doc):
snap connect chromium:raw-usb

---

## 2) Create the udev Rules File (Using sudo tee Method We Used)

We created /etc/udev/rules.d/50-zsa.rules using sudo tee with a heredoc block.
This ensures proper root write permissions without manually opening an editor.

Command used:

sudo tee /etc/udev/rules.d/50-zsa.rules > /dev/null <<'EOF'
# Rules for Oryx web flashing and live training
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

# Legacy rules for live training over webusb (Not needed for firmware v21+)
# Rule for all ZSA keyboards
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
# Rule for the Moonlander
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
# Rule for the Ergodox EZ
SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
# Rule for the Planck EZ
SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

# Wally Flashing rules for the Ergodox EZ
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"

# Keymapp Flashing rules for the Voyager
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
EOF

---

## 3) Ensure plugdev Group Exists (Official Requirement)

Some Arch-based systems do not create plugdev by default.

Check if it exists:
getent group plugdev

If it does not exist, create it:
sudo groupadd plugdev

---

## 4) Add User to plugdev Group

sudo usermod -aG plugdev $USER

IMPORTANT: You must log out completely or reboot for group membership to apply.

Recommended:
sudo reboot

---

## 5) Reload and Apply udev Rules

sudo udevadm control --reload-rules
sudo udevadm trigger

Unplug and replug the keyboard after this step.

---

## 6) Verify Group Membership

groups

Expected output includes: plugdev

---

## 7) Verify hidraw Device Permissions

ls -l /dev/hidraw*

Working state observed:
crw-rw-rw- root ... /dev/hidraw0
crw-rw-rw- root ... /dev/hidraw1
crw-rw-rw- root ... /dev/hidraw2

Once permissions were correct and plugdev membership applied, Keymapp no longer failed with:
“Failed to open a device with path '/dev/hidrawX': Permission denied”

---

## 8) Download and Run Keymapp / Wally (Official Doc)

Download the latest Linux build from the official GitHub releases page.

Make executable:
chmod +x keymapp

Run:
./keymapp

Or for Wally:
chmod +x wally
./wally

---

## Final Outcome

After installing dependencies, writing the udev rules using sudo tee, ensuring plugdev group membership, reloading udev, rebooting, and verifying device permissions, flashing worked successfully.

Keymapp was able to access the correct /dev/hidraw device without requiring sudo.
