# Lessons

Cross-plugin lessons, one file per lesson: `YYYY-MM-DD-<slug>.md`. Write one after a release or an incident, when the plugin is already working and the question is what the next plugin should do differently.

A lesson is not a changelog. It records one transferable rule, the evidence that forced it, and where it was folded into the process.

## Entry format

```markdown
# <Title>

- **Date:** YYYY-MM-DD
- **Plugin:** <repository>
- **Trigger:** release | incident | review

## What happened

The observed behavior and the evidence: command, output, screenshot, or log.

## Rule

The single rule the next plugin should follow, stated so it can be checked.

## Folded into

- `skills/dsh-plugin-development/references/<file>.md` — what changed there
- or: process only, no skill change
```

## Index

| Date | Lesson | Folded into |
|---|---|---|
| 2026-11-09 | [A junctioned workspace root breaks lexical path containment](2026-11-09-junctioned-workspace-paths.md) | `references/standards.md` J6; `dsh-plugin-pixelart` `lib/workspace.js` + `test/workspace.test.mjs` |
| 2026-11-09 | [A fixture that describes another platform must speak its path flavour](2026-11-09-platform-path-flavour.md) | `references/standards.md` K1–K7; `references/build.md` "Cross-platform"; `references/verify.md` OS in evidence |
| 2026-11-11 | [macOS terminal launch: LaunchServices, not an AppleScript session command](2026-11-11-macos-terminal-launch.md) | `references/standards.md` K4; `references/build.md` "10. Cross-platform" |
| 2026-11-11 | [npm's global package root differs by platform](2026-11-11-npm-global-root.md) | `references/standards.md` K8; `references/build.md` "10. Cross-platform" |

## Rules

- One lesson, one rule. If two rules fall out of one incident, write two files.
- Cite evidence, not recollection.
- Fold the rule into `references/` in the same change that writes the lesson, or say explicitly that it stays process-only.
- Do not rewrite an old lesson; append a new one that supersedes it and say so.
