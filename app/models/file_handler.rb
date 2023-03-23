class FileHandler < ApplicationRecord
  BYTE_SIZE_LIMIT = 1.gigabyte # just an example

  has_one_attached :csv

  def self.reached_byte_size_limit?
    blobs_byte_size = ActiveStorage::Blob.joins(:attachments)
                                         .where(active_storage_attachments: { record_type: name })
                                         .sum(:byte_size)
    blobs_byte_size > BYTE_SIZE_LIMIT
  end
end
