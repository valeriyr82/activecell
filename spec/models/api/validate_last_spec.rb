require 'spec_helper'

describe Api::ValidateLast do
  let(:company) { create(:company) }
  let(:revenue_stream) { company.revenue_streams.first }

  it 'adds error on company_id' do
    revenue_stream.destroy
    revenue_stream.errors[:company_id].should be_present
  end

  it 'does not adds error for not first items' do
    second_revenue_stream = create(:revenue_stream, company: company)
    second_revenue_stream.destroy.should be_true
  end
end
