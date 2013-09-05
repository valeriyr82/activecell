RSpec::Matchers.define :have_response_status do |expected|
  match do |actual|
    status_code_matcher = Shoulda::Matchers::ActionController::RespondWithMatcher.new(expected)
    response.status == status_code_matcher.instance_eval { @status }
  end

  failure_message_for_should do |actual|
    "Expected #{expected} but #{response.status} given"
  end

  failure_message_for_should_not do |actual|
    "Did not expect #{expected}"
  end

  description do
    "respond with #{expected}"
  end
end
