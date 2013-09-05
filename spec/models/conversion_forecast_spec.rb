require 'spec_helper'

describe ConversionForecast do
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:conversion_forecast).of_type(Integer) }
  end

  describe 'associations' do
    it { belong_to(:period) }
    it { belong_to(:stage) }
    it { belong_to(:channel) }
    it { belong_to(:scenario) }
  end
end
