#!/usr/bin/env bash

# Enable extended glob patterns at the top of this script
shopt -s extglob

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

# --- Checking Internet Connection ---
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
  echo -e "${RED}[x] Oops! No Internet Connection available. \nConnect to the Internet and try again later.${RESET}"
  exit 1
fi

# --- Golobal variables ---
fullScriptPath=$(realpath "$0")  # Get the full path of the currently running script
Music="$HOME/Music/ytdl"
Movies="$HOME/Movies/ytdl"
Pictures="$HOME/Pictures/ytdl"
mkdir -p "$Music" "$Movies" "$Pictures"  # Create directories if they don't exist

if [ ! -f "/usr/local/bin/ytdl" ]; then
  ln -s $HOME/.ytdl.sh /usr/local/bin/ytdl  # symlink (shortcut of .ytdl.sh)
fi
chmod +x $HOME/.ytdl.sh  # give execute permission to ytdl

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
  printf '\n'
  printf '\n'
}

# --- Check for dependencies ---
check_dependencies() {
  dependencies=("brew" "python3" "yt-dlp" "ffmpeg" "imagemagick" "aria2" "jq")

  for dependency in "${dependencies[@]}"; do
    installed=false
    version=""
    # Custom dependency checks
    case "$dependency" in
      # Check for Homebrew
      "brew")
        if brew --version >/dev/null 2>&1; then
          installed=true
          version=$(brew --version)
          echo "${GREEN}[+] Homebrew is already installed (Version: ${version})."
        fi
        ;;
      # Check for Python
      "python3")
        if python3 --version 2>&1 | grep -q 'Python '; then
          installed=true
          version=$(python3 --version 2>&1 | awk '{print $2}')
          echo "${GREEN}[+] Python is already installed (Version: ${version})."
        fi
        ;;
      # Check for yt-dlp
      "yt-dlp")
        if command -v yt-dlp >/dev/null 2>&1; then
          installed=true
          version=$(yt-dlp --version | grep -o '\d\+\.\d\+\.\d\+')
          echo "${GREEN}[+] yt-dlp is already installed (Version: ${version})."
        fi
        ;;
      # check for ffmpeg
      "ffmpeg")
        if command -v ffmpeg >/dev/null 2>&1; then
          installed=true
          version=$(ffmpeg -version | head -n 1 | awk '{print $3}' | cut -d'-' -f1)
          echo "${GREEN}[+] ffmpeg is already installed (Version: ${version})."
        fi
        ;;
      # Check for ImageMagick
      "imagemagick")
        if command -v magick >/dev/null 2>&1; then
          installed=true
          version=$(magick --version | grep -o 'ImageMagick [0-9.]*-[0-9]*')
          echo "${GREEN}[+] ImageMagick is already installed (Version: ${version})."
        fi
        ;;
      # check for aria2
      "aria2")
        if command -v aria2c >/dev/null 2>&1; then
          installed=true
          version=$(aria2c --version | grep -o 'aria2 version [0-9.]*')
          echo "${GREEN}[+] aria2 is already installed (Version: ${version})."
        fi
        ;;
      # Check for jq
      "jq")
        if command -v jq >/dev/null 2>&1; then
          installed=true
          version=$(jq --version | grep -o 'jq-[0-9.]*')
          echo "${GREEN}[+] jq is already installed (Version: ${version})."
        fi
        ;;
      # General executable check for unknown dependencies
      *)
        if command -v "$dependency" >/dev/null 2>&1; then
          installed=true
          echo "${GREEN}[+]${RESET} '$dependency' is already installed."
        fi
        ;;
    esac

    # If the dependency is not installed, attempt to install it
    if ! "$installed"; then
      echo "${YELLOW}[!]$RESET '$dependency' is not installed. Attempting to install..."
      case "$dependency" in
          "brew")
              echo "${YELLOW}[!]$RESET Installing Homebrew..."
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1
              ;;
          "python3")
              echo "${YELLOW}[!]$RESET Installing Python using Brew..."
              brew install python@3.13 > /dev/null 2>&1
              ;;
          "yt-dlp")
              echo "${YELLOW}[!]$RESET Installing yt-dlp using Brew..."
              brew install yt-dlp > /dev/null 2>&1
              ;;
          "ffmpeg")
              echo "${YELLOW}[!]$RESET Installing ffmpeg using Brew..."
              brew install ffmpeg > /dev/null 2>&1
              ;;
          "imagemagick")
              echo "${YELLOW}[!]$RESET Installing ImageMagick using Brew..."
              brew install imagemagick > /dev/null 2>&1
              ;;
          "aria2")
              echo "${YELLOW}[!]$RESET Installing aria2 using Brew..."
              brew install aria2 > /dev/null 2>&1
              ;;
          "jq")
              echo "${YELLOW}[!]$RESET Installing jq using Brew..."
              brew install jq > /dev/null 2>&1
              ;;
      esac

      # Recheck installation to verify success
      installed=false
      case "$dependency" in
          "brew")
            if brew --version >/dev/null 2>&1; then
              installed=true
            fi
            ;;
          "python3")
            if python3 --version 2>&1 | grep -q 'Python '; then
              installed=true
            fi
            ;;
          "yt-dlp")
            if command -v yt-dlp >/dev/null 2>&1; then
              installed=true
            fi
            ;;
          "ffmpeg")
            if command -v ffmpeg >/dev/null 2>&1; then
              installed=true
            fi
            ;;
          "imagemagick")
            if command -v magick >/dev/null 2>&1; then
              installed=true
            fi
            ;;
          "aria2")
            if command -v aria2c >/dev/null 2>&1; then
              installed=true
            fi
            ;;
          "jq")
            if command -v jq >/dev/null 2>&1; then
              installed=true
            fi
            ;;
      esac

      if "$installed"; then
        echo "${GREEN}[+]${RESET} '$dependency' installed and verified successfully."
        else
          echo "${RED}[x]${RESET} Installation verification failed for '$dependency'."
          echo "${YELLOW}[!]$RESET Please install '$dependency' manually and re-run the script."
          exit 1
        fi
    fi
  done
}

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
    if echo "$url 2>&1" | grep -qF "playlist"; then
      total=$(yt-dlp --flat-playlist --get-title "$url" 2>/dev/null | awk 'END{print NR}')
      echo -e "$info The entered URLs contain a playlist with a total of $total videos.\n"
      read -r -p "Download [E]ntire playlist or [S]elect videos? (E/S): " choice
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
          elif !(echo "$url" | grep -qE "/youtube.com|w.youtube.com|/youtu.be"); then
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

# --- ytdl main menu functions ---
if brew --version 2>&1 | grep "Homebrew" >/dev/null && python3 --version 2>&1 | grep -q 'Python ' && command -v yt-dlp >/dev/null 2>&1 && ffmpeg -version | grep -q "ffmpeg version" && magick --version 2>&1 | grep -q 'ImageMagick [0-9.]*-[0-9]*' && aria2c --version 2>&1 | grep -q 'aria2 version [0-9.]*' && jq --version 2>&1 | grep -q 'jq-[0-9.]*'; then
  # Please uncheck 'Resotre text when reopening windows' option in Terminal > Settings > Profiles > Window
  printf '\033[2J\033[3J\033[H'  # fully clear the screen and reset scrollback  # \033[2J: Clears visible screen. # \033[3J: Clears scrollback buffer (macOS). # \033[H: Moves cursor to top-left.
  if brew outdated 2>/dev/null | grep -q "^yt-dlp"; then
    echo -e "$info yt-dlp update available, please select 'Up' to update.\n"
    open "https://github.com/yt-dlp/yt-dlp/releases/"
  fi
  while true; do
    print_ytdlp
    echo -e "Up. Update \nOp. Online Play \nDl. Download \nPl. Player \nRe. Reinstall \nUn. Uninstall \nQu. Quit \n"
        read -r -p "Select: " input
        echo -e "\n"
        case "$input" in
          [Uu][pp]*)
            curl -o "$HOME/.ytdl.sh" "https://raw.githubusercontent.com/arghya339/ytdl/refs/heads/main/ytdl.sh" > /dev/null 2>&1
            if which brew > /dev/null 2>&1 && ! brew update 2>&1 | grep -q "Already up-to-date";  then
              echo -e "$running Updating Homebrew.."
              brew update > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^python@"; then
              echo -e "$running Updating python.."
              brew upgrade --formulae  python > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^yt-dlp"; then
              echo -e "$running Updating yt-dlp.."
              brew upgrade --formulae yt-dlp > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^ffmpeg"; then
              echo -e "$running Updating ffmpeg.."
              brew upgrade --formulae ffmpeg > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^imagemagick"; then
              echo -e "$running Updating ImageMagick.."
              brew upgrade --formulae imagemagick > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^aria2"; then
              echo -e "$running Updating aria2.."
              brew upgrade --formulae aria2 > /dev/null 2>&1
            fi
            if brew outdated 2>/dev/null | grep -q "^jq"; then
              echo -e "$running Updating jq.."
              brew upgrade --formulae jq > /dev/null 2>&1
            fi
            if brew list 2>/dev/null | grep -q "^vlc" && brew outdated 2>/dev/null | grep -q "vlc"; then
              echo -e "$running Updating vlc.."
              brew upgrade --cask vlc > /dev/null 2>&1
            fi
            if brew list 2>/dev/null | grep -q "^aural" && brew outdated 2>/dev/null | grep -q "aural"; then
              echo -e "$running Updating aural.."
              brew upgrade --cask aural > /dev/null 2>&1
            fi
            if brew list 2>/dev/null | grep -q "^freetube" && brew outdated 2>/dev/null | grep -q "freetube"; then
              echo -e "$running Updating freetube.."
              brew upgrade --cask freetube > /dev/null 2>&1
            fi
            if brew list 2>/dev/null | grep -q "^youtube-music" && brew outdated 2>/dev/null | grep -q "youtube-music"; then
              echo -e "$running Updating youtube-music.."
              brew upgrade --cask youtube-music > /dev/null 2>&1
            fi
            sleep 1  # wait 1 second
            ;;
          [Oo][Pp]*)
            echo -e "$running Installing Online Player..."
            brew install freetube > /dev/null 2>&1  # install freetube for online YT video playback
            brew install th-ch/youtube-music/youtube-music > /dev/null 2>&1  # install youtube-music for online YT Music audio playback
            ;;
          [Dd][Ll]*)
            dl  # Call the download function
            ;;
          [Pp][Ll]*)
            ehco -e "$running Installing Player..."
            brew install vlc > /dev/null 2>&1  # install vlc player for video playback
            brew install aural > /dev/null 2>&1  # install aural player for audio playback
            ;;
          [Rr][ee]*)
            echo -e "$running Reinstalling Python..."
            brew reinstall python > /dev/null 2>&1
            echo -e "$running Reinstalling yt-dlp..."
            brew uninstall yt-dlp > /dev/null 2>&1
            #rm /usr/local/bin/yt-dlp
            brew install yt-dlp > /dev/null 2>&1
            brew link yt-dlp > /dev/null 2>&1
            echo -e "$running Reinstalling ffmpeg..."
            brew reinstall ffmpeg > /dev/null 2>&1
            echo -e "$running Reinstalling ImageMagick..."
            brew reinstall imagemagick > /dev/null 2>&1
            echo -e "$running Reinstalling aria2..."
            brew reinstall aria2 > /dev/null 2>&1
            echo -e "$running Reinstalling jq..."
            brew reinstall jq > /dev/null 2>&1
            sleep 1  # wait 1 second
            ;;
          [Uu][Nn]*)
            # Prompt for user choice on uinstallation of python and yt-dlp
            echo "${YELLOW}Do you want to uninstall python and yt-dlp? [Y/n]${RESET}"
            read -r -p "Select: " opt
            case $opt in
              y*|Y*)
                echo -e "$running Uninstalling python.."
                brew uninstall --ignore-dependencies python > /dev/null 2>&1
                echo -e "$running Uninstalling yt-dlp.."
                brew uninstall yt-dlp > /dev/null 2>&1
                echo -e "$running Uninstalling ffmpeg.."
                brew uninstall ffmpeg > /dev/null 2>&1
                echo -e "$running Uninstalling ImageMagick.."
                brew uninstall imagemagick > /dev/null 2>&1
                echo -e "$running Uninstalling aria2.."
                brew uninstall aria2 > /dev/null 2>&1
                echo -e "$running Uninstalling jq.."
                brew uninstall jq > /dev/null 2>&1
                if brew list 2>/dev/null | grep -q "^vlc"; then
                  echo -e "$running Uninstalling vlc.."
                  brew uninstall vlc > /dev/null 2>&1
                fi
                if brew list 2>/dev/null | grep -q "^aural"; then
                  echo -e "$running Uninstalling aural.."
                  brew uninstall aural > /dev/null 2>&1
                fi
                if brew list 2>/dev/null | grep -q "^freetube"; then
                  echo -e "$running Uninstalling freetube.."
                  brew uninstall freetube > /dev/null 2>&1
                fi
                if brew list 2>/dev/null | grep -q "^youtube-music"; then
                  echo -e "$running Uninstalling youtube-music.."
                  brew uninstall youtube-music > /dev/null 2>&1
                fi
                #rm /usr/local/bin/ytdl
                #rm $HOME/ytdl.sh              
                ;;
              n*|N*) echo -e "$notice yt-dlp uninstall skipped.";sleep 1 ;;
              *) echo -e "$info Invalid choice. ytdl uninstall skipped."; sleep 2 ;;
            esac
            ;;
          [Qq]*)
            echo -e "$info Exiting.."
            sleep 0.5  # wait 500 milliseconds
            printf '\033[2J\033[3J\033[H'  # clear Terminal
            break  # Break out of the loop
            ;;
          *)
            echo -e "$info Invalid input! Please enter: Up / Op / Dl / Pl / Re / Un / Qu"
            sleep 6  # wait 6 seconds (1 seconds = 1000 milliseconds)
            printf '\033[2J\033[3J\033[H'
            ;;
        esac
        printf '\033[2J\033[3J\033[H' # clear Terminal
        echo  # Add empty line for spacing before next prompt
  done
else
  print_ytdlp  # Print the ytdlp shape
  check_dependencies  # Check for dependencies
  echo "${GREEN}✨ Powered by yt-dlp (github.com/yt-dlp/yt-dlp)"
  open "https://github.com/yt-dlp/yt-dlp"
  sleep 3  # wait 3 seconds
  printf '\033[2J\033[3J\033[H'  # clear previous session
  bash $fullScriptPath  # run script again
  exit 1
fi
##########################################