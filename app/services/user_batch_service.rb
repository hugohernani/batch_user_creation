require 'csv'

class UserBatchService
  def self.call(file_handler)
    new(file_handler).call
  end

  def initialize(file_handler)
    @file_handler = file_handler
  end

  def call
    user_responses = []
    CSV.parse(@file_handler.csv.download, headers: true, skip_blanks: true).each_with_index do |row, index|
      user = User.new(name: row['name'], password: row['password'])
      user_responses << build_user_response(user, index + 1)
    end

    stream_first_user_response(user_responses.shift)
    user_responses.each{ |user| stream_user_response(user) }
  end

  private

  def build_user_response(user, row_number)
    return Users::ValidResponsePresenter.new(user, row_number) if user.save

    Users::InvalidResponsePresenter.new(user, row_number)
  end

  def stream_first_user_response(user)
    Turbo::StreamsChannel.broadcast_update_to('users_batch', **stream_details(user))
  end

  def stream_user_response(user)
    Turbo::StreamsChannel.broadcast_append_to('users_batch', **stream_details(user))
  end

  def stream_details(user)
    {
      target: 'user_responses',
      partial: user.partial_path,
      locals: { user: user }
    }
  end
end
