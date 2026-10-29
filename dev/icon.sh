#!/usr/bin/env bash
#
# Renders assets/icon/vernier.svg into every platform's icon: the macOS .icns,
# the Windows .ico and the Linux PNGs. The outputs are committed so building
# and packaging never need an SVG renderer -- run this after changing the SVG.
#
# Needs resvg and ImageMagick: brew install resvg imagemagick
#
# Usage: dev/icon.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SVG=assets/icon/vernier.svg
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

render() { resvg -w "$1" -h "$1" "$SVG" "$2"; }

for SIZE in 16 32 64 128 256 512; do
  render "$SIZE" "assets/linux/icons/vernier-$SIZE.png"
done

mkdir "$TMP/Vernier.iconset"
for SIZE in 16 32 128 256 512; do
  render "$SIZE" "$TMP/Vernier.iconset/icon_${SIZE}x${SIZE}.png"
  render "$((SIZE * 2))" "$TMP/Vernier.iconset/icon_${SIZE}x${SIZE}@2x.png"
done
iconutil -c icns "$TMP/Vernier.iconset" -o assets/macos/Vernier.icns

magick assets/linux/icons/vernier-{16,32,64,128,256}.png assets/windows/vernier.ico
