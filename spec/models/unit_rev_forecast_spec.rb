require 'spec_helper'

describe UnitRevForecast do
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:unit_rev_forecast).of_type(Integer) }
  end

  describe 'associations' do
    it { belong_to(:scenario) }
    it { belong_to(:revenue_stream) }
    it { belong_to(:segment) }
  end
end
