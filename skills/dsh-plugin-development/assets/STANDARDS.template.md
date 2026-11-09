# Plugin standards

This repository follows the DSH plugin development process and standards:

- Process and skill: <https://github.com/dsh-works/dsh-plugin-development>
- Authority: the `deepseek-harness` checkout and the live harness. Where this file, the skill, or any note disagrees with them, they win and the file is corrected.

## Project-specific rules

Only rules that narrow or differ from the shared skill belong here. Keep the list short and every line checkable.

| Rule | Why it exists here |
|---|---|
| <rule> | <reason> |

## Local tooling

- `<check command>` is the local gate.
- `<test command>` covers pure logic offline.

## Not duplicated here

Bundle shape, effects and disposal, config, session and model-visible data, errors, locale, tool contracts, Web UI rules, packaging, compatibility, cross-platform behavior, tests, and install trust live in the shared skill. Do not copy them into this repository; a copy rots against the harness.
