require 'spec_helper'

describe UnitCacForecast do
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:unit_cac_forecast).of_type(Integer) }
  end

  describe 'associations' do
    it { belong_to(:category) }
    it { belong_to(:channel) }
    it { belong_to(:scenario) }
  end
end
