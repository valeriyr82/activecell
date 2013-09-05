require 'spec_helper'

describe ColorScheme, :branding do

  describe 'fields' do
    it { should be_timestamped_document }

    it { should have_field(:primary_light).of_type(String) }
    it { should have_field(:primary_dark).of_type(String) }
    it { should have_field(:secondary_light).of_type(String) }
    it { should have_field(:secondary_dark).of_type(String) }
    it { should have_field(:menu_other).of_type(String) }
    it { should have_field(:white).of_type(String) }
    it { should have_field(:light_grey).of_type(String) }
    it { should have_field(:grey).of_type(String) }
    it { should have_field(:dark_grey).of_type(String) }
    it { should have_field(:black).of_type(String) }
  end

  describe 'associations' do
    it { should be_embedded_in(:company_branding) }
  end

end
