# frozen_string_literal: true

module Gitlab
  module Ci
    module JobTelemetry
      # Single source of truth for trace_id and span_id derivation in CI job telemetry.
      #
      # OTel spec: trace_id is 16 bytes (32 hex chars), span_id is 8 bytes (16 hex chars).
      # https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
      module SpanIds
        TRACE_ID_HEX_LENGTH = 32
        SPAN_ID_HEX_LENGTH = 16

        class << self
          # Trace ID derived from the root pipeline's database ID. All spans across
          # the pipeline hierarchy (parent + child pipelines) share this trace_id.
          def trace_id_for(root_pipeline_id)
            format("%0#{TRACE_ID_HEX_LENGTH}x", root_pipeline_id)
          end

          # Span ID for a job's lifecycle/pending/running spans.
          # `kind` is one of SpanEmitter::SPAN_KIND_*.
          def for_job(root_pipeline_id, job_id, kind)
            input = "#{root_pipeline_id}:#{job_id}:#{kind}"
            ::OpenSSL::Digest::SHA256.hexdigest(input)[0, SPAN_ID_HEX_LENGTH]
          end

          # Span ID used as the parent for top-level pipeline job_lifecycle spans.
          # Never emitted as a real span; trace visualizers will show this as a
          # "missing parent", which is the expected behavior.
          def for_pipeline_phantom(root_pipeline_id)
            ::OpenSSL::Digest::SHA256.hexdigest("pipeline:#{root_pipeline_id}")[0, SPAN_ID_HEX_LENGTH]
          end

          # Span ID derived from a trigger (bridge) job's database ID. Used to nest
          # child pipeline jobs under the bridge in the trace view. Future Bridge
          # instrumentation must use this exact formula for its own job_lifecycle
          # span so that child pipelines correlate correctly.
          def for_bridge(bridge_id)
            format("%0#{SPAN_ID_HEX_LENGTH}x", bridge_id)
          end
        end
      end
    end
  end
end
