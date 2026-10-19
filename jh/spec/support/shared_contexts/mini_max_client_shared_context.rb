# frozen_string_literal: true

RSpec.shared_context 'with MiniMax client shared context' do
  let_it_be(:group_id) { SecureRandom.alphanumeric 32 }
  let_it_be(:api_key) { SecureRandom.alphanumeric 16 }
  let_it_be(:prompt) do
    {
      "bot_setting" => [
        {
          "bot_name" => "JIHU_BOT",
          "content" => "You are a knowledgeable assistant explaining to an engineer"
        }
      ],
      "messages" => [
        {
          "sender_type" => "USER",
          "sender_name" => "user",
          "text" => "帮我翻译下面这句话：我是谁"
        }
      ],
      "reply_constraints" => {
        "sender_type" => "BOT",
        "sender_name" => "JIHU_BOT"
      },
      "model" => "abab5.5-chat",
      "tokens_to_generate" => 1034,
      "temperature" => 0.01,
      "top_p" => 0.95
    }
  end

  let_it_be(:chat_response_body) do
    {
      "created" => 1690946370,
      "model" => "abab5.5-chat",
      "reply" => "这句话的英文翻译是：Who am I?",
      "choices" => [
        {
          "finish_reason" => "stop",
          "messages" => [
            {
              "sender_type" => "BOT",
              "sender_name" => "JIHU_BOT",
              "text" => "这句话的英文翻译是：Who am I?"
            }
          ]
        }
      ],
      "usage" => {
        "total_tokens" => 173
      },
      "input_sensitive" => false,
      "output_sensitive" => false,
      "id" => "0118fe42998edcb83fd442a3208ef334",
      "base_resp" => {
        "status_code" => 0,
        "status_msg" => ""
      }
    }
  end

  let_it_be(:failed_chat_response_body) do
    {
      "created" => 0,
      "model" => "",
      "reply" => "",
      "choices" => nil,
      "base_resp" => {
        "status_code" => 2013,
        "status_msg" => "invalid params, binding: expr_path=bot_setting, cause=missing required parameter"
      }
    }
  end

  def chat_url
    "https://api.minimax.chat/v1/text/chatcompletion_pro?GroupId=#{group_id}"
  end

  # with typical response
  def stub_chat_request
    stub_request(:post, chat_url).to_return stub_response(chat_response_body)
  end

  def stub_failed_chat_request
    stub_request(:post, chat_url).to_return stub_response(failed_chat_response_body)
  end

  def stub_response(body)
    { status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' } }
  end
end
