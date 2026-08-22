# Umbriel Layout

A noctalia bar widget that shows which layout Umbriel is tiling with and switches between them on click.

## Plugin

Manifest id `boatette/umbriel-layout`. One entry:

| Entry | Kind       | Notes                                                  |
| ----- | ---------- | ------------------------------------------------------ |
| `bar` | bar widget | Icon, letter, or word. Left click switches the layout. |

Add it to a bar as `boatette/umbriel-layout:bar`.

## Switching

Left click switches to the other layout, via `umbriel msg workspace-set-layout:<mode>`.

The widget sends an explicit mode rather than umbriel's `toggle` because it has to keep track of the layout itself, see below.

## Keeping the keybind in sync

Umbriel's IPC has no way to _read_ the current layout. Its commands are `windows`, `layers`, `keyboard-layouts`, and `msg`, and none of them report a workspace's mode; there is no layout-changed event to subscribe to either. So the widget tracks the value itself, seeded from `[layout] mode` in umbriel's config and updated on each switch it performs.

That means a switch made _behind_ the widget's back leaves the icon stale. Point the keybind at the widget instead of at umbriel:

```toml
"Mod+Shift+T" = "spawn:noctalia msg plugin boatette/umbriel-layout:bar all toggle"
```

The widget then performs the switch and updates, and keyboard and mouse agree.

Three events are accepted:

| Event    | Payload               | Effect                                     |
| -------- | --------------------- | ------------------------------------------ |
| `toggle` |                       | Switch to the other layout.                |
| `set`    | `scrolling`/`dwindle` | Switch to that layout.                     |
| `sync`   | `scrolling`/`dwindle` | Adopt that layout without calling umbriel. |

`sync` is the escape hatch for anything that switches the layout on its own: have it tell the widget afterwards.

The tracked value is shared through `noctalia.state`, so bars on several monitors always show the same thing.

## Known limits

- **Per-workspace layouts are not tracked.** `workspace-set-layout` acts on the focused workspace, and umbriel supports per-workspace `layout.mode` rules, but since the layout cannot be queried, the widget keeps a single value rather than one per workspace. If you switch layouts on one workspace and move to another that differs, the widget shows the layout you last selected, not that workspace's.
- **The seed is the config default.** After a noctalia restart with umbriel still running, the widget re-reads `[layout] mode` and can start out of date; one click puts it right. Set `initial_mode` to pin a starting value instead.
