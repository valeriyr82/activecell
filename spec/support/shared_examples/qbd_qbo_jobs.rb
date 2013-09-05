# Checks the amount of created financial transactions and if they all have company assigned
# Also, it assumes that for each row in intuit response two transactions should be created (Remember this is not true in some .ctl jobs)
shared_examples 'financial transactions records created from report' do |count, provider|
  provider ||= "qbd" 
  provider_id = (provider + "_id").to_sym
  
  context do
    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == count
    end

    it "should create two transactions per each entry" do
      FinancialTransaction.all.to_a.map(&provider_id).uniq.each do |qb_id|
        transactions = FinancialTransaction.where(provider_id => qb_id)
        transactions.count.should == 2
        transactions.select{ |t| t.is_credit == true }.should_not be_nil
        transactions.select{ |t| t.is_credit == false }.should_not be_nil
      end
    end
    
  end
end

# Checks if financial transactions connected to the given qbd_id have expected values assigned
# qbd_id, date, status, source and cents amount must be passed within an options hash to make this work
shared_examples 'a correctly created financial transaction' do |options|
  shared_assertions_name = "transaction from #{options[:source]}"
  
  describe 'When looking at a single created transaction' do
    let(:period) { Period.first }
    
    shared_examples_for shared_assertions_name do
      specify 'loaded transaction' do
        expect(subject.source).to eq(options[:source])
        expect(subject.transaction_date).to eq(Date.parse(options[:date]))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(account.id)
        expect(subject.product_id).to eq(product.id)
        expect(subject.customer_id).to eq(customer.id)
        expect(subject.status).to eq(options[:status])
      end
    end
      
    describe 'for a charge record' do
      subject { FinancialTransaction.find_by(:qbd_id => options[:qbd_id], :company_id => company.id, :is_credit => true) }

      its(:amount_cents) {should == options[:cents] * -1}
      it_behaves_like shared_assertions_name
    end
    
    describe 'for a gain record' do
      subject { FinancialTransaction.find_by(:qbd_id => options[:qbd_id], :company_id => company.id, :is_credit => false) }

      its(:amount_cents) {should == options[:cents]}
      it_behaves_like shared_assertions_name
    end
  end
end

# Checks if already existing records with same 'primary key' values are replaced by new ones and 
# if the existing records which belongs to the same company are removed if :check_for_deletes is set to true 
# (which is done in all FinancialTransaction related jobs)
# 
# NOTE: qbd_id, source, amount_cents must be passed within an options hash to make this work
shared_examples 'like it has :check_for_deletes set to true' do |options|
  raise 'You must pass :amount_cents to use this shared example' unless options.has_key?(:amount_cents)
  
  it "should update an existing transaction" do
    mentioned_transaction.reload.amount_cents.should == options[:amount_cents]
  end
    
  it "should delete existing transactions not mentioned in the received data" do
    lambda do
      not_mentioned_transaction.reload.account_id
    end.should raise_error Mongoid::Errors::DocumentNotFound
  end
end
