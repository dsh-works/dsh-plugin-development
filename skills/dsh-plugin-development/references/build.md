# Gate 2 — build

The bundle anatomy, the manifest, the two halves, installation, and the dev loop.

## Prerequisites

- Node.js 22 or newer.
- `dsh` on `PATH`, or run the same commands as `npx @deepseek-ai/dsh ...`.
- A harness checkout for reference at `Documents\harness-sc\deepseek-harness` (read only).
- A profile name. The Web profile is `web`; confirm with `dsh --profile web --dump-config`.

## 1. Create the repository

Create `Documents\deepseek-harness\<plugin-name>` from `assets/bundle/`, then rename consistently:

| Thing | Convention | Example |
|---|---|---|
| repository | `dsh-plugin-<slug>` | `dsh-plugin-companion` |
| package name | same as the repository | `dsh-plugin-companion` |
| patch row id | short slug, used in diagnostics and overlays | `companion` |
| client module id | exactly the package name | `dsh-plugin-companion` |
| locale namespace | `dsh-<slug>` | `dsh-companion` |

`git init` locally. The remote is `github.com/dsh-works/<plugin-name>`; create it in the organization and add it, do not assume it exists.

**Branches.** Commit the scaffold on `main` and cut `dev` from it immediately; from then on `main` is the stable line and `dev` is where work lands (`SKILL.md`, "Branch model"). Features use `feature/<slug>` off `dev`; a defect that must ship from stable uses `hotfix/<slug>` off `main`, merged into `main` and back into `dev`. Release by merging `dev` into `main` after the full `check`, tagging `v<version>`, then merging `main` back into `dev`. Never force-push `main` or `dev`; push each green increment.

## 2. `package.json`

The template carries the full shape. The fields that matter:

| Field | Rule |
|---|---|
| `private` | `true`. These are not published to npm. |
| `type` | `module`. The Host half is ESM. |
| `exports` | `"."`, `"./client"` (only with a browser half), `"./cordis.patch.yml"`, `"./package.json"`, `"./icon"`, `"./locale/*.json"` |
| `files` | every runtime file, the patch, the icon, `locale/`, and the README. A file missing here is missing after install. |
| `engines.node` | `>=22`. |
| `engines.dsh` | the harness release this plugin is tested against, for example `^0.2.2-rc.1`. Check `dsh --version`; do not guess. |
| `dsh.bundle.patch` | `./cordis.patch.yml`. Without it the package installs as a plain dependency and activates nothing. |
| `dsh.client` | only with a browser half: `{ "platform": "web", "immediately": true, "inject": [] }` |
| `icon` | `./icon.svg` at the top level, so Plugin Manager can render it without loading the plugin. |

No build step: `dsh plugin add` links the directory, and the harness loads the files as written. Add a build only when the plugin genuinely needs TypeScript or JSX, and then ship the built output through `files`.

## 3. `cordis.patch.yml`

```yaml
- insert:
    - id: <row-id>
      name: 'dsh-plugin-<slug>'
```

One row for a self-contained plugin. Patch semantics worth knowing:

- A later layer wins per row; a patch that targets the row by `id` replaces its whole `config`, never merges it. Restate every key.
- A plugin with nothing to configure takes no `config`. Do not add one for symmetry.
- Users disable the plugin from a profile overlay with `- id: <row-id>` and `disabled: true`; no uninstall needed.
- A bare package name in a patch resolves from the package's own dependencies; a source path resolves beside the patch file.

## 4. Host half — `index.js`

```js
export const name = '<row-id>'
export const inject = []
export function apply(ctx) {
  // registrations go here
}
```

- `inject` names the services `apply` uses. The plugin waits until they exist; if one disappears it unloads and reloads when it returns. Do not read `ctx.<name>` for a service you did not declare.
- Every registration through `ctx` is an effect: listeners, tools, slot-independent services, timers. A resource that needs explicit cleanup returns a disposer from `ctx.effect()`; keep order-dependent cleanup in one effect.
- No module-level mutable state and no singletons. Shared state lives on a service or instance owned by the plugin.
- The service form (`export default class ... extends Service`) exists for plugins that provide a service to others. Do not mix it with the function form: a default export beside `name`/`inject`/`apply` makes the Loader discard the namespace.
- If the plugin accepts configuration, export a `Config` and validate it at load; invalid configuration must fail loudly with an actionable message. Configurability is for values two deployments would set differently, not for defaults invented on the spot.

## 5. Browser half — `client.js`

Only when the plugin renders UI. `package.json` declares `dsh.client`, and `exports["./client"]` points here.

The file is a **self-contained classic script**, not an ES module. The loader evaluates it directly, and it registers through the module loader:

```js
window.__ModuleLoader__.load({
  id: 'dsh-plugin-<slug>',            // exactly the package name
  factory(require) {
    const React = require('react')     // baseline modules come through require
    return {
      inject: ['slots', 'locale'],
      apply(ctx) {
        ctx.slots.inject('<slot-id>', () =>
          ctx.slots.register({ name: '<slot-id>', id: '<row-id>', order: 0, inject: () => ({}) }, Component))
      },
    }
  },
})
```

Rules that bite:

- No `import`, no `export`, no top-level `await`. Everything the browser half needs is in the file or comes through `require`.
- Do not import `@deepseek-ai/dsh-client-*` packages. A throwing component blanks the slot entry (console: `slot entry crashed in '<slot>'`), and those packages change without notice.
- If pure logic deserves unit tests, put it in plain modules under `test/` or beside the entry, and inline it into `client.js` with a small script, the way `dsh-fren/sync-client.mjs` does. Do not let the tested copy and the shipped copy drift.
- Use theme tokens (`--dsw-alias-*`) for color; literal colors belong to artwork only.
- Register through `ctx.slots.inject(owner, () => ctx.slots.register(...))` so entries collapse with their declaration. Read session data through the slot props' selectors, not by scanning the log.

## 6. Locale and icon

- `locale/en.json` defines `meta.title` and `meta.description`; add `locale/<language>.json` only when the plugin ships that language. English is sentence case. These render in Plugin Manager and Settings without loading the plugin.
- `icon.svg` is self-contained: no external references, no embedded fonts, no scripts. Export it as `./icon` and list it in `files`. No placeholder artwork ships.

## 7. Install into a profile

```sh
# macOS / Linux
dsh plugin --profile web add ~/Documents/deepseek-harness/dsh-plugin-<slug>
```

```powershell
# Windows
dsh plugin --profile web add C:\Users\<you>\Documents\deepseek-harness\dsh-plugin-<slug>
```

That command makes the repository a `link:` dependency of the profile and appends the package to `dsh.profile.bundles`, which is what makes the bundle patch and the `dsh.client` declaration visible. The Plugins page in the Web UI does the same thing.

Ask the user before installing: installation executes the plugin code in the Host process, outside the agent sandbox. Then reload or restart the profile.

## 8. Dev loop

| Change | What makes it live |
|---|---|
| `index.js`, `client.js`, `locale/*.json`, `icon.svg` | reload or restart the profile; a browser reload alone does not re-materialize the client bundle |
| `cordis.patch.yml` row, config-only change | reload; with `dsh-hmr` enabled a config edit may apply without a restart |
| `package.json` dependencies, bundle list | re-run `dsh plugin --profile web add <path>` |
| new plugin in the profile | reload, then confirm the row in `--dump-config` |

Restarting the profile ends the running process, so coordinate it with the user rather than doing it mid-task.

## 9. Local checks before installing

```sh
node --check index.js
node --check client.js
node --test test/*.test.mjs
```

`client.js` is a classic script, so a parse check plus the live UI is what you have; do not build a custom renderer to compensate. The repo's `check` script (`npm run check`) is the gate, and the same command must pass on Windows, macOS and Linux.

Inside a confined DSH session, `node --test` can fail with `spawn EPERM`: the test runner forks worker processes with piped stdio, which the sandbox refuses. Run the file directly (`node test/package-meta.test.mjs`) for a sandboxed check, or run the full `check` script with host approval.

## 10. Cross-platform

Windows, macOS and Linux are all supported. Build for that from the scaffold, not when CI first goes
red. Rules K1–K7 in `references/standards.md`; this is the working loop.

- **CI matrix from the scaffold.** Run the same `check` on all three platforms so the first push
  catches a platform defect:

  ```yaml
  jobs:
    check:
      strategy:
        fail-fast: false
        matrix:
          os: [ubuntu-latest, macos-latest, windows-latest]
      runs-on: ${{ matrix.os }}
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: 22
        - run: npm run check
  ```

- **Test the platform, not the host.** Give each OS helper a `platform` parameter and injected
  `spawn`/filesystem seams; validate a described platform's paths with `path.win32`/`path.posix`, not
  the host's `isAbsolute`. Test every branch from any host.
- **Fixtures speak one flavour.** Build a simulated platform's paths with `path.posix`/`path.win32`,
  once, and reuse the same string in the filesystem fake and the assertion. The host's `join()` in a
  fixture for another OS passes where it was written and fails on CI.
- **Every OS action has a fallback.** Terminal (Windows Terminal/PowerShell, iTerm2/Terminal.app,
  x-terminal-emulator/gnome-terminal/xterm), directory picker (PowerShell dialog, `osascript`,
  `zenity`/`kdialog`), shell detection (`$SHELL` login/interactive probe; `where` on Windows), and the
  desktop openers. A missing tool returns a typed `*-unavailable`, not a crash or a false success.
  On macOS open the app with `open -a <app> <directory>` (LaunchServices); a bare `cd` passed as an
  AppleScript session `command` runs and closes the session immediately ("A session ended very soon
  after starting") and may raise a scripting-API prompt.
- **Platform process and env details.** `.cmd`/`.bat` shims are started through `cmd.exe` (Node refuses
  a direct spawn); read `USERPROFILE`/`APPDATA` on Windows and `HOME` elsewhere; commit executable bits
  for `bin` entries; keep path handling on `node:path`. npm's global package root is
  `<prefix>/lib/node_modules` on POSIX and `<prefix>/node_modules` on Windows — derive install
  ownership from that root, not from the bin directory.
- **Document prerequisites.** Name the terminal/picker/git/npm/PATH/permission requirements in the
  README Limits section and show the same sentence in the UI when one is missing.
- **Report the OS.** Gate 3 evidence names the OS the live checks ran on; a green CI matrix elsewhere
  is regression evidence, not a live check.

## 11. Troubleshooting

| Symptom | Likely cause |
|---|---|
| Package not listed in Plugins | not installed into this profile, or no `dsh.bundle` in `package.json` |
| Row missing from `--dump-config` | bundle not in `dsh.profile.bundles`; re-run add, then reload |
| Row PENDING | an `inject` service does not exist in this composition |
| Row FAILED | `apply` threw, or the manifest/client export is malformed; read the actual error |
| Nothing renders though the row is active | wrong slot id, missing `dsh.client`, missing `./client` export, `id` mismatching the package name, or a crashed slot entry |
| UI unchanged after an edit | client bundle not re-materialized; restart the profile |
| Config value ignored | a later patch layer replaced the row's whole `config` |
| Colors wrong in one theme | literal colors instead of theme tokens |
| Text does not switch language | key missing from the active locale file, or a hardcoded string |

## 12. Repository hygiene

README (what it does, install, configuration, verification limits), `STANDARDS.md` and `SCOPE.md` as the repo's own standing rules, `CHANGELOG.md` once released, `LICENSE`, `.nvmrc`, and a CI workflow that runs the same `check` script on `main` and `dev`. Keep the plugin's own documents with the code; they are what a future change reads first.
