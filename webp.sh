#!/bin/sh
set -o nounset
set -o errexit
bn=$(echo "$1"|cut -d'.' -f 1)
cwebp -q 80 -o "${bn}.webp" $1
case "$bn" in
*banner*)
  cwebp -q 80 -o "${bn}-1440x500.webp" -resize 1440 500 "$1"
  cwebp -q 80 -o "${bn}-1024x356.webp" -resize 1024 356 "$1"
  cwebp -q 80 -o "${bn}-768x267.webp" -resize 768 267 "$1"
  cwebp -q 80 -o "${bn}-300x104.webp" -resize 300 104 "$1"
  cwebp -q 80 -o "${bn}-474x342.webp" -resize 474 342 -crop 373 0 693 500 "$1"
  ;;
*logo*)
  cwebp -q 80 -o "${bn}-100.webp" -resize 100 0 "$1"
  ;;
*side*)
  cwebp -q 80 -o "${bn}-200x413.webp" -resize 200 413 "$1"
  ;;
esac
