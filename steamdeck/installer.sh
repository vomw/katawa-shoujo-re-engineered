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

installTypeHelp="You have two options to install the game:

1) Install the game with replacing existing Katawa Shoujo installation.
It will have achievements support, but will not auto-update. 
You won't be able to play vanilla Steam release of the game on this device after that, unless you restore original game files using Steam settings.
2) Install the game as a separate entity from Flathub. 
It will auto-update, but won't integrate with Steam achievements. 
You will be able to play vanilla Steam release and KS:RE separately
"

installType=`kdialog --title="${title}" --radiolist "${installTypeHelp}" \
"replace" "Replace current KS installation" off \
"separate" "Install KS:RE separately" off`

if [[ "${installType}" == "separate" ]]; then
    # User agreed to installation separately.
    installProgress=`kdialog --title="${title}" --progressbar "${title}"`
    qdbus $installProgress Set "" value 1
    qdbus $installProgress setLabelText "Installing Katawa Shoujo: Re-Engineered from Flathub..."
    flatpak install -y sh.fhs.KatawaShoujoReEngineered || true
    qdbus $installProgress Set "" value 80
    qdbus $installProgress setLabelText "Adding KS:RE as non-Steam game to Steam..."
    # Add-to-Steam shortcut (works only on Steam OS!)
    steamos-add-to-steam /var/lib/flatpak/app/sh.fhs.KatawaShoujoReEngineered/current/active/export/share/applications/sh.fhs.KatawaShoujoReEngineered.desktop
    qdbus $installProgress close
elif [[ "${installType}" == "replace" ]]; then
    echo "not yet"
else
    kdialog --title="${title}" --sorry "Installation aborted."

    exit
fi

steamGameID=""
if [[ "${installType}" == "separate" ]]; then
    steamGameID=`python ./shortcuts.py ~/.local/share/Steam/userdata/*/config | grep "Katawa Shoujo: Re-Engineered" | cut -d "'" -f 6`
else
    steamGameID="3068300" # Vanilla KS Steam ID
fi

echo $steamGameID

artwork=`kdialog --title="${title}" --radiolist "Choose the Steam artwork" \
"shisha" "Shizune & Misha" off \
"hanashy" "Lilly & Hanako (shy)" off \
"hanacur" "Lilly & Hanako (curious)" off \
"lemon" "Emi & Rin" off \
"saki" "Saki & Rika" off`

if [[ "${artwork}" == "" ]]; then
    kdialog --title="${title}" --sorry "Installation aborted. The game installed without artwork.\nAssign artwork manually using SteamGridDB."

    exit
fi

# The artwork is picked, time to download stuff!
wget -O "${steamGameID}p.png" "https://cdn2.steamgriddb.com/grid/e0bef5004dd56c6dd7b6019af66f2638.png"
wget -O "${steamGameID}_logo.png" "https://codeberg.org/fhs/katawa-shoujo-re-engineered/raw/branch/master/ios-icon.png"
wget -O "${steamGameID}_hero.png" "https://cdn2.steamgriddb.com/hero/55e875a41fe6ef14540212235cf7d507.png"

if [[ "${artwork}" == "shisha" ]]; then
    wget -O "${steamGameID}.png" "https://cdn2.steamgriddb.com/grid/5dd9b1b5acffc5a9064edee7e2904414.png"
elif [[ "${artwork}" == "hanashy" ]]; then
    wget -O "${steamGameID}.png" "https://cdn2.steamgriddb.com/grid/136d0b006683c59d520b9bdcad8216b2.png"
elif [[ "${artwork}" == "hanacur" ]]; then
    wget -O "${steamGameID}.png" "https://cdn2.steamgriddb.com/grid/223edfb2c306b101b2c435165a36fca5.png"
elif [[ "${artwork}" == "lemon" ]]; then
    wget -O "${steamGameID}.png" "https://cdn2.steamgriddb.com/grid/c7a3c595757b44e3104900cffaea9e68.png"
elif [[ "${artwork}" == "saki" ]]; then
    wget -O "${steamGameID}.png" "https://cdn2.steamgriddb.com/grid/a8e0e456885f13f7c01cdba8f434794b.png"
fi


for steamDir in ~/.local/share/Steam/userdata/*; do
    mkdir "${steamDir}/config/grid" || true
    cp "${steamGameID}.png" "${steamDir}/config/grid/"
    cp "${steamGameID}p.png" "${steamDir}/config/grid/"
    cp "${steamGameID}_logo.png" "${steamDir}/config/grid/"
    cp "${steamGameID}_hero.png" "${steamDir}/config/grid/"
done

kdialog --title="${title}" --msgbox "The game installed successfully. Return to Steam Gaming Mode to enjoy it."
