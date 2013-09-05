require 'spec_helper'

describe Scenario do
  it_behaves_like 'an api document with name'

  describe 'validations' do
    it { validate_uniqueness_of(:name).scoped_to(:company_id) }
  end

  describe 'associations' do
    it { belong_to(:company) }
  end
end
