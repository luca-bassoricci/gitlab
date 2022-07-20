# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Status::Bridge::Retryable do
  let(:user) { instance_double(User) }
  let(:status) { instance_double(Gitlab::Ci::Status::Core) }

  subject do
    described_class.new(status)
  end

  describe '#icon' do
    it 'does not override status icon' do
      expect(status).to receive(:icon)

      subject.icon
    end
  end

  describe '#label' do
    it 'does not override status label' do
      expect(status).to receive(:label)

      subject.label
    end
  end

  describe '#group' do
    it 'does not override status group' do
      expect(status).to receive(:group)

      subject.group
    end
  end

  describe '#status_tooltip' do
    it 'does not override status_tooltip' do
      expect(status).to receive(:status_tooltip)

      subject.status_tooltip
    end
  end

  describe 'action details' do
    let(:user) { create(:user) }
    let(:bridge) { create(:ci_bridge) }
    let(:status) { Gitlab::Ci::Status::Core.new(bridge, user) }

    describe '#has_action?' do
      context 'when user is allowed to update bridge' do
        before do
          stub_not_protect_default_branch

          bridge.project.add_developer(user)
        end

        it { is_expected.to have_action }
      end

      context 'when user is not allowed to update bridge' do
        it { is_expected.not_to have_action }
      end
    end

    describe '#action_path' do
      it { expect(subject.action_path).to include "#{bridge.id}/retry" }
    end

    describe '#action_icon' do
      it { expect(subject.action_icon).to eq 'retry' }
    end

    describe '#action_title' do
      it { expect(subject.action_title).to eq 'Retry' }
    end

    describe '#action_button_title' do
      it { expect(subject.action_button_title).to eq 'Retry this job' }
    end
  end

  describe '.matches?' do
    subject { described_class.matches?(bridge, user) }

    context 'when the bridge is retryable' do
      let(:bridge) { create(:ci_bridge, :success) }

      it 'is a correct match' do
        expect(subject).to be true
      end
    end

    context 'when the bridge is not retryable' do
      let(:bridge) { create(:ci_bridge, :failed, failure_reason: :pipeline_loop_detected) }

      it 'does not match' do
        expect(subject).to be false
      end
    end
  end
end
