require 'spec_helper'

describe 'load_qbo_bills' do
  include_context 'quickbooks online extraction setup', 'load_qbo_bill'

  context 'with stubbed processors' do
    include_context 'stubbed processors for qbo'
  
    before do
      ETL::QBO.stub(:get_default_ap_account).and_return(account.id)
      FinancialTransaction.delete_all
      engine.process batch
    end

    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      # there are 45 objects in the response
      FinancialTransaction.count.should == 90
    end
    
    it "should create unique qbo_id for each pair of created financial transactions" do
      ids = FinancialTransaction.all.map &:qbo_id
      ids.uniq.size.should == FinancialTransaction.count / 2
    end
    
    describe 'When looking at a single created transaction' do
      let(:period){Period.first}
        
      subject { FinancialTransaction.find_by(qbo_id: "716-2", company_id: company.id, is_credit: false) }

      specify 'loaded transaction' do
        expect(subject.amount_cents).to eq(7580)
        expect(subject.source).to eq('qbo_bill')
        expect(subject.transaction_date).to eq(Date.parse("2011-04-14-07:00"))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(account.id)
        expect(subject.product_id).to eq(product.id)
        expect(subject.customer_id).to eq(customer.id)
        expect(subject.status).to eq(nil)
      end
    end
  end
  
  context 'without stubbed processors' do
    let!(:period) { Period.create(first_day: Date.new(2012,1,1).to_time) }
    # need to pass :id because facotries would create with different ids while 
    # resolver caches the ids of found records which leads to errors v. difficult to debug
    let!(:vendor) { create(:vendor, company: company, qbo_id: '35', id: 35) }
    let!(:account) { create(:account, company: company, qbo_id: '33', id: 33) }
    
    before do
      # stub for default lookups
      ETL::QBO.stub(:get_default_ap_account).and_return(account.id)
      ETL::QBO.stub(:get_period_id_lookup).and_return(stub(transform: period.id))
      engine.process batch
    end
      
    describe 'When looking at a single created transaction' do
      # all the ids taken from the last bill in load_qbo_bill.yml
      subject { FinancialTransaction.find_by(qbo_id: "716-2", company_id: company.id, is_credit: false) }

      specify 'loaded transaction' do
        expect(subject.source).to eq('qbo_bill')
        expect(subject.amount_cents).to eq(7580)
        expect(subject.transaction_date).to eq(Date.parse("2011-04-14-07:00"))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(account.id)
        expect(subject.product_id).to be_nil
        expect(subject.customer_id).to be_nil
        expect(subject.status).to be_nil
      end
    end
    
    it "should create 2 transactions" do
      FinancialTransaction.count.should == 2
    end
  end
end

# sample returned bill as recorded in vhs
#    <Bill>
#    <Id idDomain="QBO">1454</Id>
#    <SyncToken>1</SyncToken>
#    <MetaData>
#      <CreateTime>2011-08-31T00:00:00-07:00</CreateTime>
#      <LastUpdatedTime>2011-08-31T00:00:00-07:00</LastUpdatedTime>
#    </MetaData>
#    <Header>
#      <DocNumber>317560</DocNumber>
#      <TxnDate>2011-08-31-07:00</TxnDate>
#      <VendorId
#        idDomain="QBO">167
#      </VendorId>
#      <TotalAmt>2500.00</TotalAmt>
#      <SalesTermId idDomain="QBO">7</SalesTermId>
#      <DueDate>2011-09-30-07:00</DueDate>
#      <Balance>0.00</Balance>
#    </Header>
#    <Line>
#      <Id
#        idDomain="QBO">1
#      </Id>
#      <Amount>2500.00</Amount>
#      <BillableStatus>NotBillable</BillableStatus>
#      <AccountId
#        idDomain="QBO">81
#      </AccountId>
#    </Line>
#  </Bill>
