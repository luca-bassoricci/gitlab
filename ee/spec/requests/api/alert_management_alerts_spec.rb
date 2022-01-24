# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::AlertManagementAlerts, :mailer do
  let_it_be(:creator) { create(:user) }
  let_it_be(:project) do
    create(:project, :public, creator_id: creator.id, namespace: creator.namespace)
  end

  let_it_be(:user) { create(:user) }
  let_it_be(:alert) { create(:alert_management_alert, project: project) }

  describe 'POST /projects/:id/alert_management_alerts/:alert_iid/metric_images' do
    include WorkhorseHelpers
    using RSpec::Parameterized::TableSyntax

    include_context 'workhorse headers'

    let(:file) { fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg') }
    let(:file_name) { 'rails_sample.jpg' }
    let(:url) { 'http://gitlab.com' }
    let(:url_text) { 'GitLab' }

    let(:params) { { url: url, url_text: url_text } }

    subject do
      workhorse_finalize(
        api("/projects/#{project.id}/alert_management_alerts/#{alert.iid}/metric_images", user),
        method: :post,
        file_key: :file,
        params: params.merge(file: file),
        headers: workhorse_headers,
        send_rewritten_field: true
      )
    end

    shared_examples 'can_upload_metric_image' do
      it 'creates a new metric image' do
        subject

        expect(response).to have_gitlab_http_status(:created)
        expect(json_response['filename']).to eq(file_name)
        expect(json_response['url']).to eq(url)
        expect(json_response['url_text']).to eq(url_text)
        expect(json_response['file_path']).to match(%r{/uploads/-/system/alert_management_metric_image/file/[\d+]/#{file_name}})
        expect(json_response['created_at']).not_to be_nil
        expect(json_response['id']).not_to be_nil
      end
    end

    shared_examples 'unauthorized_upload' do
      it 'disallows the upload' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
        expect(json_response['message']).to eq('Not allowed!')
      end
    end

    where(:user_role, :expected_status) do
      # :guest     | :unauthorized_upload
      # :reporter  | :unauthorized_upload
      :developer | :can_upload_metric_image
    end

    with_them do
      before do
        # Local storage
        stub_uploads_object_storage(MetricImageUploader, enabled: false)
        allow_any_instance_of(MetricImageUploader).to receive(:file_storage?).and_return(true)

        stub_licensed_features(alert_metric_upload: true)
        project.send("add_#{user_role}", user)
      end

      it_behaves_like "#{params[:expected_status]}"
    end

    context 'file size too large' do
      before do
        stub_licensed_features(alert_metric_upload: true)
        allow_next_instance_of(UploadedFile) do |upload_file|
          allow(upload_file).to receive(:size).and_return(AlertManagement::MetricImage::MAX_FILE_SIZE + 1)
        end
      end

      it 'returns an error' do
        subject

        expect(response).to have_gitlab_http_status(:bad_request)
        expect(response.body).to match(/File is too large/)
      end
    end

    context 'object storage enabled' do
      before do
        # Object storage
        stub_licensed_features(incident_metric_upload: true)
        stub_uploads_object_storage(MetricImageUploader)

        allow_any_instance_of(MetricImageUploader).to receive(:file_storage?).and_return(false)
        project.add_developer(user)
      end

      it_behaves_like 'can_upload_metric_image'

      it 'uploads to remote storage' do
        subject

        last_upload = AlertManagement::MetricImage.last.uploads.last
        expect(last_upload.store).to eq(::ObjectStorage::Store::REMOTE)
      end
    end
  end

  describe 'GET /projects/:id/alert_management_alerts/:alert_iid/metric_images' do
    using RSpec::Parameterized::TableSyntax

    let!(:image) { create(:alert_metric_image, alert: alert) }

    subject { get api("/projects/#{project.id}/alert_management_alerts/#{alert.iid}/metric_images", user) }

    shared_examples 'can_read_metric_image' do
      it 'can read the metric images' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.first).to match(
          {
            id: image.id,
            created_at: image.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            filename: image.filename,
            file_path: image.file_path,
            url: image.url,
            url_text: nil
          }.with_indifferent_access
        )
      end
    end

    shared_examples 'unauthorized_read' do
      it 'cannot read the metric images' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    where(:user_role, :public_project, :expected_status) do
      :not_member | false | :unauthorized_read
      :not_member | true  | :unauthorized_read
      :guest      | false | :unauthorized_read
      :reporter   | false | :unauthorized_read
      :developer  | false | :can_read_metric_image
    end

    with_them do
      before do
        stub_licensed_features(alert_metric_upload: true)
        project.send("add_#{user_role}", user) unless user_role == :not_member
        project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE) unless public_project
      end

      it_behaves_like "#{params[:expected_status]}"
    end
  end

  # describe 'PUT /projects/:id/issues/:issue_iid/metric_images/:metric_image_id' do
  #   using RSpec::Parameterized::TableSyntax

  #   let_it_be(:project) do
  #     create(:project, :public, creator_id: user.id, namespace: user.namespace)
  #   end

  #   let!(:image) { create(:issuable_metric_image, issue: issue) }
  #   let(:params) { { url: 'http://test.example.com', url_text: 'Example website 123' } }

  #   subject { put api("/projects/#{project.id}/issues/#{issue.iid}/metric_images/#{image.id}", user2), params: params }

  #   shared_examples 'can_update_metric_image' do
  #     it 'can update the metric images' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:success)
  #       expect(json_response['url']).to eq(params[:url])
  #       expect(json_response['url_text']).to eq(params[:url_text])
  #     end
  #   end

  #   shared_examples 'unauthorized_update' do
  #     it 'cannot delete the metric image' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:forbidden)
  #       expect(image.reload).to eq(image)
  #     end
  #   end

  #   shared_examples 'not_found' do
  #     it 'cannot delete the metric image' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:not_found)
  #       expect(image.reload).to eq(image)
  #     end
  #   end

  #   where(:user_role, :own_issue, :issue_confidential, :expected_status) do
  #     :not_member | false | false | :unauthorized_update
  #     :not_member | true  | false | :unauthorized_update
  #     :not_member | true  | true  | :unauthorized_update
  #     :guest      | false | true  | :not_found
  #     :guest      | false | false | :unauthorized_update
  #     :guest      | true  | false | :can_update_metric_image
  #     :reporter   | true  | false | :can_update_metric_image
  #     :reporter   | false | false | :can_update_metric_image
  #   end

  #   with_them do
  #     before do
  #       stub_licensed_features(incident_metric_upload: true)
  #       project.send("add_#{user_role}", user2) unless user_role == :not_member
  #     end

  #     let!(:issue) do
  #       author = own_issue ? user2 : user
  #       confidential = issue_confidential

  #       create(:incident, project: project, confidential: confidential, author: author)
  #     end

  #     it_behaves_like "#{params[:expected_status]}"
  #   end

  #   context 'user has access' do
  #     let(:issue) { create(:incident, project: project) }

  #     before do
  #       project.add_reporter(user2)
  #     end

  #     context 'metric image not found' do
  #       subject { delete api("/projects/#{project.id}/issues/#{issue.iid}/metric_images/#{non_existing_record_id}", user2) }

  #       it 'returns an error' do
  #         subject

  #         expect(response).to have_gitlab_http_status(:not_found)
  #         expect(json_response['message']).to eq('Metric image not found')
  #       end
  #     end

  #     context 'metric image cannot be updated' do
  #       let(:params) { { url_text: 'something_long' * 100 } }

  #       it 'returns an error' do
  #         subject

  #         expect(response).to have_gitlab_http_status(:bad_request)
  #         expect(json_response['message']).to eq('Metric image could not be updated')
  #       end
  #     end
  #   end
  # end

  # describe 'DELETE /projects/:id/issues/:issue_iid/metric_images/:metric_image_id' do
  #   using RSpec::Parameterized::TableSyntax

  #   let_it_be(:project) do
  #     create(:project, :public, creator_id: user.id, namespace: user.namespace)
  #   end

  #   let!(:image) { create(:issuable_metric_image, issue: issue) }

  #   subject { delete api("/projects/#{project.id}/issues/#{issue.iid}/metric_images/#{image.id}", user2) }

  #   shared_examples 'can_delete_metric_image' do
  #     it 'can delete the metric images' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:no_content)
  #       expect { image.reload }.to raise_error(ActiveRecord::RecordNotFound)
  #     end
  #   end

  #   shared_examples 'unauthorized_delete' do
  #     it 'cannot delete the metric image' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:forbidden)
  #       expect(image.reload).to eq(image)
  #     end
  #   end

  #   shared_examples 'not_found' do
  #     it 'cannot delete the metric image' do
  #       subject

  #       expect(response).to have_gitlab_http_status(:not_found)
  #       expect(image.reload).to eq(image)
  #     end
  #   end

  #   where(:user_role, :own_issue, :issue_confidential, :expected_status) do
  #     :not_member | false | false | :unauthorized_delete
  #     :not_member | true  | false | :unauthorized_delete
  #     :not_member | true  | true  | :unauthorized_delete
  #     :guest      | false | true  | :not_found
  #     :guest      | false | false | :unauthorized_delete
  #     :guest      | true  | false | :can_delete_metric_image
  #     :reporter   | true  | false | :can_delete_metric_image
  #     :reporter   | false | false | :can_delete_metric_image
  #   end

  #   with_them do
  #     before do
  #       stub_licensed_features(incident_metric_upload: true)
  #       project.send("add_#{user_role}", user2) unless user_role == :not_member
  #     end

  #     let!(:issue) do
  #       author = own_issue ? user2 : user
  #       confidential = issue_confidential

  #       create(:incident, project: project, confidential: confidential, author: author)
  #     end

  #     it_behaves_like "#{params[:expected_status]}"
  #   end

  #   context 'user has access' do
  #     let(:issue) { create(:incident, project: project) }

  #     before do
  #       project.add_reporter(user2)
  #     end

  #     context 'metric image not found' do
  #       subject { delete api("/projects/#{project.id}/issues/#{issue.iid}/metric_images/#{non_existing_record_id}", user2) }

  #       it 'returns an error' do
  #         subject

  #         expect(response).to have_gitlab_http_status(:not_found)
  #         expect(json_response['message']).to eq('Metric image not found')
  #       end
  #     end
  #   end
  # end
end
