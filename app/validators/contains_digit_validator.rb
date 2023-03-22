class ContainsDigitValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value&.match?(Regexp.new('[0-9]'))

    record.errors.add(attribute, error_message)
  end

  private

  def error_message
    options.fetch(:message) do
      'should have at least one digit character'
    end
  end
end
