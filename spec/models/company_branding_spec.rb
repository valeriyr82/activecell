require 'spec_helper'

describe CompanyBranding, :branding do
  let!(:company) { create(:company) }
  let(:branding) { company.branding }
  subject { branding }

  describe 'fields' do
    it { should have_field(:logo_file_name).of_type(String) }
  end

  describe 'associations' do
    it { should be_embedded_in(:company).as_inverse_of(:branding) }
    it { should embed_one(:color_scheme) }
  end

  describe 'validations' do
    before do
      # stub out communication with s3
      Paperclip::Attachment.any_instance.stub(:clear).and_return(true)
    end

    it { should validate_attachment_content_type(:logo).
                    allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg').
                    rejecting('text/plain', 'text/xml') }
    it { should validate_attachment_size(:logo).less_than(5.megabytes) }
  end

  describe '#logo_url' do
    before { branding.logo = File.open("#{Rails.root}/spec/fixtures/sample_logo.png") }

    it "generates logo url for resized style" do
      branding.logo_url.should eq(branding.logo.url(:resized))
    end
  end

end
