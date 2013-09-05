require 'spec_helper'

describe CompanySubscription, :billing do

  describe 'fields' do
    it { should be_timestamped_document }

    it { should have_field(:uuid).of_type(String) }
    it { should have_field(:state).of_type(String) }
    it { should have_field(:plan_code).of_type(String) }
    it { should have_field(:plan_name).of_type(String) }
    it { should have_field(:plan_interval_length).of_type(Integer) }
    it { should have_field(:plan_interval_unit).of_type(String) }
    it { should have_field(:plan_unit_amount_in_cents).of_type(Integer) }
    it { should have_field(:expires_at).of_type(Time) }
    it { should have_field(:trial_ends_at).of_type(Time) }

    it { should have_field(:terminated_by_advisor).of_type(Boolean).with_default_value_of(false) }
  end

  describe 'associations' do
    it { should be_embedded_in(:company).as_inverse_of(:subscription) }
  end

end
