# DingTalk card templates

The live template is held by DingTalk's card platform, not by this repository:
`createAndDeliver` names it by `cardTemplateId`, and the platform renders it.
Nothing here is read at runtime.

It is checked in anyway because a new DingTalk app needs the same template
rebuilt by hand, and "whatever is in the console" is not something a second
person can reproduce. Treat this file as the source of truth for what the
template should contain, and re-export after changing it in the console.

| File | Card | Used for |
|---|---|---|
| `duo_ai_streaming.json` | AI card | One turn: processing state, streaming progress, final answer, approval buttons |

`duo_ai_streaming.json` is the raw platform export of the AI card template.
It contains the serialized `editorData` and compiled markup in `widgetInfo`.

The template id in use is `7780797d-ee6c-4856-bba4-0b8cf5cd5e3e.schema`. It is
`DEFAULT_CARD_TEMPLATE_ID` in `jh/app/services/ai/messaging/adapters/dingtalk.rb`.
`JH_DINGTALK_DUO_CARD_TEMPLATE_ID` overrides it.

## Variables the code writes

`content` is the only streaming variable, rendered as Markdown. During a turn
it carries only the agent's latest words (never raw tool calls); at the end it
carries the final answer plus the session link. An approval request is also
written into it. The card's processing, finished, and failed states are driven
by the streaming endpoint (`isFinalize`, `isError`), not by writing a variable.

`approval_token` is an ordinary string variable, empty by default. When it is
not empty, the finished state (status 3) shows two buttons in the action area:
同意 (approve) and 拒绝 (reject). The labels are fixed Chinese text in the
template.

Each button is a "request" (回传请求) action that sends two params:

- `approval_token`, bound to the variable.
- `decision`, a fixed value: `approve` or `reject`.

Code tells the buttons apart by `decision`, not by the platform-generated
action ids.

`session_link` is an ordinary Markdown variable shown below the buttons, only
while both it and `approval_token` are set. With buttons, the request in
`content` leaves out the session link and the adapter writes it here instead,
so the link sits under the buttons. Clearing `approval_token` hides it again,
and the settled `content` carries the link as usual.

`approval_token` is signed by GitLab (Rails message verifier) over the workflow
id, the pending call's fingerprint, and the card's `outTrackId`. DingTalk signs
only the callback's timestamp, not its body, so this token is what binds a
click to its session, call, and card.

## Approval flow

The buttons only appear in the finished state. So the adapter finalizes the card
with the approval request text, then sets `approval_token` with
`PUT /v1.0/card/instances`.

After a decision (button or text reply), or when the request goes stale, the
adapter clears `approval_token`, which hides the buttons. It then finalizes the
card again with the settled text. DingTalk accepts streaming into an
already-finalized card.

### Callback registration

Cards are created with `callbackType: 'HTTP'` and
`callbackRouteKey: 'gitlab-duo-approval'` only when the instance's DingTalk
integration (Admin > Settings > Integrations > DingTalk) has a "Card callback
secret". Otherwise they use `callbackType: 'STREAM'` and show no buttons;
approval then works by text reply only.

Register the callback with DingTalk:

```shell
bundle exec rake "gitlab:dingtalk:register_card_callback[<url>]"
```

The URL is optional. It defaults to
`<GitLab external URL>/api/v4/integrations/dingtalk/card_callback`. DingTalk
does not issue the secret; it accepts whatever secret it is registered with.
When the integration has none, the task generates one and saves it to the
integration only after DingTalk accepts it. The task sends
`POST /v1.0/card/callbacks/register` with `forceUpdate: true`, so rerun it
after changing the secret or URL. Registration is per app and route key, not
per template, so changing the template does not need re-registration.

### Callback handling

GitLab verifies `x-ddpaas-signature`, which is
`Base64(HMAC-SHA256(secret, x-ddpaas-signature-timestamp))`. The timestamp is
13-digit milliseconds and must be within five minutes.

GitLab then checks the token, that the clicker's `userId` (staff id) is the
session's sender, their account binding, the license, and the feature flag. It
enqueues `Ai::Messaging::ApprovalDecisionWorker` and answers right away.

The response body also clears `approval_token`, but DingTalk ignores responses
after two seconds. Testing through a tunnel added 1-4 seconds. So the worker
clears the variable too, and nothing relies on the response.

The DingTalk behavior this relies on was checked with a probe in a real
DingTalk client on 2026-10-12: the buttons appear, a click reaches GitLab with
the expected body, clearing the variable through the API hides the buttons,
and re-finalizing works.

## Card preview text

`createAndDeliver` also sets `lastMessageI18n` on `imRobotOpenSpaceModel`
(single chat) and `imGroupOpenSpaceModel` (group chat): the text DingTalk
shows for the card in the conversation list, with a `ZH_CN` and an `EN_US`
entry ("Message from Duo" in each language). DingTalk shows whichever entry
matches the reader's client language. It is set once at delivery and never
rewritten, so it is worded to fit every state of the card. This is set in
code, not in the template.

## Setting up duo_ai_streaming

Create an AI card template on the card platform with:

- `content`, a streaming variable rendered as Markdown.
- `approval_token`, a string variable.
- `session_link`, a Markdown variable shown below the buttons as described above.
- The 同意 and 拒绝 buttons described above.

Publish it, point the template id at it, and export its schema here as
`duo_ai_streaming.json` (see Exporting).

## Exporting

Card platform -> the template -> copy its schema JSON, and save it here under
the file name above. The template id belongs in configuration, not in the file.
