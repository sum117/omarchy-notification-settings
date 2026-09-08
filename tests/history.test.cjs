const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const { test } = require('node:test');
const logic = require('../NotificationLogic.js');
const rows = [
  { originalId: 1, timestamp: 100, app: 'Signal', summary: 'Project', body: 'Meeting tomorrow', channel: 'Family' },
  { originalId: 1, timestamp: 200, app: 'Mail', summary: 'Invoice', body: 'Payment received', channel: '' }
];
test('search matches app, body, title and channel, case-insensitively', () => {
  assert.deepEqual(logic.filterHistory(rows, 'SIGNAL tomorrow family'), [rows[0]]);
  assert.deepEqual(logic.filterHistory(rows, 'invoice received'), [rows[1]]);
  assert.deepEqual(logic.filterHistory(rows, '  '), rows);
  assert.deepEqual(logic.filterHistory(rows, 'signal invoice'), []);
});
const source = fs.readFileSync(path.join(__dirname, '..', 'Service.qml'), 'utf8');
function handler(name) {
  return source.match(new RegExp(`^  function ${name}\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}`, 'm'))[0];
}
test('history loading does not mutate or replay desktop popups', () => {
  const popupModel = { count: 1, get: () => rows[1] };
  const context = vm.createContext({ NotificationLogic: logic, NotificationUrgency: { Normal: 1 }, popupModel, historyEntries: [], historyLimit: 100 });
  vm.runInContext(handler('liveHistoryRows') + handler('loadHistory'), context);
  context.loadHistory(JSON.stringify(rows[0]));
  assert.equal(context.historyEntries.length, 2);
  assert.equal(context.historyEntries[0].timestamp, 200);
  assert.equal(popupModel.count, 1);
  const stable = context.historyEntries;
  context.loadHistory(JSON.stringify(rows[0]));
  assert.equal(context.historyEntries, stable, 'unchanged refresh preserves scroll/model state');
});
test('archived entries cannot invoke a new notification that reused the same ID', () => {
  const context = vm.createContext({ NotificationLogic: logic, popupModel: { count: 1, get: () => rows[1] } });
  vm.runInContext(handler('liveIndexFor'), context);
  assert.equal(context.liveIndexFor(rows[0]), -1);
  assert.equal(context.liveIndexFor(rows[1]), 0);
});
test('removing an archived entry leaves a live notification with a reused ID alone', () => {
  const commands = [];
  let refreshed = false;
  const context = vm.createContext({
    NotificationLogic: logic,
    popupModel: { count: 1, get: () => rows[1] },
    historyEntries: rows.slice(), storageScript: 'storage', historyDir: 'history', imagesDir: 'images',
    dismissPopup() { throw new Error('Must not dismiss unrelated live notification'); },
    enqueuePopupFileJob(command) { commands.push(Array.from(command)); },
    refreshHistory() { refreshed = true; }
  });
  vm.runInContext(handler('liveIndexFor') + handler('removeHistoryEntry'), context);
  context.removeHistoryEntry(rows[0]);
  assert.deepEqual(commands, [['storage', 'delete', 'history', 'images', '100-1']]);
  assert.equal(context.historyEntries.length, 1);
  assert.equal(context.historyEntries[0].timestamp, 200);
  assert.equal(refreshed, true);
});
test('client actions invoke the selected callback and dismiss only that live entry', () => {
  let invoked = 0;
  const dismissed = [];
  const context = vm.createContext({
    console,
    liveRefForEntry() { return { actions: [{ identifier: 'reply', invoke() { invoked++; } }] }; },
    liveIndexFor() { return 3; },
    dismissPopup(index) { dismissed.push(index); }
  });
  vm.runInContext(handler('invokeEntryAction'), context);
  context.invokeEntryAction(rows[0], 'reply');
  assert.equal(invoked, 1);
  assert.deepEqual(dismissed, [3]);
  context.liveRefForEntry = () => null;
  context.invokeEntryAction(rows[0], 'reply');
  assert.equal(invoked, 1);
});
