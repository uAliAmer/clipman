#!/bin/bash
# Bluefin-DX / Fedora atomic installer for this clipman fork.
# Idempotent. No /usr writes, no rpm-ostree layering (deps ship in image).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/3] Dependency check ==="
missing=()
for c in wl-copy wl-paste wtype ydotool ydotoold python3; do
    command -v "$c" >/dev/null 2>&1 || missing+=("$c")
done
python3 -c "import gi, dbus; gi.require_version('Gtk','4.0'); gi.require_version('Adw','1')" \
    2>/dev/null || missing+=("python3-gi/dbus/GTK4/Adw")
if [ "${#missing[@]}" -ne 0 ]; then
    echo "Missing: ${missing[*]}"
    echo "Layer them:  rpm-ostree install wl-clipboard wtype ydotool python3-dbus && systemctl reboot"
    exit 1
fi
echo "  all deps present"

echo "=== [2/3] Run upstream install.sh ==="
# Upstream >= 1.3.0 needs no atomic-host patching: scripts/deps.sh checks
# packages with rpm -q (all present in the image, so no sudo/dnf), the
# extension declares GNOME 45-51, and install.sh itself removes any stale
# autostart .desktop so clipman.service is the only daemon owner.
bash "$SCRIPT_DIR/install.sh"

echo "=== [3/3] Fallback paste backend: input group + ydotoold ==="
if id -nG "$USER" | grep -qw input; then
    echo "  already in 'input' group"
else
    echo "  adding $USER to 'input' group (sudo)..."
    sudo usermod -aG input "$USER" && echo "  added — RELOGIN required"
fi
systemctl --user enable ydotoold.service && echo "  ydotoold.service enabled"

cat <<EOF

=== Done ===
LOG OUT and back in, then verify:
  id -nG | grep -qw input && echo input-OK
  systemctl --user is-active ydotoold.service clipman.service
Usage: focus a text field -> Super+V -> click a card -> pastes.
EOF
