// Platform views insert HTML without executing inline script elements.
for (const eventName of ['error', 'load']) {
  document.addEventListener(eventName, (event) => {
    const viewer = event.target;
    if (!(viewer instanceof Element) || viewer.tagName !== 'MODEL-VIEWER') return;
    const message = viewer.querySelector('#model-error');
    if (message) message.hidden = eventName !== 'error';
  }, true);
}
