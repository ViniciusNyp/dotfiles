# Dotfiles

Personal dotfiles, managed as a bare Git repository with `$HOME` as the work tree.

## Cross-platform

One repo, three targets: **macOS**, **Linux**, and **Linux under WSL2**. Knowing that explains the layout:

- Linux-only configs (`dconf`, `gtk-3.0/4.0`, `nautilus`, `tiling-assistant`, `alacritty.toml`) coexist with macOS-only ones (`.aerospace.toml`, `.config/sketchybar/`, `.config/karabiner/`, `.macos`). Neither set is dead weight.
- `.zshrc` is shared. Anything OS-specific is guarded: Homebrew shellenv only runs if `/opt/homebrew` exists, and Debian's renamed binaries (`batcat`, `fdfind`) are aliased back to `bat`/`fd` only where present.
- `.macos` (system defaults) exits early on non-Darwin, so it's safe to run blindly from a bootstrap.

## macOS desktop stack

Non-obvious wiring, in dependency order:

- **AeroSpace** (`.aerospace.toml`) is the tiling WM and the event source: workspace/monitor changes trigger SketchyBar via custom events. Top gaps are per-monitor — 0 on the notched built-in display, 28 on externals — because the bar overlays the notch strip (`notch_display_height`).
- **SketchyBar** (`.config/sketchybar/`) draws an "islands" bar on a transparent window, configured through **SbarLua** (`sketchybarrc` is Lua via `lua@5.4`; the module auto-builds from a pinned commit on first run). Plugins remain shell scripts with native event subscriptions. `topmost=window` is required: with the native menu bar auto-hidden, its hot zone otherwise sits above the bar and eats every click. A single hidden listener item runs one `aerospace list-windows --all` per event and batch-updates all workspace pills.
- Several plugins depend on a one-time **Accessibility grant for `sketchybar`**: native Control Center modals (`cc.sh`), Apple/app menu clicks (`menus.sh`), and the meeting item, which mirrors the official **MeetingBar** app's status text — if MeetingBar isn't running, the item hides itself. Menu clicks go through a compiled helper (`helpers/menus`, built with `make`) that uses the private SkyLight API; the scripts fall back to plain AX when it's missing.
- **JankyBorders** is launched from AeroSpace's `after-startup-command`.
- **Karabiner** (`.config/karabiner/karabiner.json`) maps Caps Lock → Hyper (tap = Escape) plus Hyper+key app launches. First run needs the driver approved and Input Monitoring granted.
- Terminal is **cmux** day-to-day; Ghostty is installed but not driven directly, and the zellij config is kept but currently unused.
- Container runtime is **colima**; compose/buildx come from Homebrew via `cliPluginsExtraDirs` in the local, untracked `~/.docker/config.json`.

## Installation

To install the dotfiles, follow these steps:

1. Clone this repository to your local machine:

    ```sh
    git clone --bare https://github.com/ViniciusNyp/dotfiles $HOME/.dotfiles
    ```

2. Define an alias for the dotfiles repository:

    ```sh
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    ```

3. Configure the dotfiles repository to not show untracked files:

    ```sh
    dotfiles config --local status.showUntrackedFiles no
    ```

4. Checkout the dotfiles:

    ```sh
    dotfiles checkout
    ```

    If you encounter any errors, make sure your home directory is clean and try again.

5. Set up the dotfiles repository to track the remote branch:

    ```sh
    dotfiles branch --set-upstream-to=origin/main main
    ```

6. Pull the latest changes:

    ```sh
    dotfiles pull
    ```

7. On macOS, restore packages and system defaults:

    ```sh
    brew bundle --file=$HOME/.Brewfile
    $HOME/.macos
    make -C $HOME/.config/sketchybar/helpers/menus
    ```

## Usage

To manage your dotfiles, use the `dotfiles` alias defined above. Here are some common commands:

- Add a new dotfile:

    ```sh
    dotfiles add <file>
    ```

- Add all already tracked dotfiles:

  ```sh
  dotfiles add -u
  ```

- Commit changes:

    ```sh
    dotfiles commit -m "Commit message"
    ```

- Push changes to the remote repository:

    ```sh
    dotfiles push
    ```

- Pull changes from the remote repository:

    ```sh
    dotfiles pull
    ```
