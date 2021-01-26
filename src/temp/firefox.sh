#!/usr/bin/env bash

# Stops script execution if a command has an error
#MAKE CHANGES HERE, WHEN FINISHED COPY AND PASTE THIS TO FIREFOX.SH UNDER RESOURCES/TOOLS
set -e

#SHA256=6f15dc7b7de081a4f11ffa24d6ad6cd1877131941ff762d14cb3b0faf4291867

function disableUpdate() {
    ff_def="$1/browser/defaults/profile"
    mkdir -p $ff_def
    printf '
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.checkInstallTime", false);
user_pref("app.update.silent", false);
user_pref("app.update.staging.enabled", false);
user_pref("app.update.badge", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("app.update.lastUpdateTime.addon-background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.blocklist-background-update-timer", 1182010203);
user_pref("app.update.lastUpdateTime.microsummary-generator-update-timer", 1222586145);
user_pref("intl.locale.requested", "fr");
user_pref("app.update.lastUpdateTime.search-engine-update-timer", 1182010203);' > $ff_def/user.js
}
#^ place some user pref depending on lang above, at the min affects the one in the usr/lib/firefox place
# user_pref("intl.locale.requested", "fr,en-US");
# http://releases.mozilla.org/pub/firefox/releases/84.0/linux-x86_64/en-US/
# http://releases.mozilla.org/pub/firefox/releases/84.0.2/linux-x86_64/en-US/
SHA256=4d987bc87b56dfd2518e162401496c247750ca0a18d8c9072c9ad1ecbd67cbb9 
#https://addons.mozilla.org/firefox/downloads/file/3703842/francais_language_pack-84.0buildid20210105180113-fx.xpi french lang pack 84
#or can copy from https://ftp.mozilla.org/pub/firefox/releases/84.0.2/linux-x86_64/xpi/fr.xpi
#SHA FOR THAT--> e603dc105bbfbfe5aa5d5c7ba087f4ba06f4d3b094cfa20a5aaef80d9182ac66

#ESR
SHA256=486927b18e6437c685e37983aed4ca2ce96c74802da10d7a811f7b6e22516b8b

#https://addons.mozilla.org/firefox/downloads/file/3379574/francais_language_pack-68.0buildid20190813150448-fx.xpi french lang pack 
#xpi location /usr/lib/firefox/browser/features/
#this doesnt make sense to change which one you have based on language, because then we have two images. 
function instFF() {
    if [ ! "${1:0:1}" == "" ]; then
        FF_VERS=$1
        if [ ! "${2:0:1}" == "" ]; then
            FF_INST=$2
            echo "download Firefox $FF_VERS and install it to '$FF_INST'."
            mkdir -p "$FF_INST"
            #got rid of french install of firefox lol
            FF_URL=http://releases.mozilla.org/pub/firefox/releases/$FF_VERS/linux-x86_64/en-US/firefox-$FF_VERS.tar.bz2
            echo "FF_URL: $FF_URL"
            wget --quiet $FF_URL -O /tmp/firefox.tar.bz2
            echo "${SHA256} /tmp/firefox.tar.bz2" | sha256sum -c -
            tar xvjf /tmp/firefox.tar.bz2 --strip=1 -C $FF_INST/
            ln -s "$FF_INST/firefox" /usr/bin/firefox
            rm /tmp/firefox.tar.bz2
            # Create desktop icon
            printf "[Desktop Entry]\nVersion=1.0\nEncoding=UTF-8\nName=Firefox Web Browser\nComment=Webbrowser\nExec=firefox\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=/usr/lib/firefox/browser/chrome/icons/default/default128.png\nCategories=GNOME;GTK;Network;WebBrowser;\nStartupNotify=true;" > /usr/share/applications/firefox.desktop
            # MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
            disableUpdate $FF_INST
            #try this distribution/extensions thing out
            
            exit $?
        fi
    fi
    echo "function parameter are not set correctly please call it like 'instFF [version] [install path]'"
    exit -1
}

if ! hash firefox 2>/dev/null; then
    echo "Installing Firefox. Please wait..."
    #instFF '84.0.2' '/usr/lib/firefox'
    instFF '78.6.1esr' '/usr/lib/firefox'
    
else
    echo "Firefox is already installed"
fi
