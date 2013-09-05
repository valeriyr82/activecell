module Spreadsheet
  module Converter
    def convert(value)
      if is_numeric? value
        value.to_i
      elsif is_number? value
        value.to_f
      elsif value == 'TRUE'
        true
      elsif value == 'FALSE'
        false
      elsif value == '#REF!'
        nil
      else
        value
      end
    end

    def normalize(value)
      value.downcase.gsub(/\"[^\"]+\"/,'').gsub(/[=>]/,'').strip.gsub(/\s+/, '_')
    end

    private

    def is_numeric?(i)
      i.to_i.to_s == i || i.to_f.to_s == i
    end

    def is_number?(i)
      true if Float(i) rescue false
    end

  end
end