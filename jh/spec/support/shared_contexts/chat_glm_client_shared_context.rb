# frozen_string_literal: true

RSpec.shared_context 'with ChatGLM client shared context' do
  include RandomNumberString

  let_it_be(:api_id) { SecureRandom.alphanumeric 32 }
  let_it_be(:api_secret) { SecureRandom.alphanumeric 16 }
  let_it_be(:api_key) { "#{api_id}.#{api_secret}" }
  let_it_be(:prompt) { 'You are a software developer. You can explain code snippets.' }
  let_it_be(:prompt_v3) do
    [role: 'user', content: 'You are a software developer. You can explain code snippets.']
  end

  let_it_be(:chat_response_body) do
    task_no = random_number_string(19)
    {
      'code' => 200,
      'msg' => '操作成功',
      'data' => {
        'prompt' => prompt,
        'outputText' => 'Response from ChatGLM',
        'totalTokenNum' => 3,
        'taskOrderNo' => task_no,
        'taskStatus' => 'SUCCESS',
        'requestTaskNo' => task_no
      },
      'success' => true
    }
  end

  let_it_be(:chat_v3_response_body) do
    task_no = random_number_string(19)
    {
      'code' => 200,
      'msg' => '操作成功',
      'data' => {
        'choices' => [{
          'role' => 'assistant',
          'content' => "\"我是 ChatGLM，一个基于人工智能的语言模型。\\n很高兴能和你聊天。你想聊些什么呢？\""
        }],
        "usage" => { "total_tokens" => 121 },
        'task_id' => task_no,
        'task_status' => 'SUCCESS',
        'request_id' => task_no
      },
      'success' => true
    }
  end

  let_it_be(:failed_chat_response_body) do
    {
      'code' => 1001,
      'msg' => 'Header中未收到Authorization参数，无法进行身份验证。',
      'success' => false
    }
  end

  def chat_url
    'https://maas.aminer.cn/api/paas/model/v1/open/engines/chatGLM/chatGLM'
  end

  def chat_v3_url
    'https://open.bigmodel.cn/api/paas/v3/model-api/chatglm_pro/invoke'
  end

  # with typical response
  def stub_chat_request
    stub_request(:post, chat_url).to_return stub_response(chat_response_body)
  end

  def stub_chat_v3_request
    stub_request(:post, chat_v3_url).to_return stub_response(chat_v3_response_body)
  end

  def stub_failed_chat_request
    stub_request(:post, chat_url).to_return stub_response(failed_chat_response_body)
  end

  def stub_failed_chat_v3_request
    stub_request(:post, chat_v3_url).to_return stub_response(failed_chat_response_body)
  end

  def stub_response(body)
    { status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' } }
  end
end
