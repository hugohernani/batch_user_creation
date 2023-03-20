require 'rails_helper'

RSpec.describe UserBatchUploadJob do
  subject(:job) { described_class.perform_later(file_path) }

  let(:file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'valid.csv').to_s }

  it 'enqueues the job' do
    expect { job }.to have_enqueued_job(described_class).with(file_path)
  end

  describe 'service delegation' do
    let(:batch_service) { class_double(UserBatchService, call: nil) }

    before { stub_const('UserBatchService', batch_service) }

    it 'directs processing to service' do
      UserBatchUploadJob.new(file_path).perform_now

      expect(batch_service).to have_received(:call).with(file_path)
    end
  end
end
