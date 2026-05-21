import createEventHub from '~/helpers/event_hub_factory';

export const eventHub = createEventHub();

export const SHOW_SESSION = 'SHOW_SESSION';
export const SHOW_NEW_CHAT = 'SHOW_NEW_CHAT';
export const QUEUE_CHAT_COMMAND = 'QUEUE_CHAT_COMMAND';
