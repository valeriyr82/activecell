require 'spec_helper'

describe Account do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:type).of_type(String) }
    it { should have_field(:sub_type).of_type(String) }
    it { should have_field(:account_number).of_type(String) }
    it { should have_field(:current_balance).of_type(Integer) }
    it { should have_field(:current_balance_currency).of_type(String) }
    it { should have_field(:current_balance_as_of).of_type(Date) }
    it { should have_field(:is_active).of_type(Boolean) }
  end

  describe 'associations' do
    it { have_many(:children_accounts) }
    it { belong_to(:parent_account) }
  end
end
