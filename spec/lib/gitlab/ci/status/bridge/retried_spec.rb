# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Status::Bridge::Retried do
  let(:bridge) { create(:ci_bridge, :retried) }
  let(:status) { instance_double(Gitlab::Ci::Status::Core) }
  let(:user) { instance_double(User) }

  subject { described_class.new(status) }

  describe '#icon' do
    it 'does not override status icon' do
      expect(status).to receive(:icon)

      subject.icon
    end
  end

  describe '#group' do
    it 'does not override status group' do
      expect(status).to receive(:group)

      subject.group
    end
  end

  describe '#favicon' do
    it 'does not override status label' do
      expect(status).to receive(:favicon)

      subject.favicon
    end
  end

  describe '#label' do
    it 'does not override status label' do
      expect(status).to receive(:label)

      subject.label
    end
  end

  describe '#status_tooltip' do
    let(:user) { create(:user) }

    context 'with a failed bridge' do
      let(:bridge) { create(:ci_bridge, :failed, :retried) }
      let(:failed_status) { Gitlab::Ci::Status::Failed.new(bridge, user) }
      let(:status) { Gitlab::Ci::Status::Bridge::Failed.new(failed_status) }

      it 'overrides status_tooltip' do
        expect(subject.status_tooltip).to eq 'failed - (unknown failure) (retried)'
      end
    end

    context 'with another bridge' do
      let(:bridge) { create(:ci_bridge, :retried) }
      let(:status) { Gitlab::Ci::Status::Success.new(bridge, user) }

      it 'overrides status_tooltip' do
        expect(subject.status_tooltip).to eq 'passed (retried)'
      end
    end
  end

  describe '.matches?' do
    subject { described_class.matches?(bridge, user) }

    context 'with a retried bridge' do
      it { is_expected.to be_truthy }
    end

    context 'with a bridge that has not been retried' do
      let(:bridge) { create(:ci_bridge, :success) }

      it { is_expected.to be_falsy }
    end
  end
end
