#!/usr/bin/env bash
# PNG frame sets -> VP9 WebM, <= 800 KB each, plus a JPEG poster from frame 0.
set -euo pipefail
SCR="${TUT_SCRATCH:-/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tutorial}"
OUT="$SCR/video"; mkdir -p "$OUT"
for clip in eq-machine beta-cascade cl-sampler ldt-line zero-cube compress-ladder; do
  ffmpeg -y -loglevel error -framerate 25 -i "$SCR/frames/$clip/f%04d.png" \
    -c:v libvpx-vp9 -b:v 0 -crf 34 -row-mt 1 -pix_fmt yuv420p \
    -an "$OUT/$clip.webm"
  ffmpeg -y -loglevel error -i "$SCR/frames/$clip/f0000.png" \
    -vf scale=800:-1 -q:v 6 "$OUT/$clip.jpg"
done
ls -l "$OUT"
