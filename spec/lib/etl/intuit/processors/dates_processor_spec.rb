require 'spec_helper'

describe ETL::Processor::QbdDatesProcessor do
  shared_context "objects and stubs for qbo/qbd dates processor" do |provider|
    let (:period) {Period.find_or_create_by(first_day: Time.now.beginning_of_month)}
    let!(:processor) {"ETL::Processor::#{provider}DatesProcessor".constantize.new(nil, 
        {:transaction_date_field => "TxnDate"})}
  end

  shared_examples_for 'dates processor' do |provider_class|
    describe "When there's value under configured key" do
      let(:row) {
        {"TxnDate" => Time.now.to_date, "PeriodId" => "this should be gone from the result row"}
      }

      before do
        lookup = mock
        lookup.should_receive(:transform).with('period', Time.now.to_date.to_date.beginning_of_month, row).and_return(period.id)
        "ETL::#{provider_class}".constantize.should_receive(:get_period_id_lookup).and_return(lookup)
      end

      subject{processor.process(row)}

      it { should == {txn_date: Time.now.to_date, period_id: period.id} }
    end
  end
  
  
  describe 'for QBO' do
    include_context "objects and stubs for qbo/qbd dates processor", "Qbo"
    it_behaves_like 'dates processor', "QBO"
  end
  
  describe 'for QBD' do
    include_context "objects and stubs for qbo/qbd dates processor", "Qbd"
    it_behaves_like 'dates processor', "QBD"
  end
end
