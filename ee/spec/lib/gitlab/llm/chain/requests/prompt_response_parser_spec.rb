# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Llm::Chain::Requests::PromptResponseParser, feature_category: :chat_engine do
  subject(:parser) { described_class.new }

  let(:yielded) { [] }

  def push(parser, *fragments)
    fragments.each do |fragment|
      parser.push(fragment) { |content| yielded << content }
    end
  end

  def finish(parser)
    parser.finish { |content| yielded << content }
  end

  it 'yields a frame split across two fragments once, when the frame completes' do
    push(parser, '{"content":"Hi ')

    expect(yielded).to be_empty

    push(parser, %("}\n))

    expect(yielded).to eq(['Hi '])
    expect(parser.content).to eq('Hi ')
  end

  it 'completes a frame whose delimiter arrives in a fragment of its own' do
    push(parser, '{"content":"Hi "}', "\n")

    expect(yielded).to eq(['Hi '])
  end

  it 'yields both frames of a fragment that carries two, in order' do
    push(parser, %({"content":"Hi "}\n{"content":"John!"}\n))

    expect(yielded).to eq(['Hi ', 'John!'])
    expect(parser.content).to eq('Hi John!')
  end

  it 'ignores a frame that carries no content' do
    push(parser, %({"content":"Hi "}\n{"usage":{"model":{"input_tokens":10,"output_tokens":20}}}\n))

    expect(yielded).to eq(['Hi '])
    expect(parser.content).to eq('Hi ')
  end

  it 'flushes a final frame that arrived without its delimiter' do
    push(parser, %({"content":"Hi "}\n{"content":"John!"}))

    expect(yielded).to eq(['Hi '])

    finish(parser)

    expect(yielded).to eq(['Hi ', 'John!'])
    expect(parser.content).to eq('Hi John!')
  end

  it 'has nothing to flush when the stream ended on a delimiter' do
    push(parser, %({"content":"Hi "}\n))
    finish(parser)

    expect(yielded).to eq(['Hi '])
  end

  it 'ignores a nil fragment' do
    push(parser, nil, %({"content":"Hi "}\n))

    expect(yielded).to eq(['Hi '])
  end

  it 'ignores an empty fragment' do
    push(parser, '', %({"content":"Hi "}\n))

    expect(yielded).to eq(['Hi '])
  end

  it 'skips a blank line between frames without logging it' do
    expect(Gitlab::Llm::Logger).not_to receive(:build)

    push(parser, %({"content":"Hi "}\n\n{"content":"John!"}\n))

    expect(yielded).to eq(['Hi ', 'John!'])
  end

  it 'collects content when given no block to yield to' do
    parser.push(%({"content":"Hi "}\n{"content":"John!"}))
    parser.finish

    expect(parser.content).to eq('Hi John!')
  end

  context 'when a frame cannot be read as a PromptResponse' do
    let(:logger) { instance_double(Gitlab::Llm::Logger) }

    before do
      allow(Gitlab::Llm::Logger).to receive(:build).and_return(logger)
    end

    it 'logs a warning, skips the frame, and keeps parsing the rest' do
      expect(logger).to receive(:warn).with(
        a_hash_including(
          message: "Failed to parse a frame from the AI Gateway prompts endpoint",
          event_name: 'parsing_error',
          ai_component: 'duo_chat'
        ))

      push(parser, %({"content":"Hi "}\nnot json at all\n{"content":"John!"}\n))

      expect(yielded).to eq(['Hi ', 'John!'])
      expect(parser.content).to eq('Hi John!')
    end

    it 'logs the length of a skipped frame, never its text' do
      expect(logger).to receive(:warn).with(
        message: "Failed to parse a frame from the AI Gateway prompts endpoint",
        klass: described_class.to_s,
        event_json_size: 'not json at all'.length,
        event_name: 'parsing_error',
        ai_component: 'duo_chat'
      )

      push(parser, %(not json at all\n))
    end

    it 'leaves the content empty when no frame carries any' do
      allow(logger).to receive(:warn)

      push(parser, %(not json at all\n{"usage":{"model":{"input_tokens":10,"output_tokens":20}}}))
      finish(parser)

      expect(yielded).to be_empty
      expect(parser.content).to eq('')
    end

    it 'logs and skips a frame that parses to something other than an object' do
      expect(logger).to receive(:warn).with(a_hash_including(event_name: 'parsing_error'))

      push(parser, %("just a string"\n{"content":"John!"}\n))

      expect(yielded).to eq(['John!'])
    end
  end
end
