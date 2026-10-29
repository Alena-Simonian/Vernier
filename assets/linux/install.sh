#!/usr/bin/env bash
#
# Installs Vernier for the current user, out of the unpacked release tarball.
#
# Everything lands under ~/.local, so this never needs root and never fights
# the distribution's package manager over a path it owns.
#
# Usage: ./install.sh [--uninstall]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
ICONS="$HOME/.local/share/icons/hicolor"
APPS="$HOME/.local/share/applications"
SIZES=(16 32 64 128 256 512)

refresh() {
  # Both are optional: a desktop without them still reads the directories on
  # its own schedule, and a headless box has neither installed.
  if command -v update-desktop-database >/dev/null; then
    update-desktop-database "$APPS" || true
  fi
  if command -v gtk-update-icon-cache >/dev/null; then
    gtk-update-icon-cache -qtf "$ICONS" || true
  fi
}

if [[ "${1:-}" == --uninstall ]]; then
  rm -f "$BIN/vernier" "$APPS/vernier.desktop"
  for size in "${SIZES[@]}"; do
    rm -f "$ICONS/${size}x${size}/apps/vernier.png"
  done
  refresh
  # Connections, query history and saved passwords are deliberately left: an
  # uninstall here is usually a reinstall, and they live outside all of this.
  echo "removed vernier -- data in ~/.local/share/vernier was left alone"
  exit 0
fi

mkdir -p "$BIN" "$APPS"
install -m 755 "$HERE/vernier" "$BIN/vernier"
# Exec gets the absolute path rather than the bare name the entry ships with:
# a desktop launches its entries with the session's PATH, and ~/.local/bin only
# joins that at login -- and only when it already existed. Bare `vernier` would
# leave the icon there and do nothing when clicked, until the next login.
sed "s|^Exec=vernier |Exec=$BIN/vernier |" "$HERE/vernier.desktop" > "$APPS/vernier.desktop"
chmod 644 "$APPS/vernier.desktop"
for size in "${SIZES[@]}"; do
  mkdir -p "$ICONS/${size}x${size}/apps"
  install -m 644 "$HERE/icons/vernier-$size.png" "$ICONS/${size}x${size}/apps/vernier.png"
done
refresh

echo "installed $BIN/vernier"
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "note: $BIN is not on your PATH, so running vernier from a terminal needs a new login -- the menu entry works now regardless" >&2 ;;
esac
