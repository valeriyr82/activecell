require 'spec_helper'

describe 'API v1 for background jobs', :api, :background_jobs do
  include_context 'stuff for the API integration specs'

  before do
    company.intuit_company = build(:intuit_company)
    company.save!
  end

  let!(:intuit_company) { company.intuit_company }

  describe 'POST /api/v1/background_jobs.json' do
    let(:url) { api_v1_background_jobs_url(format: :json, subdomain: company.subdomain) }
    let(:job_uuid) { 'id of new job' }

    before do
      ProcessEtlBatchJob.should_receive(:create).with({ company_id: company.id, batch_type: :full }).and_return(job_uuid)
      post_with_http_auth valid_credentials, url
    end

    it_behaves_like 'an API request with response status', :created

    describe 'returned JSON' do
      subject { response.body }
      it { should have_json_value(job_uuid).at_path('job_uuid') }
    end
  end

  describe 'GET /api/v1/background_jobs/:id.json' do
    let!(:background_job) { create(:background_job, company: company) }
    let(:url) { api_v1_background_job_url(background_job.id, format: :json, subdomain: company.subdomain) }

    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success

    describe 'returned JSON' do
      subject { response.body }

      it { should be_json_eql(background_job.to_json) }
    end
  end

  describe 'GET /api/v1/background_jobs/last.json' do
    let!(:other_background_job) { create(:background_job, company: company, created_at: 1.month.ago) }
    let!(:background_job) { create(:background_job, company: company) }

    let(:url) { last_api_v1_background_jobs_url(format: :json, subdomain: company.subdomain) }

    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success

    describe 'returned JSON' do
      subject { response.body }

      it { should be_json_eql(background_job.to_json) }
    end
  end
end
