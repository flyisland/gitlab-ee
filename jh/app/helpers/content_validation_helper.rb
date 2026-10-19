# frozen_string_literal: true

module ContentValidationHelper
  def content_blocked_plain_message(content_blocked_state = nil)
    message = s_("JH|ContentValidation|According to the relevant laws and regulations, this content is not displayed.")

    if content_blocked_state.present?
      link_start = format("<span class='js-appeal-modal gl-text-blue-500 gl-cursor-pointer gl-ml-2' " \
        "data-project-full-path='%{project_full_path}' data-id='%{id}' " \
        "data-commit-sha='%{commit_sha}' data-path='%{path}'>", \
        project_full_path: content_blocked_state.project_full_path,
        id: content_blocked_state.id,
        commit_sha: content_blocked_state.commit_sha,
        path: content_blocked_state.path)
      link_end = "</span>"
      message += format(s_("JH|ContentValidation|To appeal, please click %{link_start}here%{link_end}."), \
        link_start: link_start,
        link_end: link_end)
    end

    message.html_safe # rubocop:disable Rails/OutputSafety
  end
end
