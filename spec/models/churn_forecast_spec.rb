require 'spec_helper'

describe ChurnForecast do
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:churn_forecast).of_type(Integer) }
  end

  describe 'associations' do
    it { belong_to(:period) }
    it { belong_to(:segment) }
    it { belong_to(:scenario) }
  end
end
