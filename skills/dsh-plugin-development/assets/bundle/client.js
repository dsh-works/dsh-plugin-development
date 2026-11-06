/**
 * Browser half of the <plugin> bundle.
 *
 * This file is a self-contained classic script, not an ES module: the client
 * module loader evaluates it directly, so it must not use import/export and
 * cannot import sibling files. Everything it needs is inline here or comes
 * through `require`, which resolves baseline browser modules such as react.
 *
 * The loader id must be exactly the package name in package.json.
 */

window.__ModuleLoader__.load({
  id: 'dsh-plugin-<slug>',
  factory(require) {
    const React = require('react')
    const h = React.createElement

    /** Locale namespace owned by this plugin. */
    const NS = 'dsh-<slug>'

    /** TODO: replace with the real view. */
    function Panel(props) {
      return h('div', null, 'TODO: <plugin> is not implemented yet')
    }

    return {
      // Services this browser half uses. `slots` is required to render;
      // `locale` only when the plugin ships strings.
      inject: ['slots', 'locale'],
      apply(ctx) {
        // Confirm the slot id and its props before keeping this registration.
        ctx.slots.inject('<slot-id>', () =>
          ctx.slots.register(
            {
              name: '<slot-id>',
              id: '<row-id>',
              order: 0,
              inject: () => ({}),
            },
            Panel,
          ),
        )
      },
    }
  },
})
