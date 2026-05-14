import StreamWorker from './stream_worker?worker';

const MAX_BUFFER_SIZE = 1000;

let worker = null;
let connected = false;
const subscribers = new Map();
let messageBuffer = [];

function notify(eventType, payload) {
  const callbacks = subscribers.get(eventType);
  if (callbacks) {
    callbacks.forEach((cb) => cb(payload));
  }
}

function onWorkerMessage({ data }) {
  switch (data.type) {
    case 'open':
      connected = true;
      notify('open', data);
      break;
    case 'message': {
      if (messageBuffer.length < MAX_BUFFER_SIZE) {
        messageBuffer.push(data);
      }
      const callbacks = subscribers.get('message');
      if (callbacks?.size > 0) {
        callbacks.forEach((cb) => cb(data));
      }
      break;
    }
    case 'close':
      connected = false;
      notify('close', data);
      break;
    case 'error':
      notify('error', data);
      break;
    default:
      break;
  }
}

function ensureWorker() {
  if (!worker) {
    worker = new StreamWorker();
    worker.addEventListener('message', onWorkerMessage);
  }
  return worker;
}

export function toAbsoluteWebSocketUrl(relativeUrl) {
  if (relativeUrl.startsWith('ws://') || relativeUrl.startsWith('wss://')) {
    return relativeUrl;
  }
  if (typeof window === 'undefined') {
    return relativeUrl;
  }
  const url = new URL(relativeUrl, window.location.href);
  // eslint-disable-next-line @gitlab/require-i18n-strings
  url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
  return url.href;
}

export function connect(url, initialMessage) {
  const absoluteUrl = toAbsoluteWebSocketUrl(url);
  messageBuffer = [];
  ensureWorker();
  worker.postMessage({ type: 'connect', url: absoluteUrl, initialMessage });
}

export function send(message) {
  if (worker) {
    worker.postMessage({ type: 'send', message });
  }
}

export function disconnect() {
  if (worker) {
    worker.postMessage({ type: 'disconnect' });
    messageBuffer = [];
  }
}

export function subscribe(eventType, callback) {
  if (!subscribers.has(eventType)) {
    subscribers.set(eventType, new Set());
  }
  subscribers.get(eventType).add(callback);

  if (eventType === 'message' && messageBuffer.length > 0) {
    try {
      messageBuffer.forEach((msg) => callback(msg));
    } catch {
      // noop — subscriber error should not block other operations
    }
  }

  return {
    dispose() {
      const set = subscribers.get(eventType);
      if (set) {
        set.delete(callback);
        if (set.size === 0) {
          subscribers.delete(eventType);
        }
      }
    },
  };
}

export function getStatus() {
  return { connected, bufferedCount: messageBuffer.length };
}

export function terminate() {
  if (worker) {
    worker.postMessage({ type: 'disconnect' });
    worker.removeEventListener('message', onWorkerMessage);
    worker.terminate();
    worker = null;
  }
  connected = false;
  messageBuffer = [];
  subscribers.clear();
}
