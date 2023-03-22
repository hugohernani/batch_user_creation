class ContainsUppercaseValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value&.match(Regexp.new('[A-Z]'))

    record.errors.add(attribute, error_message)
  end

  private

  def error_message
    options.fetch(:message) do
      'should have at least one uppercase character'
    end
  end
end
