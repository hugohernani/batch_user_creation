class Batch::UsersController < ApplicationController
  def index
    render inline: limit_message if FileHandler.count > 30 # rubocop:disable Rails/RenderInline
  end

  def create
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
end
