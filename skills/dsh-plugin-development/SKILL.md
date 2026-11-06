---
name: dsh-plugin-development
description: Plan, build, install, and verify an out-of-tree DeepSeek Harness plugin bundle in a dsh-works repository. Use when the user has a plugin idea ("new plugin", "make a plugin", "cook", "build this", "add a panel / widget / tool / integration"), or asks to change, fix, publish, or re-verify an existing plugin repo. Load before writing plugin code; load reference-index.md to find the harness documentation for any unfamiliar extension point.
---

# DSH plugin development

An out-of-tree plugin is a plain ESM JavaScript **bundle** in its own `dsh-works` repository: `package.json` declaring `dsh.bundle`, a `cordis.patch.yml` layer, a Host `index.js`, an optional browser `client.js`, `locale/*.json`, `icon.svg`, tests, and a README. It is installed into a DSH profile as a `link:` dependency and rendered in the Web UI.

One plugin, one repository. This workflow repository holds process, standards, and templates — never plugin code.

**Authority:** the `deepseek-harness` checkout, and the live harness it describes, decide harness behavior and rules. This skill is a derived digest with explicit out-of-tree adaptations; where it disagrees with the harness, the harness wins and this skill is corrected. A plugin repository's own `STANDARDS.md` or `SCOPE.md` is project-specific notes, never a replacement for the harness or this skill.

Not this skill: adding a package, tool, provider, or event inside the `deepseek-harness` repository itself. That is in-tree TypeScript work governed by that checkout's `AGENTS.md`, `docs/cookbook/adding-a-package.md`, and `docs/cookbook/adding-a-tool.md`.

## Ground rules

- **Inspect before designing; design before coding.** Confirm every service name, event name, dispatch mode, slot id, and Config field against the live harness or its docs. Do not invent APIs.
- **The session log is the source of truth.** Anything the model sees must be reconstructable from committed session events; plugin memory is a derived cache.
- **Registrations are effects.** Every listener, tool, slot entry, timer, and subscription is removed when the plugin unloads or its owning declaration collapses.
- **The framework drives; the plugin computes.** Do not poll, rescan the log, or write the DOM by hand when a projection, slot, or subscription already publishes that state.
- **Verify in the running product.** Installed, registered, and rendered are three different facts. Only the third counts.

## Gates

| Gate | Produces | Passed when |
|---|---|---|
| 0. Idea | `docs/PLAN.md` from `assets/plan.template.md` | every kickoff question is answered or explicitly deferred |
| 1. Plan | outcome, surface, non-goals, acceptance checks, repo name | **user approved the plan** |
| 2. Build | repository, code, locale, icon, tests, README | local checks pass; `dsh plugin add` installs without warnings |
| 3. Verify | acceptance checks with evidence | the live UI shows it and the checks pass |
| 4. Lesson | `lessons/<YYYY-MM-DD>-<slug>.md` in this repository | lesson committed when the work is released or the incident closed |

Tiers: a **new plugin** runs gates 0–4. A **feature** on a released plugin reruns gates 1–4 with a plan delta. A **fix** needs a short note, a regression check, and gate 4 — but a fix that changes intended behaviour is a feature: stop, switch tier.

Approval protocol at gate 1: present `PLAN.md` in the conversation, ask with the question tool (Approve / Changes needed / Stop), and wait for an explicit answer. Silence, a topic change, or "looks fine" without reading is not approval. Before approval, the only files you may write are documentation in the plugin repository — no source.

## Branch model

Every plugin repository has two long-lived branches and short-lived work branches:

| Branch | Role |
|---|---|
| `main` | **stable line.** Only commits whose checks passed — and, after a release, whose gate-3 evidence was recorded — live here. This is the line a profile should link for day-to-day use. |
| `dev` | **integration line.** Daily work lives here; several features can be queued or in flight. |
| `feature/<slug>` | one feature, cut from `dev`, merged back into `dev`, deleted after the merge. |
| `hotfix/<slug>` | a defect fix that ships from the stable line: cut from `main`, merged into `main`, then merged back into `dev`. |

- A new plugin starts with its scaffold on `main`; cut `dev` immediately after the first green `check` and never develop on `main` again except release and hotfix merges.
- Before a release: bump `package.json` and `CHANGELOG.md` on `dev`, run the full `check`, merge `dev` into `main`, tag `v<version>`, then bring `main` back into `dev`.
- Never force-push `main` or `dev`. Commit each green increment and push the branch you are on (`git push -u origin <branch>` the first time).
- A linked checkout runs whatever branch it has checked out; gate 3 states which branch was installed and verified. Switching the checkout to `dev` to try work in the live UI is expected — say so when it happens.
- Recommended on GitHub: protection on `main` and `dev` that requires the `check` workflow and refuses direct pushes to `main`.

## Where work happens

| Location | Use for |
|---|---|
| plugin repo, `Documents\deepseek-harness\<plugin-name>` | code, tests, local docs — a clone of `github.com/dsh-works/<plugin-name>` |
| this workflow repository | process, templates, skill, lessons |
| harness checkout, `Documents\harness-sc\deepseek-harness` | read-only reference: docs, examples, installed-skill templates |

## Fast path

1. Ask the kickoff questions and write `PLAN.md` (`references/plan.md`).
2. Choose the surface from the decision table in `references/surfaces.md`.
3. Copy `assets/bundle/` into a new plugin directory and rename the package and row id (`references/build.md`). Commit the scaffold on `main`, cut `dev`, and do all further work there or on a `feature/<slug>` branch.
4. Implement the Host half first, then the browser half; add locale and icon before installing. Merge each green increment into `dev` and push it.
5. Install into the profile and reload it (`references/build.md`), then verify against the checks (`references/verify.md`). Verify the branch that is actually installed.
6. Release by merging `dev` into `main` after the full `check` and the recorded evidence; tag it and sync `main` back into `dev`.
7. Commit, write the lesson, and report what is verified and what is not.

## Hard rules

- **Never hand-edit a profile.** Use `dsh plugin --profile <name> add <absolute plugin path>` (or the Plugins page); it owns the `link:` dependency and the `dsh.profile.bundles` entry. A hand-written profile edit needs its own approval and usually drifts.
- **Installing executes plugin code in the Host process.** Treat it as a trust decision. Ask before installing; never install a package whose source you have not read.
- **Never claim verified without evidence.** State exactly which checks ran, in which theme and language, and which did not.
- **Never touch user data without request.** Settings, sessions, and browser storage belong to the user; testing must restore them.
- **Locale is part of the deliverable, English first.** Ship `locale/en.json` with `meta.title` and `meta.description`; add `locale/<language>.json` only for languages the plugin actually ships. English copy is sentence case. Do not leave placeholder artwork silently in place.
- **Restarting the profile is a user decision.** After Host or client source changes, the profile must be reloaded or restarted before the new code is live. Coordinate with the user; a running agent session may not survive it.

## Plugin repository anatomy

| File | Purpose |
|---|---|
| `package.json` | `name`, `private`, `type: module`, `main`, `exports` (`.` plus `./client`, `./icon`, `./locale/*.json`, `./cordis.patch.yml`), `files` whitelist, `engines.dsh`, `dsh.bundle`, optional `dsh.client` |
| `cordis.patch.yml` | the bundle layer: usually one `insert` row with a stable `id` |
| `index.js` | Host plugin: `name`, optional `inject`, optional `Config`, `apply(ctx, config)` |
| `client.js` | browser plugin, only when the plugin renders UI; declared through `dsh.client` |
| `locale/en.json` (+ optional other languages) | `meta.title` / `meta.description` for Plugin Manager and Settings |
| `icon.svg` | exported as `./icon`, self-contained, no external references |
| `test/` | `node --test` suites for pure logic and package metadata |
| `README.md` | what it does, install, configuration, verification limits |
| `STANDARDS.md`, `SCOPE.md` | project-specific notes from `assets/STANDARDS.template.md`; never a replacement for the harness or this skill |

## References

| Read | When |
|---|---|
| `references/plan.md` | gates 0–1: kickoff questions, plan template, approval |
| `references/surfaces.md` | choosing the extension point before writing code |
| `references/build.md` | bundle anatomy, scaffold, install, dev loop, troubleshooting |
| `references/standards.md` | every rule the code must satisfy, MUST/SHOULD |
| `references/verify.md` | gate 3: install result, UI checks, evidence, rollback |
| `references/reference-index.md` | which harness document answers which question |

Before gate 1, read `lessons/README.md` in this repository when it exists. After a release or an incident, append one entry following the format it defines.
