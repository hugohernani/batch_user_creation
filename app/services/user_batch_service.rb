class UserBatchService
  def self.call(file_path)
    new(file_path).call
  end

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    # TODO: Also handle invalid file and invalid/missing headers

    view_users = []
    CSV.foreach(@file_path, headers: true).each do |row|
      user = User.new(name: row['name'], password: row['password'])
      view_users << build_view_user(user)
    end

    view_users.each{ |user| broadcast(user) }
  end

  private

  def build_view_user(user)
    user.save ? Users::ValidPresenter.new(user) : Users::InvalidPresenter.new(user)
  end

  def broadcast(user)
    stream_details = {
      partial: "batch/users/#{user.response_partial}",
      locals: { user: user }
    }
    Turbo::StreamsChannel.broadcast_prepend_to(:user_listing, **stream_details)
  end
end
