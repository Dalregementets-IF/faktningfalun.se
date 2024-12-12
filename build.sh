#!/usr/bin/env sh
srcfile=$1
destfile=$2

mkdir -p "${destfile%/*}"
cp $TMPL/header.html build/header.tmp
cp $TMPL/footer.html build/footer.tmp
basename=${srcfile##*/}
basename=${basename%.*}
export PAGE_TITLE=$(grep -m1 'title: ' "$srcfile" | cut -d' ' -f2-)
export DESCRIPTION=$(grep -m1 'description: ' "$srcfile" | cut -d' ' -f2-)
export KEYWORDS=$(grep -m1 'keywords: ' "$srcfile" | cut -d' ' -f2-)
sideimages=$(grep -m1 'sideimages: ' "$srcfile" | cut -d' ' -f2-)
banner=0
nostatic=0
notitle=0
for flag in $(grep -m1 'flags: ' "$srcfile" | cut -d' ' -f2-); do
    case $flag in
        notitle)
            notitle=1
            ;;
        banner)
            banner=1
            ;;
        *)
            echo "unknown flag: $flag"
            ;;
    esac
done
if [ $notitle -eq 1 ]; then
    export TITLE=$SITE_TITLE
else
    export TITLE="$PAGE_TITLE · $SITE_TITLE"
fi
if [ $banner -eq 1 ]; then
    export BANNER="banner-$basename"
    sed -i -e "/<!-- BANNER -->/{r ${TMPL}/banner.html" -e 'd}' build/header.tmp
fi
envsubst < build/header.tmp > "$destfile"

content=$(tail -n+8 "$srcfile")

if [ -n "$sideimages" ]; then
    tmp="<div id=\"primary\">
  <div class=\"entry-content clearfix\">
    $content
  </div>
</div>
<div id=\"secondary\">"
    for img in $sideimages; do
        tmp="$tmp
<div class=\"paintoverlay\">
  <img alt=\"\" loading=\"lazy\" src=\"img/$img-200.webp\">
  <div class=\"side\"></div>
</div>"
    done
    tmp="$tmp
</div>"
else
    tmp="<div class=\"entry-content clearfix\">
  $content
</div>"
fi
    echo "$tmp" >> "$destfile"
envsubst < build/footer.tmp >> "$destfile"
rm build/*.tmp
