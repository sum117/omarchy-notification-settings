# Omarchy Notifications Settings

A notification service and bar panel for Omarchy's Quickshell-based desktop, with
searchable history, notification actions, one-click verification-code copying,
and configurable toast placement.

This is [sum117's fork](https://github.com/sum117/omarchy-notification-settings)
of [Andrew Scofield's plugin](https://github.com/andrewscofield/omarchy-notification-settings),
which builds on Omarchy's notification service. This fork uses the plugin ID
`sum117.notifications-settings`. See the migration steps below for older installs.

## Improvements in this fork

- **Native panel:** Omarchy controls, theme colors, shell fonts, and corner settings.
  The panel opens beside the clicked bell and closes on a second click, Escape,
  or a click outside. Controls support keyboard navigation.
- **History inside the panel:** A searchable, scrolling list combines active alerts
  with up to 100 recent archived entries. Search matches application, title,
  message, and channel. Viewing history does not replay desktop toasts.
- **Interactive toasts:** Card-sized Wayland surfaces make dismissal, code copying,
  and application actions clickable. Long stacks scroll within the screen.
- **Reliable actions:** Live cards expose the sender's action buttons. Archived
  entries can focus an existing application window; expired callbacks are not
  replayed. Notification identity checks keep older entries from acting on a
  newer notification that reuses the same ID.
- **Smoother history updates:** Updates follow storage changes and preserve unchanged
  lists. Search is debounced, and clear-history help stays inside the panel.
- **Sender icons and consistent controls:** Sender images take priority, with desktop
  icons and Omarchy's bundled agent logos as fallbacks. Application identity is
  preserved in history, and Codex logos adapt to the notification theme. History,
  settings, copy, and dismissal controls use Nerd Font glyphs; search stays plain.
- **Regression coverage and repository cleanup:** Tests cover panel dismissal,
  history identity, icon selection, and card input. Generated Python caches are
  excluded from version control.

## Features

The plugin retains the original configurable six toast positions, notification
grouping by channel or application, channel badges, display-duration choices,
sticky chat alerts, Do Not Disturb, notification previews, verification-code
extraction, and persistent notification state.

## Requirements

- Omarchy with its Quickshell shell and native plugin UI components
- Python 3 for notification storage
- `wl-clipboard` for copying verification codes
- `libnotify` for previews (`notify-send`)
- Omarchy's configured Nerd Font for interface glyphs

This plugin uses Omarchy's installed controls and assets; it is not a standalone
Quickshell configuration. Only one notification service can own the session's
`org.freedesktop.Notifications` D-Bus name.

## Install

Clone the fork into the directory matching its plugin ID:

```bash
git clone https://github.com/sum117/omarchy-notification-settings.git ~/.config/omarchy/plugins/sum117.notifications-settings
```

Merge the following entries into `~/.config/omarchy/shell.json`, preserving your
other plugins and bar items. Register this service, disable the stock service,
and add the bell to your preferred bar section. This example places it on the right:

```json
{
  "plugins": [
    { "id": "sum117.notifications-settings" }
  ],
  "disabledPlugins": [
    "omarchy.notifications"
  ],
  "bar": {
    "layout": {
      "right": [
        { "id": "sum117.notifications-settings" }
      ]
    }
  }
}
```

Restart the shell:

```bash
omarchy restart shell
```

## Migrate an existing installation

Earlier versions used `andrewscofield.notifications-settings`. To migrate, first
save any local edits and back up `~/.config/omarchy/shell.json`. Rename the
installation directory, then update it from this fork:

```bash
mv ~/.config/omarchy/plugins/andrewscofield.notifications-settings ~/.config/omarchy/plugins/sum117.notifications-settings
git -C ~/.config/omarchy/plugins/sum117.notifications-settings remote set-url origin https://github.com/sum117/omarchy-notification-settings.git
git -C ~/.config/omarchy/plugins/sum117.notifications-settings pull --ff-only
```

Use the `mv` command only if the destination directory does not already exist.
Replace `andrewscofield.notifications-settings` with
`sum117.notifications-settings` throughout `~/.config/omarchy/shell.json`,
including any `plugins`, `bar.layout`, and `cloneSourceRestores` entries.
Update custom commands that summon the old plugin ID, then run
`omarchy restart shell`. Keep `omarchy.notifications` disabled.

Settings and notification history keep their existing storage paths; no state
migration is needed. Upstream repository links and attribution remain unchanged.

## Use

- **Bell:** Left-click opens history and settings. Right-click toggles DND; the bell
  changes to a crossed-out glyph while DND is enabled.
- **History:** Search notifications, then right-click an entry or use its remove
  button to dismiss it or remove its archived record. Clear history removes
  archived entries while keeping active alerts.
- **Live notifications:** Click a card to invoke its default action, or focus the
  application when no default action is available. Use the sender's action buttons
  for other actions. Right-click or choose Dismiss to dismiss a toast.
- **Verification codes:** Choose Copy Code to copy the detected code to the
  clipboard. Right-clicking that control dismisses the toast without copying.
- **Settings:** Choose position, grouping, and duration, toggle DND, or send a
  preview. Previews opened from settings appear in the panel's History tab.

While the panel is open, desktop toasts are hidden and their timers pause;
notifications remain accessible in the panel. Sticky chat alerts and urgency can
change when a notification expires, independently of the selected duration.

The existing history command also opens this panel:

```bash
omarchy shell notifications showHistory
```

## Update

```bash
git -C ~/.config/omarchy/plugins/sum117.notifications-settings pull --ff-only
omarchy restart shell
```

If you have local edits, review and commit or save them before updating.

## Return to stock notifications

Remove this plugin from `plugins` and `bar.layout` in
`~/.config/omarchy/shell.json`, remove `omarchy.notifications` from
`disabledPlugins`, then run `omarchy restart shell`.

## Local storage and notification handling

Settings are stored in `~/.local/state/omarchy/notifications.json`. Active and
archived notifications, plus saved images, live under
`~/.local/state/omarchy/notifications/`. Notification content is stored locally
as plaintext, including any verification codes present in messages.

The Python storage helper uses private directories, bounded reads, and atomic
writes. Notification text is rendered as plain text; image sources are limited
to supported local files, providers, and icon names. Arbitrary command hints
are not executed. Application actions use the live notification's callbacks,
and the focus fallback uses Omarchy's application-focus helper.

## Development checks

From the repository root:

```bash
node tests/panel.test.cjs
node tests/history.test.cjs
node tests/icons.test.cjs
python3 tests/run-card-input.py
git diff --check
```

The Python check requires an Omarchy installation and runs actual card pointer
handlers in an isolated offscreen Quickshell instance. Compositor input regions,
bar anchoring, and theme appearance should also be checked in a live Wayland session.

## Credits and license

Original plugin by **Andrew Scofield**, built on **Omarchy**. Fork improvements
by **Joao Victor Weyne Parente Caliman (sum117)**. See
[ATTRIBUTIONS.md](ATTRIBUTIONS.md) for the contribution breakdown and asset sources.

Distributed under the [MIT License](LICENSE), retaining upstream copyright notices.
