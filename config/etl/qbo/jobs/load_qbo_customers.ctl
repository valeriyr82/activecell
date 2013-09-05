@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, qbo_id: {"$ne" => nil}}

source :in, {
    :type => :mongo,
    :source => 'qbo',
    :entity => 'customer'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'}

destination :out, {
    :type => :active_resource,
    :class_name => 'Customer',
    :existing_where => @existing_where,
    :check_for_deletes => true
},
{
    :virtual => {
        :company_id => @company_id
    },
    :order => {
        :company_id => :company_id,
        :qbo_id => :id,
        :name => :name
    },
    :primarykey => [:company_id, :qbo_id]
}
