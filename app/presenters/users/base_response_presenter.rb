class Users::BaseResponsePresenter
  def initialize(user)
    @user = user
  end

  def partial_path
    raise NotImplementedError, 'implement partial path for user type'
  end
end
