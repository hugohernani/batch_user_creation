class Users::InvalidResponsePresenter < Users::BaseResponsePresenter
  def partial_path
    'batch/users/invalid_response'
  end

  def to_s
    "#{@user.name} - INVALID"
  end
end
