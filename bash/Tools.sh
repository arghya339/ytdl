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
