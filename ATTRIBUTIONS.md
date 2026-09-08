# Attributions

## Original plugin

[Andrew Scofield](https://github.com/andrewscofield) created
[Omarchy Notifications Settings](https://github.com/andrewscofield/omarchy-notification-settings),
the MIT-licensed plugin from which this repository was forked.

His plugin provides the foundation for the configurable notification settings,
six toast positions, verification-code extraction and copying, channel grouping
and badges, sticky chat behavior, previews, and notification storage used here.
The fork also retains its plain-text rendering and restrictions on executable
notification hints. Andrew's copyright notice remains in [LICENSE](LICENSE).

## Omarchy

[Omarchy](https://github.com/basecamp/omarchy), by David Heinemeier Hansson and
contributors, supplies the original notification-service foundation and the
shell this plugin integrates with. The plugin's manifest records that lineage
as `omarchy.notifications`.

The fork uses Omarchy's installed panel and control components, theme values,
fonts, application-focus helper, and native icon conventions. The Codex, Claude,
and Fireworks logo fallbacks reference assets in the installed Omarchy Agents
plugin (`$OMARCHY_PATH/shell/plugins/agents/assets/`); those logo files are not
bundled in this repository. Other sender icons come from the notification itself
or the application's desktop entry and installed icon theme. Interface glyphs
are rendered by the configured Nerd Font.

Omarchy's [MIT license](https://github.com/basecamp/omarchy/blob/master/LICENSE)
includes the copyright notice for David Heinemeier Hansson, preserved here in
[LICENSE](LICENSE). Referenced application logos and installed fonts remain
subject to their respective owners' terms; this fork's license does not relicense
those external assets.

## Fork contributions

[Joao Victor Weyne Parente Caliman (sum117)](https://github.com/sum117) maintains
[this fork](https://github.com/sum117/omarchy-notification-settings).

Fork contributions include the native themed and anchored panel, panel dismissal
fixes, DND indicator states, searchable in-panel history, event-driven history
updates, live-action and notification-identity handling, card-sized toast input
surfaces, sender-icon fallbacks and persistence, interface glyph choices,
regression tests, repository cleanup, and revised documentation.

These changes extend the upstream work and are distributed under the same MIT
license. The retained plugin ID supports existing installations; it does not
indicate that Andrew maintains this fork.
