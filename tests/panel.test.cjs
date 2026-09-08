const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');

// Run the widget's actual handlers against KeyboardPanel's owner-delegating
// close contract, without requiring a running desktop session.
const source = fs.readFileSync(path.join(__dirname, '..', 'BarWidget.qml'), 'utf8');
const handlers = ['open', 'close', 'toggle', 'togglePanel'].map(name => {
  const match = source.match(new RegExp(`^  function ${name}\\(\\) \\{[\\s\\S]*?^  \\}`, 'm'));
  assert.ok(match, `Missing ${name} handler`);
  return match[0];
}).join('\n');

function widget() {
  const context = vm.createContext({ panelLoader: { item: null } });
  vm.runInContext(handlers, context);
  const panel = { open: false, close() { context.close(); } };
  context.panelLoader.item = panel;
  Object.defineProperty(context, 'opened', { get: () => context.panelLoader.item?.open === true });
  return { context, panel };
}

test('repeated bell clicks open, close, and reopen the panel', () => {
  const { context, panel } = widget();
  for (const expected of [true, false, true, false]) {
    context.togglePanel();
    assert.equal(panel.open, expected);
  }
});

test('Escape/outside-click close delegates through the owner without recursion', () => {
  const { context, panel } = widget();
  context.open();
  panel.close();
  assert.equal(panel.open, false);
  context.open();
  assert.equal(panel.open, true);
});

test('shell/coordinator close is idempotent and safe before the panel loads', () => {
  const { context, panel } = widget();
  context.open();
  context.close();
  context.close();
  assert.equal(panel.open, false);
  context.panelLoader.item = null;
  assert.doesNotThrow(() => { context.close(); context.open(); context.togglePanel(); });
});
