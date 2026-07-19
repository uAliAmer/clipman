# Install on Bluefin-DX / Fedora Atomic (GNOME 50, Wayland)

Tailored for immutable Fedora (Bluefin/Silverblue/Kinoite-family). No `/usr`
writes, no `rpm-ostree` layering needed — all deps already ship in the image.

## Prerequisites (verify, already present on Bluefin-DX)
```bash
command -v wl-copy wl-paste wtype ydotool ydotoold   # all should resolve
python3 -c "import gi, dbus; gi.require_version('Gtk','4.0'); gi.require_version('Adw','1')"
```
If any are missing on a non-Bluefin atomic host, layer them:
```bash
rpm-ostree install wl-clipboard wtype ydotool python3-dbus && systemctl reboot
```

## One-shot install
```bash
git clone <THIS_REPO_URL> ~/.local/share/clipman-app
cd ~/.local/share/clipman-app
./install-bluefin.sh
```
Then **log out and back in** (required: loads the GNOME extension, activates
the `input` group, starts `ydotoold`).

## What `install-bluefin.sh` does
1. Checks the deps are present (they ship in the Bluefin-DX image).
2. Runs upstream `install.sh` unmodified (needs no sudo on Bluefin since
   1.3.0). That installs the extension, `Super+V` custom keybind →
   `launcher.sh toggle`, and the user `clipman.service` (the only daemon
   owner; it removes any stale autostart `.desktop`).
3. Adds you to the `input` group (needs your sudo password) and enables the
   user `ydotoold.service` — only for the fallback paste path.

## Paste backend
Primary path is native: the GNOME Shell extension injects the keystroke with a
Clutter virtual device. `ydotool` (kernel `uinput`) is only a fallback, since
Mutter refuses the virtual-keyboard protocol `wtype` uses. See `CUSTOMIZATIONS.md`.

## Verify after relogin
```bash
id -nG | grep -qw input && echo "input group OK"
systemctl --user is-active ydotoold.service clipman.service
ls -l "$XDG_RUNTIME_DIR/.ydotool_socket"
```
Then: focus a text field → `Super+V` → click a card → it pastes.

## Uninstall
```bash
cd ~/.local/share/clipman-app && ./uninstall.sh
systemctl --user disable --now ydotoold.service
```
(Remove yourself from `input` group manually if desired:
`sudo gpasswd -d $USER input`.)
