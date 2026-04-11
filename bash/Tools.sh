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
  ffmpeg -y -v quiet -i "$filePath" -c:a aac -b:a 192k -c:v copy -disposition:v:0 attached_pic "$Music/Convert/$fileNameWOExt.m4a"
  #mv "$Music/Convert/$fileNameWOExt.m4a" "$Music/Convert/$fileNameWOExt.m4r"  # for iPhone
}

Audio2AudioRingtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  file_ext=${fileName##*.}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -c copy "$Music/Ringtone/$fileNameWOExt.$file_ext"
  #[ "$file_ext" == "m4a" ] && mv "$Music/Ringtone/$fileNameWOExt.m4a" "$Music/Ringtone/$fileNameWOExt.m4r"  # for iPhone
}

M4A2MP3Ringtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -c:a libmp3lame -q:a 0 "$Music/Ringtone/$fileNameWOExt.mp3"
}

MP32M4ARingtone() {
  filePath=${1}
  start_time=$2
  mkdir -p $Music/Ringtone
  fileName=$(basename "$filePath")
  fileNameWOExt=${fileName%.*}
  ffmpeg -y -v quiet -i "$filePath" -ss $start_time -t 30 -c aac -b:a 192k "$Music/Ringtone/$fileNameWOExt.m4a"
  #mv "$Music/Ringtone/$fileNameWOExt.m4a" "$Music/Ringtone/$fileNameWOExt.m4r"  # for iPhone
}