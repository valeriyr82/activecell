@company_id = control.options[:company_id]
@existing_where = {company_id: @company_id, qbd_id: {"$ne"=>nil}}
source :in, {
	:type 	=> :mongo,
	:source => 'qbd',
  :entity => 'vendor'
}

after_read :flatten_hash_array, {:array_field => 'MetaData'} 

destination :out, {
	:type => :active_resource,
	:class_name 	=> 'Vendor',
	:existing_where => @existing_where,
	:check_for_deletes => true
},
{
  :virtual => {
	  :company_id => @company_id
  },
  :order => {
  	:company_id => :company_id,
   	:name => :name,
  	:active => :active,
  	:qbd_id => :id
  },
	:primarykey => [:company_id, :qbd_id]
}