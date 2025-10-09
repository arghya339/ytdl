#!/usr/bin/env bash

# Enable extended glob patterns at the top of this script
shopt -s extglob

# --- Downloading latest ytdl.sh file from GitHub ---
curl -sL -o "$HOME/.ytdl.sh" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/ytdl.sh"
if [ ! -f "/usr/local/bin/ytdl" ]; then
  ln -s $HOME/.ytdl.sh /usr/local/bin/ytdl  # symlink (shortcut of .ytdl.sh)
fi
chmod +x $HOME/.ytdl.sh  # give execute permission to ytdl

# --- Define ANSI color codes ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)

# --- Colored log indicators ---
good="\033[92;1m[✔]\033[0m"
bad="\033[91;1m[✘]\033[0m"
info="\033[94;1m[i]\033[0m"
running="\033[37;1m[~]\033[0m"
notice="\033[93;1m[!]\033[0m"
question="\033[93;1m[?]\033[0m"

# --- Define the ansi color codes ---
Reset='\033[0m'
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

# --- Golobal variables ---
fullScriptPath=$(realpath "$0")  # Get the full path of the currently running script
Music="$HOME/Music/ytdl"
Movies="$HOME/Movies/ytdl"
Pictures="$HOME/Pictures/ytdl"
mkdir -p "$Music" "$Movies" "$Pictures"  # Create directories if they don't exist

# --- Checking Internet Connection ---
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
  echo -e "${RED}[x] Oops! No Internet Connection available. \nConnect to the Internet and try again later.${RESET}"
  exit 1
fi

# --- Construct the ytdlp shape using string concatenation (ANSI Big Money-se Font) ---
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
  printf "${Red}  \\$\$    \$\$           𝒟𝑒𝓋𝑒𝓁𝑜𝓅𝑒𝓇: @𝒶𝓇𝑔𝒽𝓎𝒶𝟥𝟥𝟫 ${Reset} ${White} ${Reset}  ${Red}     | \$\$       ${Reset}\n"
  printf "${Red}   \\$\$\$\$\$\$      https://github.com/arghya339/ytdl ${Reset}  ${White}  ${Reset}${Red}\\\$\$  ${Reset}\n"
  #printf '\n'
  echo
}

# --- Check if brew is installed ---
if brew --version >/dev/null 2>&1; then
  brew update > /dev/null 2>&1
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1
fi
formulaeList=$(brew list 2>/dev/null)
outdatedFormulae=$(brew outdated 2>/dev/null)

# --- formulae upgrade function ---
formulaeUpdate() {
  local formulae=$1
  if echo "$outdatedFormulae" | grep -q "^$formulae" 2>/dev/null; then
    echo -e "$running Upgrading $formulae formulae.."
    brew upgrade "$formulae" > /dev/null 2>&1
  fi
}

# --- formulae install function ---
formulaeInstall() {
  local formulae=$1
  if ! echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Installing $formulae formulae.."
    brew install "$formulae" > /dev/null 2>&1
  fi
}

# --- formulae reinstall function ---
formulaeReinstall() {
  local formulae=$1
  if echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Reinstalling $formulae formulae.."
    brew reinstall "$formulae" > /dev/null 2>&1
  fi
}

# --- formulae uninstall function ---
formulaeUninstall() {
  local formulae=$1
  if echo "$formulaeList" | grep -q "$formulae" 2>/dev/null; then
    echo -e "$running Uninstalling $formulae formulae.."
    brew uninstall "$formulae" > /dev/null 2>&1
  fi
}

# --- Install/Update dependencies ---
formulaeUpdate "bash"  # bash update
formulaeUpdate "grep"  # grep update
formulaeUpdate "curl"  # curl update
formulaeInstall "python"  # python install/update
formulaeInstall "yt-dlp"  # yt-dlp install/update
formulaeInstall "ffmpeg"  # ffmpeg install/update
formulaeInstall "imagemagick"  # imagemagick install/update
formulaeInstall "aria2"  # aria2 install/update
formulaeInstall "jq"  # jq install/update

# --- Crop the thumbnail into a square for audio downloads from YouTube ---
crop_artwork() {
  # Get latest downloaded files
  latest_mp3=$(ls -t "$Music"/*.mp3 | head -1)
    
  # Download thumbnail separately
  yt-dlp --skip-download --write-thumbnail --convert-thumbnails png "$url" -o "$Music/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'

  latest_png=$(ls -t "$Music"/*.png | head -1)

  # Process thumbnail if downloaded
  if [ -f "$latest_png" ]; then
    cropped_png="${latest_png%.*}.cropped.png"
    magick "$latest_png" -thumbnail 500x500^ -gravity center -extent 500x500 "$cropped_png"
        
    # Embed using ffmpeg
    ffmpeg -i "$latest_mp3" -i "$cropped_png" -map 0 -map 1 \
      -c copy -id3v2_version 3 -metadata:s:v title="Album cover" \
      -metadata:s:v comment="Cover (front)" -y "${latest_mp3%.*}.temp.mp3" >/dev/null 2>&1
        
      mv -f "${latest_mp3%.*}.temp.mp3" "$latest_mp3"
      rm -f "$latest_png" "$cropped_png"
  fi
}

# --- Use Playlist Name as Album Metadata ---
playlistNameAsAlbumMetadata() {
  # Get latest downloaded files
  latest_mp4=$(ls -t "$Movies"/*.mp4 2>/dev/null | head -n 1)
  latest_mkv=$(ls -t "$Movies"/*.mkv 2>/dev/null | head -n 1)
  # Determine the latest video based on available files
  if [ -n "$latest_mkv" ]; then
    latest_video="$latest_mkv"
    if echo "$url 2>&1" | grep -qF "playlist"; then
      latest_infoJson=$(ls -t "$Movies"/*.info.json | head -1) # Get the latest info.json file
      if ffmpeg -i "$latest_video" 2>&1 | grep -q "PURL"; then
        # Extract PURL value from the video using ffprobe
        playlistUrl=$(ffprobe -v error -show_entries format_tags=PURL -of default=noprint_wrappers=1:nokey=1 "$latest_video")
        # Remove PURL and set VURL with ffmpeg
        ffmpeg -i "$latest_video" -c copy -metadata PURL= -metadata VURL="$playlistUrl" -y "${latest_video%.*}.temp.mkv"
        # Replace original file
        rm "$latest_video" && mv "${latest_video%.*}.temp.mkv" "$latest_video"

        playlistUrl=$(jq -r '.id' "$latest_infoJson")  # Extract the playlist URL from info.json
        # Use ffmpeg to add the playlist URL as album metadata
        ffmpeg -i "$latest_video" -c copy -metadata AURL="https://www.youtube.com/playlist?list=$playlistUrl" -y "${latest_video%.*}.temp.mkv"
        rm "$latest_video" && mv "${latest_video%.*}.temp.mkv" "$latest_video"
      fi
      if ! ffmpeg -i "$latest_video" 2>&1 | grep -q "album"; then
        playlistTitle=$(jq -r '.title' "$latest_infoJson")  # Extract the playlist title (name) from info.json
        # Use ffmpeg to add the playlist title as album metadata
        ffmpeg -i "$latest_video" -c copy -metadata album="$playlistTitle" -y "${latest_video%.*}.temp.mkv"
        rm "$latest_video" && mv "${latest_video%.*}.temp.mkv" "$latest_video"
      fi
    fi
  elif [ -n "$latest_mp4" ]; then
    latest_video="$latest_mp4"
    if echo "$url 2>&1" | grep -qF "playlist"; then
      latest_infoJson=$(ls -t "$Movies"/*.info.json | head -1) # Get the latest info.json file
      if ffmpeg -i "$latest_video" 2>&1 | grep -q "PURL"; then
        # Rename PURL to VURL in metadata using ffmpeg
        playlistUrl=$(ffprobe -v error -show_entries format_tags=PURL -of default=noprint_wrappers=1:nokey=1 "$latest_video")
        ffmpeg -i "$latest_video" -c copy -metadata PURL= -metadata VURL="$playlistUrl" -y "${latest_video%.*}.temp.mp4"
        rm "$latest_video" && mv "${latest_video%.*}.temp.mp4" "$latest_video"
        
        playlistUrl=$(jq -r '.id' "$latest_infoJson")  # Extract the playlist URL from info.json
        # Use ffmpeg to add the playlist URL as album metadata
        ffmpeg -i "$latest_video" -c copy -metadata AURL="https://www.youtube.com/playlist?list=$playlistUrl" -y "${latest_video%.*}.temp.mp4"
        rm "$latest_video" && mv "${latest_video%.*}.temp.mp4" "$latest_video"
      fi
      if ! ffmpeg -i "$latest_video" 2>&1 | grep -q "album"; then
        playlistTitle=$(jq -r '.title' "$latest_infoJson")  # Extract the playlist title (name) from info.json
        # Use ffmpeg to add the playlist title as album metadata
        ffmpeg -i "$latest_video" -c copy -metadata album="$playlistTitle" -y "${latest_video%.*}.temp.mp4"
        rm "$latest_video" && mv "${latest_video%.*}.temp.mp4" "$latest_video"
      fi
    fi
  fi
} 

# --- Display Video URL Data ---
videoUrlData() {
  urlInfo=$(yt-dlp -F "$url" 2>&1)
  if echo "$urlInfo" | grep -qF "ERROR"; then
    echo -e "${RED}[x] Failed to fetch video data.${RESET}"
    bash $fullScriptPath  # Restart the script
    exit 1  # Exit from script loop
  fi
  echo -e "formatCode | extension | resolution |  size   | codec  | bitrate\n"
  echo -e "$info Video Height/Resolution/Quality: 4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p\n"
  echo "$urlInfo" | grep -E 'mp4|vp09|av01' | grep -v 'audio only'  # 4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p
  echo -e "\n"
  echo -e "$info audio-only bitrates/codec/quality: 48k|64k|96k|128k|192k|256k|320k\n"
  echo "$urlInfo" | grep -E "Default|opus|m4a" # audio only
  echo -e "\n\n"
  echo -e "$info Download images as PNG/SVG/GIF from various websites: png/svg/gif\n"
  echo -e "$info Use compatible formats: (AV01 video + MP4A audio) / (VP09 video + Opus audio)\n"
  echo -e "$info <videoFormatCode>+<audioFormatCode>: (ie.: 299+251)\n"
}

# Confirmation prompt function
confirmPrompt() {
  Prompt=${1}
  local -n prompt_buttons=$2
  Selected=${3:-0}  # :- set value as 0 if unset
  maxLen=50
  
  # breaks long prompts into multiple lines (50 characters per line)
  lines=()  # empty array
  while [ -n "$Prompt" ]; do
    lines+=("${Prompt:0:$maxLen}")  # take first 50 characters from $Prompt starting at index 0
    Prompt="${Prompt:$maxLen}"  # removes first 50 characters from $Prompt by starting at 50 to 0
  done
  
  # print all-lines except last-line
  last_line_index=$(( ${#lines[@]} - 1 ))  # ${#lines[@]} = number of elements in lines array
  for (( i=0; i<last_line_index; i++ )); do
    echo -e "${lines[i]}"
  done
  last_line="${lines[$last_line_index]}"
  
  echo -ne '\033[?25l'  # Hide cursor
  while true; do
    show_prompt() {
      echo -ne "\r\033[K"  # n=noNewLine r=returnCursorToStartOfLine \033[K=clearLine
      echo -ne "$last_line "
      [ $Selected -eq 0 ] && echo -ne "${whiteBG}➤ ${prompt_buttons[0]} $Reset   ${prompt_buttons[1]}" || echo -ne "  ${prompt_buttons[0]}  ${whiteBG}➤ ${prompt_buttons[1]} $Reset"  # highlight selected bt with white bg
    }; show_prompt

    read -rsn1 key
    case $key in
      $'\E')
      # /bin/bash -c 'read -r -p "Type any ESC key: " input && printf "You Entered: %q\n" "$input"'  # q=safelyQuoted
        read -rsn2 -t 0.1 key2  # -r=readRawInput -s=silent(noOutput) -t=timeout -n2=readTwoChar | waits upto 0.1s=100ms to read key 
        case $key2 in 
          '[C') Selected=1 ;;  # right arrow key
          '[D') Selected=0 ;;  # left arrow key
        esac
        ;;
      [Yy]*) Selected=0; show_prompt; break ;;
      [Nn]*) Selected=1; show_prompt; break ;;
      "") break ;;  # Enter key
    esac
  done
  echo -e '\033[?25h' # Show cursor
  return $Selected  # return Selected int index from this fun
}

# --- Download YouTube Videos using yt-dlp ---
dl() {
    printf '\033[2J\033[3J\033[H'  # clear Terminal
    print_ytdlp  # Print the ytdlp shape
    read -r -p "Please enter the URLs: " url  # https://youtu.be/__NeP0RqACU
    # Remove the ?feature=shared from the URL if it exists
    if echo "$url 2>&1" | grep -qF "?feature=shared"; then
      url=$(echo "$url" | sed 's/\?feature=shared//')
    fi
    echo -e "\n"
    echo -e "$running Fetching URLs metadata...\n"
    if echo "$url 2>&1" | grep -qF "list"; then
      total=$(yt-dlp --flat-playlist --get-title "$url" 2>/dev/null | awk 'END{print NR}')
      echo -e "$info The entered URLs contain a playlist with a total of $total videos.\n"
      buttons=("<Entire>" "<Select>"); confirmPrompt "Download Entire playlist or Select videos?" "buttons" && choice=Entire || choice=Select
      echo -e "\n\n"  
        if [[ "$choice" =~ [Ss] ]]; then
            echo -e "$info List of Playlist items: \n\n"
            # yt-dlp --flat-playlist --get-title "$url" | nl -s ") " -w 2
            yt-dlp --flat-playlist --get-title "$url" 2> >(grep -v 'Incomplete data received\|Falling back on generic' >&2) | nl -s ") " -w 2
            echo -e "\n\n"
            echo -e "$info Enter video numbers (e.g.: 1,3,5 or 2-5 or 1,4-6)"
            read -r -p "Select items: " playlist_items
            echo -e "$info List of Playlist videos with Quality: \n\n"
            yt-dlp -F "$url" --playlist-items "$playlist_items"
        else
            ehco -e "$notice Entire playlist selected."
        fi
      echo -e "\n\n"
      echo -e "$info Playlist Quality: png|svg|gif|mp3|4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p\n"
    else
      echo -e "\n\n"
      videoUrlData  # Display video URL data by calling the function
    fi
    # Add playlist-items to yt-dlp command if specified
    if [ -n "$playlist_items" ]; then
        items_args="--playlist-items $playlist_items"
    else
        items_args=""
    fi
  while true; do
    read -r -p "Please select the Quaility: " quality
    echo -e "\n\n"
    case "$quality" in
      "144p" | "144"*)
        # Attempt to download 144p with preferred codecs (MP4)
        if yt-dlp -F $url | grep -q -E '144p'; then
          yt-dlp -f 'bestvideo[height=144]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')  # wide compatibility (MP4=AVC+AAC/m4a)  # Mark YouTube Videos Chapters as Videos Chapters
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 144p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata  # Use Playlist Name as Album Metadata by calling the function
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 144p Quality not available"
        fi
        ;;
      "240p" | "240"*)
        # Attempt to download 240p with preferred codecs (MP4)
        if yt-dlp -F $url | grep -q -E '240p'; then
          yt-dlp -f 'bestvideo[height=240]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 240p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 240p Quality not available"
        fi
        ;;
      "360p" | "360"*)
        # Attempt to downlaod 360p with preferred codecs (MP4)
        if yt-dlp -F $url | grep -q -E '360p'; then
          yt-dlp -f 'bestvideo[height=360]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 360p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 360p Quality not available"
        fi
        ;;
      "480p" | "480" | "sd"*)
        if yt-dlp -F $url | grep -q -E '480p'; then
          # Attempt to download 480p with preferred codecs (MP4)
          yt-dlp -f 'bestvideo[height=480]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 480p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice SD Quality not available"
        fi
        ;;
      "720p" | "720" | "hd" | "mp4" | "video"*)
        if yt-dlp -F $url | grep -q -E '720p'; then
          # Attempt to download 720p with preferred codecs (MP4) and capture output
          yt-dlp -f 'bestvideo[height=720]+bestaudio[ext=m4a]' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 720p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mp4 --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break # Exit the quality selection loop after attempting download (either way)
        else
          echo -e "$notice HD Quality not available"
        fi
        ;;
      "1080p" | "1080" | "full hd"*)
        if yt-dlp -F $url | grep -q -E '1080p'; then
          # Attempt to download 1080p with preferred codecs (MP4)
          yt-dlp -f 'bestvideo[height=1080]+bestaudio[ext=m4a]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format srt --convert-subs srt \
            --sponsorblock-mark sponsor "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 1080p MP4. Falling back to default quality (bestvideo+bestaudio MP4)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format srt --convert-subs srt --sponsorblock-mark sponsor \
              "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice Full HD Quality not available"
        fi
        ;;
      "1440p" | "1440" | "2k" | "mkv"*)
        # Attempt to download 1440p with preferred codecs (MKV)
        if yt-dlp -F $url | grep -q -E '1440p'; then
          yt-dlp -f 'bestvideo[height=1440]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor \
            --external-downloader aria2c --external-downloader-args "-x 16 -k 1M" "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')  # Use aria2c as downloader instead of the default (curl)
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 1440p MKV. Falling back to default quality (bestvideo+bestaudio MKV)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" \
              -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 2k Quality not available"
        fi
        ;;
      "2160p" | "2160" | "4k"*)
        # Attempt to download 2160p with preferred codecs (MKV)
        if yt-dlp -F $url | grep -q -E '2160p'; then
          yt-dlp -f 'bestvideo[height=2160]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor \
            --external-downloader aria2c --external-downloader-args "-x 16 -k 1M" "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 2160p MKV. Falling back to default quality (bestvideo+bestaudio MKV)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" \
              -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 4k Quality not available"
        fi
        ;;
      "4320p" | "4320" | "8k"*)
        # Attempt to download 4320p with preferred codecs (MKV)
        if yt-dlp -F $url | grep -q -E '4320p'; then
          yt-dlp -f 'bestvideo[height<=4320]+bestaudio[ext=webm]' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor \
            --external-downloader aria2c --external-downloader-args "-x 16 -k 1M" "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download 4320p MKV. Falling back to default quality (bestvideo+bestaudio MKV)."
            yt-dlp --force-overwrite -f 'bestvideo+bestaudio' $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor "$url" \
              -o "$Movies/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
          fi
          playlistNameAsAlbumMetadata
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice 8k Quality not available"
        fi
        ;;
      "Default" | "audio only" | "m4a" | "mp3" | "music"*)
        # Attempt to download Default audio only with preferred codecs (MP3)
        if yt-dlp -F $url | grep -q -E 'Default'; then
          if echo "$url" | grep -qE "/youtube.com|w.youtube.com|/youtu.be"; then
              # Download audio without embedded thumbnail
              yt-dlp -x --audio-format mp3 $items_args --no-embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format srt --convert-subs srt --sponsorblock-remove music_offtopic \
                "$url" -o "$Music/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
              crop_artwork  # Crop Artwork in square for audio downloads from YouTube by calling the function
          else
            yt-dlp -x --audio-format mp3 $items_args --embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format srt --convert-subs srt --sponsorblock-remove music_offtopic $url \
              -o "$Music/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'  # sponsorblock categories: sponsor, intro, outro, selfpromo, preview, filler, interaction, music_offtopic
          fi
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice Audio not available"
        fi
        ;;
      *k)
        # Attempt to download slected audio quality with preferred codecs (MP3)
        if yt-dlp -F $url | grep -q -E 'medium|low'; then
          if echo "$url" | grep -qE "/youtube.com|w.youtube.com|/youtu.be"; then
              # Download audio without embedded thumbnail
              yt-dlp -x --audio-format mp3 $items_args --audio-quality ${quality} --no-embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format vtt --sponsorblock-remove music_offtopic \
                $url -o "$Music/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'
              crop_artwork
          elif echo "$url" | grep -qE "/music.youtube.com"; then
            yt-dlp -x --audio-format mp3 $items_args --audio-quality ${quality} --embed-thumbnail --add-metadata --write-subs --sub-lang "all,-live_chat" --sub-format vtt --sponsorblock-remove music_offtopic $url \
              -o "$Music/%(title)s.%(ext)s" 2>&1 | grep --line-buffered '\[download\]'  # --sponsorblock-remove all  # Remove all sponsor segments
          fi
          Sleep 6  # Wait 6 seconds
          break
        else
          echo -e "$notice Selected Audio Quality not available"
        fi
        ;;
      +([0-9])'+'+([0-9]) )
        # Attempt to download selected video format code with selected audio format code (MKV)
          yt-dlp -f "$quality" $items_args --merge-output-format mkv --embed-thumbnail --add-metadata --write-info-json --write-subs --sub-lang all --sub-format vtt --sponsorblock-mark sponsor --external-downloader aria2c \
            --external-downloader-args "-x 16 -k 1M" "$url" -o "$Movies/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download Selected formate code (MKV)."
          else
            playlistNameAsAlbumMetadata
            Sleep 6  # Wait 6 seconds
            break
          fi
        ;;
      "png" | "jpg" | "images" | "photos" | "pictures"*)
        # Attempt to download images (PNG/JPG)
        yt-dlp --skip-download --write-thumbnail --convert-thumbnails png "$url" -o "$Pictures/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
        EXIT_CODE=$?
        if [ "$EXIT_CODE" -ne 0 ]; then
          echo "${YELLOW}[!]$RESET Failed to download Images as PNG. Falling back to default format (JPG)."
          yt-dlp --skip-download --write-thumbnail --convert-thumbnails jpg "$url" -o "$Pictures/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
          EXIT_CODE=$?
          if [ "$EXIT_CODE" -ne 0 ]; then
            echo "${YELLOW}[!]$RESET Failed to download Images as JPG. Falling back to default format (WEBP)."
            yt-dlp --skip-download --write-thumbnail "$url" -o "$Pictures/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
            EXIT_CODE=$?
            if [ "$EXIT_CODE" -ne 0 ]; then
              echo "${YELLOW}[!]$RESET Failed to download Images."
            else
              # Get latest downloaded files
              latest_webp=$(ls -t "$Pictures"/*.webp | head -1)
              ffmpeg -i "$latest_webp" "${latest_webp%.*}.png" >/dev/null 2>&1  # Convert WEBP to PNG
              ffmpeg -i "$latest_webp" "${latest_webp%.*}.jpg" >/dev/null 2>&1  # Convert WEBP to JPG
              rm -rf "$latest_webp"  # Remove WEBP file
              Sleep 6  # Wait 6 seconds
              break
            fi
          else
            Sleep 6  # Wait 6 seconds
            break
          fi
        else
          Sleep 6  # Wait 6 seconds
          break
        fi
        ;;
      "svg" | "illustrations"*)
        # Attempt to download SVG images
        yt-dlp --skip-download --write-thumbnail "$url" -o "$Pictures/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
        EXIT_CODE=$?
        if [ "$EXIT_CODE" -ne 0 ]; then
          echo "${YELLOW}[!]$RESET Failed to download SVG Images."
        else
          Sleep 6  # Wait 6 seconds
          break
        fi
        ;;
      "gif" | "animated images"*)
        # Attempt to download GIF images
        yt-dlp --skip-download --write-thumbnail "$url" -o "$Pictures/%(title)s.%(ext)s" 2>&1 | tee >(grep --line-buffered '\[download\]')
        EXIT_CODE=$?
        if [ "$EXIT_CODE" -ne 0 ]; then
          echo "${YELLOW}[!]$RESET Failed to download GIF Images."
        else
          Sleep 6  # Wait 6 seconds
          break
        fi
        ;;
      *)
        echo -e "$info Invalid input"
        Sleep 1  # Wait 1 second
        printf '\033[2J\033[3J\033[H'
        print_ytdlp
        if echo "$url 2>&1" | grep -qF "playlist"; then
          echo -e "$info List of Playlist videos with Quality: \n\n"
          yt-dlp -F "$url" --playlist-items "$playlist_items"
          echo -e "\n\n"
          echo -e "$info Playlist Quality: mp3|4320p|1440p|2160p|1080p|720p|480p|360p|240p|144p\n"
        else
          videoUrlData
        fi
        ;;
    esac
  done
}

menu() {
  local -n menu_options=$1
  local -n menu_buttons=$2
  
  selected_option=0
  selected_button=0
  
  show_menu() {
    printf '\033[2J\033[3J\033[H'
    print_ytdlp  # call print_ytdlp function
    echo -e "Navigate with [↑] [↓] [←] [→] || Select with [↵]\n"
    for ((i=0; i<=$((${#menu_options[@]} - 1)); i++)); do
      if [ $i -eq $selected_option ]; then
        echo -e "${whiteBG}➤ ${menu_options[$i]} $Reset"
      else
        [ $(($i + 1)) -le 9 ] && echo " $(($i + 1)). ${menu_options[$i]}" || echo "$(($i + 1)). ${menu_options[$i]}"
      fi
    done
    echo
    for ((i=0; i<=$((${#menu_buttons[@]} - 1)); i++)); do
      if [ $i -eq $selected_button ]; then
        [ $i -eq 0 ] && echo -ne "${whiteBG}➤ ${menu_buttons[$i]} $Reset" || echo -ne "  ${whiteBG}➤ ${menu_buttons[$i]} $Reset"
      else
        [ $i -eq 0 ] && echo -n "  ${menu_buttons[$i]}" || echo -n "   ${menu_buttons[$i]}"
      fi
    done
    echo
  }

  printf '\033[?25l'
  while true; do
    show_menu
    read -rsn1 key
    case $key in
      $'\E')  # ESC
        # /bin/bash -c 'read -r -p "Type any ESC key: " input && printf "You Entered: %q\n" "$input"'  # q=safelyQuoted
        read -rsn2 -t 0.1 key2
        case "$key2" in
          '[A')  # Up arrow
            selected_option=$((selected_option - 1))
            [ $selected_option -lt 0 ] && selected_option=$((${#menu_options[@]} - 1))
            ;;
          '[B')  # Down arrow
            selected_option=$((selected_option + 1))
            [ $selected_option -ge ${#menu_options[@]} ] && selected_option=0
            ;;
          '[C')  # Right arrow
            [ $selected_button -lt $((${#menu_buttons[@]} - 1)) ] && selected_button=$((selected_button + 1))
            ;;
          '[D')  # Left arrow
            [ $selected_button -gt 0 ] && selected_button=$((selected_button - 1))
            ;;
        esac
        ;;
      '')  # Enter key
        break
        ;;
      [0-9])
        if [ $key -eq 0 ]; then
          # if $key is 0, then select last option
          selected_option=$((${#options[@]} - 1))
        elif [ $key -gt ${#options[@]} ]; then
          # if $key is greaterthen total option, then select first option
          selected_option=0
        else
          # otherwise select option that match with $key
          selected_option=$(($key - 1))
        fi
       ;;
    esac
  done
  printf '\033[?25h'

  [ $selected_button -eq 0 ] && { printf '\033[2J\033[3J\033[H'; selected=$selected_option; }
  [ $selected_button -eq $((${#menu_buttons[@]} - 1)) ] && { printf '\033[2J\033[3J\033[H'; echo "Script exited !!"; exit 0; }
}

# --- ytdl main menu functions ---
  printf '\033[2J\033[3J\033[H'  # fully clear the screen and reset scrollback  # \033[2J: Clears visible screen. # \033[3J: Clears scrollback buffer (macOS). # \033[H: Moves cursor to top-left.
  while true; do
    if echo "$outdatedFormulae" | grep -q "^yt-dlp" 2>/dev/null; then
      echo -e "$info yt-dlp update available, please select 'Up' to update.\n"
      open "https://github.com/yt-dlp/yt-dlp/releases/"
    fi
    options=(Update Online\ Play Download Player Reinstall Uninstall); buttons=("<Select>" "<Exit>"); menu "options" "buttons"
        case "${options[$selected]}" in
          [Uu][pp]*)
            formulaeUpdate "python"  # python update
            formulaeUpdate "yt-dlp"  # yt-dlp update
            formulaeUpdate "ffmpeg"  # ffmpeg update
            formulaeUpdate "imagemagick"  # imagemagick update
            formulaeUpdate "aria2"  # aria2 update
            formulaeUpdate "jq"  # jq update
            echo "$formulaeList" | grep -q "^vlc" 2>/dev/null && formulaeUpdate "vlc"  # vlc update
            echo "$formulaeList" | grep -q "^aural" 2>/dev/null && formulaeUpdate "aural"  # aural update
            echo "$formulaeList" | grep -q "^freetube" 2>/dev/null && formulaeUpdate "freetube"  # freetube update
            echo "$formulaeList" | grep -q "^youtube-music" 2>/dev/null && formulaeUpdate "youtube-music"  # youtube-music update
            sleep 1  # wait 1 second
            ;;
          [Oo][Pp]*)
            echo -e "$running Installing Online Player..."
            echo "$formulaeList" | grep -q "freetube" 2>/dev/null || brew install freetube > /dev/null 2>&1  # install freetube for online YT video playback
            echo "$formulaeList" | grep -q "youtube-music" 2>/dev/null || brew install th-ch/youtube-music/youtube-music > /dev/null 2>&1  # install youtube-music for online YT Music audio playback
            ;;
          [Dd][Ll]*)
            dl  # Call the download function
            ;;
          [Pp][Ll]*)
            ehco -e "$running Installing Player..."
            echo "$formulaeList" | grep -q "vlc" 2>/dev/null || brew install vlc > /dev/null 2>&1  # install vlc player for video playback
            echo "$formulaeList" | grep -q "aural" 2>/dev/null || brew install aural > /dev/null 2>&1  # install aural player for audio playback
            ;;
          [Rr][ee]*)
            formulaeReinstall "python"  # python reinstall
            formulaeReinstall "yt-dlp"  # yt-dlp reinstall
            formulaeReinstall "ffmpeg"  # ffmpeg reinstall
            formulaeReinstall "imagemagick"  # imagemagick reinstall
            formulaeReinstall "aria2"  # aria2 reinstall
            formulaeReinstall "jq"  # jq reinstall
            sleep 1  # wait 1 second
            ;;
          [Uu][Nn]*)
            # Prompt for user choice on uinstallation of python and yt-dlp
            buttons=("<Yes>" "<No>"); confirmPrompt "Do you want to uninstall ytdl?" "buttons" "1" && opt=Yes || opt=No
            case $opt in
              y*|Y*)
                formulaeUninstall "python"  # python uninstall
                formulaeUninstall "yt-dlp"  # yt-dlp uninstall
                formulaeUninstall "ffmpeg"  # ffmpeg runinstall
                formulaeUninstall "imagemagick"  # imagemagick uninstall
                formulaeUninstall "aria2"  # aria2 uninstall
                formulaeUninstall "jq"  # jq uninstall
                formulaeUninstall "vlc"  # vlc uninstall
                formulaeUninstall "aural"  # aural uninstall
                formulaeUninstall "freetube"  # freetube uninstall
                formulaeUninstall "youtube-music"  # youtube-music uninstall
                rm -f "$HOME/.ytdl.sh"; rm -f /usr/local/bin/ytdl           
                ;;
              n*|N*) echo -e "$notice ytdl uninstall skipped!";sleep 1 ;;
            esac
            ;;
        esac
  done
##########################################
