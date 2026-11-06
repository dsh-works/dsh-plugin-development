# Where to read what

The authoritative documentation is the `deepseek-harness` checkout. Paths below are relative to that checkout (`Documents\harness-sc\deepseek-harness`). When a path has moved, find the owner by subject — the tiers are stable even when a file is not.

## Start here, in order

| Question | Read |
|---|---|
| What is a plugin, in the harness's own terms? | `docs/cordis-primer.md`, then `docs/cordis-tutorial/index.md` (7 keyless chapters) |
| How do I write and load one from a config file? | `docs/user/develop/basic/index.md`, `basic/tool.md`, `basic/config.md`, `basic/publish.md` |
| What is the process and strategy the harness itself uses? | `packages/preset/agent-preset/skills/cordis-plugin-development/SKILL.md` and especially `references/practices.md` |
| What extension points exist, and which one should I use? | `docs/cookbook/extension-cookbook.md`; `docs/architecture.md#where-new-behavior-goes`; `docs/subsystems/README.md` |
| How is a package put together? | `docs/cookbook/adding-a-package.md` |

## By subject

| Subject | Read |
|---|---|
| Lifecycle, effects, disposal, HMR | `docs/user/develop/framework/index.md`; `docs/cordis-primer.md#practical-rules`; `docs/defensive-patterns/general.md` |
| Services, `inject`, dependency loading | `docs/user/develop/framework/service.md`; `docs/glossary.md` |
| Events, dispatch modes, waterfall `next()` | `docs/user/develop/framework/events.md`; `docs/cordis-primer.md#dispatch-modes`; `docs/event-producer-consumer.md` |
| Tools: schema DSL, execute contract, background jobs, PTC | `docs/cookbook/adding-a-tool.md`; `docs/subsystems/tools.md`; `docs/tool-catalog.md` |
| Tool UI cards and presentation | `docs/cookbook/adding-a-tool.md#how-your-tool-renders-in-a-ui` |
| Web UI slots and client modules | `docs/subsystems/slots.md`; `docs/subsystems/client-modules.md`; `docs/subsystems/web-client.md` |
| Chat rows and Conversation assembly | `docs/subsystems/conversation.md` |
| Locale, settings cards, plugin display metadata | `docs/cookbook/adding-a-settings-card.md`; `docs/cookbook/adding-a-package.md#plugin-display-metadata` |
| Session events, turn/step, projections | `docs/subsystems/session.md`; `docs/subsystems/session-projection.md` |
| LLM adapters and streaming | `docs/cookbook/adding-an-llm-adapter.md`; `docs/subsystems/llm-streaming.md` |
| MCP servers as tools | `docs/subsystems/mcp.md`; `packages/mcp/mcp-client/README.md` |
| Profiles, bundles, patch layers, install mechanics | `docs/user/develop/basic/publish.md`; `packages/boot/app-boot/README.md#profiles`; `packages/boot/plugin-manager/README.md` |
| Every config field a row can set | `docs/config-catalog.md` |
| Swappable capability families | `docs/capability-seams.md`; `docs/glossary.md#capability-seam` |
| Publishing through a plugin index | `docs/user/guide/plugin-market.md`; `apps/plugin-market-generator/README.md` |
| The review standards this repo enforces | `docs/defensive-patterns/README.md`; `.agents/skills/cordis-styling-nitpicking/SKILL.md`; `.agents/skills/dsh-code-review/SKILL.md` |
| UI design and review expectations | `.agents/skills/dsh-client-ui-ux/SKILL.md`; `docs/ui-design-review-cases.md` |
| Tool descriptions from the model's point of view | `packages/preset/agent-preset/skills/agent-experience/SKILL.md` |

## Worked examples

| Example | Why read it |
|---|---|
| `packages/todo/tool-todo/` | smallest complete tool plugin, Host plus Client |
| `packages/shell/tool-bash/` | production tool: output schema, background work, presentation |
| `packages/plan/plan-mode/` | multi-surface plugin: service, projection, command, tool, client half |
| `packages/acp/acp/` | protocol driver over `ctx.agents`, teardown to quiescence |
| `Documents\deepseek-harness\dsh-plugin-pixelart` | a real out-of-tree bundle with a large browser half |
| `Documents\deepseek-harness\dsh-fren` | a real bundle whose entire feature lives in `client.js` |

## Loading and inspecting a plugin

- `docs/user/develop/basic/publish.md` explains bundle vs profile and the layer order.
- `docs/sub/` does not exist — if a path fails, search by tier name: `docs/cookbook/`, `docs/subsystems/`, `docs/user/develop/`, `packages/*/*/README.md`.
- Installed packages ship `lib/types/*.d.ts` and JSDoc; a source checkout ships `src/`. Prefer the installed package's declarations when diagnosing a running install, and the checkout when reading behaviour.

## Keeping this index honest

- The harness is a developer preview: paths and APIs move between releases.
- Before trusting an entry, check that the file exists; if it does not, find the replacement by subject and update this file.
- When `engines.dsh` moves for a plugin, re-read the changed rows of this table before writing code.
