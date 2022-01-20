# frozen_string_literal: true

RSpec.describe QA::Tools::TestResourceDataProcessor do
  let(:info) { 'information' }
  let(:api_path) { '/foo' }
  let(:result) { [{ info: info, api_path: api_path }] }

  describe '.collect' do
    context 'when resource is not restricted' do
      let(:resource) { instance_double(QA::Resource::Project, api_delete_path: '/foo', api_response: 'foo') }

      it 'collects resource' do
        expect(described_class.collect(resource, info)).to eq(result)
      end
    end

    context 'when resource is mocked' do
      let(:resource) { double(RSpec::Mocks::Double, api_delete_path: '/foo', api_response: 'foo') }

      it 'does not collect resource' do
        expect(described_class.collect(resource, info)).to eq(nil)
      end
    end
  end
end
