require 'spec_helper'

describe Feedback do
  describe 'fields' do
    it { should be_timestamped_document }
    it { should have_field(:body).of_type(String) }
    it { should have_field(:active_page).of_type(String) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
