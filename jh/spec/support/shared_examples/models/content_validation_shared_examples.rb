# frozen_string_literal: true

RSpec.shared_examples 'content validation with project' do |member_type, validate_attr|
  describe 'validations' do
    describe validate_attr.to_s do
      let(:entity) { build(member_type) }

      context 'when project is public' do
        before do
          entity.project.visibility_level = Gitlab::VisibilityLevel::PUBLIC
        end

        context "with #{attr} untrust" do
          before do
            stub_content_validation_request(false)
          end

          it { expect(entity).not_to allow_value('你好 sensitive').for(validate_attr) }
        end

        context "with #{attr} trust" do
          before do
            stub_content_validation_request(true)
          end

          it { expect(entity).to allow_value('你好 Gitlab！').for(validate_attr) }
        end

        context "with #{attr} untrust but content validation disabed" do
          before do
            disable_content_validation
          end

          it { expect(entity).to allow_value('你好 sensitive').for(validate_attr) }
        end
      end

      context 'when project is private' do
        context "with #{attr} untrust" do
          before do
            entity.project.visibility_level = Gitlab::VisibilityLevel::PRIVATE
            stub_content_validation_request(false)
          end

          it { expect(entity).to allow_value('你好 sensitive').for(validate_attr) }
        end
      end
    end
  end
end

RSpec.shared_examples 'content validation' do |member_type, validate_attr|
  describe 'validations' do
    describe validate_attr.to_s do
      let!(:entity) { create(member_type) }

      context "with #{attr} untrust" do
        before do
          stub_content_validation_request(false)
        end

        it { expect(entity).not_to allow_value('你好 sensitive').for(validate_attr) }
      end

      context "with #{attr} trust" do
        before do
          stub_content_validation_request(true)
        end

        it { expect(entity).to allow_value('你好 Gitlab！').for(validate_attr) }
      end

      context "with #{attr} untrust but content validation disabed" do
        before do
          disable_content_validation
        end

        it { expect(entity).to allow_value('你好 sensitive').for(validate_attr) }
      end
    end
  end
end
