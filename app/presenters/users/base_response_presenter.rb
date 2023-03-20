class Users::BaseResponsePresenter
  def initialize(user, row_number)
    @user = user
    @row_number = row_number
  end

  def id
    @row_number
  end

  def name
    @user.name
  end

  def partial_path
    raise NotImplementedError, 'implement partial path for user type'
  end
end
