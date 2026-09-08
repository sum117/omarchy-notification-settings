import QtQuick
import QtQuick.Window
import QtTest
import "components"

Window {
  width: 420; height: 420; visible: true
  Timer {
    interval: 150; running: true
    onTriggered: {
      try {
        input.runChecks()
        console.log("CARD_INPUT_PASS")
      } catch (e) { console.error("CARD_INPUT_FAIL", e) }
      Qt.quit()
    }
  }
  TestCase {
    id: input
    visible: true
    when: false
    width: 420; height: 420
    NotificationCard {
      id: card
      width: 380; height: implicitHeight
      app: "Test"; summary: "Test notification"
      body: "Your verification code is: 123456"
      actions: [{ identifier: "reply", text: "Reply" }]
      fontFamily: "monospace"
    }
    SignalSpy { id: dismissed; target: card; signalName: "closeRequested" }
    SignalSpy { id: activated; target: card; signalName: "cardClicked" }
    SignalSpy { id: action; target: card; signalName: "actionRequested" }
    SignalSpy { id: copied; target: card; signalName: "otpCopied" }
    function reset() { dismissed.clear(); activated.clear(); action.clear(); copied.clear() }
    function check(condition, message) { if (!condition) throw new Error(message) }
    function runChecks() {
      mouseClick(card, 180, 35, Qt.RightButton)
      check(dismissed.count === 1 && activated.count === 0, "right-click body must dismiss")
      reset()
      mouseClick(card, 180, 35, Qt.LeftButton)
      check(activated.count === 1 && dismissed.count === 0, "left-click body must activate")
      reset()
      var copy = findChild(card, "copyCode")
      check(!!copy, "copy control must exist")
      mouseClick(copy, copy.width / 2, copy.height / 2, Qt.RightButton)
      check(dismissed.count === 1 && copied.count === 0 && activated.count === 0, "right-click OTP must dismiss without copying or opening")
      reset()
      var reply = findChild(card, "notificationAction-reply")
      check(!!reply, "client action must be exposed")
      mouseClick(reply, reply.width / 2, reply.height / 2, Qt.LeftButton)
      check(action.count === 1 && action.signalArguments[0][0] === "reply" && activated.count === 0, "client button must invoke only its action")
      reset()
      var close = findChild(card, "dismissNotification")
      mouseClick(close, close.width / 2, close.height / 2, Qt.LeftButton)
      check(dismissed.count === 1 && activated.count === 0, "dismiss button must not activate")
    }
  }
}
