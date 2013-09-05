require 'spec_helper'

describe 'load_all_qbo_objects' do
  include_context 'extraction objects'

  let!(:intuit_company) do
    ic = IntuitCompany.new(realm: 497421705, access_token: "qyprdu6vPmoGcpFXOZht5vlwgJ5JlM1wszm6ojYZQOb1kiSz", access_secret: "qC8urLItuovknC6I2DfM7jIMNP1ni9pUcmdST13B", provider: "QBO")
    ic.company = company
    ic.save
    ic
  end
  
  let!(:batch_auth_hash) do
    {
      company: company.id, 
      realm: intuit_company.realm, 
      provider: intuit_company.provider,
      oauth_token: intuit_company.oauth_token
    }
  end
  
  context 'parsing load_all_qbo_objects_test' do
    @lines = File.open(Rails.root.to_s + "/spec/fixtures/etl/qbo/load_all_qbo_objects.ebf" ).readlines.join.split("\n")
    @lines.delete_if(&:blank?).slice(3..-1).each do |line|
      job_name = line.match(/\[:(.*)\]/)[1] # extract the job name from string like "extract '{entities: [:job]}'"
      it "should load #{job_name}" do
        VCR.use_cassette("qbo/load_qbo_#{job_name}") do
          single_command_file = File.new("temp.ebf", "w")
          single_command_file.write(line)
          single_command_file.close
          batch = ETL::Batch::Batch.resolve(single_command_file, nil, 
            { company_id: company.id, batch_id: execution_batch.id, authentication: batch_auth_hash} )
          File.delete("temp.ebf")
          
          engine.process batch
        end
      end
    end
  end
end
