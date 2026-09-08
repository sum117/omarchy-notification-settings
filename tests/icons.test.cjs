const assert = require('node:assert/strict');
const { test } = require('node:test');
const logic = require('../NotificationLogic.js');
test('desktop identity and supplied icon survive persistence and history', () => {
  const entry = logic.snapshotOf({ id: 1, appName: 'Example', appIcon: 'example-icon', hints: { 'desktop-entry': 'org.example.App' } }, 123);
  const restored = logic.parsePopupFiles(logic.serializePopup(entry, 1), 1)[0];
  assert.equal(restored.desktopEntry, 'org.example.App');
  assert.equal(restored.appIcon, 'example-icon');
});
test('Codex uses Omarchy light/dark assets and never guesses from message contents', () => {
  assert.deepEqual(logic.officialAgentIconPaths('Codex', '/usr/share/omarchy', false), ['/usr/share/omarchy/shell/plugins/agents/assets/codex.svg']);
  assert.deepEqual(logic.officialAgentIconPaths('Codex', '/usr/share/omarchy', true), ['/usr/share/omarchy/shell/plugins/agents/assets/codex-light.svg', '/usr/share/omarchy/shell/plugins/agents/assets/codex.svg']);
  assert.deepEqual(logic.officialAgentIconPaths('omarchy-action', '/usr/share/omarchy', false), []);
  assert.deepEqual(logic.officialAgentIconPaths('../codex', '/usr/share/omarchy', false), []);
});
test('image-path hints retain file paths instead of opaque placeholder providers', () => {
  const entry = logic.snapshotOf({ id: 2, appName: 'Codex', image: 'image://icon//tmp/avatar.png', hints: { 'image-path': '/tmp/avatar.png' } }, 200);
  assert.equal(entry.image, '/tmp/avatar.png');
  assert.equal(logic.persistablePopup(entry, '/tmp/history-images/').copies[0].from, '/tmp/avatar.png');
});
