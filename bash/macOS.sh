#!/bin/bash

# Copyright (C) 2025, Arghyadeep Mondal <github.com/arghya339>

[ -f "$ytdlJson" ] && AutoUpdatesDependencies=$(jq -r '.AutoUpdatesDependencies' "$ytdlJson" 2>/dev/null) || AutoUpdatesDependencies=true

formulaeUpdate() {
  local formulae=$1
  if echo "$outdatedFormulae" | grep -q "^$formulae" 2>/dev/null; then
    echo -e "$running Upgrading $formulae formulae.."
    brew upgrade "$formulae" > /dev/null 2>&1
  fi
}

formulaeInstall() {
  local formulae=$1
  if ! echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Installing $formulae formulae.."
    brew install "$formulae" > /dev/null 2>&1
  fi
}

formulaeReinstall() {
  local formulae=$1
  if echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Reinstalling $formulae formulae.."
    brew reinstall "$formulae" > /dev/null 2>&1
  fi
}

formulaeUninstall() {
  local formulae=$1
  if echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Uninstalling $formulae formulae.."
    brew uninstall "$formulae" > /dev/null 2>&1
  fi
}

dependencies() {
  formulaeList=$(brew list 2>/dev/null)
  outdatedFormulae=$(brew outdated 2>/dev/null)
  grep -q "^yt-dlp" <<< "$outdatedFormulae" && open "https://github.com/yt-dlp/yt-dlp/releases"
  brew --version &>/dev/null && brew update > /dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  formulaeInstall "bash"
  formulaeInstall "grep"
  formulaeInstall "curl"
  formulaeInstall "jq"
  formulaeInstall "ca-certificate"
  formulaeInstall "aria2"
  formulaeInstall "python"
  formulaeInstall "ffmpeg"
  formulaeInstall "yt-dlp"
  formulaeInstall "nodejs"
  formulaeInstall "deno"
  formulaeInstall "imagemagick"
  # https://github.com/aria2/aria2/issues/1920
  aria2c -q -U "User-Agent: $USER_AGENT" --header="Referer: https://one.one.one.one/" --ca-certificate="/etc/ssl/cert.pem" --async-dns=true --async-dns-server="$cloudflareIP" "https://one.one.one.one/" >/dev/null 2>&1
  # https://aria2.github.io/manual/en/html/aria2c.html#exit-status
  if [ $? -eq 28 ]; then
    [ $(uname -m) == "x86_64" ] && Arch=amd64 || Arch=arm64
    curl -L --progress-bar -C - -o $Download/aria2c-macos-$Arch.tar https://github.com/tofuliang/aria2/releases/download/20240919/aria2c-macos-$Arch.tar
    pv "$Download/aria2c-macos-$Arch.tar" | tar -xf - -C "$Download" && rm -f "$Download/aria2c-macos-$Arch.tar"
    sudo mv $Download/aria2c /usr/local/bin/aria2c
    if aria2c -v &>/dev/null; then
      aria2c -v | head -1 | awk '{print $3}'
    else
      sudo xattr -d com.apple.quarantine /usr/local/bin/aria2c && aria2c -v | head -1 | awk '{print $3}'
    fi
  fi
  rm -f index.html
}
[ $AutoUpdatesDependencies == true ] && checkInternet && dependencies