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