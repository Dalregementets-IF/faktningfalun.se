#!/bin/sh
set -o nounset
set -o errexit

mkdir -p build/img 
for f in $(find $1/*); do
    relpath=${f#${1}/}
    destbase="build/img/${relpath%.*}"
    if [ -d $f ]; then
        mkdir -p $destbase
        continue
    fi
    if [ -f "${destbase}.webp" ]; then
        continue
    fi
    cwebp -q 80 -o "${destbase}.webp" $f
    case "${destbase##*/}" in
    banner-* | *-banner)
      cwebp -q 80 -o "${destbase}-1440x500.webp" -resize 1440 500 "$f"
      cwebp -q 80 -o "${destbase}-1024x356.webp" -resize 1024 356 "$f"
      cwebp -q 80 -o "${destbase}-768x267.webp" -resize 768 267 "$f"
      cwebp -q 80 -o "${destbase}-300x104.webp" -resize 300 104 "$f"
      cwebp -q 80 -o "${destbase}-474x342.webp" -resize 474 342 -crop 373 0 693 500 "$f"
      ;;
    *logo*)
      cwebp -q 80 -o "${destbase}-100.webp" -resize 100 0 "$f"
      ;;
    side-* | qr-* | *-side)
      cwebp -q 80 -o "${destbase}-200.webp" -resize 200 0 "$f"
      ;;
    *pictogram*)
      cwebp -q 80 -o "${destbase}-35.webp" -resize 35 0 "$f"
      ;;
    esac
done
