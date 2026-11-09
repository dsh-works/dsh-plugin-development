# Gate 3 — verify

Installed, registered, and rendered are three different facts. This gate is about the third one. Evidence, not assertion.

## What counts as evidence

| Surface | Evidence that counts |
|---|---|
| Host tool | a real tool call in a session: request arguments, the exact result content, and the error path when bad input is passed |
| Interception / hook | the decision is observed: the call is denied, rewritten, or annotated exactly as planned, with the surrounding call visible |
| Web UI slot | a screenshot of the live page in **light and dark**, the element present and positioned beside comparable host UI, console free of `slot entry crashed in '<slot>'` |
| Chat row | the row appears around the correct turn/step in a real session, and replay of the same session shows the same row |
| Session-derived state | the value changes on the durable event it derives from, survives a reload, and does not flicker on queued-input handoff |
| MCP / configuration-only | the server's tool is listed and callable, and the configuration row is visible in the composed profile |
| LLM adapter | a real response from the provider, including usage and a tool call, plus the error path |
| Any persistence | set, reload, still correct; corrupt or absent value, sensible fallback |

A screenshot of a mock page, a registry entry, an `application: applied` line, or "the code looks right" is not evidence of what the user sees.

## Checks that always apply

1. **Installed.** The package is in the profile as a `link:` dependency, the bundle is in `dsh.profile.bundles`, and the row appears in the composed profile:
   ```powershell
   dsh --profile web --dump-config | Select-String -Pattern '<row-id>' -Context 2,4
   ```
2. **Enabled.** The row is not `disabled` and the plugin's fiber is active, not PENDING or FAILED. PENDING means a missing `inject` service; FAILED means `apply` threw — read the console/log line, not the guess.
3. **Rendered.** The browser half registers its slot entry. Open DevTools once: a missing entry and a crashed entry look identical on screen.
4. **Themes.** Light and dark, with the plugin beside a comparable host component. Literal colors that vanish or clash are a defect.
5. **Language.** Switch the UI language if the plugin ships more than one locale; every visible string changes and no key leaks.
6. **Restart.** Reload the page, and if the plugin owns Host state, restart the profile. State that was meant to persist persists; state that was meant to be transient is gone.
7. **Restore user state.** Anything the test changed — settings, browser storage, a dragged position — is restored or the user is told.
8. **Negative control.** At least one check must confirm the plugin refuses or degrades as designed: bad input, missing service, cancelled work, or a disabled row. A green path alone is not verification.
9. **Platform.** Record which OS the live checks ran on. A green CI matrix on the other platforms is regression evidence, not a live check; report the two separately.

## Recording

Fill the acceptance checks in `docs/PLAN.md` with: check number, result (`pass` / `fail` / `not run`), evidence (one line — the command, the screenshot name, the result text), the OS when a live check ran, and date. Leave nothing implied. `not run` is allowed and must be reported; an unrun check is not a pass.

Report at the end of the turn: what was verified, in which theme and language, what was not verified and why, and what the user must do (for example, restart the profile).

## Rollback

- Disable without uninstalling: override the row in a profile overlay with `disabled: true`, then reload.
- Uninstall: `dsh plugin --profile web remove <package-name>`, then reload.
- If the plugin wrote user data, say where and how to clear it; never clear it without being asked.

## When verification is blocked

If browser control or a restart is unavailable, stop at what can be checked: syntax, manifest, install result, bundle presence, and the composed profile. Say plainly which checks did not run and why. Do not substitute a mock page, a second browser, or an emulated DOM for the live page.
