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

## Rules

- One lesson, one rule. If two rules fall out of one incident, write two files.
- Cite evidence, not recollection.
- Fold the rule into `references/` in the same change that writes the lesson, or say explicitly that it stays process-only.
- Do not rewrite an old lesson; append a new one that supersedes it and say so.
