# frozen_string_literal: true

module SecretsManagement
  module ProjectSecretsManagers
    module PipelineHelper
      extend ActiveSupport::Concern

      def ci_auth_path
        path_parts = [
          full_project_namespace_path,
          'auth',
          ci_auth_mount
        ]

        path_parts << 'cel' if use_cel_pipeline_auth?
        path_parts << 'login'

        path_parts.compact.join('/')
      end

      def use_cel_pipeline_auth?
        Feature.enabled?(:project_secrets_cel_pipeline_auth, project)
      end

      def pipeline_auth_cel_program(project_id)
        {
          variables: [
            { name: "expected_pid", expression: %("#{project_id}") },
            { name: "pid", expression: %q(('project_id' in claims) ? string(claims['project_id']) : "") },
            { name: "uid", expression: %q(('user_id' in claims) ? string(claims['user_id']) : "") },
            { name: "aud", expression: %q(('aud' in claims) ? string(claims['aud']) : "") },
            { name: "expected_aud", expression: %("#{aud}") },
            { name: "sub", expression: %q(('sub' in claims) ? claims['sub'] : "") },
            { name: "scope",
              expression: %q(('secrets_manager_scope' in claims) ? string(claims['secrets_manager_scope']) : "") },
            { name: "correlation_id",
              expression: %q(('correlation_id' in claims) ? string(claims['correlation_id']) : "") },
            { name: "namespace_id",
              expression: %q(('namespace_id' in claims) ? string(claims['namespace_id']) : "") },
            { name: "ref_type",
              expression: %q(('ref_type' in claims) ? string(claims['ref_type']) : "") },
            { name: "ref",
              expression: %q(('ref' in claims) ? string(claims['ref']) : "") },
            { name: "environment",
              expression: %q(('environment' in claims) ? string(claims['environment']) : "") },
            { name: "env_hex",
              expression: %q(environment != "" ? "%x".format([environment]) : "") },
            { name: "ref_hex",
              expression: %q(ref != "" ? "%x".format([ref]) : "") },
            { name: "global_policy",
              expression: %q("pipelines/global") },
            { name: "env_policy",
              expression: %q(environment != "" ? "pipelines/env/" + env_hex : "") },
            { name: "branch_policy",
              expression: %q(ref_type == "branch" && ref != "" ? "pipelines/branch/" + ref_hex : "") },
            { name: "combined_policy",
              # rubocop:disable Layout/LineLength -- CEL expression readability
              expression: %q(ref_type == "branch" && ref != "" && environment != "" ? "pipelines/combined/env/" + env_hex + "/branch/" + ref_hex : "") },
            # rubocop:enable Layout/LineLength
            { name: "pipeline_id",
              expression: %q(('pipeline_id' in claims) ? string(claims['pipeline_id']) : "") },
            { name: "job_id",
              expression: %q(('job_id' in claims) ? string(claims['job_id']) : "") }
          ],
          expression: <<~'CEL'.strip
            sub == "" ? "missing subject" :
            !sub.startsWith("project_path:") ? "invalid subject for pipeline authentication" :
            scope == "" ? "missing secrets_manager_scope" :
            scope != "pipeline" ? "invalid secrets_manager_scope" :
            pid == "" ? "missing project_id" :
            pid != expected_pid ? "token project_id does not match project" :
            uid == "" ? "missing user_id" :
            aud == "" ? "missing audience" :
            aud != expected_aud ? "audience validation failed" :
            pb.Auth{
              display_name: "pipeline:" + pid,
              alias: logical.Alias { name: "pipeline:" + pid },
              policies: [global_policy] + (env_policy != "" ? [env_policy] : []) + (branch_policy != "" ? [branch_policy] : []) + (combined_policy != "" ? [combined_policy] : []),
              metadata: {
                "correlation_id": correlation_id,
                "user_id": uid,
                "project_id": pid,
                "namespace_id": namespace_id,
                "pipeline_id": pipeline_id,
                "job_id": job_id
              }
            }
          CEL
        }
      end

      def ci_secrets_mount_full_path
        [
          full_project_namespace_path,
          ci_secrets_mount_path
        ].compact.join('/')
      end

      def ci_policy_name(environment, branch)
        if environment != "*" && branch != "*"
          ci_policy_name_combined(environment, branch)
        elsif environment != "*"
          ci_policy_name_env(environment)
        elsif branch != "*"
          ci_policy_name_branch(branch)
        else
          ci_policy_name_global
        end
      end

      def ci_policy_name_global
        %w[pipelines global].compact.join('/')
      end

      def ci_policy_name_env(environment)
        ["pipelines", "env", hex(environment)].compact.join('/')
      end

      def ci_policy_name_branch(branch)
        ["pipelines", "branch", hex(branch)].compact.join('/')
      end

      def ci_policy_name_combined(environment, branch)
        ["pipelines", "combined", "env", hex(environment), "branch", hex(branch)].compact.join('/')
      end

      def ci_auth_literal_policies
        [
          ci_policy_name("*", "*"),
          ci_policy_template_literal_environment,
          ci_policy_template_literal_branch,
          ci_policy_template_literal_combined
        ]
      end

      def ci_policy_template_literal_environment
        "{{ if and (ne nil (index . \"environment\")) (ne \"\" .environment) }}" \
          "pipelines/env/{{ .environment | hex }}{{ end }}"
      end

      def ci_policy_template_literal_branch
        "{{ if and (eq \"branch\" .ref_type) (ne \"\" .ref) }}" \
          "pipelines/branch/{{ .ref | hex }}{{ end }}"
      end

      def ci_policy_template_literal_combined
        "{{ if and (eq \"branch\" .ref_type) (ne nil (index . \"environment\")) (ne \"\" .environment) }}" \
          "pipelines/combined/env/{{ .environment | hex}}/branch/{{ .ref | hex }}{{ end }}"
      end

      def ci_auth_glob_policies(environment, branch)
        ret = []

        ret.append(ci_policy_template_glob_environment(environment)) if environment.include?("*")
        ret.append(ci_policy_template_glob_branch(branch)) if branch.include?("*")

        if environment.include?("*") && branch.include?("*")
          ret.append(ci_policy_template_combined_glob_environment_glob_branch(environment, branch))
        elsif environment.include?("*") && branch.exclude?("*")
          ret.append(ci_policy_template_combined_glob_environment_branch(environment, branch))
        elsif environment.exclude?("*") && branch.include?("*")
          ret.append(ci_policy_template_combined_environment_glob_branch(environment, branch))
        end

        ret
      end

      def ci_policy_template_glob_environment(env_glob)
        # rubocop:disable Layout/LineLength -- expression readability
        env_glob_hex = hex(env_glob)
        "{{ if and (ne nil (index . \"environment\")) (ne \"\" .environment) (eq \"#{env_glob_hex}\" (.environment | hex)) }}" \
          "#{ci_policy_name_env(env_glob)}{{ end }}"
        # rubocop:enable Layout/LineLength
      end

      def ci_policy_template_glob_branch(branch_glob)
        branch_glob_hex = hex(branch_glob)
        "{{ if and (eq \"branch\" .ref_type) (ne \"\" .ref) (eq \"#{branch_glob_hex}\" (.ref | hex)) }}" \
          "#{ci_policy_name_branch(branch_glob)}{{ end }}"
      end

      def ci_policy_template_combined_glob_environment_branch(env_glob, branch_literal)
        # rubocop:disable Layout/LineLength -- expression readability
        env_glob_hex = hex(env_glob)
        "{{ if and (eq \"branch\" .ref_type) (ne \"\" .ref) (ne nil (index . \"environment\")) (ne \"\" .environment) " \
          "(eq \"#{env_glob_hex}\" (.environment | hex)) }}" \
          "#{ci_policy_name_combined(env_glob, branch_literal)}{{ end }}"
        # rubocop:enable Layout/LineLength
      end

      def ci_policy_template_combined_environment_glob_branch(env_literal, branch_glob)
        # rubocop:disable Layout/LineLength -- expression readability
        branch_glob_hex = hex(branch_glob)
        "{{ if and (eq \"branch\" .ref_type) (ne \"\" .ref) (ne nil (index . \"environment\")) (ne \"\" .environment) " \
          "(eq \"#{branch_glob_hex}\" (.ref | hex)) }}" \
          "#{ci_policy_name_combined(env_literal, branch_glob)}{{ end }}"
        # rubocop:enable Layout/LineLength
      end

      def ci_policy_template_combined_glob_environment_glob_branch(env_glob, branch_glob)
        # rubocop:disable Layout/LineLength -- expression readability
        env_glob_hex = hex(env_glob)
        branch_glob_hex = hex(branch_glob)
        "{{ if and (eq \"branch\" .ref_type) (ne \"\" .ref) (ne nil (index . \"environment\")) (ne \"\" .environment) " \
          "(eq \"#{env_glob_hex}\" (.environment | hex)) (eq \"#{branch_glob_hex}\" (.ref | hex)) }}" \
          "#{ci_policy_name_combined(env_glob, branch_glob)}{{ end }}"
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
