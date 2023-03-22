class UserBatchUploadJob < ApplicationJob
  queue_as :default

  def perform(file_handler)
    UserBatchService.call(file_handler)
  end
end
