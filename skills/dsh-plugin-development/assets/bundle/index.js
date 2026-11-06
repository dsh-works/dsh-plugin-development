/**
 * Host half of the <plugin> bundle.
 *
 * This file exists in the repository even when all behaviour is in client.js:
 * the package has to be a Loader row, which is what makes its `dsh.client`
 * declaration discoverable when the Web client module graph is composed.
 *
 * Keep pure logic in separate modules so it is unit-testable under plain Node.
 */

/** Short id used in diagnostics; must match the patch row id. */
export const name = '<row-id>'

/** Host services this plugin depends on. Declare every service used in apply. */
export const inject = []

/**
 * Host half body. Every registration is an effect and is removed when the
 * plugin unloads.
 * @param ctx - the Cordis context for this plugin.
 */
export function apply(ctx) {
  // Register tools, listeners, or prompt sections here. For example:
  //
  //   ctx.on('turn/end', () => { ... })
  //   ctx.effect(() => { const timer = setInterval(...); return () => clearInterval(timer) })
  //
  // Nothing to do here yet.
  void ctx
}
