require 'spec_helper'

describe Channel do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'

  describe 'fields' do
    it { should have_field(:commission).of_type(Float) }
  end

  describe 'associations' do
    it { have_many(:customers) }
    it { have_many(:channel_segment_mix) }
  end

  describe "#check_channel_segment_mix" do
    let(:company) { create(:company) }
    subject(:channel) { create(:channel, company: company) }

    it 'should have a complete channel/segment mix' do
      channel.channel_segment_mix.sum(:distribution).should eq(1)
    end
  end

end
