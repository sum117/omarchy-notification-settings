import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "andrewscofield.notifications-settings"
  readonly property bool hovered: button.tooltipHovered

  readonly property var service: bar && bar.shell
    ? (bar.shell.serviceFor("andrewscofield.notifications-settings") || bar.shell.serviceFor(root.moduleName) || bar.shell.serviceFor("andrew.notifications") || bar.shell.firstPartyServiceFor("omarchy.notifications"))
    : null
  readonly property bool isCenter: bar && bar.layoutConfig && bar.layoutConfig.center
    ? bar.layoutConfig.center.some(function(entry) {
        return (typeof entry === "string" ? entry : entry.id) === root.moduleName
      }) : false
  readonly property bool centerHovered: bar && bar.centerSectionRevealHeld === true && bar.centerHoverRevealSuppressed !== true
  readonly property bool isDnd: service ? service.doNotDisturb : false
  readonly property bool panelOpen: panelLoader.item ? panelLoader.item.open : false
  readonly property bool revealed: !isCenter || hovered || panelOpen || centerHovered || isDnd

  // Match the standard icon slot and full bar height so the glyph shares
  // the same center and baseline as its neighboring buttons.
  implicitWidth: revealed ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight
  visible: true
  clip: true

  Behavior on implicitWidth { NumberAnimation { duration: 120 } }
  Behavior on opacity { NumberAnimation { duration: 120 } }
  opacity: panelOpen ? 1.0 : (hovered ? 1.0 : (revealed ? (isCenter ? 0.45 : 1.0) : 0.0))

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // Matched Nerd Font bells: the slash appears only while DND is on.
    text: root.isDnd ? "󰂛" : "󰂚"
    tooltipText: root.isDnd ? "Notifications Muted · Right-click to unmute" : "Notification Settings"
    useActiveColor: root.isDnd
    activeColor: Color.urgent
    active: root.isDnd

    onPressed: function(btn) {
      if (btn === Qt.RightButton) {
        if (root.service) root.service.setDoNotDisturb(!root.service.doNotDisturb)
      } else {
        root.togglePanel()
      }
    }
  }

  readonly property bool opened: panelLoader.item ? panelLoader.item.open === true : false

  function toggle() {
    opened ? close() : open()
  }

  function togglePanel() {
    toggle()
  }

  function open() {
    if (panelLoader.item) panelLoader.item.open = true
  }

  function close() {
    // KeyboardPanel.close() delegates to its owner, so finish the close here.
    if (panelLoader.item) panelLoader.item.open = false
  }

  Loader {
    id: panelLoader
    active: true
    sourceComponent: panelComponent
  }

  Component {
    id: panelComponent
    NotificationSettingsPanel {
      anchorItem: button
      bar: root.bar
      owner: root
    }
  }
}
