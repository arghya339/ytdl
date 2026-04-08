#!/usr/bin/bash

# Copyright (C) 2025, Arghyadeep Mondal <github.com/arghya339>

[ -f "$ytdlJson" ] && AutoUpdatesDependencies=$(jq -r '.AutoUpdatesDependencies' "$ytdlJson" 2>/dev/null) || AutoUpdatesDependencies=true

pkgUpdate() {
  pkg=$1
  if echo "$outdatedPkg" | grep -q "^$pkg/" 2>/dev/null; then
    echo -e "$running Upgrading $pkg pkg.."
    output=$(yes "N" | apt install --only-upgrade "$pkg" -y 2>/dev/null)
    echo "$output" | grep -q "dpkg was interrupted" 2>/dev/null && { yes "N" | dpkg --configure -a; yes "N" | apt install --only-upgrade "$pkg" -y > /dev/null 2>&1; }
  fi
}

pkgInstall() {
  pkg=$1
  if echo "$installedPkg" | grep -q "^$pkg/" 2>/dev/null; then
    pkgUpdate "$pkg"
  else
    echo -e "$running Installing $pkg pkg.."
    pkg install "$pkg" -y > /dev/null 2>&1
  fi
}

pkgUninstall() {
  installedPkg=$(pkg list-installed 2>/dev/null)
  pkg=$1
  if echo "$installedPkg" | grep -q "^$pkg/" 2>/dev/null; then
    echo -e "$running Uninstalling $pkg pkg.."
    pkg uninstall "$pkg" -y > /dev/null 2>&1
  fi
}

dependencies() {
  installedPkg=$(pkg list-installed 2>/dev/null)  # list of installed pkg
  pkg update > /dev/null 2>&1 || apt update >/dev/null 2>&1  # It downloads latest package list with versions from Termux remote repository, then compares them to local (installed) pkg versions, and shows a list of what can be upgraded if they are different.
  outdatedPkg=$(apt list --upgradable 2>/dev/null)  # list of outdated pkg
  echo "$outdatedPkg" | grep -q "dpkg was interrupted" 2>/dev/null && { yes "N" | dpkg --configure -a; outdatedPkg=$(apt list --upgradable 2>/dev/null); }
  pkgInstall "apt"  # apt update
  pkgInstall "dpkg"  # dpkg update
  pkgInstall "bash"  # bash update
  pkgInstall "libgnutls"  # pm apt & dpkg use it to securely download packages from repositories over HTTPS
  pkgInstall "coreutils"  # It provides basic file, shell, & text manipulation utilities. such as: ls, cp, mv, rm, mkdir, cat, echo, etc.
  pkgInstall "termux-core"  # it's contains basic essential cli utilities, such as: ls, cp, mv, rm, mkdir, cat, echo, etc.
  pkgInstall "termux-tools"  # it's provide essential commands, sush as: termux-change-repo, termux-setup-storage, termux-open, termux-share, etc.
  pkgInstall "termux-keyring"  # it's use during pkg install/update to verify digital signature of the pkg and remote repository
  pkgInstall "termux-am"  # termux am (activity manager) update
  pkgInstall "termux-am-socket"  # termux am socket (when run: am start -n activity ,termux-am take & send to termux-am-stcket and it's send to Termux Core to execute am command) update
  pkgInstall "inetutils"  # ping utils is provided by inetutils
  pkgInstall "util-linux"  # it provides: kill, killall, uptime, uname, chsh, lscpu
  pkgInstall "libsmartcols"  # a library from the util-linux pkg
  pkgInstall "curl"  # curl update
  pkgInstall "libcurl"  # curl lib update
  pkgInstall "openssl"  # openssl install/update
  curl -V &>/dev/null || yes "N" | apt install --reinstall curl openssl -y
  pkgInstall "aria2"  # aria2 install/update
  pkgInstall "jq"  # jq install/update
  pkgInstall "grep"  # grep update
  pkgInstall "gawk"  # gnu awk update
  pkgInstall "sed"  # sed update
  pkgInstall "python"
  pkgInstall "libc++"  # libc++ update
  pkgInstall "ffmpeg"
  pkgInstall "python-yt-dlp"
  pkgInstall "nodejs"
  pkgInstall "deno"
  pkgInstall "imagemagick"
}
[ $AutoUpdatesDependencies == true ] && checkInternet && dependencies