require 'spec_helper'

describe ETL::QBD do
  shared_examples 'an existing resolver' do |resolver_name|
    describe "when #{resolver_name} was created once" do
      before do
        ETLCache.resolvers[resolver_name] = "#{resolver_name}_resolver"
      end
    
      it "should use one from cache" do
        ActiveResourceResolver.should_not_receive(:new)
        ETL::QBD.send("get_#{resolver_name}_resolver".to_sym).should == "#{resolver_name}_resolver"
      end
    end
  end

  shared_examples 'not yet saved resolver' do |resolver_name|
    describe "with no #{resolver_name} resolver yet" do
      before do
        ETLCache.resolvers[resolver_name] = nil
        ETL::QBD.stub(:existing_where).and_return({})
        ActiveResourceResolver.should_receive(:new).with(resolver_name.to_s.capitalize.constantize, nil, {}, :qbd_id).and_return("#{resolver_name}_resolver")
        ETL::QBD.send("get_#{resolver_name}_resolver".to_sym) #call it once already to test caching
      end
    
      it "should create new one" do
        ETL::QBD.send("get_#{resolver_name}_resolver".to_sym).should == "#{resolver_name}_resolver"
      end
      
      it "should stay under resolvers[:#{resolver_name}]" do
        ETLCache.resolvers[resolver_name].should == "#{resolver_name}_resolver"
      end
    end
  end

  shared_examples 'id lookup' do |resolver_name|
    describe "with no #{resolver_name} resolver yet" do
      before do
        ETLCache.resolvers["#{resolver_name}_id_lookup".to_sym] = nil
      
        stubbed_resolver = mock
        ETL::QBD.stub("get_#{resolver_name}_resolver".to_sym).and_return(stubbed_resolver)
      
        ETL::Transform::ForeignKeyLookupTransform.should_receive(:new).
          with(ETL::QBD, "#{resolver_name} id lookup", {:resolver => stubbed_resolver, :cache => true}).
          and_return("#{resolver_name}_lookup")
        ETL::QBD.send("get_#{resolver_name}_id_lookup".to_sym) #call it once already to test caching
      end
    
      it "should create new one" do
        ETL::QBD.send("get_#{resolver_name}_id_lookup".to_sym).should == "#{resolver_name}_lookup"
      end
      
      it "should stay under resolvers[:#{resolver_name}]" do
        ETLCache.resolvers["#{resolver_name}_id_lookup".to_sym].should == "#{resolver_name}_lookup"
      end
    end
  end

  shared_examples 'account lookup' do |lookup_name, where_params|
    before do
      @method = "get_product_#{lookup_name}_account_lookup".to_sym
      @storage_key = "product_#{lookup_name}_account_lookup".to_sym
    end
  
    describe "with no #{lookup_name} lookup" do
      before do
        ETL::QBD.should_receive(:get_default_rev_account).at_most(:once).and_return('mocked')
      
        ETLCache.resolvers[@storage_key] = nil
        ETL::Transform::ForeignKeyLookupTransform.should_receive(:new).once.and_return("mocked_lookup")
        ETL::QBD.send(@method)  #call it once already to test caching
      end

      it "should create new one" do
        ETL::QBD.send(@method).should == "mocked_lookup"
      end
      
      it "should stay under resolvers hash" do
        ETLCache.resolvers[@storage_key].should == "mocked_lookup"
      end
    end
  
    describe "with no #{lookup_name} lookup" do 
      before do
        ETLCache.resolvers[@storage_key] = "#{lookup_name}_lookup_mocked"
      end
    
      it "should use one from cache" do
        ETL::Transform::ForeignKeyLookupTransform.should_not_receive(:new)
        ETL::QBD.send(@method).should == "#{lookup_name}_lookup_mocked"
      end
    end
  end

  let!(:user) { create(:user, email: 'user@email.com', password: 'secret password') }
  let!(:company) { create(:company, users: [user]) }
  let(:account) { create(:account) }

  describe "#company" do
    it "should be cached" do
      Company.should_receive(:find).once.and_return(company)

      ETL::QBD.company.should == company
      ETL::QBD.company.should == company
    end
  end

  context "defaults" do
    before do
      ETL::QBD.should_receive(:company).at_most(:once).and_return(company)
    end
  
    describe "#get_default_rev_account" do
      before do
        company.stub_chain(:accounts, :revenue, :asc, :first).and_return(account)
        account.should_receive(:id).at_most(:once).and_return(1)
        ETL::QBD.get_default_rev_account
      end

      it "should be cached" do
        ETL::QBD.get_default_rev_account.should == 1
      end
      
      it "should be stored" do
        ETLCache.resolvers[:default_rev_account_id].should == 1
      end
    end
  
    describe "#get_default_exp_account" do
      before do
        company.stub_chain(:accounts, :expense, :asc, :first).and_return(account)
        account.should_receive(:id).at_most(:once).and_return(1)
        ETL::QBD.get_default_exp_account
      end
      
      it "should be cached" do
        ETL::QBD.get_default_exp_account.should == 1
      end
      
      it "should be stored" do
        ETLCache.resolvers[:default_exp_account_id].should == 1
      end
    end
    
    describe "#get_default_ap_account" do
      before do
        company.stub_chain(:accounts, :where, :asc, :first).and_return(account)
        account.should_receive(:id).at_most(:once).and_return(1)
        ETL::QBD.get_default_ap_account
      end
      
      it "should be cached" do
        ETL::QBD.get_default_ap_account.should == 1
      end
      
      it "should be stored" do
        ETLCache.resolvers[:get_default_ap_account].should == 1
      end
    end
    
    describe "#get_default_ar_account" do
      before do
        company.stub_chain(:accounts, :where, :asc, :first).and_return(account)
        account.should_receive(:id).at_most(:once).and_return(1)
        ETL::QBD.get_default_ar_account
      end
      
      it "should be cached" do
        ETL::QBD.get_default_ar_account.should == 1
      end
      
      it "should be stored" do
        ETLCache.resolvers[:get_default_ar_account].should == 1
      end
    end
  end
  
  describe "#get_period_resolver" do
    describe 'with no period resolver yet' do
      before do
        ETLCache.resolvers[:period] = nil
        ActiveResourceResolver.should_receive(:new).with(Period, nil, nil, :first_day).and_return(1)
        ETL::QBD.get_period_resolver #call it once already to test caching
      end
      
      it "should create new one" do
        ETL::QBD.get_period_resolver.should == 1
      end
      
      it "should stay under resolvers[:period]" do
        ETLCache.resolvers[:period] == 1
      end
    end
    
    it_behaves_like 'an existing resolver', :period
  end
  
  describe "#get_account_resolver" do
    it_behaves_like 'not yet saved resolver', :account
    it_behaves_like 'an existing resolver', :account
  end
  
  describe "#get_customer_resolver" do
    it_behaves_like 'not yet saved resolver', :customer
    it_behaves_like 'an existing resolver', :customer
  end
  
  describe "#get_employee_resolver" do
    it_behaves_like 'not yet saved resolver', :employee
    it_behaves_like 'an existing resolver', :employee
  end
  
  describe "#get_product_resolver" do
    it_behaves_like 'not yet saved resolver', :product
    it_behaves_like 'an existing resolver', :product
  end
  
  describe "#get_vendor_resolver" do
    it_behaves_like 'not yet saved resolver', :vendor
    it_behaves_like 'an existing resolver', :vendor
  end
  
  describe "#get_period_id_lookup" do
    it_behaves_like 'id lookup', :period
  end
  
  describe "#get_account_id_lookup" do
    it_behaves_like 'id lookup', :account
  end
  
  describe "#get_customer_id_lookup" do
    it_behaves_like 'id lookup', :customer
  end
  
  describe "#get_employee_id_lookup" do
    it_behaves_like 'id lookup', :employee
  end
  
  describe "#get_product_id_lookup" do
    it_behaves_like 'id lookup', :product
  end
  
  describe "#get_product_id_lookup" do
    it_behaves_like 'id lookup', :vendor
  end

  describe "#get_product_inc_account_lookup" do
    it_behaves_like 'account lookup', :inc
  end
  
  describe "#get_product_exp_account_lookup" do
    it_behaves_like 'account lookup', :exp
  end

  describe "#get_product_cogs_account_lookup" do
    it_behaves_like 'account lookup', :cogs
  end
  
  describe "#get_product_asset_account_lookup" do
    it_behaves_like 'account lookup', :asset
  end
end
