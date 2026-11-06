# <Title>

<One paragraph: what the user can now do, and where it appears in the harness.>

## Install

```powershell
dsh plugin --profile web add C:\Users\<you>\Documents\deepseek-harness\dsh-plugin-<slug>
```

Reload or restart the profile afterwards. Remove it with `dsh plugin --profile web remove dsh-plugin-<slug>`; disable it without removing it by targeting the row id in a profile overlay.

## Configuration

| Field | Default | Meaning |
|---|---|---|
| — | — | The plugin takes no configuration. |

## What the model sees

<Only when the plugin registers a tool or prompt text: the exact schema or prose, or a link to it. Otherwise delete this section.>

## Verification

- Verified: <checks run, theme, language, date>
- Not verified: <checks not run and why>
- Known limits: <behaviour the plugin cannot observe or cannot do>
