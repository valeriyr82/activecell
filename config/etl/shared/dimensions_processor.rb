module ETL
  module Processor
    module DimensionsProcessor
      extend ActiveSupport::Concern
      included do
        attr_reader :ordering_map
        attr_reader :lookup_class
      
        def process(row)
          @customer_lookup = lookup_class.get_customer_id_lookup
          @employee_lookup = lookup_class.get_employee_id_lookup
          @vendor_lookup = lookup_class.get_vendor_id_lookup
          @product_lookup = lookup_class.get_product_id_lookup

          customer  = row[key_for_field(:customer, "CustomerId")]
          employee  = row[key_for_field(:employee, "EmployeeId")]
          vendor    = row[key_for_field(:vendor, "VendorId")]
          product   = row[key_for_field(:product, "ItemId")]

          case row["EntityType"]
          when 'Customer'
            customer  ||= row["EntityId"]
          when 'Employee'
            employee  ||= row["EntityId"]
          when 'Vendor'
            vendor    ||= row["EntityId"]
          end

          row[:customer_id] = @customer_lookup.transform('customer',customer,row)
          row[:employee_id] = @employee_lookup.transform('employee',employee,row)
          row[:vendor_id] = @vendor_lookup.transform('vendor',vendor,row)
          row[:product_id] = @product_lookup.transform('product', product, row)

          row.reject!{|k,v| ["CustomerId", "EmployeeId", "ItemId", "VendorId"].include? k }
          row
        end
        
        private
        
        def key_for_field(field, default)
          return default if ordering_map.blank?
          ordering_map.fetch(field, default)
        end
        
      end
      
    end
  end
end
