# DSH plugin development

The process, standards, and templates for building DeepSeek Harness plugins in the `dsh-works` organization. It exists so that an idea becomes an agreed plan before it becomes code, and so that no plugin is called done before it was seen working in the live Web UI.

Plugin code does not live here. One plugin is one repository in `dsh-works`; this repository holds the shared process, the `dsh-plugin-development` skill, and a lessons ledger.

## Layout

```
skills/
  dsh-plugin-development/     the skill: SKILL.md, references/, assets/
    SKILL.md                  gates, ground rules, hard rules, routing
    references/               plan, surfaces, build, standards, verify, reference index
    assets/                   plan template and a copyable bundle scaffold
lessons/                      cross-plugin lessons, indexed
docs/decisions.md             why the process looks like this
install.ps1 / install.cmd / install.sh   links the skills into the DSH skills folder
```

## Install on a machine

```powershell
git clone https://github.com/dsh-works/dsh-plugin-development.git
cd dsh-plugin-development
.\install.cmd
```

The script creates a directory junction in `%USERPROFILE%\.dsh\skills\`, so `git pull` in this repository updates the live skill without copying anything. Start a new DSH session afterwards; the skill catalog is discovered per session.

`install.cmd` only wraps `install.ps1` with `-ExecutionPolicy Bypass`, because a default Windows setup refuses to run `.ps1` files. Remove the links with `.\install.cmd -Uninstall`. Do not delete the skills folder recursively while the links exist; remove the links first.

On macOS or Linux use `./install.sh` and `./install.sh --uninstall`.

## How a plugin gets built

The skill runs five gates: **idea**, **plan** (the user approves it), **build**, **verify** in the running harness, and **lesson**. The full rules are in `skills/dsh-plugin-development/SKILL.md`; the practical detail lives in its `references/`:

| Read | When |
|---|---|
| `references/plan.md` | turning an idea into an approvable plan |
| `references/surfaces.md` | picking the extension point (tool, hook, UI slot, chat row, MCP, adapter) |
| `references/build.md` | scaffolding, manifest, install, dev loop |
| `references/standards.md` | the MUST/SHOULD rules the code has to satisfy |
| `references/verify.md` | proving it works, and rolling back |
| `references/reference-index.md` | which harness document answers which question |

## Branches

Every plugin repository keeps `main` as the **stable line** and `dev` as the **integration line**. Work happens on `dev`, or on a `feature/<slug>` branch cut from it; a `hotfix/<slug>` is cut from `main`, merged into `main`, then merged back into `dev`. A release merges `dev` into `main` after the full `check`, tags `v<version>`, and merges `main` back into `dev`. Never force-push either long-lived branch; never develop directly on `main` after the initial scaffold. The rules are in `skills/dsh-plugin-development/SKILL.md`; the practical steps are in `references/build.md`.

## Where plugins live

| Artifact | Location |
|---|---|
| plugin repository | `github.com/dsh-works/<plugin-name>`, cloned to `Documents\deepseek-harness\<plugin-name>` |
| harness reference checkout | `Documents\harness-sc\deepseek-harness` — read only |
| process, skill, lessons | this repository |

## Compatibility

DeepSeek Harness is in developer preview and its plugin APIs are pre-stable. Every plugin declares `engines.dsh` in `package.json`; when the harness moves, re-audit `references/standards.md` against the new checkout rather than assuming the old rules still hold.

## Dependencies

Building a plugin needs Node.js 22 or newer and a `dsh` installation on `PATH` (or a harness checkout, where `pnpm dsh` runs the same launcher from source). This repository itself has no dependencies.
