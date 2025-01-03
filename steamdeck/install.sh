#!/bin/bash
# Copyright (c) 2024 Fleeting Heartbeat Studios
# Licensed under MPL 2.0 license.

title="Katawa Shoujo: Re-Engineered"

# Asking user to continue.
if !(kdialog --title="${title}" --yesno \
    "Welcome to the Katawa Shoujo: Re-Engineered Steam Deck installer!\nAre you ready to install the game?")
then
    kdialog --title="${title}" --sorry "Installation aborted."

    exit
fi

mkdir /tmp/ksre-installer
cd /tmp/ksre-installer
curl -o installer.sh "https://codeberg.org/fhs/katawa-shoujo-re-engineered/raw/branch/hdkv/steam_deck_installer/steamdeck/installer.sh"
curl -o shortcuts.py "https://codeberg.org/fhs/katawa-shoujo-re-engineered/raw/branch/hdkv/steam_deck_installer/steamdeck/shortcuts.py"
chmod +x installer.sh
./installer.sh
