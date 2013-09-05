require 'spec_helper'

describe Intuit::AvailableListXmlParser, :intuit do
  let(:xml) { File.read(Rails.root.join('spec', 'fixtures', 'intuit_available_list.xml')) }

  let(:parser) { described_class.new(xml) }
  subject { parser }

  it { should respond_to(:xml) }
  its(:xml) { should == xml }

  it { should respond_to(:doc) }
  its(:doc) { should be_an_instance_of(Nokogiri::XML::Document) }

  describe '#find_by_realm' do
    it { should respond_to(:find_by_realm) }

    describe 'result' do
      subject { parser.find_by_realm(realm) }

      context 'when company was found' do
        let(:realm) { 502945835 }

        it { should_not be_nil }
        its([:realm]) { should == realm }
        its([:name]) { should == 'Active Cell' }
        its([:sign_up_at]) { should == Time.parse('2012-07-24T09:31:06Z') }
      end

      context 'when company was not found' do
        let(:realm) { 666 }

        it { should be_nil }
      end
    end
  end
end
