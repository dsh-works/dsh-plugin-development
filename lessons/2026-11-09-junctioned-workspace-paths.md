# A junctioned workspace root breaks lexical path containment

- **Date:** 2026-11-09
- **Plugin:** dsh-plugin-pixelart
- **Trigger:** release (v0.5.0 live gate)

## What happened

The v0.5 refactor moved the plugin checkout to its canonical directory and left the old path as a Windows
directory junction, then relinked the `web` profile. Offline checks were green: 383 tests, including
containment tests with `..`, absolute-outside paths and symlinked files.

The live gate immediately failed: `pixelart_gallery` returned
`path is outside the workspace (...\dsh-pixelart-tool): ...\dsh-plugin-pixelart\art\gate3-slime.png`.
The session workspace was the junctioned legacy path. The gallery resolved each candidate through
`realpath` (correctly, to catch symlink escapes) and then formatted the result relative to the *lexical*
workspace root. The real candidate did not share the lexical prefix, so the plugin refused its own file.

A unit test with a directory junction (no admin needed via `fs.symlink(..., 'junction')`) and an
end-to-end run of the real gallery tool against a junctioned workspace reproduced and then fixed it:
`workspaceRelative` now retries on real paths, and against the real root for a not-yet-created file.

## Rule

When a containment or relative-path check compares a root with a candidate, both sides must be on the
same path basis. If candidates are resolved through `realpath` to defeat link escapes, the root must be
resolved the same way before the comparison — and that includes a workspace root that is itself reached
through a symlink or junction. A lexical-root comparison against real candidates rejects the plugin's
own files in exactly the deployment layout a migration creates.

## Folded into

- `skills/dsh-plugin-development/references/standards.md` — added a J-section rule requiring
  link/junction-aware containment (real root vs real candidate), with the failure named.
- Plugin repository: `lib/workspace.js` junction-safe fallback and `test/workspace.test.mjs`
  (directory-junction case).
- Process only: any path-containment change now gets a junctioned-workspace case, and the live gate
  runs before the tag — the offline suite could not see this because the tests passed a real root.
