require 'spec_helper'

describe TimesheetTransaction do
  it_behaves_like 'an api period document'
  it_behaves_like 'an api summary document'

  describe 'fields' do
    it { should have_field(:amount_minutes).of_type(Integer) }
  end

  describe 'associations' do
    it { should belong_to(:period) }
    it { should belong_to(:product) }
    it { should belong_to(:customer) }
    it { should belong_to(:employee) }
    it { should belong_to(:employee_activity) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount_minutes) }
  end
end
