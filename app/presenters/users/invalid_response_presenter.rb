class Users::InvalidResponsePresenter < Users::BaseResponsePresenter
  def errors
    @user.errors.messages.inject('') do |error_messages, (field, errors)|
      error_messages << "#{field.capitalize} #{errors.to_sentence}"
    end
  end

  def partial_path
    'batch/users/invalid_response'
  end
end
