class UserBatchUploadJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    UserBatchService.call(file_path)
  end
end
