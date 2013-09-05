require 'spec_helper'

describe Industry do
  it_behaves_like 'an api document with name'
  
  describe 'fields' do
    it { should have_field(:suggested_streams).of_type(Array) }
    it { should have_field(:suggested_channels).of_type(Array) }
    it { should have_field(:suggested_segments).of_type(Array) }
    it { should have_field(:suggested_stages).of_type(Array) }
  end
  
  describe 'associations' do
    it { should have_many(:companies) }
  end
end
