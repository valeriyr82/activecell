require 'spec_helper'

describe Period do
  describe 'fields' do
    it { should have_field(:first_day).of_type(Date) }
  end

  describe 'default scope' do
    before do
      first_period = Time.now.beginning_of_month - 60.months
      120.times do |time|
        Period.find_or_create_by(first_day: first_period + time.months)
      end
    end

    it 'returns 72 periods by default' do
      Period.all.should have(72).items
    end

    it 'returns >72 periods unscoped' do
      Period.unscoped.should have_at_least(73).items
    end
  end

end
