require 'spec_helper'

describe Spreadsheet do
  before :all do
    Spreadsheet.configure = {
        path: File.expand_path('../../fixtures/spreadsheet/meta_data.yml', __FILE__),
        spreadsheet_key: '0Aq6I3AMo8MZjdFN4ZHpacWxJODRjTF9vQ3FfUTVPSUE',
    }
  end

  it 'should load meta data from yaml file' do
    Spreadsheet.meta_config.should_not be_nil
  end

  it 'should load table config from meta_config' do
    Spreadsheet.meta_config.should have_key 'scenarios'
  end

  describe 'with cache_path set' do
    let(:file_worksheet) { Spreadsheet::FileWorksheet.new  File.expand_path('../../fixtures/spreadsheet/worksheet1.yml', __FILE__) }
    before { Spreadsheet.stub(:cache).and_return({}) }

    it 'should cache worksheets' do
      Spreadsheet.should_receive(:worksheets).and_return file_worksheet
      Spreadsheet.tables 'scenarios'
    end
  end

  describe '#tables' do
    let(:static_rows) { YAML.load_file File.expand_path '../../fixtures/spreadsheet/worksheet1.yml', __FILE__ }
    let(:cube_rows) { YAML.load_file File.expand_path '../../fixtures/spreadsheet/worksheet2.yml', __FILE__ }
    let(:worksheet) { double 'Worksheet' }
    let(:spreadsheet) { double 'Spreadsheet' }

    before do
      spreadsheet.stub(:worksheets).and_return [worksheet, worksheet]
      Spreadsheet.stub(:spreadsheet).and_return spreadsheet
    end

    context 'static table' do
      before do
        worksheet.stub(:rows).and_return static_rows
        worksheet.stub(:cell_name_to_row_col).and_return [2,4]
      end

      it 'should return static table hash data' do
        table = Spreadsheet.tables 'scenarios'
        table.should_not be_nil
        table.should be_is_a Hash
        table[:scenarios].should have(2).items
        table[:scenarios][0][:id].should eq 1
        table[:scenarios][0][:name].should == 'Base'
      end
    end

    context 'cube table' do
      before do
        worksheet.stub(:rows).and_return cube_rows
        worksheet.stub(:cell_name_to_row_col) do |value|
          if value == 'F1'
            [1,6]
          elsif value == 'G2'
            [2,7]
          end
        end
      end

      it 'should return cube table hash data' do
        table = Spreadsheet.tables 'topline'
        table.should_not be_nil
        table.should be_is_a Hash
        table[:topline].should have(180).items
        table[:topline][0][:channel_id].should eq 1
        table[:topline][0][:month_ids].should eq 1
        table[:topline][0][:value].should eq 4
      end
    end

    it 'should return list of table' do
      Spreadsheet.stub(:load_table) { |name, config| { name => nil } }
      table = Spreadsheet.tables 'scenarios, topline'
      table.should have_key 'scenarios'
      table.should have_key 'topline'
    end

    it 'should return all tables from meta file' do
      Spreadsheet.stub(:load_table) { |name, config| { name => nil } }
      table = Spreadsheet.tables
      table.keys.should have(2).items
    end
  end
end
