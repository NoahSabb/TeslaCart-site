#!/bin/bash
# prep-media.sh — convert a phone photo/video into the exact file the site wants.
#
#   ./prep-media.sh [options] <input-file> <slot> [start] [duration]
#   ./prep-media.sh --list
#
# Options (videos only):
#   --speed N      play N times faster (2 = 2x, 0.5 = half speed / slow motion)
#   --boomerang    play forward then backward, so it loops seamlessly
#
# Examples:
#   ./prep-media.sh ~/Desktop/IMG_1234.HEIC cart-wide
#   ./prep-media.sh ~/Desktop/IMG_5678.MOV steering-test
#   ./prep-media.sh ~/Desktop/IMG_5678.MOV hero 00:00:04 12   # trim: 12s from 0:04
#   ./prep-media.sh --speed 2 ~/Desktop/long.MOV brake-bench  # 2x faster
#   ./prep-media.sh --boomerang ~/Desktop/sweep.MOV hero 0 4  # seamless 8s loop
#
# Originals are never modified. Output always lands in assets/ with the right name.

set -euo pipefail
cd "$(dirname "$0")"

SLOTS="hero:mp4 hero-poster:jpg cart-wide:jpg wiring-diagram:png \
electronics-closeup:jpg detectnet:jpg steering-test:mp4 brake-bench:mp4 \
drive-test:mp4 camera-mount-cad:png"

MAXW=2000        # max image width in px
VIDH=1080        # max video height in px
CRF="${CRF:-24}"   # video quality: lower = better + bigger. Override: CRF=28 ./prep-media.sh ...

die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

list_slots() {
  printf '\n  %-22s %-7s %s\n' SLOT MAKES STATUS
  printf '  %s\n' "----------------------------------------------------"
  for pair in $SLOTS; do
    slot="${pair%%:*}"; ext="${pair##*:}"; f="assets/$slot.$ext"
    if [ -f "$f" ]; then
      status="$(du -h "$f" | cut -f1 | tr -d ' ') — in place"
    else
      status="missing"
    fi
    printf '  %-22s %-7s %s\n' "$slot" ".$ext" "$status"
  done
  echo
}

SPEED=""; BOOM=0; POS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --list|-l)   list_slots; exit 0 ;;
    --speed)     SPEED="${2:-}"; shift 2 ;;
    --speed=*)   SPEED="${1#*=}"; shift ;;
    --boomerang) BOOM=1; shift ;;
    -h|--help)   sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          die "unknown option: $1" ;;
    *)           POS+=("$1"); shift ;;
  esac
done
set -- ${POS[@]+"${POS[@]}"}
[ $# -ge 2 ] || { echo "usage: $0 [--speed N] [--boomerang] <input-file> <slot> [start] [duration]"; list_slots; exit 1; }

IN="$1"; SLOT="$2"; START="${3:-}"; DUR="${4:-}"

if [ -n "$SPEED" ]; then
  awk -v s="$SPEED" 'BEGIN{exit !(s+0>0)}' || die "--speed needs a positive number (2 = 2x, 0.5 = slow motion)"
fi
[ -f "$IN" ] || die "no such file: $IN"

EXT=""
for pair in $SLOTS; do [ "${pair%%:*}" = "$SLOT" ] && EXT="${pair##*:}"; done
[ -n "$EXT" ] || { echo "unknown slot: $SLOT" >&2; list_slots; exit 1; }

OUT="assets/$SLOT.$EXT"
mkdir -p assets

# Is the input a video? Ask the file itself, not the extension.
if file -b --mime-type "$IN" | grep -q '^video/'; then IN_KIND=video; else IN_KIND=image; fi

if [ "$EXT" = "mp4" ]; then
  [ "$IN_KIND" = video ] || die "slot '$SLOT' needs a video, but that file is an image."
  TRIM=()
  [ -n "$START" ] && TRIM+=(-ss "$START")
  [ -n "$DUR" ]   && TRIM+=(-t "$DUR")

  # scale, then optional speed change
  CHAIN="scale=-2:'min($VIDH,ih)'"
  [ -n "$SPEED" ] && CHAIN="$CHAIN,setpts=PTS/$SPEED"

  DESC="video"
  [ -n "$SPEED" ] && DESC="$DESC at ${SPEED}x"
  [ "$BOOM" = 1 ] && DESC="$DESC, boomerang"
  echo "converting $DESC -> $OUT"

  # ${TRIM[@]+...} guard: bash 3.2 (macOS) errors on an empty array under `set -u`
  if [ "$BOOM" = 1 ]; then
    # reverse holds every frame in memory, so keep boomerang sources short
    LEN=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$IN" 2>/dev/null || echo 0)
    SRCLEN="${DUR:-$LEN}"
    awk -v l="$SRCLEN" 'BEGIN{exit !(l+0>30)}' && \
      echo "note: boomeranging a long clip is memory-hungry — consider trimming first."
    ffmpeg -hide_banner -loglevel error -y ${TRIM[@]+"${TRIM[@]}"} -i "$IN" \
      -filter_complex "[0:v]$CHAIN,split[a][b];[b]reverse[r];[a][r]concat=n=2:v=1[out]" \
      -map "[out]" -c:v libx264 -crf "$CRF" -preset slow \
      -pix_fmt yuv420p -movflags +faststart -an "$OUT"
  else
    ffmpeg -hide_banner -loglevel error -y ${TRIM[@]+"${TRIM[@]}"} -i "$IN" \
      -vf "$CHAIN" -c:v libx264 -crf "$CRF" -preset slow \
      -pix_fmt yuv420p -movflags +faststart -an "$OUT"
  fi
else
  if [ "$IN_KIND" = video ]; then
    # pull a still frame out of a video (handy for hero-poster)
    echo "extracting frame at ${START:-00:00:00} -> $OUT"
    ffmpeg -hide_banner -loglevel error -y -ss "${START:-00:00:00}" -i "$IN" \
      -frames:v 1 -vf "scale='min($MAXW,iw)':-2" "$OUT"
  else
    W=$(sips -g pixelWidth "$IN" 2>/dev/null | awk '/pixelWidth/{print $2}')
    echo "converting image (${W:-?}px wide) -> $OUT"
    if [ -n "$W" ] && [ "$W" -gt "$MAXW" ]; then
      sips -s format "${EXT/jpg/jpeg}" -Z "$MAXW" "$IN" --out "$OUT" >/dev/null
    else
      sips -s format "${EXT/jpg/jpeg}" "$IN" --out "$OUT" >/dev/null
    fi
  fi
fi

SIZE=$(du -h "$OUT" | cut -f1 | tr -d ' ')
BYTES=$(stat -f%z "$OUT")
printf '\033[32mdone:\033[0m %s (%s)\n' "$OUT" "$SIZE"
if [ "$BYTES" -gt 10485760 ]; then
  echo "note: that's over 10 MB — consider trimming it shorter, or re-run with a higher CRF:"
  echo "      CRF=28 is noticeably smaller. Edit CRF at the top of this script."
fi
