require 'rails_helper'

describe FileHandler do
  describe '.reached_byte_size_limit?' do
    subject(:reached_limit?) { described_class.reached_byte_size_limit? }

    before { stub_const('FileHandler::BYTE_SIZE_LIMIT', 100.bytes) }

    context 'when there are blob attachments exceeding the limit' do
      before do
        create(:file_handler).csv.attach(io: Tempfile.new('1'), filename: '1.csv')
        create(:file_handler).csv.attach(io: Tempfile.new('2'), filename: '2.csv')

        # 102 bytes > 100 bytes
        ActiveStorage::Blob.update_all(byte_size: 51.bytes) # rubocop:disable Rails/SkipsModelValidations
      end

      it { is_expected.to be true }
    end

    context 'when existing blobs does not exceed limit' do
      before do
        create(:file_handler).csv.attach(io: Tempfile.new('1'), filename: '1.csv')
        create(:file_handler).csv.attach(io: Tempfile.new('2'), filename: '2.csv')

        # 98 bytes < 100 bytes
        ActiveStorage::Blob.update_all(byte_size: 49.bytes) # rubocop:disable Rails/SkipsModelValidations
      end

      it { is_expected.to be false }
    end
  end
end
