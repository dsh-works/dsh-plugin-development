# A fixture that describes another platform must speak its path flavour

- **Date:** 2026-11-09
- **Plugin:** `dsh-plugin-viburnum`
- **Trigger:** incident (CI red on two platforms)

## What happened

The plugin was developed on Windows. Its suite was green locally, but on macOS eight of 125 tests
failed, all from fixtures that assumed Windows: `world.work + '\\README.md'`, `resolve('C:/dsh/...')`,
`normalize('C:/repos/a')` and `link:C:/repos/a` dependencies. The tests asserted the host's path
behaviour while the plugin used the running platform's `node:path`; on POSIX a `C:/...` string is
relative, so the expected and actual values could never meet.

A runtime defect hid in the same class: the terminal command builder validated its directory with the
host's `isAbsolute`, so a test could not build a `win32` command from macOS (and the reverse) even
though the builder itself was correct. The fix validated with the path flavour of the platform being
described.

The fix added a three-OS CI matrix (`ubuntu-latest`, `macos-latest`, `windows-latest`). The first
windows run then caught the same class again, in reverse: a macOS/Linux test built a POSIX probe path
with the host's `join()`, so on Windows the fixture path began with a backslash and `parseProbe`
correctly refused it. Two tests failed on windows only. Building that fixture path with `path.posix`
fixed it while the injected filesystem keys stayed host-flavoured to match the module's own `join()`.

Measured evidence: baseline `npm run check` on macOS — 143 tests / 135 pass / 8 fail; after the
portable fixtures — 143 / 143; with the CLI feature and its 11 tests — 161 / 161 on macOS, and the
three-OS CI matrix green at `b46189f`.

## Rule

A test, fixture, or helper that describes a platform other than the running one builds that
platform's paths in that platform's own flavour (`node:path/posix` or `node:path/win32`), and platform
behaviour is exercised through injected `platform`, `spawn`, and filesystem seams — host-flavoured
`join`/`resolve`/`isAbsolute` in a simulated-platform fixture passes where it was written and fails
in CI.

## Folded into

- `skills/dsh-plugin-development/references/standards.md` — new section K (K1–K7), cross-platform
  MUST/SHOULD rules.
- `skills/dsh-plugin-development/references/build.md` — new "Cross-platform" section: CI matrix,
  seams, path flavour, per-platform fallbacks.
- `skills/dsh-plugin-development/references/verify.md` — live checks must name the OS they ran on.
- `skills/dsh-plugin-development/SKILL.md` — "Cross-platform by default" hard rule.
