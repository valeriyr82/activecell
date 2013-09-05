require 'spec_helper'

describe Api::SummaryDocument do
  let(:company)   { create(:company) }
  let(:period_1)  { create(:period) }
  let(:period_2)  { create(:period) }
  let(:account)   { create(:account) }
  let!(:employee) { create(:employee, company: company) }

  let!(:ft1) { create(:financial_transaction, company: company, period: period_1, account: account, amount_cents: 1) }
  let!(:ft2) { create(:financial_transaction, company: company, period: period_1, account: account, amount_cents: 5) }
  let!(:ft3) { create(:financial_transaction, company: company, period: period_2, account: account, amount_cents: 9) }

  describe 'summary' do
    subject(:summary) { company.reload.financial_transactions.summary }

    it { should have(2).items }
    it 'aggregates properly' do
      period_1_summary = summary.select { |row| row[:period] = period_1 }
      period_1_summary.first[:amount_cents].should == 6
    end
  end

  describe 'by_params' do
    subject(:by_params) { company.reload.financial_transactions.by_params(period_id: period_1.id)}

    it { should have(2).items }
  end
end
