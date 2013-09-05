require 'spec_helper'

describe ConversionSummary do
  describe 'fields' do
    it { should have_field(:customer_volume).of_type(Integer) }
  end

  describe 'associations' do
    it { should belong_to(:period) }
    it { should belong_to(:company) }
    it { should belong_to(:stage) }
    it { should belong_to(:channel) }
  end
end
