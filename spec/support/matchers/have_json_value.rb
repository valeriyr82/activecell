module Matchers
  class HaveJsonValue
    include JsonSpec::Helpers
    include JsonSpec::Exclusion
    include JsonSpec::Messages

    attr_reader :expected, :actual

    def diffable?
      true
    end

    def initialize(expected_value = nil)
      @expected_value = expected_value.to_json
    end

    def matches?(actual_json)
      raise "Expected value not provided" if @expected_value.nil?

      @actual, @expected = scrub(actual_json, @path), scrub(@expected_value)
      @actual == @expected
    end

    def at_path(path)
      @path = path
      self
    end

    def failure_message_for_should
      message_with_path("Expected value")
    end

    def failure_message_for_should_not
      message_with_path("Expected not have value")
    end

    def description
      message_with_path("have value '#{@expected_value}'")
    end

    private

    def scrub(json, path = nil)
      generate_normalized_json(exclude_keys(parse_json(json, path))).chomp + "\n"
    end
  end
end

JsonSpec::Matchers.module_eval do
  def have_json_value(value = nil)
    Matchers::HaveJsonValue.new(value)
  end
end
