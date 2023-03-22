class ContainsLowercaseValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value&.match?(Regexp.new('[a-z]'))

    record.errors.add(attribute, error_message)
  end

  private

  def error_message
    options.fetch(:message) do
      'should have at least one lowercase character'
    end
  end
end
