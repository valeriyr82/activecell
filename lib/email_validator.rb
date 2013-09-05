class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEXP = /\A[^@]+@[^@]+\z/

  def validate_each(record, attribute, value)
    unless value.match(EMAIL_REGEXP)
      record.errors[attribute] << (options[:message] || "is invalid")
    end
  end
end
