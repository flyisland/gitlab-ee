import { i18n as duoUiI18n } from '@gitlab/duo-ui/dist/config';
import duoChatView from 'ee/ai/tanuki_bot/components/duo_chat_view.vue';
import duoAgenticChatView from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat_view.vue';

// duo chat 上这块 i18n 不生效，直接写中文
const CHAT_DISCLAIMER = '内容由AI生成，可能不准确，请注意核实';

duoUiI18n['GlDuoChat.chatDisclaimer'] = CHAT_DISCLAIMER;
duoUiI18n['WebDuoChat.chatDisclaimer'] = CHAT_DISCLAIMER;
duoUiI18n['WebAgenticDuoChat.chatDisclaimer'] = CHAT_DISCLAIMER;

duoChatView.i18n.CHAT_DISCLAIMER = CHAT_DISCLAIMER;
duoAgenticChatView.i18n.CHAT_DISCLAIMER = CHAT_DISCLAIMER;
