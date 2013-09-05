require 'spec_helper'

describe StaffingForecast do
  it_behaves_like 'an api document which belongs to company'
  it_behaves_like 'an api occurence document'

  describe 'fields' do
    it { should have_field(:fixed_delta).of_type(Integer) }
    it { should have_field(:revenue_threshold).of_type(Integer) }
  end

  describe 'associations' do
    it { should belong_to(:scenario) }
    it { should belong_to(:employee_type) }
    it { should belong_to(:occurrence_period) }
  end
    
  describe 'validations' do
    it { validate_inclusion_of(:occurrence) }
  end
end
