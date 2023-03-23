class Batch::UsersController < ApplicationController
  def index
    render inline: limit_message if reached_limit? # rubocop:disable Rails/RenderInline
  end

  def create
    redirect_to :index if reached_limit?
    @handler = FileHandler.new(file_handler_params)

    if @handler.save
      UserBatchUploadJob.perform_later(@handler)
      head :ok
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def file_handler_params
    params.require(:file_handler).permit(:csv)
  end

  def limit_message
    <<~STR
      You have reached a limit of uploaded files.<br />
      Contact developer for renewal.<br />
      hhernanni@gmail.com
    STR
  end

  # temporary solution for limiting upload feature
  # so that we have a plan for bucket cost saving
  def reached_limit?
    FileHandler.reached_byte_size_limit?
  end
  helper_method :reached_limit?
end
