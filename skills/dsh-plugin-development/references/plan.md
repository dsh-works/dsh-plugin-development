# Gate 0-1 — the plan

Nothing gets built before its plan is agreed. This file covers the kickoff questions, the plan itself, and the approval that closes gate 1.

## Tier first

| Tier | When | Gates |
|---|---|---|
| New plugin | the repository does not exist yet | 0, 1, 2, 3, 4 |
| Feature | released plugin, new capability or changed behaviour | 1, 2, 3, 4 with a plan delta |
| Fix | defect only, restores intended behaviour | short note, regression check, 4 |

A fix that starts changing intended behaviour is a feature: stop, switch tiers, rerun the plan gate. When in doubt take the higher tier.

## Gate 0 — kickoff

Ask decisions, not paragraphs. Use the question tool with three to six related questions per call, the recommended option first, and one line of consequence per option. Skip a question you can answer from the repository or the harness docs; never skip one the user must decide.

| Question | What it decides |
|---|---|
| What should the user be able to do that they cannot do now? | the outcome, and whether there is a plugin at all |
| Where should it appear — tool call, UI panel/overlay, chat row, background behaviour, MCP tools? | the surface (`references/surfaces.md`) |
| What state does it own, and must that survive a reload or restart? | Host state vs browser storage vs session-derived |
| What should it never do — scope, permissions, data it must not touch? | non-goals and guardrails |
| How will we know it works, in one observable sentence? | the acceptance checks |
| Is there an existing plugin or harness feature this must not duplicate? | reuse instead of a second implementation |

A question the user marks "not sure" is deferred explicitly and named in the plan. It is not silently dropped.

## Gate 1 — the plan

Write `docs/PLAN.md` in the plugin repository, from `assets/plan.template.md`. Keep it to one page. It must contain:

- **Outcome** — the observable sentence, in the user's terms.
- **Surface** — the chosen extension point and why the weaker alternatives do not fit.
- **Non-goals** — what this version deliberately does not do.
- **Risks and unknowns** — anything that could force a redesign, with the cheapest experiment that settles it.
- **Acceptance checks** — numbered, observable, and pass/fail. Each names the trigger, the expected result, and how it is observed (tool transcript, UI element, console, file). "Works" is not a check.
- **Verification plan** — which checks need a restart, a second language, a second theme, or a second browser profile.
- **Repository** — the `dsh-works` name, the row id, the package name, the `engines.dsh` range.
- **Open questions** — every deferred one, with the answer that unblocks it.

## Approval

1. Present `PLAN.md` in the conversation, not only as a file change.
2. Ask with the question tool: `Approve plan?` — `Approve (Recommended)`, `Changes needed`, `Stop for now`. Without the tool, offer the same three options in prose.
3. Wait for an explicit answer. Silence, a topic change, or "looks fine" without reading is not approval.
4. Record it in the plan header: `Approved by <name> on <YYYY-MM-DD>.` and add a revision entry on later changes.

Before approval the only files you may write are documentation in the plugin repository. No source, no manifest, no CI.

## Scope changes during the build

When something discovered while building changes behaviour, data, the surface, settings, or compatibility: stop, update the plan sections, bump the revision, and ask for approval again. Silent scope growth is how plans rot.

## Anti-patterns

- Writing the plugin first and the plan afterwards.
- A plan with no acceptance checks, or with checks that cannot fail.
- Choosing a surface before confirming it exists in the current harness.
- "While we are in there" additions the user did not ask for.
- Treating a deferred question as answered.
