import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "components"

KeyboardPanel {
  id: root

  readonly property var service: bar && bar.shell
    ? bar.shell.serviceFor("andrewscofield.notifications-settings") : null
  readonly property bool dnd: service ? service.doNotDisturb : false
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  property bool previewSent: false
  property bool historyView: true
  property bool countedOpen: false

  function updatePanelPresence() {
    if (!service || countedOpen === open) return
    service.panelOpenCount = Math.max(0, service.panelOpenCount + (open ? 1 : -1))
    countedOpen = open
    if (open) service.refreshHistory()
  }
  Component.onDestruction: {
    if (countedOpen && service) service.panelOpenCount = Math.max(0, service.panelOpenCount - 1)
  }

  // Use KeyboardPanel's anchor placement, screen clamping and dismissal.
  centerOnBar: false
  focusTarget: form
  contentWidth: fittedContentWidth(Style.space(380))
  contentHeight: fittedContentHeight(historyView ? Style.space(550) : mainColumn.implicitHeight + navigation.implicitHeight + Style.spacing.lg)

  component Section: PanelSectionHeader {
    Layout.fillWidth: true
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  component Separator: PanelSeparator {
    Layout.fillWidth: true
    foreground: root.foreground
  }

  component Choices: RowLayout {
    id: choices
    property var options: []
    property string value: ""
    signal selected(string value)
    Layout.fillWidth: true
    spacing: Style.spacing.md

    Repeater {
      model: choices.options
      Button {
        required property var modelData
        Layout.fillWidth: true
        text: modelData.label
        selected: choices.value === modelData.value
        bordered: true
        focusable: true
        foreground: root.foreground
        fontFamily: root.fontFamily
        onClicked: choices.selected(modelData.value)
        onActiveFocusChanged: if (activeFocus) root.revealControl(this)
      }
    }
  }

  // Keep focused controls in view when the screen cannot fit the whole form.
  function revealControl(item) {
    var pos = item.mapToItem(mainColumn, 0, 0)
    var next = scroller.contentY
    if (pos.y < next) next = pos.y
    else if (pos.y + item.height > next + scroller.height)
      next = pos.y + item.height - scroller.height
    scroller.contentY = Math.max(0, Math.min(next, scroller.contentHeight - scroller.height))
  }

  FocusScope {
    id: form
    anchors.fill: parent
    Keys.onEscapePressed: root.close()

    Connections {
      target: root
      function onOpenChanged() { root.updatePanelPresence() }
    }
    Connections {
      target: root.service
      function onOpenHistorySerialChanged() { root.historyView = true }
    }

    RowLayout {
      id: navigation
      anchors.top: parent.top
      width: parent.width
      spacing: Style.spacing.md
      Button {
        Layout.fillWidth: true
        text: "History"
        selected: root.historyView
        bordered: true
        focusable: true
        foreground: root.foreground
        fontFamily: root.fontFamily
        onClicked: {
          root.historyView = true
          if (root.service) root.service.refreshHistory()
        }
      }
      Button {
        Layout.fillWidth: true
        text: "Settings"
        selected: !root.historyView
        bordered: true
        focusable: true
        foreground: root.foreground
        fontFamily: root.fontFamily
        onClicked: root.historyView = false
      }
    }

    NotificationHistory {
      anchors.top: navigation.bottom
      anchors.topMargin: Style.spacing.lg
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      visible: root.historyView
      service: root.service
      foreground: root.foreground
      fontFamily: root.fontFamily
      onActivated: root.close()
    }

    Timer {
      id: previewTimer
      interval: 2000
      onTriggered: root.previewSent = false
    }

    Flickable {
      id: scroller
      visible: !root.historyView
      anchors.top: navigation.bottom
      anchors.topMargin: Style.spacing.lg
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      contentWidth: width
      contentHeight: mainColumn.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      flickableDirection: Flickable.VerticalFlick
      Controls.ScrollBar.vertical: Controls.ScrollBar {
        policy: scroller.contentHeight > scroller.height ? Controls.ScrollBar.AsNeeded : Controls.ScrollBar.AlwaysOff
      }

      ColumnLayout {
        id: mainColumn
        width: scroller.width
        spacing: Style.spacing.lg
        enabled: root.service !== null

        PanelHero {
          Layout.fillWidth: true
          title: "Notifications"
          meta: root.dnd ? "Do not disturb" : "Notifications on"
          foreground: root.foreground
          fontFamily: root.fontFamily
          iconComponent: Component {
            OpticalGlyph {
              implicitWidth: Style.font.display
              implicitHeight: Style.font.display
              text: root.dnd ? "󰂛" : "󰂚"
              fontFamily: root.fontFamily
              fontSize: Style.font.display
              color: root.foreground
            }
          }
        }

        Toggle {
          Layout.fillWidth: true
          label: "Do not disturb"
          checked: root.dnd
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: if (root.service) root.service.setDoNotDisturb(!root.dnd)
          onActiveFocusChanged: if (activeFocus) root.revealControl(this)
        }

        Separator {}
        Section { text: "TOAST POSITION" }
        Choices {
          value: root.service ? root.service.position : "bottom-center"
          options: [
            { value: "top-left", label: "Top left" },
            { value: "top-center", label: "Top center" },
            { value: "top-right", label: "Top right" }
          ]
          onSelected: function(value) { if (root.service) root.service.setPosition(value) }
        }
        Choices {
          value: root.service ? root.service.position : "bottom-center"
          options: [
            { value: "bottom-left", label: "Bottom left" },
            { value: "bottom-center", label: "Bottom center" },
            { value: "bottom-right", label: "Bottom right" }
          ]
          onSelected: function(value) { if (root.service) root.service.setPosition(value) }
        }

        Section { text: "DISPLAY TIMEOUT" }
        Choices {
          value: root.service ? String(root.service.timeoutSeconds) : "8"
          options: [
            { value: "3", label: "3s" }, { value: "5", label: "5s" },
            { value: "8", label: "8s" }, { value: "12", label: "12s" },
            { value: "15", label: "15s" }
          ]
          onSelected: function(value) { if (root.service) root.service.setTimeoutSeconds(Number(value)) }
        }

        Section { text: "GROUP NOTIFICATIONS" }
        Choices {
          value: root.service ? root.service.groupingMode : "channel"
          options: [
            { value: "all", label: "All" },
            { value: "app", label: "By app" },
            { value: "channel", label: "By channel" }
          ]
          onSelected: function(value) { if (root.service) root.service.setGroupingMode(value) }
        }

        Separator {}
        Toggle {
          Layout.fillWidth: true
          label: "Copy verification codes"
          description: "Show a copy button for one-time codes"
          checked: root.service ? root.service.otpCopy : true
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: if (root.service) root.service.setOtpCopy(!root.service.otpCopy)
          onActiveFocusChanged: if (activeFocus) root.revealControl(this)
        }
        Toggle {
          Layout.fillWidth: true
          label: "Keep chat alerts visible"
          description: "Dismiss messaging notifications manually"
          checked: root.service ? root.service.infiniteChat : true
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: if (root.service) root.service.setInfiniteChat(!root.service.infiniteChat)
          onActiveFocusChanged: if (activeFocus) root.revealControl(this)
        }

        Separator {}
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.md
          Button {
            Layout.fillWidth: true
            text: root.previewSent ? "Sent" : "Preview"
            bordered: true
            focusable: true
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: {
              if (!root.service) return
              root.service.sendPreview()
              root.historyView = true
              root.service.refreshHistory()
              root.previewSent = true
              previewTimer.restart()
            }
            onActiveFocusChanged: if (activeFocus) root.revealControl(this)
          }
          Button {
            Layout.fillWidth: true
            text: "History"
            bordered: true
            focusable: true
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: {
              root.historyView = true
              if (root.service) root.service.refreshHistory()
            }
            onActiveFocusChanged: if (activeFocus) root.revealControl(this)
          }
          Button {
            Layout.fillWidth: true
            text: "Dismiss all"
            bordered: true
            focusable: true
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: if (root.service) root.service.dismissAll()
            onActiveFocusChanged: if (activeFocus) root.revealControl(this)
          }
        }
      }
    }
  }

}
