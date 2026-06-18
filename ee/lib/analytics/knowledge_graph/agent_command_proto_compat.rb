# frozen_string_literal: true

require 'google/protobuf/descriptor_pb'

module Analytics
  module KnowledgeGraph
    module AgentCommandProtoCompat
      MESSAGE_CONSTANTS = {
        ListAgentCommandsRequest: 'gkg.v1.ListAgentCommandsRequest',
        ListAgentCommandsResponse: 'gkg.v1.ListAgentCommandsResponse',
        InvokeAgentCommandRequest: 'gkg.v1.InvokeAgentCommandRequest',
        InvokeAgentCommandResponse: 'gkg.v1.InvokeAgentCommandResponse'
      }.freeze

      class << self
        def install!
          add_descriptors unless descriptor_available?('gkg.v1.ListAgentCommandsRequest')
          define_message_constants
          define_service_rpcs unless service_rpc_available?
        end

        private

        def add_descriptors
          file_descriptor = ::Google::Protobuf::FileDescriptorProto.new(
            name: 'gitlab_rails_gkg_agent_commands.proto',
            package: 'gkg.v1',
            dependency: ['gkg.proto'],
            syntax: 'proto3'
          )

          file_descriptor.message_type << list_agent_commands_request_descriptor
          file_descriptor.message_type << list_agent_commands_response_descriptor
          file_descriptor.message_type << invoke_agent_command_request_descriptor
          file_descriptor.message_type << invoke_agent_command_response_descriptor

          ::Google::Protobuf::DescriptorPool.generated_pool.add_serialized_file(file_descriptor.to_proto)
        end

        def define_message_constants
          MESSAGE_CONSTANTS.each do |constant_name, descriptor_name|
            next if ::Gkg::V1.const_defined?(constant_name, false)

            ::Gkg::V1.const_set(
              constant_name,
              ::Google::Protobuf::DescriptorPool.generated_pool.lookup(descriptor_name).msgclass
            )
          end
        end

        def define_service_rpcs
          service = ::Gkg::V1::KnowledgeGraphService::Service

          service.rpc :ListAgentCommands,
            ::Gkg::V1::ListAgentCommandsRequest,
            ::Gkg::V1::ListAgentCommandsResponse
          service.rpc :InvokeAgentCommand,
            ::Gkg::V1::InvokeAgentCommandRequest,
            ::Gkg::V1::InvokeAgentCommandResponse

          ::Gkg::V1::KnowledgeGraphService.module_eval { remove_const(:Stub) }
          ::Gkg::V1::KnowledgeGraphService.const_set(:Stub, service.rpc_stub_class)
        end

        def descriptor_available?(name)
          !::Google::Protobuf::DescriptorPool.generated_pool.lookup(name).nil?
        end

        def service_rpc_available?
          stub = ::Gkg::V1::KnowledgeGraphService::Stub
          stub.method_defined?(:list_agent_commands) && stub.method_defined?(:invoke_agent_command)
        end

        def list_agent_commands_request_descriptor
          message('ListAgentCommandsRequest') do |descriptor|
            descriptor.field << field(
              name: 'command_names',
              number: 1,
              label: :LABEL_REPEATED,
              type: :TYPE_STRING
            )
            descriptor.field << field(
              name: 'format',
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_ENUM,
              type_name: '.gkg.v1.ResponseFormat'
            )
          end
        end

        def list_agent_commands_response_descriptor
          message('ListAgentCommandsResponse') do |descriptor|
            descriptor.field << field(
              name: 'commands',
              number: 1,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: '.gkg.v1.ToolDefinition'
            )
            descriptor.field << field(
              name: 'formatted_text',
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING
            )
          end
        end

        def invoke_agent_command_request_descriptor
          message('InvokeAgentCommandRequest') do |descriptor|
            descriptor.field << field(
              name: 'command_name',
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING
            )
            descriptor.field << field(
              name: 'parameters_json',
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING
            )
          end
        end

        def invoke_agent_command_response_descriptor
          message('InvokeAgentCommandResponse') do |descriptor|
            descriptor.oneof_decl << ::Google::Protobuf::OneofDescriptorProto.new(name: 'content')
            descriptor.field << field(
              name: 'result_json',
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              oneof_index: 0
            )
            descriptor.field << field(
              name: 'formatted_text',
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              oneof_index: 0
            )
          end
        end

        def message(name)
          descriptor = ::Google::Protobuf::DescriptorProto.new(name: name)
          yield descriptor
          descriptor
        end

        def field(name:, number:, label:, type:, type_name: nil, oneof_index: nil)
          descriptor = ::Google::Protobuf::FieldDescriptorProto.new(
            name: name,
            number: number,
            label: label,
            type: type
          )
          descriptor.type_name = type_name if type_name
          descriptor.oneof_index = oneof_index if oneof_index
          descriptor
        end
      end
    end
  end
end

::Analytics::KnowledgeGraph::AgentCommandProtoCompat.install!
