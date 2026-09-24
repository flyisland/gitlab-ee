# frozen_string_literal: true

module JH
  module EmailsHelper
    extend ::Gitlab::Utils::Override

    override :header_logo
    def header_logo
      if current_appearance&.header_logo? && !current_appearance.header_logo.filename.ends_with?('.svg')
        image_tag(
          current_appearance.header_logo_path,
          style: 'height: 50px'
        )
      else
        image_tag(
          image_url('mailers/gitlab_logo.png'),
          size: '55x97',
          alt: 'Jihu GitLab'
        )
      end
    end
  end
end
