require 'spec_helper'

describe Stage do
  it_behaves_like 'an api document with name'
  
  describe 'fields' do
    it { should have_field(:lag_periods).of_type(Integer) }
    it { should have_field(:position).of_type(Integer) }
  end
  
  describe 'associations' do
    it { belong_to(:company) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:position).scoped_to(:company_id) }
    it { should validate_presence_of(:position) }
  end
  
end
