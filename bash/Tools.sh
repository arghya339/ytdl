#!/bin/bash

# Copyright (C) 2025, Arghyadeep Mondal <github.com/arghya339>

MKV2MP4() {
  filePath=${1}
  mkdir -p $Movies/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -c copy -map 0:v -map 0:a "$Movies/Convert/$fileNameWOExt.mp4"
}

MP42MKV() {
  filePath=${1}
  mkdir -p $Movies/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -c copy -map 0 "$Movies/Convert/$fileNameWOExt.mkv"
}

Video2MP3() {
  filePath=${1}
  mkdir -p $Music/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -map a -c:a libmp3lame -q:a 0 "$Music/Convert/$fileNameWOExt.mp3"
}

Video2M4A() {
  filePath=${1}
  mkdir -p $Music/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -vn -c:a aac -q:a 192k "$Music/Convert/$fileNameWOExt.m4a"
  #mv "$Music/Convert/$fileNameWOExt.m4a" "$Music/Convert/$fileNameWOExt.m4r"  # for iPhone
}

Video2MP3Ringtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -vn -c:a libmp3lame -q:a 0 "$Music/Ringtone/$fileNameWOExt.mp3"
}

Video2M4ARingtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -vn -c:a aac -b:a 192k "$Music/Ringtone/$fileNameWOExt.m4a"
  #mv "$Music/Ringtone/$fileNameWOExt.m4a" "$Music/Ringtone/$fileNameWOExt.m4r"  # for iPhone
}

M4A2MP3() {
  filePath=${1}
  mkdir -p $Music/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -c:a libmp3lame -q:a 0 -c:v copy "$Music/Convert/$fileNameWOExt.mp3"
}

MP32M4A() {
  filePath=${1}
  mkdir -p $Music/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -c:a aac -b:a 192k -c:v copy "$Music/Convert/$fileNameWOExt.m4a"
  #mv "$Music/Convert/$fileNameWOExt.m4a" "$Music/Convert/$fileNameWOExt.m4r"  # for iPhone
}

Audio2AudioRingtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  file_ext=${fileName##*.}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -c copy "$Music/Ringtone/temp.$file_ext"
  ffmpeg -y -v quiet -i "$Music/Ringtone/temp.$file_ext" -i "$filePath" -map 0:a -map 1:v -c:v copy "$Music/Ringtone/$fileNameWOExt.$file_ext"
  rm -f "$Music/Ringtone/temp.$file_ext"
  #[ "$file_ext" == "m4a" ] && mv "$Music/Ringtone/$fileNameWOExt.m4a" "$Music/Ringtone/$fileNameWOExt.m4r"  # for iPhone
}

M4A2MP3Ringtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -ss $start_time -i "$filePath" -t 30 -c:a libmp3lame -q:a 0 -c:v copy "$Music/Ringtone/$fileNameWOExt.mp3"
}

MP32M4ARingtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -ss $start_time -i "$filePath" -t 30 -c:a aac -b:a 192k -c:v copy "$Music/Ringtone/$fileNameWOExt.m4a"
  #mv "$Music/Ringtone/$fileNameWOExt.m4a" "$Music/Ringtone/$fileNameWOExt.m4r"  # for iPhone
}

Images2Images() {
  filePath=${1}
  CONVERT2=$2
  mkdir -p $Pictures/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  case "$CONVERT2" in
    jpg|jpeg) ffmpeg -y -v quiet -i "$filePath" -q:v 1 "$Pictures/Convert/$fileNameWOExt.$CONVERT2" ;;
    *) ffmpeg -y -v quiet -i "$filePath" -lossless 1 "$Pictures/Convert/$fileNameWOExt.$CONVERT2" ;;
  esac
}

Video2GIF() {
  filePath=${1}
  start_time=$2
  mkdir -p $Pictures/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -hide_banner -loglevel error -ss $start_time -t 3 -i "$filePath" -map 0:v:0 -vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=single[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" "$Pictures/Convert/$fileNameWOExt.gif"
}

GIF2Video() {
  filePath=${1}
  CONVERT2=$2
  mkdir -p $Movies/Convert
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  [ "$CONVERT2" == "mp4" ] && ffmpeg -y -v quiet -i "$filePath" -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$Movies/Convert/$fileNameWOExt.mp4" || ffmpeg -y -v quiet -i "$filePath" -c:v libx264 -crf 20 -pix_fmt yuv420p "$Movies/Convert/$fileNameWOExt.mkv"
}