#!/bin/sh
set -o nounset
set -o errexit
fcver="6.1.10"
icver="1.5.0"
rrver="2.6.4"
wdir="tmp/"
fcdir="${wdir}/fullcalendar-${fcver}"
fcout="${fcdir}.zip"
icout="${wdir}/ical.min.js"
rrout="${wdir}/rrule.min.js"
mkdir -p "${wdir}"
if [ ! -f "${icout}" ]; then
  wget "https://github.com/kewisch/ical.js/releases/download/v${icver}/ical.min.js" -O "${icout}"
  echo "\n" >> "${icout}"
fi
if [ ! -f "${rrout}" ]; then
  wget "https://cdn.jsdelivr.net/npm/rrule@${rrver}/dist/es5/rrule.min.js" -O "${rrout}"
fi
if [ ! -f "${fcout}" ]; then
  wget "https://github.com/fullcalendar/fullcalendar/releases/download/v${fcver}/fullcalendar-${fcver}.zip" -O "${fcout}"
fi
mkdir -p "${fcdir}"
unzip -o "${fcout}" \
    fullcalendar-${fcver}/packages/core/index.global.min.js \
    fullcalendar-${fcver}/packages/core/locales/sv.global.min.js \
    fullcalendar-${fcver}/packages/daygrid/index.global.min.js \
    fullcalendar-${fcver}/packages/list/index.global.min.js \
    fullcalendar-${fcver}/packages/rrule/index.global.min.js \
    fullcalendar-${fcver}/packages/luxon3/index.global.min.js \
    -d "${wdir}"
cat "${icout}" \
    ${rrout} \
    ${fcdir}/packages/core/index.global.min.js \
    ${fcdir}/packages/core/locales/sv.global.min.js \
    ${fcdir}/packages/daygrid/index.global.min.js \
    ${fcdir}/packages/list/index.global.min.js \
    ${fcdir}/packages/rrule/index.global.min.js \
    ${fcdir}/packages/luxon3/index.global.min.js \
    data/js/buildcalendar.js \
    > data/js/calendar.min.js
