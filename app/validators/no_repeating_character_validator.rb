class NoRepeatingCharacterValidator < ActiveModel::EachValidator
  REPEATING_LIMIT = 3

  def validate_each(record, attribute, value)
    return unless value
    return unless repeating_character?(value)

    record.errors.add(attribute, error_message)
  end

  private

  def repeating_character?(value)
    repeating_chunks = value.each_char.chunk_while do |prev, succ|
      prev == succ
    end

    repeating_chunks.any?{ |chunk| chunk.size >= character_limit }
  end

  def error_message
    options.fetch(:message) do
      "should not contain #{character_limit} or more characters in a row"
    end
  end

  def character_limit
    options[:limit] || REPEATING_LIMIT
  end
end
