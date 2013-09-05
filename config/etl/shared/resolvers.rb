# Public: Set of resolvers from QBD/QBO data source. 
#   These resolvers are cached once to avoid constant database queries
#   during execution.
#
module ETL
  module Shared
    def provider 
      self.name.demodulize.downcase
    end
    
    def company_id
      ETLCache.resolvers[:company_id]
    end
      
    def company
      ETLCache.resolvers[:current_company] ||= Company.find(company_id)
    end
      
    def existing_where
      { company_id: company_id, "#{self.provider}_id".to_sym => { "$ne" => nil } }
    end

    # defaults  
    
    def get_default_rev_account
      ETLCache.resolvers[:default_rev_account_id] ||= company.
        accounts.revenue.asc(:account_number).first.id 
    end
    
    def get_default_exp_account
      ETLCache.resolvers[:default_exp_account_id] ||= company.
        accounts.expense.asc(:account_number).first.id
    end
    
    def get_default_ap_account
      ETLCache.resolvers[:get_default_ap_account] ||= company.
        accounts.where(:sub_type => "Accounts Payable").asc(:account_number).first.id
    end
    
    def get_default_ar_account
      ETLCache.resolvers[:get_default_ar_account] ||= company.
        accounts.where(:sub_type => "Accounts Receivable").asc(:account_number).first.id
    end
    
    # in activecell--allowing nulls!
    #
    # def get_default_customer
    #   ETLCache.resolvers[:default_customer_id] = company.default_plug(Customer).id
    # end
    # 
    # def get_default_employee
    #   ETLCache.resolvers[:default_employee_id] = company.default_plug(Employee).id
    # end
    # 
    # def get_default_item
    #   ETLCache.resolvers[:default_item_id] = company.default_plug(ItemDimension).id
    # end
    # 
    # def get_default_vendor
    #   ETLCache.resolvers[:default_vendor_id] = company.default_plug(VendorDimension).id
    # end
    
    # resolvers 
    
    def get_period_resolver
      ETLCache.resolvers[:period] ||= ActiveResourceResolver.new(
        Period, nil, nil, :first_day
      )
    end
    
    def get_account_resolver
      ETLCache.resolvers[:account] ||= ActiveResourceResolver.new(
        Account, nil, existing_where, "#{self.provider}_id".to_sym
      )
    end
  	
    def get_customer_resolver
      ETLCache.resolvers[:customer] ||= ActiveResourceResolver.new(
        Customer, nil, existing_where, "#{self.provider}_id".to_sym
      )
    end

    def get_employee_resolver
      ETLCache.resolvers[:employee] ||= ActiveResourceResolver.new(
        Employee, nil, existing_where, "#{self.provider}_id".to_sym
      )
    end

    def get_product_resolver
      ETLCache.resolvers[:product] ||= ActiveResourceResolver.new(
        Product, nil, existing_where, "#{self.provider}_id".to_sym
      )
    end
      
    def get_vendor_resolver
      ETLCache.resolvers[:vendor] ||= ActiveResourceResolver.new(
        Vendor, nil, existing_where, "#{self.provider}_id".to_sym
      )
    end
      
    # transforms
    
    def get_period_id_lookup
      ETLCache.resolvers[:period_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'period id lookup', {
          :resolver => get_period_resolver, 
          :cache => true
        }
      )
    end

    def get_account_id_lookup
      ETLCache.resolvers[:account_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'account id lookup', {
          :resolver => get_account_resolver, 
          :cache => true
        }
      )
    end
    
    def get_customer_id_lookup
      ETLCache.resolvers[:customer_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'customer id lookup', {
          :resolver => get_customer_resolver, 
          :cache => true
        }
      )
    end

    def get_employee_id_lookup
      ETLCache.resolvers[:employee_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'employee id lookup', {
          :resolver => get_employee_resolver, 
          :cache => true
        }
      )
    end

    def get_product_id_lookup
      ETLCache.resolvers[:product_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'product id lookup', {
          :resolver => get_product_resolver, 
          :cache => true
        }
      )
    end
      
    def get_vendor_id_lookup
      ETLCache.resolvers[:vendor_id_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'vendor id lookup', {
          :resolver => get_vendor_resolver, 
          :cache => true
        }
      )
    end

    def get_product_inc_account_lookup
      ETLCache.resolvers[:product_inc_account_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'product income account lookup', {
          :resolver => get_product_resolver, 
          :cache => true,
          :target_field => :income_account_id,
          :default => get_default_rev_account
        }
      )        
    end

    def get_product_exp_account_lookup
      ETLCache.resolvers[:product_exp_account_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'product expense account lookup', {
          :resolver => get_product_resolver, 
          :cache => true,
          :target_field => :expense_account_id
        }
      )        
    end

    def get_product_cogs_account_lookup
      ETLCache.resolvers[:product_cogs_account_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'product cogs account lookup', {
          :resolver => get_product_resolver, 
          :cache => true,
          :target_field => :cogs_account_id
        }
      )        
    end

    def get_product_asset_account_lookup
      ETLCache.resolvers[:product_asset_account_lookup] ||=
        ETL::Transform::ForeignKeyLookupTransform.new(
        self, 'product asset account lookup', {
          :resolver => get_product_resolver, 
          :cache => true,
          :target_field => :asset_account_id
        }
      )        
    end
  end
  
  module QBO
    extend ETL::Shared
  end
  
  module QBD
    extend ETL::Shared
  end
end
