let socket = null;

function disconnect() {
  if (socket) {
    if (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING) {
      socket.close(1000);
    }
    socket = null;
  }
}

function send(message) {
  if (socket?.readyState === WebSocket.OPEN) {
    const payload = typeof message === 'string' ? message : JSON.stringify(message);
    socket.send(payload);
  }
}

function decodeBinaryPayload(payload) {
  if (payload instanceof ArrayBuffer || payload?.byteLength !== undefined) {
    return new TextDecoder().decode(payload);
  }
  if (typeof payload?.text === 'function') return payload.text();
  return String(payload);
}

function connect(url, initialMessage) {
  disconnect();

  try {
    const ws = new WebSocket(url);
    socket = ws;

    ws.onopen = () => {
      if (initialMessage) {
        send(initialMessage);
      }
      self.postMessage({ type: 'open' });
    };

    ws.onmessage = async (event) => {
      try {
        const data =
          typeof event.data === 'string' ? event.data : await decodeBinaryPayload(event.data);
        self.postMessage({ type: 'message', data });
      } catch {
        self.postMessage({ type: 'error' });
      }
    };

    ws.onclose = (event) => {
      if (socket === ws) {
        socket = null;
        self.postMessage({ type: 'close', code: event.code, reason: event.reason });
      }
    };

    ws.onerror = () => {
      if (socket === ws) {
        self.postMessage({ type: 'error' });
      }
    };
  } catch (e) {
    self.postMessage({ type: 'error' });
  }
}

self.addEventListener('message', ({ data }) => {
  switch (data.type) {
    case 'connect':
      connect(data.url, data.initialMessage);
      break;
    case 'send':
      send(data.message);
      break;
    case 'disconnect':
      disconnect();
      break;
    default:
      break;
  }
});
