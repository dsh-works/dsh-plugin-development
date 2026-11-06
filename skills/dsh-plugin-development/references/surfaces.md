# Choosing an extension point

Pick the weakest mechanism that produces the requested result; a stronger mechanism must preserve what weaker plugins contribute. Sources: `docs/cookbook/extension-cookbook.md`, `docs/cookbook/adding-a-tool.md`, `packages/preset/agent-preset/skills/cordis-plugin-development/references/practices.md`, `docs/architecture.md#where-new-behavior-goes`.

## Decision table

| The user-visible result wanted | Likely surface |
|---|---|
| The model can do a new kind of work | Host tool |
| Tools are filtered or denied, or the model sees different context each step | Hook and interception |
| A control, badge, panel, or decoration in the Web page | Web UI slot |
| A Chat transcript row for an event no built-in view covers | Chat row |
| A page or panel reflecting what the session is doing | Session-derived state (+ a slot) |
| The tools of an external MCP server | MCP bridge (configuration only) |
| A new model provider or protocol | LLM adapter |
| One session gets a different tool, persona, or prompt set | Agent preset placement |
| A persistence backend, Remote endpoint, or new event type | Not covered here |

## Host tool

**Use when** the model should be able to cause the effect. **Mechanism** `ctx.tools.register(definition)` in the Host `apply`: the registry validates arguments against `parameters`, validates the canonical return against `output.schema`, and sends `output.render` to the model. Registration is an effect; schemas join prompt assembly and PTC can call the tool for free.

```js
import { readFile } from 'node:fs/promises'
export const inject = ['tools']

export function apply(ctx) {
  ctx.tools.register({
    name: 'read_file',
    description: 'Read a file from disk.',
    parameters: { path: { type: 'string', required: true, description: 'Absolute path' } },
    output: { schema: { type: 'string' }, render: (_args, value) => [{ type: 'text', text: value }] },
    async execute(args, exec) {
      return readFile(args.path, { encoding: 'utf8', signal: exec.signal })
    },
  })
}
```

**Gotchas** return one canonical JSON value — explanation belongs in `output.render`, never content blocks from the body; honor `exec.signal`; long work uses `ctx.jobs.start({ kind, label, owner: exec.agent, run })` and returns a typed handle; `presentCall`/`presentResult` are pure, UI-only, and replay-safe. `defineTool` is the TypeScript helper; plain JS registers the object directly. Docs: `docs/cookbook/adding-a-tool.md`, `packages/core/tools/README.md#extension-points`.

## Hook and interception

**Use when** you change existing behavior instead of adding a capability. **Mechanism** documented event listeners; use the weakest rung that suffices: `ctx.tools.restrict()` (only removes tools) < `ctx.tools.guard()` (final deny) < a waterfall listener (rewrites or observes) < `system-prompt/assemble` (replaces the whole assembly).

```js
export const inject = ['tools']

export function apply(ctx) {
  ctx.tools.guard(exec => (exec.name === 'bash' && isBlocked(exec.arguments)) ? 'Blocked by policy.' : undefined)
  ctx.on('tools/pre-execute', async (exec, next) => {
    if (await isDenied(exec)) return { kind: 'deny', reason: 'Denied by policy.' }
    return next()
  })
}
```

**Gotchas** a waterfall listener MUST return `next()`; spread an `agent/pre-step` decision (`{ ...decision, messages }`) so fields such as `startsRequestSeries` survive; `restrict()` needs a scoped context, so call `agent.ctx.tools.restrict({ deny: [...] })` from an `agent/created` listener; `guard()` is synchronous, so return `ask` from `tools/pre-execute` when the decision must await. Observe final outcomes on `tools/result`, transform on `tools/post-execute`, and add prompt text with `ctx.systemPrompt.section()` — never by listening to `system-prompt/assemble` to insert text or tools. Docs: `docs/cookbook/extension-cookbook.md`, `packages/preset/agent-preset/skills/cordis-plugin-development/references/practices.md`.

## Web UI slot

**Use when** a person must see or operate something in the page. **Mechanism** the bundle adds a browser half: `package.json` declares `dsh.client` plus a `./client` export, `index.js` is the Host half (`export function apply() {}` when there is nothing to do), and `client.js` registers a lazy factory. Register through `ctx.slots.inject(slot, () => ctx.slots.register(options, Component))` so the contribution leaves when the owning declaration collapses.

```jsonc
// package.json fragment
"exports": { ".": "./index.js", "./client": "./client.js" },
"dsh": { "bundle": { "patch": "./cordis.patch.yml" }, "client": { "platform": "web", "inject": ["@deepseek-ai/dsh-client-ui-conversation"] } }
```

```js
// client.js
// id is exactly the package name from package.json
window.__ModuleLoader__.load({ id: 'dsh-plugin-my-panel', factory(require) {
  const React = require('react')
  return { inject: ['slots'], apply(ctx) {
    ctx.slots.inject('conversation.input.dock', () => ctx.slots.register(
      { name: 'conversation.input.dock', id: 'my-panel', order: 10 }, () => React.createElement('div', null, 'hello')))
  } }
} })
```

**Gotchas** style with theme tokens (`--dsw-alias-*`) only; never runtime-import a Harness Client package (`dsh.client.inject` names only order activation and stay allowed); no iframe page served from the Host, no DOM writes outside your component, no `document.body` appends. Confirm slot options and props with `cordis_inspect_query` `Slots` before writing the view, and pick a slot that already allocates the space. Docs: `docs/subsystems/slots.md`, `packages/preset/agent-preset/skills/cordis-plugin-development/references/ui-plugin.md`.

## Chat row

**Use when** the transcript should show a new kind of event as its own row. **Mechanism** register one `ConversationNodeDefinition` with `ctx.uiConversation.events.register()` and its keyed view in the `conversation.chat.node` slot; the Conversation layer owns paging, Turn/Step placement, and incremental assembly, and the definition's `kind` is the renderer key.

```js
const definition = {
  kind: 'my-row', target: 'chat',
  match: event => event.type === 'my-domain/thing' ? { id: String(event.data.id), role: 'start' } : null,
  start: (_context, match) => ({ seq: match.event.seq, text: match.event.data.text }),
  update: context => context.state,
  buildViewNode: context => context.state === undefined ? null : ({
    key: context.key, kind: 'my-row', id: context.id, target: 'chat',
    anchorSeq: context.state.seq - 0.1, visibility: 'visible', data: context.state,
  }),
}
ctx.effect(() => ctx.uiConversation.events.register(definition), 'my-row: definition')
ctx.slots.inject('conversation.chat.node', () => ctx.slots.register(
  { name: 'conversation.chat.node', key: 'my-row' }, MyRowView))
```

**Gotchas** `match` reads only the current event; `update` must be deterministically replayable by log `seq`; never scan the event window or fold session state yourself. A plugin may not append a new event `type`, so the row must present an event the session already records. Without a registration, the built-in fallback renders unknown rows generically. Docs: `docs/subsystems/conversation.md`, `docs/cookbook/extension-cookbook.md`.

## Session-derived state

**Use when** a view, badge, or toolbar must reflect turn, tool, or assistant progress. **Mechanism** wait on durable events (`turn/end`, `assistant/message`, `tool/result`); render live tokens from `agent/assistant-stream`. Derive the value once on the Host from committed events and hand it to the slot through props or inject, so the Client subscribes only to the slice it renders.

```js
export const inject = ['agents']

export function apply(ctx) {
  ctx.on('session/event', (session, event) => {
    if (event.type === 'turn/end') publish(session.id, deriveTurnSummary(event))
  })
}
```

**Gotchas** do not poll `agent/status`; `whenIdle()` does not mean one follow-up finished, because several inputs can share one running interval. `agent.followup()` wakes the agent; `agent.inject()` writes context that can wait in the inbox and wakes nothing, so a timer that must cause work calls `followup()` and is cleared in the owning effect. Never append a new session event `type` (`Session.append()` cannot set `ignorable: true`, so the session would refuse to reopen). Docs: `packages/preset/agent-preset/skills/cordis-plugin-development/references/practices.md`, `docs/subsystems/session.md`.

## MCP bridge

**Use when** the result already exists as tools on an MCP server. **Mechanism** a configuration-only bundle: `package.json` with `dsh.bundle.patch`, and a patch inserting the installed `@deepseek-ai/dsh-mcp-client`. No `index.js`, no `client.js`, no code.

```yaml
- insert:
    - id: demo-mcp
      name: '@deepseek-ai/dsh-mcp-client'
      config:
        serverName: demo
        transport: streamable-http
        url: http://127.0.0.1:3000/mcp
        failOnStartupError: true
```

**Gotchas** stdio uses `transport: stdio` with `command` and optional `args`, `env`, `cwd`; the row's Config schema is authoritative. Reference credentials through Loader `!!js`, never by copying secrets into config or conversation text. Verify by calling a newly available `mcp__<serverName>__<tool>`, and repair the same bundle on failure instead of inserting duplicates. Docs: `packages/preset/agent-preset/skills/cordis-plugin-development/references/mcp-bundle.md`.

## LLM adapter

**Use when** and only when the idea is a model provider, not a new model-facing capability. **Mechanism** register an adapter instance per provider route.

```ts
// type shape, not runnable JS — a plain-JS bundle registers an instance, it does not reimplement this class verbatim
class MyAdapter extends LlmAdapter {
  async * stream(options: GenerateOptions): AsyncIterable<StreamChunk> { /* ... */ }
}
export const inject = ['llm']
export function apply(ctx: Context, config: Config) {
  ctx.llm.registerAdapter(['my-provider'], new MyAdapter(config))
}
```

**Gotchas** emit `usage` before `finish` and nothing after it; tool-call `arguments` stay raw JSON strings end to end; block `index`es are first-seen order. Two sanctioned error paths: throw from `stream()` for transport/protocol failures, or end with `finish { kind: 'error' | 'aborted' }` for in-band failures; honor `options.signal`; replay native metadata only through `finish.replayState`. One adapter per provider route — duplicates throw and multi-route registration is all-or-nothing. Real-provider coverage is required. Docs: `docs/cookbook/adding-an-llm-adapter.md`, `docs/subsystems/llm-streaming.md`.

## Host row vs agent preset placement

A bundle-patch row at the profile root is **Host plane**: its registrations serve every session. An agent preset contributes only what one session adds on top (`preset-<id>` row, `config.plugins`): persona, scoped tools, prompt sections, policies. A preset plugin that supplies a service must isolate the provider and all its consumers in the same realm — scope controls contribution visibility, `isolate` controls service instances — and a service consumed by Host plugins belongs in the Host composition. Prefer Host rows unless the result is deliberately per-session. Docs: `packages/preset/agent-preset/skills/editing-cordis-compositions/SKILL.md`, `docs/architecture.md#where-new-behavior-goes`.

New session event types, persistence backends, Typert Remote endpoints (`@Remote`), subagent/terminal/shell/sandbox providers, and Conversation-node infrastructure beyond a business row all require building against a published seam package. An out-of-tree bundle can configure the shipped implementations through `cordis.patch.yml`; it cannot add a new implementation without that seam package.
