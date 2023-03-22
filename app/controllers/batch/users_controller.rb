class Batch::UsersController < ApplicationController
  def index; end

  def create
    @handler = FileHandler.new(file_handler_params)

    if @handler.save
      UserBatchUploadJob.perform_later(@handler.csv_path)
      head :ok
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def file_handler_params
    params.require(:file_handler).permit(:csv)
  end
end
