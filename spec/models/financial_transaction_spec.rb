require 'spec_helper'

describe FinancialTransaction do
  it_behaves_like 'an api period document'
  it_behaves_like 'an api summary document'

  describe 'fields' do
    it { should have_field(:amount_cents).of_type(Integer) }
  end

  describe 'associations' do
    it { should belong_to(:period) }
    it { should belong_to(:account) }
    it { should belong_to(:product) }
    it { should belong_to(:customer) }
    it { should belong_to(:employee) }
    it { should belong_to(:vendor) }
  end

  describe 'validations' do
    it { should validate_presence_of(:period) }
    it { should validate_presence_of(:account) }
    it { should validate_presence_of(:amount_cents) }
    it { should validate_numericality_of(:amount_cents) }
  end
end
