# Customizations (fork of MohammedEl-sayedAhmed/clipman)

Personal fork of [clipman](https://github.com/MohammedEl-sayedAhmed/clipman) (Apache-2.0)
running on **Bluefin-DX (Fedora atomic), GNOME Shell 50, Wayland**.

Tracks **upstream v1.3.0**. Since 1.2 upstream paste is **native**: the GNOME
Shell extension restores focus (`RestorePreviousFocus`) and injects the
keystroke with a Clutter virtual device (`SimulatePaste`) — inside the
compositor, so it works where `wtype` cannot. This makes the old fork
`window.py` ydotool/keycode hacks unnecessary; they were dropped when merging
1.2. `wtype`/`ydotool` remain only as a fallback for non-GNOME compositors.

## Remaining fork deltas

**None.** Up to 1.2.0 `install-bluefin.sh` patched two things at deploy time
(extension `shell-version` 45–48 → 45–50, and the `sudo dnf/apt` dep step).
Upstream 1.3.0 made both unnecessary: the extension declares GNOME 45–51, and
`scripts/deps.sh` checks packages with `rpm -q`, which pass on Bluefin, so
`install.sh` runs unmodified with no sudo.

## Fork-only files

- `install-bluefin.sh` — idempotent atomic-host installer (dep check, runs
  upstream `install.sh` unmodified, sets up the ydotool fallback backend).
- `INSTALL-BLUEFIN.md` — setup + verification.
- This file.

## Runtime note (fallback only)

The `ydotool` fallback path still needs **ydotoold running** + user in the
**`input` group** (`/dev/uinput`). On GNOME 50 the native extension path is
primary, so this is belt-and-suspenders. See `INSTALL-BLUEFIN.md`.
