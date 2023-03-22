class Users::InvalidResponsePresenter < Users::BaseResponsePresenter
  def errors
    @user.errors.full_messages
  end

  def partial_path
    'batch/users/invalid_response'
  end
end
