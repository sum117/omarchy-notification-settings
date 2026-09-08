import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "../NotificationLogic.js" as Logic

ColumnLayout {
  id: root
  property var service: null
  property string fontFamily: Style.font.family
  property color foreground: Color.foreground
  signal activated()
  spacing: Style.spacing.lg

  property string searchQuery: ""
  readonly property var rows: Logic.filterHistory(service ? service.historyEntries : [], searchQuery)

  Timer {
    id: searchDelay
    interval: 120
    onTriggered: {
      root.searchQuery = search.text
      list.positionViewAtBeginning()
    }
  }

  TextField {
    id: search
    Layout.fillWidth: true
    placeholderText: "Search notifications…"
    foreground: root.foreground
    font.family: root.fontFamily
    selectByMouse: true
    onTextChanged: searchDelay.restart()
  }

  RowLayout {
    Layout.fillWidth: true
    Text {
      Layout.fillWidth: true
      textFormat: Text.PlainText
      text: root.service && root.service.historyLoading && root.service.historyEntries.length === 0
        ? "Loading…" : root.rows.length + " notifications"
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      color: Qt.darker(root.foreground, 1.4)
    }
    Button {
      text: "Clear history"
      iconText: "󰅙"
      focusable: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      onClicked: if (root.service) root.service.clearHistory()
    }
  }

  Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    text: "Clear history keeps active alerts."
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    color: Qt.darker(root.foreground, 1.4)
    wrapMode: Text.WordWrap
  }

  ListView {
    id: list
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: Style.spacing.lg
    model: root.rows
    cacheBuffer: Style.space(400)
    boundsBehavior: Flickable.StopAtBounds
    Controls.ScrollBar.vertical: Controls.ScrollBar {}

    delegate: ColumnLayout {
      id: row
      required property var modelData
      width: list.width
      spacing: Style.spacing.xs

      RowLayout {
        Layout.fillWidth: true
        Text {
          Layout.fillWidth: true
          textFormat: Text.PlainText
          text: Qt.formatDateTime(new Date(row.modelData.timestamp), "ddd d MMM · HH:mm")
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          color: Qt.darker(root.foreground, 1.4)
        }
        Button {
          iconText: "󰅙"
          tooltipText: "Remove notification"
          focusable: true
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: if (root.service) root.service.removeHistoryEntry(row.modelData)
        }
      }

      NotificationCard {
        Layout.fillWidth: true
        app: row.modelData.app
        desktopEntry: row.modelData.desktopEntry || ""
        summary: row.modelData.summary
        body: row.modelData.body
        appIcon: row.modelData.appIcon
        image: row.modelData.image
        channel: row.modelData.channel
        glyph: row.modelData.glyph
        urgency: row.modelData.urgency
        timestamp: row.modelData.timestamp
        fontFamily: root.fontFamily
        cornerRadius: Style.cornerRadius
        expanded: true
        otpEnabled: root.service ? root.service.otpCopy : false
        actions: root.service ? root.service.actionsForEntry(row.modelData) : []
        onCloseRequested: if (root.service) root.service.removeHistoryEntry(row.modelData)
        onCardClicked: {
          if (root.service) root.service.activateHistory(row.modelData)
          root.activated()
        }
        onActionRequested: function(identifier) {
          if (root.service) root.service.invokeEntryAction(row.modelData, identifier)
          root.activated()
        }
      }
    }

    Text {
      anchors.centerIn: parent
      width: parent.width
      visible: root.rows.length === 0 && !(root.service && root.service.historyLoading)
      textFormat: Text.PlainText
      text: search.text.trim() ? "No matching notifications" : "No notifications yet"
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      color: Qt.darker(root.foreground, 1.4)
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
    }
  }
}
