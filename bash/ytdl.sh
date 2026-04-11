#!/usr/bin/env bash

# Copyright (C) 2025, Arghyadeep Mondal <github.com/arghya339>

shopt -s extglob

good="\033[92;1m[✔]\033[0m"
bad="\033[91;1m[✘]\033[0m"
info="\033[94;1m[i]\033[0m"
running="\033[37;1m[~]\033[0m"
notice="\033[93;1m[!]\033[0m"
question="\033[93;1m[?]\033[0m"

DarkRed='\033[31m'
Red='\033[38;5;196m'
Orange='\033[38;5;202m'
TrueOrange='\033[38;2;255;165;0m'
Yellow='\033[33m'
Green='\033[32m'
Blue='\033[34m'
TrueBlue='\033[38;5;021m'
Indigo='\033[38;5;54m'
TrueIndigo='\033[38;2;75;0;130m'
Violet='\033[38;5;93m'
TrueViolet='\033[38;2;138;43;226m'
DarkMagenta='\033[35m'
Magenta='\033[38;2;255;0;255m'
DarkCyan='\033[36m'
Cyan='\033[38;2;0;255;255m'
DarkWhite='\033[37m'
White='\033[97m'
whiteBG="\e[47m\e[30m"
Reset='\033[0m'

checkInternet() {
  if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    return
  else
    echo -e "$bad ${Red}No Internet Connection available!${Reset}"
    return 1
  fi
}

if [[ "$(uname)" == "Darwin" ]]; then
  isMacOS=true; isAndroid=false
elif [[ -d "/sdcard" ]] && [[ -d "/system" ]]; then
  isAndroid=true; isMacOS=false
fi

read rows cols < <(stty size)
ytdl="$HOME/.ytdl"
ytdlJson="$ytdl/ytdl.json"
fullScriptPath=$(realpath "$0")
if [ $isAndroid == true ]; then
  Music="/sdcard/Music/ytdl"
  Movies="/sdcard/Movies/ytdl"
  Pictures="/sdcard/Pictures/ytdl"
else
  Music="$HOME/Music/ytdl"
  Movies="$HOME/Movies/ytdl"
  Pictures="$HOME/Pictures/ytdl"
fi
mkdir -p "$ytdl" "$Music" "$Movies" "$Pictures"
eButtons=("<Select>" "<Exit>")
bButtons=("<Select>" "<Back>")
ynButtons=("<Yes>" "<No>")
tfButtons=("<true>" "<false>")
buttonsSymbol="➤"; symbol0="[ ]"; symbol1="[*]"
[ $isMacOS == true ] && cert="--ca-certificate=/etc/ssl/cert.pem" || cert=

[ $isAndroid == true ] && scripts=(Termux)
[ $isMacOS == true ] && scripts=(macOS)
scripts+=(Tools fileSelector menu confirmPrompt)

run() {
  if [ $isAndroid == true ]; then
    [ ! -f "$PREFIX/bin/ytdl" ] && ln -s ~/.ytdl.sh $PREFIX/bin/ytdl
  elif [ $isMacOS == true ]; then
    [ ! -f "/usr/local/bin/ytdl" ] && ln -s $HOME/.ytdl.sh /usr/local/bin/ytdl
  fi
  [ ! -x $HOME/.ytdl.sh ] && chmod +x $HOME/.ytdl.sh
  
  for ((c=0; c<${#scripts[@]}; c++)); do
    source $ytdl/${scripts[c]}.sh
  done
}

[ -f "$ytdl/.version" ] && localVersion=$(cat "$ytdl/.version") || localVersion=
checkInternet &>/dev/null && remoteVersion=$(curl -sL "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/bash/.version") || remoteVersion="$localVersion"
updates() {
  curl -sL -o "$ytdl/.version" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/bash/.version"
  #curl -sL -o "$ytdl/CHANGELOG.md" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/bash/CHANGELOG.md"
  curl -sL -o "$HOME/.ytdl.sh" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/bash/ytdl.sh"
  if [ $isAndroid == true ]; then
    [ ! -f "$PREFIX/bin/ytdl" ] && ln -s ~/.ytdl.sh $PREFIX/bin/ytdl
  elif [ $isMacOS == true ]; then
    [ ! -f "/usr/local/bin/ytdl" ] && ln -s $HOME/.ytdl.sh /usr/local/bin/ytdl
  fi
  [ ! -x $HOME/.ytdl.sh ] && chmod +x $HOME/.ytdl.sh
  for ((c=0; c<${#scripts[@]}; c++)); do
    if [ $c -le 2 ]; then
      curl -sL -o "$ytdl/${scripts[c]}.sh" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/bash/${scripts[c]}.sh"
    else
      curl -sL -o "$ytdl/${scripts[c]}.sh" "https://raw.githubusercontent.com/arghya339/Simplify/refs/heads/next/bash/${scripts[c]}.sh"
    fi
    source $ytdl/${scripts[c]}.sh
  done
}
[ -f "$ytdlJson" ] && AutoUpdatesScript=$(jq -r '.AutoUpdatesScript' "$ytdlJson" 2>/dev/null) || AutoUpdatesScript=true
if [ $AutoUpdatesScript == true ]; then
  [ "$remoteVersion" != "$localVersion" ] && { checkInternet && updates && localVersion="$remoteVersion"; } || run
else
  run
fi

print_ytdlp() {
  printf "${Red}              __     ${Reset}      ${White} __         ${Reset}${Red}       __  __           ${Reset}\n"
  printf "${Red}             |  \    ${Reset}      ${White}|  \        ${Reset}${Red}      |  \|  \          ${Reset}\n"
  printf "${Red}  __    __  _| \$\$_   ${Reset}      ${White} \\\$\$\       ${Reset}${Red}  ____| $\$| $\$  ______  ${Reset}\n"
  printf "${Red} |  \  |  \|   \$\$ \  ${Reset}      ${White}  \\\$\$\      ${Reset}${Red} /      $\$| $\$ /      \ ${Reset}\n"
  printf "${Red} | \$\$  | \$\$ \\$\$\$\$\$\$  ${Reset}      ${White}   >\$\$\     ${Reset}${Red}|  $\$\$\$\$\$\$| $\$|  $\$\$\$\$\$\ ${Reset}\n"
  printf "${Red} | \$\$  | \$\$  | \$\$ __ ${Reset}      ${White}  /  \$\$     ${Reset}${Red}| $\$  | $\$| $\$| $\$  | $\$${Reset}\n"
  printf "${Red} | \$\$__/ \$\$  | \$\$|  \ ${Reset}     ${White} /  \$\$      ${Reset}${Red}| $\$__| $\$| $\$| $\$__/ $\$${Reset}\n"
  printf "${Red}  \\$\$    \$\$   \\$\$  \$\$ ${Reset}     ${White}|  \$\$ ______ ${Reset}${Red}\\$\$    $\$| $\$| $\$    $\$ ${Reset}\n"
  printf "${Red}  _\\$\$\$\$\$\$\$    \\$\$\$\$ ${Reset}      ${White} \\$\$ |      \\ ${Reset}${Red}\\\$\$\$\$\$\$\$ \\$\$| $\$\$\$\$\$\$ ${Reset}\n"
  printf "${Red} |  \__| \$\$          ${Reset}      ${White}      \\$\$\$\$\$\$${Reset}${Red}             | \$\$       ${Reset}\n"
  printf "${Red}  \\$\$    \$\$                                 ${Reset} ${White} ${Reset}  ${Red}     | \$\$       ${Reset}\n"
  printf "${Red}   \\$\$\$\$\$\$                                        ${Reset}  ${White}  ${Reset}${Red}\\\$\$  ${Reset}\n"
  echo
}

crop_artwork() {
  latest_mp3=$(ls -t "$Music"/*.mp3 | head -1)
  
  # Download thumbnail separately || --write-thumbnail
  yt-dlp --js-runtimes deno --remote-components ejs:github --skip-download --write-thumbnail --convert-thumbnails png "$url" -o "$Music/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
  
  latest_png=$(ls -t "$Music"/*.png | head -1)
  
  if [ -f "$latest_png" ]; then
    cropped_png="${latest_png%.*}.cropped.png"
    magick "$latest_png" -thumbnail 500x500^ -gravity center -extent 500x500 "$cropped_png"
    
    ffmpeg -i "$latest_mp3" -i "$cropped_png" -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -y "${latest_mp3%.*}.temp.mp3" &>/dev/null
      
      mv -f "${latest_mp3%.*}.temp.mp3" "$latest_mp3"
      rm -f "$latest_png" "$cropped_png"
  fi
}

playlistNameAsAlbumMetadata() {
  latest_video="$Movies/$(ls -t $Movies | grep -E '\.(mp4|mkv)$' | head -1)"
  ext="${latest_video##*.}"
  if echo "$url 2>&1" | grep -qF "playlist"; then
    latest_infoJson=$(ls -t "$Movies"/*.info.json | head -1)
    if ffmpeg -i "$latest_video" 2>&1 | grep -q "PURL"; then
      playlistUrl=$(ffprobe -v error -show_entries format_tags=PURL -of default=noprint_wrappers=1:nokey=1 "$latest_video")
      ffmpeg -i "$latest_video" -c copy -metadata PURL= -metadata VURL="$playlistUrl" -y "${latest_video%.*}.temp.$ext"
      rm -f "$latest_video" && mv "${latest_video%.*}.temp.$ext" "$latest_video"
      playlistUrl=$(jq -r '.id' "$latest_infoJson")
      ffmpeg -i "$latest_video" -c copy -metadata AURL="https://www.youtube.com/playlist?list=$playlistUrl" -y "${latest_video%.*}.temp.$ext"
      rm -f "$latest_video" && mv "${latest_video%.*}.temp.$ext" "$latest_video"
    fi
    if ! ffmpeg -i "$latest_video" 2>&1 | grep -q "album"; then
      playlistTitle=$(jq -r '.title' "$latest_infoJson")
      ffmpeg -i "$latest_video" -c copy -metadata album="$playlistTitle" -y "${latest_video%.*}.temp.$ext"
      rm -f "$latest_video" && mv "${latest_video%.*}.temp.$ext" "$latest_video"
    fi
  fi
} 

audioFormatExtraction() {
  mapfile -t audioOnly < <(grep -E "audio only" <<< "$urlInfo")
  audioFormatsList=(); AIDs=(); AEXTs=(); CHs=(); AFILESIZEs=(); ACODECs=(); ABRs=(); ASRs=(); LANGUAGEs=(); AQUALITYs=()
  for ((i=$((${#audioOnly[@]}-1)); i>=0; i--)); do
    #echo "$((${#audioOnly[@]}-i)). ${audioOnly[i]}"
    j=$((${#audioOnly[@]}-1-i))
    audioFormat="${audioOnly[i]}"
    AIDs+=($(awk '{print $1}' <<< "$audioFormat"))
    AEXTs+=($(awk '{print $2}' <<< "$audioFormat"))
    CHs+=($(awk '{print $5}' <<< "$audioFormat"))
    AFILESIZEs+=($(awk '{print $7}' <<< "$audioFormat"))
    ACODECs+=($(awk '{print $13}' <<< "$audioFormat"))
    ABRs+=($(awk '{print $14}' <<< "$audioFormat"))
    ASRs+=($(awk '{print $15}' <<< "$audioFormat"))
    Language=$(awk '{print $16}' <<< "$audioFormat")
    LANGUAGEs+=(${Language//[\[\]]/})
    AQuality=$(awk '{print $17}' <<< "$audioFormat")
    AQUALITYs+=(${AQuality%,})
    audioFormatsList+=("ID:${AIDs[j]}|EXT:${AEXTs[j]}|CH:${CHs[j]}|SIZE:${AFILESIZEs[j]}|ACODEC:${ACODECs[j]}|ABR:${ABRs[j]}|ASR:${ASRs[j]}|LANG:${LANGUAGEs[j]}|QUALITY:${AQUALITYs[j]}")
  done
  if menu audioFormatsList bButtons; then
    audioFormatList="${audioFormatsList[selected]}"
    AID="${AIDs[selected]}"
    ABR="${ABRs[selected]}"
  fi
}


URLData() {
  urlInfo=$(yt-dlp --js-runtimes deno --remote-components ejs:github -F "$url" -q 2>&1)
  if echo "$urlInfo" | grep -qF "ERROR"; then
    echo -e "$bad ${Red}Failed to fetch URL data !!${Reset}"
    bash $fullScriptPath
    exit 1
  fi
  #echo "$urlInfo" | head -1
  #echo -e "\n\nvideo only:"
  #grep -E "video only" <<< "$urlInfo"
  #echo -e "\n\naudio only:"
  #grep -E "audio only" <<< "$urlInfo"
  #echo -e "\n\n$info VideoQuality | ABR | VID+AID: (AV01 video + MP4A audio) / (VP09 video + Opus audio) | images: (PNG/JPG/WEBP/GIF)\n"
  downloadOptions=(Video Audio Images)
  if menu downloadOptions bButtons; then
    downloadOption="${downloadOptions[selected]}"
    if [ "$downloadOption" == "Video" ]; then
      mapfile -t videoOnly < <(grep -E "video only" <<< "$urlInfo")
      formatsList=(); IDs=(); EXTs=(); RESOLUTIONs=(); FPSs=(); FILESIZEs=(); VCODECs=(); VBRs=(); QUALITYs=()
      for ((i=$((${#videoOnly[@]}-1)); i>=0; i--)); do
        #echo "$((${#videoOnly[@]}-i)). ${videoOnly[i]}"
        j=$((${#videoOnly[@]}-1-i))
        Format="${videoOnly[i]}"
        IDs+=($(awk '{print $1}' <<< "$Format"))
        EXTs+=($(awk '{print $2}' <<< "$Format"))
        RESOLUTIONs+=($(awk '{print $3}' <<< "$Format"))
        FPSs+=($(awk '{print $4}' <<< "$Format"))
        FILESIZEs+=($(awk '{print $6}' <<< "$Format"))
        VCODECs+=($(awk '{print $10}' <<< "$Format"))
        VBRs+=($(awk '{print $11}' <<< "$Format"))
        Quality=$(awk '{print $14}' <<< "$Format")
        QUALITYs+=(${Quality%,})
        formatsList+=("ID:${IDs[j]}|EXT:${EXTs[j]}|RES:${RESOLUTIONs[j]}|FPS:${FPSs[j]}|SIZE:${FILESIZEs[j]}|CODEC:${VCODECs[j]}|VBR:${VBRs[j]}|QUALITY:${QUALITYs[j]}")
      done
      if menu formatsList bButtons; then
        formatList="${formatsList[selected]}"
        ID="${IDs[selected]}"
        QUALITY="${QUALITYs[selected]}"
      fi
      audioFormatExtraction
      if [ -n "$formatList" ] && [ -n "$audioFormatList" ]; then
        echo -e "Selected video only: $formatList\nSelected audio only: $audioFormatList"
        format="$ID+$AID"
      elif [ -n "$formatList" ]; then
        echo "Selected video format: $formatList"
        format="$QUALITY"
      elif [ -n "$audioFormatList" ]; then
        echo "Selected audio only: $audioFormatList"
        format="$ABR"
      else
        format="bestvideo"
      fi
    elif [ "$downloadOption" == "Audio" ]; then
      audioFormatExtraction
      [ -n "$audioFormatList" ] && { echo "Selected audio only: $audioFormatList"; format="$ABR"; } || format="bestaudio"
    else
      format="images"
    fi
  fi
}

dl() {
    printf '\033[2J\033[3J\033[H'
    print_ytdlp
    read -r -p "Type URL: " url  # https://youtu.be/__NeP0RqACU
    grep -qF "?feature=shared" <<< "$url" && url=$(echo "$url" | sed 's/\?feature=shared//')
    echo -e "\n$running Fetching URL metadata...\n"
    if echo "$url 2>&1" | grep -qF "list"; then
      total=$(yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist --get-title "$url" 2>/dev/null | awk 'END{print NR}')
      echo -e "$info The entered URL contain a playlist with a total of $total videos.\n"
      buttons=("<Entire>" "<Select>"); confirmPrompt "Download Entire playlist or Select videos?" "buttons" && choice="Entire" || choice="Select"
        if [ "$choice" == "Select" ]; then
            echo -e "\n\n$info List of Playlist items: \n\n"
            # yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist --get-title "$url" | nl -s ") " -w 2
            yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist --get-title "$url" 2> >(grep -v 'Incomplete data received\|Falling back on generic' >&2) | nl -s ") " -w 2
            echo -e "\n\n$info Enter video numbers (e.g.: 1,3,5 or 2-5 or 1,4-6)"
            read -r -p "Select items: " playlist_items
            echo -e "$info List of Playlist videos with Format: \n\n"
            yt-dlp --js-runtimes deno --remote-components ejs:github -F "$url" --playlist-items "$playlist_items" -q
        else
            ehco -e "\n\n$notice Entire playlist selected !!"
        fi
      echo -e "\n\n$info Playlist Format: png|svg|gif|mp3|4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p\n"
      read -r -p "Select Format: " format
      echo -e "\n\n"
    else
      echo -e "\n\n"
      URLData
    fi
    [ -n "$playlist_items" ] && items_args="--playlist-items $playlist_items" || items_args=""
  while true; do
    case "$format" in
      [Bb][Ee][Ss][Tt][Vv][Ii][Dd][Ee][Oo])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -qE 'video'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          [ $? -ne 0 ] && { cat $ytdl/ytdlp_error_log.txt; echo -e "${Yellow}Failed to download MP4!${Reset}"; }
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice Video unavailable !!"
        fi
        ;;
      4320* | 8[Kk] | [Ff][Uu][Hh][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '4320p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height<=4320]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor --external-downloader-args "aria2c: -x 16 -s 16 --console-log-level=error --download-result=hide --summary-interval=0" $cert "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "${Yellow}Failed to download 4320p MKV! Falling back to default quality (bestvideo+bestaudio MKV).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 8k Quality unavailable !!"
        fi
        ;;
      2160* | 4[Kk] | [Uu][Hh][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '2160p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=2160]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor --external-downloader-args "aria2c: -x 16 -s 16 --console-log-level=error --download-result=hide --summary-interval=0" $cert "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 2160p MKV! Falling back to default quality (bestvideo+bestaudio MKV).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 4k Quality unavailable !!"
        fi
        ;;
      1440* | 2[Kk] | [Qq][Hh][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '1440p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=1440]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor --external-downloader-args "aria2c: -x 16 -s 16 --console-log-level=error --download-result=hide --summary-interval=0" $cert "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 1440p MKV! Falling back to default quality (bestvideo+bestaudio MKV).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 2k Quality unavailable !!"
        fi
        ;;
      1080* | [Ff][Hh][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '1080p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=1080]+bestaudio[ext=m4a]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "${Yellow}Failed to download 1080p MKV! Falling back to default quality (bestvideo+bestaudio MKV).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice FHD Quality unavailable !!"
        fi
        ;;
      720* | [Hh][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '720p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=720]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 720p MP4! Falling back to default quality (bestvideo+bestaudio MP4).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice HD Quality unavailable !!"
        fi
        ;;
      480* | [Ss][Dd])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '480p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=480]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 480p MP4! Falling back to default quality (bestvideo+bestaudio MP4).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice SD Quality unavailable !!"
        fi
        ;;
      360*)
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '360p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=360]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 360p MP4! Falling back to default quality (bestvideo+bestaudio MP4).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 360p Quality unavailable !!"
        fi
        ;;
      240*)
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '240p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=240]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 240p MP4! Falling back to default quality (bestvideo+bestaudio MP4).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 240p Quality unavailable !!"
        fi
        ;;
      144*)
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E '144p'; then
          yt-dlp --js-runtimes deno --remote-components ejs:github -f 'bestvideo[height=144]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download 144p MP4! Falling back to default quality (bestvideo+bestaudio MP4).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          fi
          playlistNameAsAlbumMetadata
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice 144p Quality unavailable !!"
        fi
        ;;
      [Bb][Ee][Ss][Tt][Aa][Uu][Dd][Ii][Oo])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -q -E 'Default'; then
          if grep -qE "/youtube.com|w.youtube.com|/youtu.be" <<< "$url"; then
              yt-dlp --js-runtimes deno --remote-components ejs:github -x --audio-format mp3 $items_args --no-embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format srt --convert-subs srt --sponsorblock-remove music_offtopic "$url" -o "$Music/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
              [ $? -eq 0 ] && crop_artwork || { cat $ytdl/ytdlp_error_log.txt; echo -e "${Yellow}Failed to download MP3 from YouTube!${Reset}"; }
          else
            yt-dlp --js-runtimes deno --remote-components ejs:github -x --audio-format mp3 $items_args --embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format srt --convert-subs srt --sponsorblock-remove music_offtopic $url -o "$Music/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt  # sponsorblock categories: sponsor, intro, outro, selfpromo, preview, filler, interaction, music_offtopic, hook, poi_highlight, chapter, all (default)
            [ $? -ne 0 ] && { cat $ytdl/ytdlp_error_log.txt; echo -e "${Yellow}Failed to download MP3 from YT Music!${Reset}"; }
          fi
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice Audio unavailable !!"
        fi
        ;;
      *[Kk])
        if yt-dlp --js-runtimes deno --remote-components ejs:github -F $url | grep -qE "$format"; then
          if grep -qE "/youtube.com|w.youtube.com|/youtu.be" <<< "$url"; then
              yt-dlp --js-runtimes deno --remote-components ejs:github -x --audio-format mp3 $items_args --audio-quality ${format} --no-embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format vtt --sponsorblock-remove music_offtopic $url -o "$Music/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
              [ $? -eq 0 ] && crop_artwork || { cat $ytdl/ytdlp_error_log.txt; echo -e "${Yellow}Failed to download MP3 from YouTube!${Reset}"; }
          elif grep -qE "/music.youtube.com" <<< "$url"; then
            yt-dlp --js-runtimes deno --remote-components ejs:github -x --audio-format mp3 $items_args --audio-quality ${format} --embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format vtt --sponsorblock-remove music_offtopic $url -o "$Music/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt  # --sponsorblock-remove all  # Remove all sponsor segments
            [ $? -ne 0 ] && { cat $ytdl/ytdlp_error_log.txt; echo -e "${Yellow}Failed to download MP3 from YT Music!${Reset}"; }
          fi
          echo; read -p "Press Enter to continue..."
          break
        else
          echo -e "$notice Selected Audio Format $format unavailable !!"
        fi
        ;;
      +([0-9])'+'+([0-9]) )
          yt-dlp --js-runtimes deno --remote-components ejs:github -f "$format" $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor --external-downloader-args "aria2c: -x 16 -s 16 --console-log-level=error --download-result=hide --summary-interval=0" $cert "$url" -o "$Movies/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download Selected formate code $format in MKV!${Reset}"
          else
            playlistNameAsAlbumMetadata
            echo; read -p "Press Enter to continue..."
            break
          fi
        ;;
      [Pp][Nn][Gg] | [Jj][Pp][Gg] | [Jj][Pp][Ee][Gg] | [Ww][Ee][Bb][Pp] | [Gg][Ii][Ff] | [Ii][Mm][Aa][Gg][Ee][Ss])
        yt-dlp --js-runtimes deno --remote-components ejs:github --skip-download --write-thumbnail --convert-thumbnails png "$url" -o "$Pictures/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
        if [ $? -ne 0 ]; then
          cat $ytdl/ytdlp_error_log.txt
          echo -e "$notice ${Yellow}Failed to download Images as PNG! Falling back to JPG format.${Reset}"
          yt-dlp --js-runtimes deno --remote-components ejs:github --skip-download --write-thumbnail --convert-thumbnails jpg "$url" -o "$Pictures/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
          if [ $? -ne 0 ]; then
            cat $ytdl/ytdlp_error_log.txt
            echo -e "$notice ${Yellow}Failed to download Images as JPG! Falling back to default format (WEBP).${Reset}"
            yt-dlp --js-runtimes deno --remote-components ejs:github --skip-download --write-thumbnail "$url" -o "$Pictures/%(title)s.%(ext)s" -q --progress 2> $ytdl/ytdlp_error_log.txt
            if [ $? -ne 0 ]; then
              cat $ytdl/ytdlp_error_log.txt
              echo -e "$notice ${Yellow}Failed to download Images !!${Reset}"
            else
              latest_webp=$(ls -t "$Pictures"/*.webp | head -1)
              ffmpeg -i "$latest_webp" "${latest_webp%.*}.png" &>/dev/null
              ffmpeg -i "$latest_webp" "${latest_webp%.*}.jpg" &>/dev/null 2>&1
              rm -f "$latest_webp"
              echo; read -p "Press Enter to continue..."
              break
            fi
          else
            echo; read -p "Press Enter to continue..."
            break
          fi
        else
          echo; read -p "Press Enter to continue..."
          break
        fi
        ;;
      *)
        echo -e "$info Invalid input !!"
        Sleep 1
        printf '\033[2J\033[3J\033[H'
        print_ytdlp
        if grep -qF "playlist" <<< "$url"; then
          echo -e "$info List of Playlist videos with Format: \n\n"
          yt-dlp --js-runtimes deno --remote-components ejs:github -F "$url" --playlist-items "$playlist_items"
          echo -e "\n\n$info Playlist Format: mp3|4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p\n"
        else
          URLData
        fi
        ;;
    esac
  done
}

printf '\033[2J\033[3J\033[H'  # fully clear the screen and reset scrollback  # \033[2J: Clears visible screen. # \033[3J: Clears scrollback buffer (macOS). # \033[H: Moves cursor to top-left.
input=2
while true; do
  options=("Update" "Online Play" "Download" "Tools" "Player" "Reinstall" "Uninstall")
  menu "options" "eButtons" "" "" "$input" && input="$selected"
  case "${options[input]}" in
    Update)
      updates
      dependencies
      if [ $isMacOS == true ]; then
        formulaeUpdate "vlc"
        formulaeUpdate "aural"
        formulaeUpdate "freetube"
        formulaeUpdate "pear-desktop"  # https://github.com/pear-devs/pear-desktop
      fi
      ;;
    Online\ Play)
      if [ $isMacOS == true ]; then
        echo -e "$running Installing Online Player..."
        formulaeInstall "freetube"  # install freetube for online YT video playback
        open -a "FreeTube"
        formulaeInstall "pear-desktop"  # install pear-desktop for online YT Music audio playback
        open -a "YouTube Music"
      fi
      ;;
    Download) dl ;;
    Tools)
      tools=("Video→Video" "Video→Audio" "Video→Ringtone" "Audio→Ringtone" "Images→Images" "Animations" "Documents" "Cipher")
      selected_tool=0
      while true; do
        menu tools bButtons "" "" $selected_tool && selected_tool=$selected || break
        case "${tools[selected_tool]}" in
          "Video→Video")
            v2v=("MKV→MP4" "MP4→MKV")
            selected_v2v=0
            while true; do
              menu v2v bButtons "" "" $selected_v2v && selected_v2v=$selected || break
              case "${v2v[selected_v2v]}" in
                "MKV→MP4") fileSelector "mkv" && MKV2MP4 "$filePath" ;;
                "MP4→MKV") fileSelector "mp4" && MP42MKV "$filePath" ;;
              esac
            done
            ;;
          "Video→Audio")
            v2a=("MKV→MP3" "MP4→MP3" "MKV→M4A" "MP4→M4A")
            selected_v2a=0
            while true; do
              menu v2a bButtons "" "" $selected_v2a && selected_v2a=$selected || break
              case "${v2a[selected_v2a]}" in
                "MKV→MP3"|"MP4→MP3")
                  [ "${v2a[selected_v2a]}" == "MKV→MP3" ] && video_ext=mkv || video_ext=mp4
                  fileSelector "$video_ext" && Video2MP3 "$filePath"
                  ;;
                "MKV→M4A"|"MP4→M4A")
                  [ "${v2a[selected_v2a]}" == "MKV→M4A" ] && video_ext=mkv || video_ext=mp4
                  fileSelector "$video_ext" && Video2M4A "$filePath"
                  ;;
              esac
            done
            ;;
          "Video→Ringtone")
            v2r=("MKV→MP3Ringtone" "MP4→MP3Ringtone" "MKV→M4ARingtone" "MP4→M4ARingtone")
            selected_v2r=0
            while true; do
              menu v2r bButtons "" "" $selected_v2r && selected_v2r=$selected || break
              case "${v2r[selected_v2r]}" in
                "MKV→MP3Ringtone"|"MP4→MP3Ringtone")
                  [ "${v2r[selected_v2r]}" == "MKV→MP3Ringtone" ] && video_ext=mkv || video_ext=mp4
                  if fileSelector $video_ext; then
                    read -r -p "StartTime: " -i "00:00" -e start_time
                    [ -n "$start_time" ] && Video2MP3Ringtone "$filePath" "$start_time"
                  fi
                  ;;
                "MKV→M4ARingtone"|"MP4→M4ARingtone")
                  [ "${v2r[selected_v2r]}" == "MKV→M4ARingtone" ] && video_ext=mkv || video_ext=mp4
                  if fileSelector $video_ext; then
                    read -r -p "StartTime: " -i "00:00" -e start_time
                    [ -n "$start_time" ] && Video2M4ARingtone "$filePath" "$start_time"
                  fi
                  ;;
              esac
            done
            ;;
        esac
      done
      ;;
    Player)
      if [ $isMacOS == true ]; then
        ehco -e "$running Installing Player..."
        formulaeInstall "vlc"  # install vlc player for local/remote video playback
        formulaeInstall "aural"  # install aural player for local audio playback
      fi
      ;;
    Reinstall)
      if [ $isMacOS == true ]; then
        formulaeReinstall "jq"
        formulaeReinstall "aria2"
        formulaeReinstall "python"
        formulaeReinstall "ffmpeg"
        formulaeReinstall "yt-dlp"
        formulaeReinstall "nodejs"
        formulaeReinstall "deno"
        formulaeReinstall "imagemagick"
      fi
      ;;
    Uninstall)
      confirmPrompt "Are you sure you want to uninstall ytdl?" "ynButtons" "1" && response=Yes || response=No
      case "$response" in
        Yes)
          echo -ne "${Red}Type 'yes' in capital to continue: ${Reset}" && read -r userInput
          case "$userInput" in
            YES)
              [ -d "$ytdl" ] && rm -rf "$ytdl"
              [ -f "$HOME/.ytdl.sh" ] && rm -f "$HOME/.ytdl.sh"
              if [ $isAndroid == true ]; then
                [ -f "$PREFIX/bin/ytdl" ] && rm -f "$PREFIX/bin/ytdl"
                [ -f "$HOME/.shortcuts/ytdl" ] && rm -f "$HOME/.shortcuts/ytdl"
                [ -f "$HOME/.termux/widget/dynamic_shortcuts/ytdl" ] && rm -f "$HOME/.termux/widget/dynamic_shortcuts/ytdl"
              elif [ $isMacOS == true ]; then
                [ -f "/usr/local/bin/ytdl" ] && rm -f "/usr/local/bin/ytdl"
              fi
              confirmPrompt "Do you want to remove this script-related dependency?" "ynButtons" "1" && response=Yes || response=No
              case "$response" in
                Yes)
                  if [ $isAndroid == true ]; then
                    pkgUninstall "jq"
                    pkgUninstall "aria2c"
                    pkgUninstall "python"
                    pkgUninstall "ffmpeg"
                    pkgUninstall "python-yt-dlp"
                    pkgUninstall "nodejs"
                    pkgUninstall "deno"
                    pkgUninstall "imagemagick"
                  elif [ $isMacOS == true ]; then
                    formulaeUninstall "jq"
                    formulaeUninstall "aria2c"
                    formulaeUninstall "python"
                    formulaeUninstall "ffmpeg"
                    formulaeUninstall "yt-dlp"
                    formulaeUninstall "nodejs"
                    formulaeUninstall "deno"
                    formulaeUninstall "imagemagick"
                  fi
                  ;;
              esac
              confirmPrompt "Do you want to remove Player?" "ynButtons" "1" && response=Yes || response=No
              case "$response" in
                Yes)
                  if [ $isMacOS == true ]; then
                    formulaeUninstall "vlc"
                    formulaeUninstall "aural"
                    formulaeUninstall "freetube"
                    formulaeUninstall "pear-desktop"  # youtube-music uninstall
                  fi
                  ;;
              esac
              ;;
          esac
        ;;
      esac
    ;;
  esac
done
###############################################
