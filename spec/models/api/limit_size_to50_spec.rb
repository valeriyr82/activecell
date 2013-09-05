require 'spec_helper'

describe Api::LimitSizeTo50 do
  let(:company) { create(:company) }

  before do
    49.times { create(:segment, company: company) }
    company.should have(50).segments
  end

  it 'adds error on company_id' do
    new_segment = build(:segment, company: company)
    new_segment.save()
    new_segment.errors[:company_id].should be_present
  end
end
