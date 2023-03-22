class FileHandler < ApplicationRecord
  has_one_attached :csv

  def csv_path
    ActiveStorage::Blob.service.path_for(csv.key) if csv
  end
end
