# macOS terminal launch: LaunchServices, not an AppleScript session command

- **Date:** 2026-11-11
- **Plugin:** dsh-plugin-viburnum
- **Trigger:** incident (live gate)

## What happened

A workbench **Terminal** action opens the desktop terminal in a bundle checkout. The macOS
implementation used AppleScript:

    tell application "iTerm2" to create window with default profile command "cd '<checkout>'"

iTerm2 runs `command` as the session's own command and closes the session when it exits, so `cd`
completed instantly and the window died:

    A session ended very soon after starting. Check that the command in profile "Default" is correct.

An attempted fix that appended `&& exec $SHELL -l` to the same AppleScript string failed the same way
and additionally raised iTerm2's automation/scripting-API prompt. LaunchServices works:

    open -a iTerm <checkout>        # iTerm2 3.5+ renamed its bundle to iTerm.app
    open -a iTerm2 <checkout>       # older bundle name, fallback
    open -a Terminal <checkout>

`open` needs no automation permission and starts the app's own login shell in that directory. Verified
live: the Host action returned `opened: true`, clicking **Terminal** in the workbench opened a second
window, and `lsof` showed both shells' cwd at the checkout.

## Rule

Open a desktop application at a directory through the OS launcher (`open -a <app> <directory>` on
macOS), not through an AppleScript session `command`. A session command is the session: a one-shot
command such as `cd` exits and the window closes immediately, and scripting the app may require
automation or scripting-API grants the OS launcher never needs.

## Folded into

- `skills/dsh-plugin-development/references/standards.md` K4 — LaunchServices rule for desktop apps
- `skills/dsh-plugin-development/references/build.md` "10. Cross-platform" — the OS-action fallback bullet
