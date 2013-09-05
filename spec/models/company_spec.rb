require 'spec_helper'

describe Company do
  let(:company) { create(:company) }
  subject { company }

  describe 'fields' do
    it { should have_field(:name).of_type(String) }
    it { should have_field(:subdomain).of_type(String) }
    it { should have_field(:url).of_type(String) }

    it { should have_field(:address_1).of_type(String) }
    it { should have_field(:address_2).of_type(String) }
    it { should have_field(:postal_code).of_type(String) }
  end

  it { should be_paranoid_document }
  it { should be_timestamped_document }

  describe 'scopes' do
    let!(:first_company) { create(:company, subdomain: 'foo') }
    let!(:second_company) { create(:company, subdomain: 'bar') }

    describe '.find_by_subdomain' do
      it 'should find a company by subdomain' do
        Company.find_by_subdomain('foo').should == first_company
        Company.find_by_subdomain('bar').should == second_company
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_uniqueness_of(:subdomain) }
    it { should validate_length_of(:subdomain).within(1..63) }

    describe '#subdomain' do
      before do
        subject.subdomain = subdomain
        subject.valid?
      end

      shared_examples_for 'validation errors on subdomain' do
        it { should_not be_valid }

        it 'should have errors on :subdomain' do
          subdomain_errors = subject.errors[:subdomain]
          subdomain_errors.should_not be_empty
        end
      end

      %w(www admin launchpad jenkins demo).each do |reserved_subdomain|
        context "for reserved subdomain: '#{reserved_subdomain}'" do
          let(:subdomain) { reserved_subdomain }
          include_examples 'validation errors on subdomain'
          it "it should set 'is reserved' error on :subdomain field" do
            subject.errors[:subdomain].should include('is reserved')
          end
        end
      end

      context 'for characters other that letters, numbers and dash' do
        ['!@#$', '.'].each do |invalid_subdomain|
          context "for subdomain: '#{invalid_subdomain}'" do
            let(:subdomain) { invalid_subdomain }
            include_examples 'validation errors on subdomain'
          end
        end
      end

      context "when domain starts with: '-'" do
        let(:subdomain) { '-starts-with-illegal-character' }
        include_examples 'validation errors on subdomain'
      end

      context "when domain ends with: '-'" do
        let(:subdomain) { 'ends-with-illegal-character-' }
        include_examples 'validation errors on subdomain'
      end
    end
  end

  describe 'delegators' do
    it { should delegate(:summary).to(:financial_transactions).with_prefix }
    it { should delegate(:by_params).to(:financial_transactions).with_prefix }
    it { should delegate(:summary).to(:timesheet_transactions).with_prefix }
    it { should delegate(:by_params).to(:timesheet_transactions).with_prefix }
  end

  describe 'associations' do
    it { belong_to(:industry) }
    it { belong_to(:country) }

    it { have_many(:accounts) }
    it { have_many(:scenarios) }

    it { have_many(:customers) }
    it { have_many(:channels) }
    it { have_many(:segments) }
    it { have_many(:stages) }

    it { have_many(:employees) }
    it { have_many(:employee_types) }

    it { have_many(:products) }
    it { have_many(:revenue_streams) }

    it { have_many(:vendors) }
    it { have_many(:categories) }

    it { have_many(:conversion_summary) }
    it { have_many(:documents) }
    it { have_many(:financial_transactions) }
    it { have_many(:timesheet_transactions) }

    it { have_many(:churn_forecast) }
    it { have_many(:conversion_forecast) }
    it { have_many(:unit_cac_forecast) }
    it { have_many(:unit_rev_forecast) }

    it { have_many(:expense_forecasts) }
    it { have_many(:staffing_forecasts) }
  end

  describe 'callbacks' do
    describe '.after_save' do
      let(:company) { create(:company, :without_scenarios) }
      subject { company }

      it 'generates a base scenario' do
        subject.scenarios.should have(1).item
      end

      describe 'generated scenario' do
        subject { company.scenarios.first }
        its(:name) { should == 'Base Plan' }
      end

      it 'generates a first revenue stream' do
        subject.scenarios.should have(1).item
      end

      describe 'generated revenue stream' do
        subject { company.revenue_streams.first }
        its(:name) { should == 'General' }
      end

      it 'generates a first channel' do
        subject.scenarios.should have(1).item
      end

      describe 'generated channel' do
        subject { company.channels.first }
        its(:name) { should == 'General' }
      end

      it 'generates a first segment' do
        subject.scenarios.should have(1).item
      end

      describe 'generated segment' do
        subject { company.segments.first }
        its(:name) { should == 'General' }
      end

      it 'generates a first stage' do
        subject.scenarios.should have(1).item
      end

      describe 'generated stage' do
        subject { company.stages.first }
        its(:name) { should == 'Customer' }
      end

      it 'generates a first employee type' do
        subject.scenarios.should have(1).item
      end

      describe 'generated employee type' do
        subject { company.employee_types.first }
        its(:name) { should == 'General' }
      end

      it 'generates a first category' do
        subject.scenarios.should have(1).item
      end

      describe 'generated category' do
        subject { company.categories.first }
        its(:name) { should == 'General' }
      end

    end
  end

  describe '#to_json' do
    it { should respond_to(:to_json) }

    describe 'result' do
      subject { company.to_json }

      it { should have_json_path('id') }
      it { should have_json_path('_type') }
      it { should have_json_path('name') }
      it { should have_json_path('subdomain') }
      it { should have_json_path('url') }

      it { should have_json_path('logo_file_name') }
      it { should have_json_path('logo_url') }

      it { should have_json_path('address_1') }
      it { should have_json_path('address_2') }
      it { should have_json_path('postal_code') }
      it { should have_json_path('country_id') }

      describe '#is_connected_to_intuit field' do
        it { should have_json_value(false).at_path('is_connected_to_intuit') }

        context 'when it is connected to intuit' do
          before { company.stub(connected_to_intuit?: true) }
          it { should have_json_value(true).at_path('is_connected_to_intuit') }
        end
      end

      describe '#is_intuit_token_expired field' do
        it { should have_json_value(nil).at_path('is_intuit_token_expired') }

        context 'when intuit token is not expired' do
          before { company.stub(intuit_token_expired?: false) }
          it { should have_json_value(false).at_path('is_intuit_token_expired') }
        end

        context 'when intuit token is expired' do
          before { company.stub(intuit_token_expired?: true) }
          it { should have_json_value(true).at_path('is_intuit_token_expired') }
        end
      end

      describe '#is_advised' do
        it { should have_json_value(false).at_path('is_advised') }

        context 'when the company is not advised' do
          before { company.stub(advised?: false) }
          it { should have_json_value(false).at_path('is_advised') }
        end

        context 'when intuit token is expired' do
          before { company.stub(advised?: true) }
          it { should have_json_value(true).at_path('is_advised') }
        end
      end

      describe 'trial period fields' do
        it { should have_json_path('is_in_trial') }
        it { should have_json_path('is_trial_expired') }
        it { should have_json_path('trial_days_left') }
        it { should have_json_value(30).at_path('trial_days_left') }

        describe 'when billing is overridden' do
          before { company.stub(billing_overridden?: true) }

          it { should_not have_json_path('is_in_trial') }
          it { should_not have_json_path('is_trial_expired') }
          it { should_not have_json_path('trial_days_left') }
        end
      end
    end
  end

  describe '#subscriber' do
    it { should respond_to(:subscriber) }

    describe 'result' do
      subject { company.subscriber }
      it { should be_an_instance_of(RecurlySubscriber) }
    end
  end

  describe '#suggested_subdomain' do
    it { should respond_to(:suggested_subdomain) }

    describe 'result' do
      subject { company.suggested_subdomain }

      context 'for name with capital letters' do
        before { company.name = 'TEST Name' }

        it 'should include only downcases characters' do
          should_not match(/[A-Z]/)
          should == 'test-name'
        end
      end

      context 'for name with illegal characters' do
        before { company.name = 'TEST with 123~!@#$%^&*()_+{}":|?><"foo' }

        it 'should include only valid characters' do
          should == 'test-with-123foo'
        end
      end

      context 'for name with white characters' do
        before { company.name = "foo\nbar     biz fiz" }

        it 'should replace white characters with single dash' do
          should == 'foo-bar-biz-fiz'
        end
      end
    end
  end

end
