shared_context 'intuit extraction setup' do |job|
  # ..so the requested reports are till august only
  before { time_travel_to('2012-08-01') }
  after { back_to_the_present }

  include_context 'extraction objects'

  let!(:intuit_company) do
    ic = IntuitCompany.new(realm: 174322770, access_token: "qyprdccBfAsG24NCvLzv88kkkXtWccNPxQPn7ygRGZz4Yv14", access_secret: "EBGtBuaKrbDfHCIpN2esvtJD2UMLEatE4joLdLJE", provider: "QBD")
    ic.company = company
    ic.save
    ic
  end

  let!(:batch_auth_hash) do
    {
        :company => company.id,
        :realm => intuit_company.realm,
        :provider => intuit_company.provider,
        :oauth_token => intuit_company.oauth_token
    }
  end

  file_path = Rails.root.to_s + "/spec/fixtures/etl/qbd/#{job}_test.ebf"

  let!(:batch) do
    ETL::Batch::Batch.resolve(file_path, nil,
        {company_id: company.id, batch_id: execution_batch.id, authentication: batch_auth_hash})
  end

  use_vcr_cassette "qbd/#{job}"
end

shared_context 'quickbooks online extraction setup' do |job|
  # ..so the requested reports are till august only
  before { time_travel_to('2012-08-01') }
  after { back_to_the_present }

  include_context 'extraction objects'
  let!(:intuit_company) do
    ic = IntuitCompany.new(realm: 497421705, access_token: "qyprdu6vPmoGcpFXOZht5vlwgJ5JlM1wszm6ojYZQOb1kiSz", access_secret: "qC8urLItuovknC6I2DfM7jIMNP1ni9pUcmdST13B", provider: "QBO")
    ic.company = company
    ic.save
    ic
  end

  let!(:batch_auth_hash) do
    {
        :company => company.id,
        :realm => intuit_company.realm,
        :provider => intuit_company.provider,
        :oauth_token => intuit_company.oauth_token
    }
  end

  file_path = Rails.root.to_s + "/spec/fixtures/etl/qbo/#{job}_test.ebf"
  let!(:batch) do
    ETL::Batch::Batch.resolve(file_path, nil,
        {company_id: company.id, batch_id: execution_batch.id, authentication: batch_auth_hash})
  end

  use_vcr_cassette "qbo/#{job}"
end

shared_context 'extraction objects' do
  let!(:company) { create(:company) }
  let!(:execution_batch) {ETL::Execution::Batch.create(company_id: company.id)}
  let!(:engine) {ETL::Engine.new}
end


shared_context 'stubbed processors for intuit' do
  let!(:account) { create(:account, :company => company, :qbd_id => '899') }
  let!(:vendor) { create(:vendor, :company => company) }
  let!(:product) { create(:product, :company => company) }
  let!(:employee) { create(:employee, :company => company) }
  let!(:customer) { create(:customer, :company => company) }

  before do
    @customer_lu = mock, @employee_lu = mock, @vendor_lu = mock, @product_lu = mock
    ETL::QBD.stub(:get_customer_id_lookup).and_return(@customer_lu)
    ETL::QBD.stub(:get_employee_id_lookup).and_return(@employee_lu)
    ETL::QBD.stub(:get_vendor_id_lookup).and_return(@vendor_lu)
    ETL::QBD.stub(:get_product_id_lookup).and_return(@product_lu)
    @customer_lu.stub(:transform).with('customer', anything(), anything()).and_return(customer.id)
    @employee_lu.stub(:transform).with('employee', anything(), anything()).and_return(employee.id)
    @vendor_lu.stub(:transform).with('vendor', anything(), anything()).and_return(vendor.id)
    @product_lu.stub(:transform).with('product', anything(), anything()).and_return(product.id)

    # stub for the qbd_accounts_processor
    ETL::QBD.stub(:get_account_id_lookup).and_return(mock(:transform => account.id))

    # stub for the qbd_dates_processor
    Period.find_or_create_by(first_day: Date.new(2012, 1, 1).to_time)
    ETL::QBD.stub(:get_period_id_lookup).and_return(stub(:transform => Period.first.id))
  end
end

shared_context 'stubbed processors for qbo' do
  let!(:account) {create(:account, :company => company, :qbo_id => '899')}
  let!(:vendor) {create(:vendor, :company => company)}
  let!(:product) {create(:product, :company => company)}
  let!(:employee){ create(:employee, :company => company) }
  let!(:customer){ create(:customer, :company => company) }

  before do
    @customer_lu = mock, @employee_lu = mock, @vendor_lu = mock, @product_lu = mock
    ETL::QBO.stub(:get_customer_id_lookup).and_return(@customer_lu)
    ETL::QBO.stub(:get_employee_id_lookup).and_return(@employee_lu)
    ETL::QBO.stub(:get_vendor_id_lookup).and_return(@vendor_lu)
    ETL::QBO.stub(:get_product_id_lookup).and_return(@product_lu)
    @customer_lu.stub(:transform).with('customer', anything(), anything()).and_return(customer.id)
    @employee_lu.stub(:transform).with('employee', anything(), anything()).and_return(employee.id)
    @vendor_lu.stub(:transform).with('vendor', anything(), anything()).and_return(vendor.id)
    @product_lu.stub(:transform).with('product', anything(), anything()).and_return(product.id)

    # stub for the qbo_accounts_processor
    ETL::QBO.stub(:get_account_id_lookup).and_return(mock(:transform => account.id))

    # stub for the qbo_dates_processor
    Period.find_or_create_by(first_day: Date.new(2012,1,1).to_time)
    ETL::QBO.stub(:get_period_id_lookup).and_return(stub(:transform => Period.first.id))
  end
end

# qbd_id and source must be passed within an options hash to make this work
shared_context 'financial transactions for qbd_load jobs' do |options|
  let!(:mentioned_transaction) { create(:financial_transaction, :qbd_id => options[:qbd_id], :source => options[:source],
      :account => account, :company => company, :is_credit => true, :amount_cents => 10) }
  let!(:not_mentioned_transaction) { create(:financial_transaction, :qbd_id => "someNonExistingId", :account => account,
      :company => company, :source => options[:source], :is_credit => true) }
end
