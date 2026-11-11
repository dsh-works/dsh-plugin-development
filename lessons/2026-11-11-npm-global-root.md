# npm's global package root differs by platform

- **Date:** 2026-11-11
- **Plugin:** dsh-plugin-viburnum
- **Trigger:** incident (live gate)

## What happened

The Command line card reports whether `vib` is installed and whether the global link resolves into the
plugin's own checkout, so **Remove** only touches an install the plugin created. Live on macOS the card
said `available` but `owned: false` and hid Remove.

`npm link` had put the package at `<prefix>/lib/node_modules/dsh-plugin-viburnum`; the ownership check
read `<prefix>/node_modules/dsh-plugin-viburnum`. On Windows the npm prefix (`%APPDATA%\npm`) *is* the
global package directory, so the same code accidentally worked there. The fix is one per-platform
helper — `<prefix>/lib/node_modules` on POSIX, `<prefix>/node_modules` on Windows — verified against
the real link (`owned: true`) and covered by the fixture tests.

## Rule

Never infer npm's global package directory from the bin directory or from one platform's layout:
POSIX keeps global packages under `<prefix>/lib/node_modules` and shims under `<prefix>/bin`; the
Windows prefix is already the package directory. Put the per-platform root in one named helper and
exercise it against a real npm install, not only fixtures.

## Folded into

- `skills/dsh-plugin-development/references/standards.md` K8 — npm global layout rule
- `skills/dsh-plugin-development/references/build.md` "10. Cross-platform" — the platform process/env bullet
