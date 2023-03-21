class Users::ValidResponsePresenter < Users::BaseResponsePresenter
  def partial_path
    'batch/users/valid_response'
  end

  def to_s
    "#{@user.name} - VALID"
  end
end
